//
//  SKIAdBannerView.m
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import "SKIAdBannerView.h"

#import "SKIConstants.h"

#import "SKIAdRequest_Private.h"
#import "SKIAdRequestResponse.h"

#import "SKIAdEventTracker.h"

#import "SKIAdRequestError_Private.h"
#import "SKIAdReportViewController.h"

@interface SKIAdBannerView () <SKIAdRequestDelegate, UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UILabel *reportLabelView;

@property (copy, nonatomic) SKIAdRequest *request;
@property (strong, nonatomic) SKIAdRequestResponse *requestResponse;

@end

@implementation SKIAdBannerView

+ (instancetype)bannerView {
	return [[self alloc] initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.clipsToBounds = YES;
		self.adSize = kSKIAdSizeBanner;
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		self.clipsToBounds = YES;
		self.adSize = kSKIAdSizeBanner;
	}
	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	[self updateFrames];
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	
	[self updateFrames];
}

- (void)setAdSize:(SKIAdSize)adSize {
	_adSize = adSize;
	
	[self updateFrames];
}

- (void)updateFrames {
	if (_webView) {
		CGPoint point = (CGPoint){(self.bounds.size.width - self.adSize.width) / 2.f, (self.bounds.size.height - self.adSize.height) / 2.f};
		_webView.frame = (CGRect){point, self.adSize};
	}
	
	if (_reportLabelView) {
		CGRect frame = _reportLabelView.frame;
		frame.origin = CGPointZero;
		_reportLabelView.frame = frame;
	}
}

- (void)loadRequest:(SKIAdRequest *)request {
	if (_request) {
		[_request cancel];
	}
	
	self.request = request;
	self.request.adUnitID = self.adUnitID;
	self.request.adType = kSKIAdTypeBannerImage;
	self.request.adSize = self.adSize;
	self.request.delegate = self;
	
	[self.request load];
}

- (void)skiAdRequest:(SKIAdRequest *)request didReceiveResponse:(SKIAdRequestResponse *)response {
	if (response.error) {
		if ([self.delegate respondsToSelector:@selector(skiAdView:didFailToReceiveAdWithError:)]) {
			[self.delegate skiAdView:self didFailToReceiveAdWithError:response.error];
		}
		
		return;
	}
	
	if (response.htmlSnippet.length == 0) {
		return;
	}
	
	self.requestResponse = response;
	
	self.webView.delegate = self;
	[self.webView loadHTMLString:response.htmlSnippet baseURL:nil];
}

- (void)skiAdRequest:(SKIAdRequest *)request didFailWithError:(SKIAdRequestError *)error {
	if ([self.delegate respondsToSelector:@selector(skiAdView:didFailToReceiveAdWithError:)]) {
		[self.delegate skiAdView:self didFailToReceiveAdWithError:error];
	}
}

- (UIWebView *)webView {
	if (!_webView) {
		CGPoint point = (CGPoint){(self.bounds.size.width - self.adSize.width) / 2.f, (self.bounds.size.height - self.adSize.height) / 2.f};
		self.webView = [[UIWebView alloc] initWithFrame:(CGRect){point, self.adSize}];
		_webView.scrollView.bounces = NO;
		_webView.scrollView.scrollEnabled = NO;
		_webView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | //UIViewAutoresizingFlexibleWidth |
		                                UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin |
		//                                UIViewAutoresizingFlexibleHeight |
										UIViewAutoresizingFlexibleBottomMargin;
		_webView.hidden = YES;
		[self addSubview:_webView];
	}

	return _webView;
}

- (UILabel *)reportLabelView {
	if (_reportLabelView != nil) {
		return _reportLabelView;
	}
	
	_reportLabelView = [[UILabel alloc] initWithFrame:(CGRect){{0.f, 0.f}, CGSizeZero}];
	_reportLabelView.textColor = [UIColor colorWithRed:0.27f green:0.5f blue:0.7f alpha:1.f];
	_reportLabelView.font = [UIFont monospacedDigitSystemFontOfSize:17 weight:UIFontWeightRegular];
	_reportLabelView.text = @"Report";
	_reportLabelView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:0.7f];
	_reportLabelView.userInteractionEnabled = YES;
	_reportLabelView.font = [UIFont systemFontOfSize:13.f];
	[_reportLabelView sizeToFit];
	_reportLabelView.hidden = YES;
	
	UITapGestureRecognizer *reportTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
	[_reportLabelView addGestureRecognizer:reportTapGesture];
	
	[self addSubview:self.reportLabelView];
	
	return _reportLabelView;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture {
	if (gesture.view == self.reportLabelView) {
		__weak typeof(self) wSelf = self;
		[SKIAdReportViewController showFromViewController:self.rootViewController callback:^(BOOL canceled, NSString * _Nullable email, NSString * _Nullable message) {
			if (canceled) {
				return;
			}
			
			[[SKIAdEventTracker defaultTracker] sendReportWithDeviceData:wSelf.requestResponse.deviceInfo adId:wSelf.requestResponse.rawResponse[@"AdId"] adUnitId:wSelf.adUnitID email:email message:message];
			
			SKIAsyncOnMain(^{
				if ([wSelf.delegate respondsToSelector:@selector(skiAdView:didFailToReceiveAdWithError:)]) {
					SKIAdRequestError *requestError = [SKIAdRequestError errorNoFillWithUserInfo:nil];
					[wSelf.delegate skiAdView:wSelf didFailToReceiveAdWithError:requestError];
				}
			});
		}];
	}
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		if (webView.isLoading) {
			return NO;
		}
		
		NSURL *url = request.URL;
		if ([[UIApplication sharedApplication] canOpenURL:url]) {
			
			if ([self.delegate respondsToSelector:@selector(skiAdViewWillLeaveApplication:)]) {
				[self.delegate skiAdViewWillLeaveApplication:self];
			}
			
			[[UIApplication sharedApplication] openURL:url];
			
			return NO;
		}
		
		return NO;
	}
	
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[webView stringByEvaluatingJavaScriptFromString:@"document.body.style.margin='0';document.body.style.padding='0';"];
	webView.hidden = NO;
	self.reportLabelView.hidden = NO;
	
	if ([self.delegate respondsToSelector:@selector(skiAdViewDidReceiveAd:)]) {
		[self.delegate skiAdViewDidReceiveAd:self];
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	webView.hidden = YES;
	self.reportLabelView.hidden = YES;
	
	if ([self.delegate respondsToSelector:@selector(skiAdView:didFailToReceiveAdWithError:)]) {
		SKIAdRequestError *requestError = [SKIAdRequestError errorInternalErrorWithUserInfo:@{NSUnderlyingErrorKey : error}];
		[self.delegate skiAdView:self didFailToReceiveAdWithError:requestError];
	}
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

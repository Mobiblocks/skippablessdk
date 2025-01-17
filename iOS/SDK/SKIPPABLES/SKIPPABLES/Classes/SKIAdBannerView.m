//
//  SKIAdBannerView.m
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import <WebKit/WebKit.h>

#import "SKIAdBannerView.h"

#import "SKIConstants.h"

#import "SKIAdRequest_Private.h"
#import "SKIAdRequestResponse.h"

#import "SKIAdEventTracker.h"

#import "SKIAdRequestError_Private.h"
#import "SKIAdReportViewController.h"

@interface SKIAdBannerView () <SKIAdRequestDelegate, WKNavigationDelegate>

@property (strong, nonatomic) WKWebView *webView;
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

- (void)setCenter:(CGPoint)center {
	[super setCenter:center];

	[self updateFrames];
}

- (void)setBounds:(CGRect)bounds {
	[super setBounds:bounds];

	[self updateFrames];
}

- (void)setAdSize:(SKIAdSize)adSize {
	_adSize = adSize;
	
	[self updateFrames];
}

- (void)setScaleToFillWidth:(BOOL)scaleToFillWidth {
	_scaleToFillWidth = scaleToFillWidth;
	[self updateFrames];
}

- (void)updateFrames {
	if (_webView) {
		CGSize size = self.adSize;
		if (self.scaleToFillWidth) {
			size.width = MAX(size.width, self.bounds.size.width);
		}

		CGPoint point = (CGPoint){(self.bounds.size.width - size.width) / 2.f, (self.bounds.size.height - size.height) / 2.f};
		_webView.frame = (CGRect){point, size};
	}
	
	if (_webView && _reportLabelView) {
		CGRect frame = _reportLabelView.frame;
		frame.origin = _webView.frame.origin;
		_reportLabelView.frame = frame;
	}
}

- (void)loadRequest:(SKIAdRequest *)request {
	if (!request.test && (self.adUnitID == nil || self.adUnitID.length == 0)) {
		if ([self.delegate respondsToSelector:@selector(skiAdView:didFailToReceiveAdWithError:)]) {
			id<SKIAdBannerViewDelegate> delegate = self.delegate;
			SKIAsyncOnMain(^{
				SKIAdRequestError *error = [SKIAdRequestError errorInvalidArgumentWithUserInfo:@{
																								 NSLocalizedDescriptionKey: @"Ad unit id is empty"
																								 }];
				[delegate skiAdView:self didFailToReceiveAdWithError:error];
			});
		}
		
		return;
	}
	
	if (_request) {
		_request.delegate = nil;
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
	
	self.webView.navigationDelegate = self;
	[self.webView loadHTMLString:response.htmlSnippet baseURL:nil];
}

- (WKWebView *)webView {
	if (!_webView) {
		CGPoint point = (CGPoint){(self.bounds.size.width - self.adSize.width) / 2.f, (self.bounds.size.height - self.adSize.height) / 2.f};
		self.webView = [[WKWebView alloc] initWithFrame:(CGRect){point, self.adSize}];
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
	
	CGPoint origin = _webView ? _webView.frame.origin : CGPointZero;
	CGSize size = (CGSize){12, 12};
	_reportLabelView = [[UILabel alloc] initWithFrame:(CGRect){origin, size}];
	_reportLabelView.textColor = [UIColor colorWithRed:0.27f green:0.5f blue:0.7f alpha:1.f];
	_reportLabelView.font = [UIFont monospacedDigitSystemFontOfSize:17 weight:UIFontWeightRegular];
	_reportLabelView.text = @"i";
	_reportLabelView.textAlignment = NSTextAlignmentCenter;
	_reportLabelView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:0.7f];
	_reportLabelView.userInteractionEnabled = YES;
	_reportLabelView.font = [UIFont systemFontOfSize:11.f];
//	[_reportLabelView sizeToFit];
	_reportLabelView.hidden = YES;
	
	UITapGestureRecognizer *reportTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
	[_reportLabelView addGestureRecognizer:reportTapGesture];
	
	[self addSubview:self.reportLabelView];
	
	return _reportLabelView;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture {
	if (gesture.view == self.reportLabelView) {
		__weak typeof(self) wSelf = self;
		WKWebView *webView = _webView;
		UILabel *reportLabelView = _reportLabelView;
		[SKIAdReportViewController showFromViewController:self.rootViewController callback:^(BOOL canceled, NSString * _Nullable email, NSString * _Nullable message) {
			if (canceled) {
				return;
			}
			
			[[SKIAdEventTracker defaultTracker] sendReportWithDeviceData:wSelf.requestResponse.deviceInfo adId:wSelf.requestResponse.rawResponse[@"AdId"] adUnitId:wSelf.adUnitID email:email message:message];
			
			SKIAsyncOnMain(^{
				webView.hidden = YES;
				reportLabelView.hidden = YES;
				if ([wSelf.delegate respondsToSelector:@selector(skiAdView:didFailToReceiveAdWithError:)]) {
					SKIAdRequestError *requestError = [SKIAdRequestError errorNoFillWithUserInfo:@{
																								   NSLocalizedDescriptionKey : @"No ad available a this time."
																								   }];
					[wSelf.delegate skiAdView:wSelf didFailToReceiveAdWithError:requestError];
				}
			});
		}];
	}
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
	if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
		if (webView.isLoading) {
			decisionHandler(WKNavigationActionPolicyCancel);
		}

		NSURL *url = navigationAction.request.URL;
		if ([[UIApplication sharedApplication] canOpenURL:url]) {

			if ([self.delegate respondsToSelector:@selector(skiAdViewWillLeaveApplication:)]) {
				[self.delegate skiAdViewWillLeaveApplication:self];
			}

			[[UIApplication sharedApplication] openURL:url];

			decisionHandler(WKNavigationActionPolicyCancel);
		} else {
			decisionHandler(WKNavigationActionPolicyCancel);
		}
	} else {
		decisionHandler(WKNavigationActionPolicyAllow);
	}
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
	[webView evaluateJavaScript:@"document.body.style.margin='0';document.body.style.padding='0';" completionHandler:nil];

	[self updateFrames];

	webView.hidden = NO;
	self.reportLabelView.hidden = NO;

	if ([self.delegate respondsToSelector:@selector(skiAdViewDidReceiveAd:)]) {
		[self.delegate skiAdViewDidReceiveAd:self];
	}
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
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

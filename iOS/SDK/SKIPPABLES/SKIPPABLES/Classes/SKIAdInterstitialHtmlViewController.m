//
//  SKIAdInterstitialHtmlViewController.m
//  SKIPPABLES
//
//  Created by Daniel on 2/18/19.
//  Copyright © 2019 Mobiblocks. All rights reserved.
//

#import "SKIAdInterstitialHtmlViewController.h"

#import <WebKit/WebKit.h>

#import "SKIAdInterstitial.h"
#import "SKIAdInterstitial_Private.h"
#import "SKIAdRequestResponse.h"
#import "SKIAdEventTracker.h"
#import "SKIAdReportViewController.h"

@interface SKIAdInterstitialHtmlViewController () <WKNavigationDelegate>

@property (assign, nonatomic) NSInteger skipSeconds;
@property (strong, nonatomic) NSTimer *skipTimer;

@property (strong, nonatomic) UIView *skipView;
@property (strong, nonatomic) UILabel *skipLabelView;
@property (strong, nonatomic) UILabel *reportLabelView;

@property (strong, nonatomic) WKWebView *webView;

@end

@implementation SKIAdInterstitialHtmlViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self) {
		self.skipSeconds = 5;
	}

	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.view.backgroundColor = UIColor.blackColor;

	self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:[[WKWebViewConfiguration alloc] init]];
	self.webView.navigationDelegate = self;
	[self.webView loadHTMLString:self.ad.response.htmlSnippet baseURL:self.ad.response.htmlSnippetBaseUrl];

	[self.view addSubview:self.webView];

	self.skipView = [[UIView alloc] initWithFrame:(CGRect){{0.f, 0.f}, {100.f, 24.f}}];
	self.skipView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:0.7f];
	self.skipView.userInteractionEnabled = NO;

	self.skipLabelView = [[UILabel alloc] initWithFrame:(CGRect){{8.f, 0.f}, {84.f, 24.f}}];
	self.skipLabelView.textColor = [UIColor colorWithWhite:0.6 alpha:1.f];
	self.skipLabelView.font = [UIFont monospacedDigitSystemFontOfSize:17 weight:UIFontWeightRegular];

	UITapGestureRecognizer *skipTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
	[self.skipView addGestureRecognizer:skipTapGesture];

	[self.skipView addSubview:self.skipLabelView];
	[self.view addSubview:self.skipView];

	self.reportLabelView = [[UILabel alloc] initWithFrame:(CGRect){{8.f, 0.f}, CGSizeZero}];
	self.reportLabelView.textColor = [UIColor colorWithRed:0.27f green:0.5f blue:0.7f alpha:1.f];
	self.reportLabelView.font = [UIFont monospacedDigitSystemFontOfSize:17 weight:UIFontWeightRegular];
	self.reportLabelView.text = @"Report";
	self.reportLabelView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:0.7f];
	self.reportLabelView.userInteractionEnabled = YES;
	self.reportLabelView.font = [UIFont systemFontOfSize:13.f];
	[self.reportLabelView sizeToFit];
	self.reportLabelView.hidden = YES;

	UITapGestureRecognizer *reportTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
	[self.reportLabelView addGestureRecognizer:reportTapGesture];

	[self.view addSubview:self.reportLabelView];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self updateSkip];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
		log.idenitifier = @"adInterstitialHtmlView.didAppear";
	}];

	[self resumeTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
		log.idenitifier = @"adInterstitialHtmlView.willDisappear";
	}];

	[self suspenTimer];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];

	CGRect frame = self.view.bounds;

	if (@available(iOS 11.0, *)) {
		frame = self.view.safeAreaLayoutGuide.layoutFrame;
	}

	CGRect wFrame = frame;
	wFrame.size.height -= 24;
	self.webView.frame = wFrame;

	CGRect sFrame = CGRectZero;
	sFrame.origin.x = frame.origin.x + frame.size.width - 100;
	sFrame.origin.y = frame.origin.y + frame.size.height - 24;
	sFrame.size.width = 100;
	sFrame.size.height = 24;

	self.skipView.frame = sFrame;

	CGRect rFrame = self.reportLabelView.frame;
	rFrame.origin.x = frame.origin.x;
	rFrame.origin.y = frame.origin.y + frame.size.height - 24;

	self.reportLabelView.frame = rFrame;
}

- (void)applicationDidBecomeActive:(BOOL)previouslyVisible {
	[super applicationDidBecomeActive:previouslyVisible];

	[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
		log.idenitifier = @"adInterstitialHtmlView.applicationDidBecomeActive";
	}];

	[self resumeTimer];
}

- (void)applicationWillResignActive:(BOOL)previouslyVisible {
	[super applicationWillResignActive:previouslyVisible];

	[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
		log.idenitifier = @"adInterstitialHtmlView.applicationWillResignActive";
	}];

	[self suspenTimer];
}

- (void)resumeTimer {
	if (self.skipSeconds <= 0 || self.skipTimer.isValid) {
		return;
	}

	self.skipTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick) userInfo:self repeats:YES];
}

- (void)suspenTimer {
	[self cancelTimer];
}

- (void)cancelTimer {
	if (!self.skipTimer.isValid) {
		return;
	}

	[self.skipTimer invalidate];
	self.skipTimer = nil;
}

- (void)timerTick {
	self.skipSeconds -= 1;
	if (self.skipSeconds <= 0) {
		[self cancelTimer];
	}

	[self updateSkip];
}

- (void)updateSkip {
	if (self.skipSeconds > 0) {
		NSTimeInterval remaining = self.skipSeconds;
		if (remaining < 60.) {
			NSString *durationString = [NSString stringWithFormat:@"Skip in %d", (int)remaining];
			self.skipLabelView.text = durationString;
		} else {
			NSString *durationString = [NSString stringWithFormat:@"Skip in %d:%02d", (int)(remaining / 60) % 60, (int)remaining % 60];
			self.skipLabelView.text = durationString;
		}
		self.skipView.userInteractionEnabled = NO;
	} else {
		self.skipLabelView.textColor = UIColor.whiteColor;
		self.skipLabelView.text = @"Skip";
		self.skipView.userInteractionEnabled = YES;

		self.reportLabelView.hidden = NO;
	}
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture {
	if (gesture.view == self.skipView) {
		[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
			log.idenitifier = @"adInterstitialHtmlView.userSkip";
		}];
		//		[self sendSkipEvents];
		[self closeInterstitial];
	} else 	if (gesture.view == self.reportLabelView) {
		[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
			log.idenitifier = @"adInterstitialVideoView.userReport";
		}];
		__weak typeof(self) wSelf = self;
		[SKIAdReportViewController showFromViewController:wSelf callback:^(BOOL canceled, NSString * _Nullable email, NSString * _Nullable message) {
			if (canceled) {
				return;
			}

			[[SKIAdEventTracker defaultTracker] sendReportWithDeviceData:wSelf.ad.response.deviceInfo
																	adId:wSelf.ad.response.rawResponse[@"AdId"] ?: @""
																adUnitId:wSelf.ad.adUnitID
																   email:email
																 message:message];

			SKIAsyncOnMain(^{
				[wSelf closeInterstitial];
			});
		}];
	}
}

- (void)closeInterstitial {
	[self cancelTimer];

	if ([self.ad.delegate respondsToSelector:@selector(skiInterstitialWillDismiss:)]) {
		[self.ad.delegate skiInterstitialWillDismiss:self.ad];
	}
	[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
		log.idenitifier = @"adInterstitialHtmlView.close";
		log.desc = @"Report to user.";
		log.info = @{
					 @"method": @"skiInterstitialWillDismiss:",
					 @"delegateIsSet": @(self.ad.delegate != nil)
					 };
	}];

	__weak typeof(self) wSelf = self;
	[self dismissViewControllerAnimated:YES
							 completion:^{
								 if ([wSelf.ad.delegate respondsToSelector:@selector(skiInterstitialDidDismiss:)]) {
									 [wSelf.ad.delegate skiInterstitialDidDismiss:self.ad];
								 }
							 }];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
	if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
		decisionHandler(WKNavigationActionPolicyCancel);
		NSURL *url = navigationAction.request.URL;
		if (url) {
			[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
				log.idenitifier = @"adInterstitialHtmlView.userClick";
				log.info = @{
							 @"url": url.absoluteString
							 };
			}];
			if (@available(iOS 10.0, *)) {
				[[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
					if (success) {
						if ([self.ad.delegate respondsToSelector:@selector(skiInterstitialWillLeaveApplication:)]) {
							[self.ad.delegate skiInterstitialWillLeaveApplication:self.ad];
						}
						[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
							log.idenitifier = @"adInterstitialHtmlView.openClick";
							log.desc = @"Report to user.";
							log.info = @{
										 @"url": url.absoluteString ?: [NSNull null],
										 @"method": @"skiInterstitialWillLeaveApplication:",
										 @"delegateIsSet": @(self.ad.delegate != nil)
										 };
						}];
						[self closeInterstitial];
					}
				}];
			} else {
				if ([[UIApplication sharedApplication] openURL:url]) {
					if ([self.ad.delegate respondsToSelector:@selector(skiInterstitialWillLeaveApplication:)]) {
						[self.ad.delegate skiInterstitialWillLeaveApplication:self.ad];
					}
					[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
						log.idenitifier = @"adInterstitialHtmlView.openClick";
						log.desc = @"Report to user.";
						log.info = @{
									 @"url": url.absoluteString ?: [NSNull null],
									 @"method": @"skiInterstitialWillLeaveApplication:",
									 @"delegateIsSet": @(self.ad.delegate != nil)
									 };
					}];
					[self closeInterstitial];
				}
			}
		}
	} else {
		decisionHandler(WKNavigationActionPolicyAllow);
	}
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
	NSLog(@"didFinishNavigation");

	[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
		log.idenitifier = @"adInterstitialHtmlView.didFinishNavigation";
	}];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
	NSLog(@"didFailNavigation");

	[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
		log.idenitifier = @"adInterstitialHtmlView.didFailNavigation";
		log.error = error;
	}];
}

- (BOOL)prefersStatusBarHidden {
	return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
	return UIStatusBarAnimationFade;
}

- (void)dealloc {
	[self cancelTimer];
}

@end

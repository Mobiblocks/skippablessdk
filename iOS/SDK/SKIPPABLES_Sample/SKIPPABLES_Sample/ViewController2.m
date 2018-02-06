//
//  ViewController2.m
//  SKIPPABLES_Sample
//
//  Created by Daniel on 1/11/18.
//  Copyright © 2018 Mobiblocks. All rights reserved.
//

#import "ViewController2.h"

#import <SKIPPABLES/SKIPPABLES.h>

@interface ViewController2 () <SKIAdBannerViewDelegate>

@property(strong, nonatomic) SKIAdBannerView *bannerView;

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.bannerView = [SKIAdBannerView bannerView];
	self.bannerView.adSize = kSKIAdSizeBanner;
	self.bannerView.translatesAutoresizingMaskIntoConstraints = NO;
	
	self.bannerView.adUnitID = @"your_ad_unit_id";
	self.bannerView.delegate = self;
	
	SKIAdRequest *adRequest = [SKIAdRequest request];
#ifdef DEBUG
	adRequest.test = YES;
#endif
	[self.bannerView loadRequest:adRequest];
	
	[self.view addSubview:self.bannerView];
	[self.view addConstraints:@[
		[NSLayoutConstraint constraintWithItem:self.bannerView
		                             attribute:NSLayoutAttributeHeight
		                             relatedBy:NSLayoutRelationEqual
		                                toItem:nil
		                             attribute:NSLayoutAttributeNotAnAttribute
		                            multiplier:1.0
		                              constant:50.f],
		[NSLayoutConstraint constraintWithItem:self.bannerView
		                             attribute:NSLayoutAttributeBottom
		                             relatedBy:NSLayoutRelationEqual
		                                toItem:self.bottomLayoutGuide
		                             attribute:NSLayoutAttributeTop
		                            multiplier:1
		                              constant:0],
		[NSLayoutConstraint constraintWithItem:self.bannerView
		                             attribute:NSLayoutAttributeLeft
		                             relatedBy:NSLayoutRelationEqual
		                                toItem:self.view
		                             attribute:NSLayoutAttributeLeft
		                            multiplier:1
		                              constant:0],
		[NSLayoutConstraint constraintWithItem:self.bannerView
		                             attribute:NSLayoutAttributeRight
		                             relatedBy:NSLayoutRelationEqual
		                                toItem:self.view
		                             attribute:NSLayoutAttributeRight
		                            multiplier:1
		                              constant:0]
	]];
}

/// Called when an ad request loaded an ad.
- (void)skiAdViewDidReceiveAd:(SKIAdBannerView *)view {
	NSLog(@"skiAdViewDidReceiveAd");
}

/// Called when an ad request failed.
- (void)skiAdView:(SKIAdBannerView *)view didFailToReceiveAdWithError:(SKIAdRequestError *)error {
	NSLog(@"skiAdView:didFailToReceiveAdWithError: %@", error);
}

/// Called just before presenting the user a full screen view.
- (void)skiAdViewWillPresentScreen:(SKIAdBannerView *)adView {
	NSLog(@"skiAdViewWillPresentScreen");
}

/// Called just before dismissing a full screen view.
- (void)skiAdViewWillDismissScreen:(SKIAdBannerView *)adView {
	NSLog(@"skiAdViewWillDismissScreen");
}

/// Called just after dismissing a full screen view.
- (void)skiAdViewDidDismissScreen:(SKIAdBannerView *)adView {
	NSLog(@"skiAdViewDidDismissScreen");
}

/// Called just before the application will background or terminate because the user clicked on an
/// ad that will launch another application (such as the App Store).
- (void)skiAdViewWillLeaveApplication:(SKIAdBannerView *)adView {
	NSLog(@"skiAdViewWillLeaveApplication");
}

@end


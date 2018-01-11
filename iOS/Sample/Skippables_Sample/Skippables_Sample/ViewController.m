//
//  ViewController.m
//  Skippables_Sample
//
//  Created by Daniel on 1/3/18.
//  Copyright © 2018 Mobiblocks. All rights reserved.
//

#import "ViewController.h"

#import <SKIPPABLES/SKIPPABLES.h>

#define kAdUnitId @"your_ad_unit_id"

@interface ViewController () <SKIAdBannerViewDelegate, SKIAdInterstitialDelegate>

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet SKIAdBannerView *adView;
@property (strong, nonatomic) SKIAdInterstitial *adInterstitial;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adViewBottomConstraint;

@end

@implementation ViewController

- (void)loadView {
	[super loadView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.adViewBottomConstraint.constant = -self.adView.bounds.size.height;
	self.adView.adUnitID = kAdUnitId;
	self.adView.delegate = self;
	
	[self.button setTitle:@"Load Interstitial" forState:UIControlStateNormal];
	
	[self loadBanner];
}

- (IBAction)buttonTap:(id)sender {
	if (!self.adInterstitial) {
		[self loadInterstitial];
	} else {
		[self.adInterstitial presentFromRootViewController:self];
		
		self.adInterstitial = nil;
		
		[self.button setTitle:@"Load Interstitial" forState:UIControlStateNormal];
	}
}

- (void)loadBanner {
	SKIAdRequest *request = [SKIAdRequest request];
	request.test = YES;
	[self.adView loadRequest:request];
}

- (void)loadInterstitial {
	[self.button setTitle:@"Loading intertitial" forState:UIControlStateNormal];
	self.button.enabled = NO;
	
	self.adInterstitial = [SKIAdInterstitial interstitial];
	self.adInterstitial.adUnitID = kAdUnitId;
	self.adInterstitial.delegate = self;
	
	SKIAdRequest *request = [SKIAdRequest request];
	request.test = YES;
	[self.adInterstitial loadRequest:request];
}

- (void)skiAdViewDidReceiveAd:(SKIAdBannerView *)view {
	self.adViewBottomConstraint.constant = 0;
	[UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
		[self.view layoutIfNeeded];
	}];
}

- (void)skiAdView:(SKIAdBannerView *)view didFailToReceiveAdWithError:(SKIAdRequestError *)error {
	self.adViewBottomConstraint.constant = -self.adView.bounds.size.height;
	[UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
		[self.view layoutIfNeeded];
	}];
	NSLog(@"%@", error);
}

- (void)skiInterstitialDidReceiveAd:(SKIAdInterstitial *)interstitial {
	[self.button setTitle:@"Show Interstitial" forState:UIControlStateNormal];
	self.button.enabled = YES;
}

- (void)skiInterstitial:(SKIAdInterstitial *)interstitial didFailToReceiveAdWithError:(SKIAdRequestError *)error {
	NSLog(@"%@", error);
	[self.button setTitle:@"Load Interstitial" forState:UIControlStateNormal];
	self.button.enabled = YES;
	
	self.adInterstitial = nil;
}

@end

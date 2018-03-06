//
//  ViewController.m
//  Sample
//
//  Copyright © 2018 Mobiblocks. All rights reserved.
//

#import "ViewController.h"

#import <SKIPPABLES/SKIPPABLES.h>

#define kAdUnitId1 @""
#define kAdUnitId2 @""
#define kAdUnitId3 @""

#define kBannerAdUnitId @""

@interface ViewController () <SKIAdBannerViewDelegate, SKIAdInterstitialDelegate>

@property(strong, nonatomic) SKIAdInterstitial *interstitial1;
@property(strong, nonatomic) SKIAdInterstitial *interstitial2;
@property(strong, nonatomic) SKIAdInterstitial *interstitial3;

@property (weak, nonatomic) IBOutlet SKIAdBannerView *bannerView;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.interstitial1 = [self createAndLoadWithAdUnitId:kAdUnitId1];
	self.interstitial2 = [self createAndLoadWithAdUnitId:kAdUnitId2];
	self.interstitial3 = [self createAndLoadWithAdUnitId:kAdUnitId3];
	
	SKIAdRequest *request = [self createAdRequest];
	
	self.bannerView.hidden = YES;
	self.bannerView.adUnitID = kBannerAdUnitId;
	self.bannerView.delegate = self;
	
	[self.bannerView loadRequest:request];
}

- (SKIAdRequest *)createAdRequest {
	SKIAdRequest *request = [SKIAdRequest request];
	request.test = YES;
	
	return request;
}

- (SKIAdInterstitial *)createAndLoadWithAdUnitId:(NSString *)adUnitId {
	SKIAdRequest *request = [self createAdRequest];
	
	SKIAdInterstitial *interstitial = [SKIAdInterstitial interstitial];
	interstitial.adUnitID = adUnitId;
	interstitial.delegate = self;
	
	[interstitial loadRequest:request];
	
	return interstitial;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"example1"]) {
		if (self.interstitial1.isReady) {
			[self.interstitial1 presentFromRootViewController:self];
		} else if (!self.interstitial1.isLoading || self.interstitial1.hasBeenUsed) {
			self.interstitial1 = [self createAndLoadWithAdUnitId:kAdUnitId1];
		}
	} else if ([segue.identifier isEqualToString:@"example2"]) {
		if (self.interstitial2.isReady) {
			[self.interstitial2 presentFromRootViewController:self];
		} else if (!self.interstitial2.isLoading || self.interstitial2.hasBeenUsed) {
			self.interstitial2 = [self createAndLoadWithAdUnitId:kAdUnitId2];
		}
	} else if ([segue.identifier isEqualToString:@"example3"]) {
		if (self.interstitial3.isReady) {
			[self.interstitial3 presentFromRootViewController:self];
		} else if (!self.interstitial3.isLoading || self.interstitial3.hasBeenUsed) {
			self.interstitial3 = [self createAndLoadWithAdUnitId:kAdUnitId3];
		}
	}
}

- (void)skiInterstitial:(SKIAdInterstitial *)interstitial didFailToReceiveAdWithError:(SKIAdRequestError *)error {
	
}

- (void)skiInterstitialDidDismiss:(SKIAdInterstitial *)ad {
	if (ad == self.interstitial1) {
		self.interstitial1 = [self createAndLoadWithAdUnitId:kAdUnitId1];
	} else if (ad == self.interstitial2) {
		self.interstitial2 = [self createAndLoadWithAdUnitId:kAdUnitId2];
	} else if (ad == self.interstitial3) {
		self.interstitial3 = [self createAndLoadWithAdUnitId:kAdUnitId3];
	}
}

- (void)skiAdViewDidReceiveAd:(SKIAdBannerView *)view {
	self.bannerView.hidden = NO;
}

- (void)skiAdView:(SKIAdBannerView *)view didFailToReceiveAdWithError:(SKIAdRequestError *)error {
	self.bannerView.hidden = YES;
}

@end

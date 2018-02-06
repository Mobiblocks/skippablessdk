//
//  ViewController.m
//  SKIPPABLES_Sample
//
//  Created by Daniel on 10/4/17.
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import "ViewController.h"
#import "ViewController2.h"
#import <CoreLocation/CoreLocation.h>

#import <SKIPPABLES/SKIPPABLES.h>

@interface ViewController () <SKIAdBannerViewDelegate, SKIAdInterstitialDelegate>

@property (weak, nonatomic) IBOutlet UIButton *showButton;
@property (weak, nonatomic) IBOutlet SKIAdBannerView *bottomAdView;
@property (weak, nonatomic) IBOutlet SKIAdBannerView *mediumAdView;
@property (weak, nonatomic) IBOutlet SKIAdBannerView *halfPageAdView;
@property (strong, nonatomic) SKIAdInterstitial *adInterstitial;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adViewBottomConstraint;
@property (strong, nonatomic) CLLocationManager *lmanager;
@property (weak, nonatomic) IBOutlet UISwitch *testSwitch;

@end

@implementation ViewController

- (void)viewDidLoad {
	self.view.backgroundColor = [UIColor whiteColor];
	//cpc
	if (!self.bannerAdUnitId) {
		self.bannerAdUnitId = @"4AEDD12C-3B41-42B3-8763-DEDA7FDB06CA";
	}
	
	if (!self.interstitialAdUnitId) {
		self.interstitialAdUnitId = @"AE08B81B-3C70-4525-9370-0B715B5A92E4";
	}
	
	[super viewDidLoad];
	_lmanager = [[CLLocationManager alloc] init];
	[_lmanager requestWhenInUseAuthorization];
	// Do any additional setup after loading the view, typically from a nib.
	self.adViewBottomConstraint.constant = -self.bottomAdView.bounds.size.height;
	
	self.bottomAdView.adUnitID = self.bannerAdUnitId;
	self.bottomAdView.delegate = self;
	
	self.mediumAdView.adUnitID = self.bannerAdUnitId;
	self.mediumAdView.adSize = kSKIAdSizeMediumRectangle;
	self.mediumAdView.delegate = self;
	
	self.halfPageAdView.adUnitID = self.bannerAdUnitId;
	self.halfPageAdView.adSize = kSKIAdSizeHalfPage;
	self.halfPageAdView.delegate = self;
	
	[self.showButton setTitle:@"Load Interstitial" forState:UIControlStateNormal];
	
//	NSURL *url = [[NSBundle mainBundle] URLForResource:@"Inline_Simple" withExtension:@"xml"];
//	id vast = [SKIAdRequest loadVastFromFileUrl:url];
//	NSURL *url2 = [[NSBundle mainBundle] URLForResource:@"Video_Clicks_and_click_tracking-Inline-test" withExtension:@"xml"];
//	id vast2 = [SKIAdRequest loadVastFromFileUrl:url2];
	
	[self loadBanners];
//	[self loadInterstitial];
}

- (IBAction)showIntertitial:(id)sender {
	if (!self.adInterstitial) {
		[self loadInterstitial];
	} else {
		[self.adInterstitial presentFromRootViewController:self];
		
		self.adInterstitial = nil;
		
		[self.showButton setTitle:@"Load Interstitial" forState:UIControlStateNormal];
	}
}

- (IBAction)dismiss:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)testSwitchValueChanged:(id)sender {
	[self loadBanners];
	if (self.adInterstitial) {
		[self loadInterstitial];
	}
}

- (IBAction)showSecond:(id)sender {
	ViewController *cpm = [[ViewController alloc] initWithNibName:nil bundle:nil];
	cpm.bannerAdUnitId = @"1AB106BB-327D-4994-A56C-6408E6C1D774";
	cpm.interstitialAdUnitId = @"3E5EC0E3-E4AE-4F9E-819E-9BDDDAE9A848";
	[self presentViewController:cpm animated:YES completion:nil];
}

- (void)loadBanners {
	SKIAdRequest *request = [SKIAdRequest request];
	
	[request setLocationWithLatitude:47.021151f longitude:28.837918f accuracy:50.f];
	[request setLocationWithDescription:@"94041 US"];
	request.test = self.testSwitch.on;
	request.gender = kSKIGenderMale;
	request.yearOfBirth = 1988;
	[self.bottomAdView loadRequest:request];
	[self.mediumAdView loadRequest:request];
	[self.halfPageAdView loadRequest:request];
}

- (void)loadInterstitial {
	[self.showButton setTitle:@"Loading intertitial" forState:UIControlStateNormal];
	self.showButton.enabled = NO;
	
	self.adInterstitial = [SKIAdInterstitial interstitial];
	self.adInterstitial.adUnitID = self.interstitialAdUnitId;
	self.adInterstitial.delegate = self;
	
	SKIAdRequest *request = [SKIAdRequest request];
	
	[request setLocationWithLatitude:47.021151f longitude:28.837918f accuracy:50.f];
	[request setLocationWithDescription:@"94041 US"];
	request.test = self.testSwitch.on;
	request.gender = kSKIGenderMale;
	request.yearOfBirth = 1988;
	[self.adInterstitial loadRequest:request];
}

- (void)skiAdViewDidReceiveAd:(SKIAdBannerView *)view {
	if (view == self.bottomAdView) {
		self.adViewBottomConstraint.constant = 0;
		[UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
			[self.view layoutIfNeeded];
		}];
	} else {
		[UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
			view.alpha = 1.0;
		}];
	}
}

- (void)skiAdView:(SKIAdBannerView *)view didFailToReceiveAdWithError:(SKIAdRequestError *)error {
	if (view == self.bottomAdView) {
		self.adViewBottomConstraint.constant = -self.bottomAdView.bounds.size.height;
		[UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
			[self.view layoutIfNeeded];
		}];
	} else {
		[UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
			view.alpha = 0.0;
		}];
	}
	NSLog(@"%@", error);
}

- (void)skiInterstitialDidReceiveAd:(SKIAdInterstitial *)interstitial {
	[self.showButton setTitle:@"Show Interstitial" forState:UIControlStateNormal];
	self.showButton.enabled = YES;
	
//	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//		[interstitial presentFromRootViewController:self];
//	});
}

- (void)skiInterstitial:(SKIAdInterstitial *)interstitial didFailToReceiveAdWithError:(SKIAdRequestError *)error {
	NSLog(@"%@", error);
	[self.showButton setTitle:@"Load Interstitial" forState:UIControlStateNormal];
	self.showButton.enabled = YES;
	
	self.adInterstitial = nil;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	ViewController *cpm = (ViewController *)segue.destinationViewController;
	cpm.bannerAdUnitId = @"1AB106BB-327D-4994-A56C-6408E6C1D774";
	cpm.interstitialAdUnitId = @"3E5EC0E3-E4AE-4F9E-819E-9BDDDAE9A848";
}


@end

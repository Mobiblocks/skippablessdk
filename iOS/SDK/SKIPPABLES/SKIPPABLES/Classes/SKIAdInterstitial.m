//
//  SKIAdInterstitial.m
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import "SKIAdInterstitial.h"

#import "SKIConstants.h"

#import "SKIAdRequestError_Private.h"
#import "SKIAdRequest_Private.h"
#import "SKIAdRequestResponse.h"

#import "SKIAdInterstitialViewController.h"

@interface SKIAdInterstitial () <SKIAdRequestDelegate, SKIAdInterstitialViewControllerDelegate, UIWebViewDelegate>

@property (strong, nonatomic) SKIAdInterstitialViewController *interstitialViewController;

@property (copy, nonatomic) SKIAdRequest *request;
@property (strong, nonatomic) SKIAdRequestResponse *response;

@end

@implementation SKIAdInterstitial

+ (instancetype)interstitial {
	return [[self alloc] init];
}

- (instancetype)init
{
	self = [super init];
	if (self) {
	}
	return self;
}

- (void)loadRequest:(SKIAdRequest *)request {
	if (_request) {
		self.interstitialViewController = nil;
		[_request cancel];
	}
	
	self.request = request;
	self.request.adUnitID = self.adUnitID;
	self.request.adType = kSKIAdTypeInterstitialVideo;
	self.request.adSize = kSKIAdSizeFullscreen;
	self.request.delegate = self;
	
	[self.request load];
	
	_isLoading = YES;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
	if (!_isReady || !rootViewController || _hasBeenUsed) {
		return;
	}
	
	_hasBeenUsed = YES;
	if ([self.delegate respondsToSelector:@selector(skiInterstitialWillPresent:)]) {
		[self.delegate skiInterstitialWillPresent:self];
	}
	
	[rootViewController presentViewController:self.interstitialViewController animated:YES completion:nil];
}

- (void)skiAdRequest:(SKIAdRequest *)request didReceiveResponse:(SKIAdRequestResponse *)response {
	if (response.error) {
		_isLoading = NO;
		
		if ([self.delegate respondsToSelector:@selector(skiInterstitial:didFailToReceiveAdWithError:)]) {
			[self.delegate skiInterstitial:self didFailToReceiveAdWithError:response.error];
		}
		
		return;
	}
	
	if (response.htmlSnippet.length == 0 && response.videoVast.length == 0) {
		// at this point on of htmlSnippet or videoVast should not be empty
		// adding this error just in case
		_isLoading = NO;
		SKIAdRequestError *error = [SKIAdRequestError errorNoFillWithUserInfo:nil];
		if ([self.delegate respondsToSelector:@selector(skiInterstitial:didFailToReceiveAdWithError:)]) {
			[self.delegate skiInterstitial:self didFailToReceiveAdWithError:error];
		}
		return;
	}
	
	self.response = response;
	
	self.interstitialViewController = [SKIAdInterstitialViewController viewController];
	[self.interstitialViewController preloadWithAd:self];
}

- (void)skiAdRequest:(SKIAdRequest *)request didFailWithError:(SKIAdRequestError *)error {
	_isLoading = NO;
	if ([self.delegate respondsToSelector:@selector(skiInterstitial:didFailToReceiveAdWithError:)]) {
		[self.delegate skiInterstitial:self didFailToReceiveAdWithError:error];
	}
}

- (void)interstitialViewControllerDidFinishLoading:(SKIAdInterstitialViewController *)controller {
	_isLoading = NO;
	_isReady = YES;
	if ([self.delegate respondsToSelector:@selector(skiInterstitialDidReceiveAd:)]) {
		[self.delegate skiInterstitialDidReceiveAd:self];
	}
}

- (void)interstitialViewController:(SKIAdInterstitialViewController *)controller didFailToLoadWithErr:(SKIAdRequestError *)error {
	_isLoading = NO;
	if ([self.delegate respondsToSelector:@selector(skiInterstitial:didFailToReceiveAdWithError:)]) {
		[self.delegate skiInterstitial:self didFailToReceiveAdWithError:error];
	}
}

@end

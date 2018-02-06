//
//  SKIAdInterstitial.m
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import "SKIAdInterstitial.h"

#import "SKIConstants.h"

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
		if ([self.delegate respondsToSelector:@selector(skiInterstitial:didFailToReceiveAdWithError:)]) {
			[self.delegate skiInterstitial:self didFailToReceiveAdWithError:response.error];
		}
		
		return;
	}
	
	if (response.htmlSnippet.length == 0 && response.videoVast.length == 0) {
		//TODO: send error??
		return;
	}
	
	self.response = response;
	
	self.interstitialViewController = [SKIAdInterstitialViewController viewController];
	[self.interstitialViewController preloadWithAd:self];
}

- (void)skiAdRequest:(SKIAdRequest *)request didFailWithError:(SKIAdRequestError *)error {
	if ([self.delegate respondsToSelector:@selector(skiInterstitial:didFailToReceiveAdWithError:)]) {
		[self.delegate skiInterstitial:self didFailToReceiveAdWithError:error];
	}
}

- (void)interstitialViewControllerDidFinishLoading:(SKIAdInterstitialViewController *)controller {
	_isReady = YES;
	[self.delegate skiInterstitialDidReceiveAd:self];
}

- (void)interstitialViewController:(SKIAdInterstitialViewController *)controller didFailToLoadWithErr:(SKIAdRequestError *)error {
	if ([self.delegate respondsToSelector:@selector(skiInterstitial:didFailToReceiveAdWithError:)]) {
		[self.delegate skiInterstitial:self didFailToReceiveAdWithError:error];
	}
}

@end

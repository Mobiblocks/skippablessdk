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

#import "SKIVASTCompressedCreative.h"

#import "SKIAdInterstitialViewController.h"

@interface SKIAdInterstitial () <SKIAdRequestDelegate, SKIAdInterstitialViewControllerDelegate, UIWebViewDelegate>

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
	if (self.isLoading) {
		return;
	}
	
	_isReady = NO;
	_hasBeenUsed = NO;
	
	if (!request.test && (self.adUnitID == nil || self.adUnitID.length == 0)) {
		if ([self.delegate respondsToSelector:@selector(skiInterstitial:didFailToReceiveAdWithError:)]) {
			id<SKIAdInterstitialDelegate> delegate = self.delegate;
			SKIAsyncOnMain(^{
				SKIAdRequestError *error = [SKIAdRequestError errorInvalidArgumentWithUserInfo:@{
																								 NSLocalizedDescriptionKey: @"Ad unit id is empty"
																								 }];
				[delegate skiInterstitial:self didFailToReceiveAdWithError:error];
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
	
	SKIAdInterstitialViewController *viewController = [SKIAdInterstitialViewController viewController];
	viewController.delegate = self;
	viewController.ad = self;
	[rootViewController presentViewController:viewController animated:YES completion:nil];
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
	
	_isLoading = NO;
	_isReady = YES;
	if ([self.delegate respondsToSelector:@selector(skiInterstitialDidReceiveAd:)]) {
		[self.delegate skiInterstitialDidReceiveAd:self];
	}
}

- (void)interstitialViewControllerDidFinishLoading:(SKIAdInterstitialViewController *)controller {
//	_isLoading = NO;
//	_isReady = YES;
//	if ([self.delegate respondsToSelector:@selector(skiInterstitialDidReceiveAd:)]) {
//		[self.delegate skiInterstitialDidReceiveAd:self];
//	}
}

- (void)interstitialViewController:(SKIAdInterstitialViewController *)controller didFailToLoadWithErr:(SKIAdRequestError *)error {
//	_isLoading = NO;
//	if ([self.delegate respondsToSelector:@selector(skiInterstitial:didFailToReceiveAdWithError:)]) {
//		[self.delegate skiInterstitial:self didFailToReceiveAdWithError:error];
//	}
}

- (void)dealloc {
	if (!_hasBeenUsed && _response.compressedCreative.localMediaUrl) {
		NSError *error = nil;
		if (![[NSFileManager defaultManager] removeItemAtURL:_response.compressedCreative.localMediaUrl error:&error]) {
			DLog(@"Failed to delete local media url: %@", error);
		}
	}
}

@end

//
//  SKIAdInterstitial.m
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import "SKIAdInterstitial.h"
#import "SKIAdInterstitial_Private.h"

#import "SKIConstants.h"

#import "SKIAdRequestError_Private.h"
#import "SKIAdRequest_Private.h"
#import "SKIAdRequestResponse.h"

#import "SKIVASTCompressedCreative.h"

#import "SKIAdInterstitialVideoViewController.h"
#import "SKIAdInterstitialHtmlViewController.h"

#import "SKIAdEventTracker.h"

@interface SKIAdInterstitial () <SKIAdRequestDelegate, SKIAdInterstitialViewControllerDelegate, UIWebViewDelegate>

@property (copy, nonatomic) SKIAdRequest *request;
@property (strong, nonatomic) SKIAdRequestResponse *response;
@property (strong, nonatomic) SKIErrorCollector *errorCollector;
@property (strong, nonatomic) SKISDKSessionLogger *sessionLogger;
@property (assign, nonatomic) BOOL logErrors;

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
	
	if (_sessionLogger) {
		[_sessionLogger report];
		_sessionLogger = nil;
	}
	
	self.request = request;
	self.request.adUnitID = self.adUnitID;
	self.request.adType = kSKIAdTypeInterstitial;
	self.request.adSize = kSKIAdSizeFullscreen;
	self.request.delegate = self;
	
	[self.request load];
	
	_isLoading = YES;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
	[_sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
		log.idenitifier = @"adInterstitial.present";
	}];
	if (!_isReady || !rootViewController || _hasBeenUsed) {
		BOOL isReady = _isReady;
		BOOL hasBeenUsed = _hasBeenUsed;
		BOOL rootViewControllerIsSet = rootViewController != nil;
		BOOL isLoading = _isLoading;
		[_sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
			log.idenitifier = @"adInterstitial.present.error";
			log.info = @{
						 @"isReady": @(isReady),
						 @"hasBeenUsed": @(hasBeenUsed),
						 @"rootViewControllerIsSet": @(rootViewControllerIsSet),
						 @"isLoading": @(isLoading)
						 };
		}];
		return;
	}
	
	_hasBeenUsed = YES;
	if ([self.delegate respondsToSelector:@selector(skiInterstitialWillPresent:)]) {
		[self.delegate skiInterstitialWillPresent:self];
	}
	
	[_sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
		log.idenitifier = @"adInterstitial.present.success";
		log.desc = @"Report to user.";
		log.info = @{
					 @"method": @"skiInterstitialWillPresent:",
					 @"delegateIsSet": @(self.delegate != nil)
					 };
	}];

	if (self.response.interstitialType == kSKIAdTypeInterstitialTypeHtml) {
		SKIAdInterstitialHtmlViewController *viewController = [SKIAdInterstitialHtmlViewController viewController];
		viewController.delegate = self;
		viewController.ad = self;
		[rootViewController presentViewController:viewController animated:YES completion:nil];
	} else {
		SKIAdInterstitialVideoViewController *viewController = [SKIAdInterstitialVideoViewController viewController];
		viewController.delegate = self;
		viewController.ad = self;
		[rootViewController presentViewController:viewController animated:YES completion:nil];
	}
}

- (void)skiAdRequest:(SKIAdRequest *)request didReceiveResponse:(SKIAdRequestResponse *)response {
	self.sessionLogger = request.sessionLogger;
	
	[_sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
		log.idenitifier = @"adInterstitial.response";
	}];
	if (response.error) {
		_isLoading = NO;
		
		if ([self.delegate respondsToSelector:@selector(skiInterstitial:didFailToReceiveAdWithError:)]) {
			[self.delegate skiInterstitial:self didFailToReceiveAdWithError:response.error];
		}
		
		[_sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
			log.idenitifier = @"adInterstitial.response.error";
			log.desc = @"Report to user.";
			log.info = @{
						 @"method": @"skiInterstitial:didFailToReceiveAdWithError:",
						 @"delegateIsSet": @(self.delegate != nil)
						 };
		}];
		
		return;
	}
	
	if (response.htmlSnippet.length == 0 && response.videoVast.length == 0) {
		// at this point on of htmlSnippet or videoVast should not be empty
		// adding this error just in case
		_isLoading = NO;
		SKIAdRequestError *error = [SKIAdRequestError errorNoFillWithUserInfo:@{
																				NSLocalizedDescriptionKey : @"No ad available a this time."
																				}];
		if ([self.delegate respondsToSelector:@selector(skiInterstitial:didFailToReceiveAdWithError:)]) {
			[self.delegate skiInterstitial:self didFailToReceiveAdWithError:error];
		}
		
		[_sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
			log.idenitifier = @"adInterstitial.response.error";
			log.desc = @"Report to user. Empty ad data after processing!!!";
			log.info = @{
						 @"method": @"skiInterstitial:didFailToReceiveAdWithError:",
						 @"delegateIsSet": @(self.delegate != nil)
						 };
		}];
		return;
	}
	
	self.response = response;
	self.errorCollector = request.errorCollector;
	self.logErrors = request.logErrors;
	_isLoading = NO;
	_isReady = YES;
	if ([self.delegate respondsToSelector:@selector(skiInterstitialDidReceiveAd:)]) {
		[self.delegate skiInterstitialDidReceiveAd:self];
	}
	
	[_sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
		log.idenitifier = @"adInterstitial.response.success";
		log.desc = @"Report to user.";
		log.info = @{
					 @"method": @"skiInterstitialDidReceiveAd:",
					 @"delegateIsSet": @(self.delegate != nil)
					 };
	}];
}

- (void)interstitialViewControllerDidFinishLoading:(SKIAdInterstitialVideoViewController *)controller {
//	_isLoading = NO;
//	_isReady = YES;
//	if ([self.delegate respondsToSelector:@selector(skiInterstitialDidReceiveAd:)]) {
//		[self.delegate skiInterstitialDidReceiveAd:self];
//	}
}

- (void)interstitialViewController:(SKIAdInterstitialVideoViewController *)controller didFailToLoadWithErr:(SKIAdRequestError *)error {
//	_isLoading = NO;
//	if ([self.delegate respondsToSelector:@selector(skiInterstitial:didFailToReceiveAdWithError:)]) {
//		[self.delegate skiInterstitial:self didFailToReceiveAdWithError:error];
//	}
}

- (void)dealloc {
	if (_sessionLogger) {
		__block SKISDKSessionLogger *logger = _sessionLogger;
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[logger build:^(SKISDKSessionLog * _Nonnull log) {
				log.idenitifier = @"adInterstitial.dealloc";
			}];
			[logger report];
			logger = nil;
		});
		_sessionLogger = nil;
	}
	
	if (!_hasBeenUsed && _response.compactVast.ad.bestMediaFile.localMediaUrl) {
		NSError *error = nil;
		if (![[NSFileManager defaultManager] removeItemAtURL:_response.compactVast.ad.bestMediaFile.localMediaUrl error:&error]) {
			DLog(@"Failed to delete local media url: %@", error);
		}
	}
}

@end

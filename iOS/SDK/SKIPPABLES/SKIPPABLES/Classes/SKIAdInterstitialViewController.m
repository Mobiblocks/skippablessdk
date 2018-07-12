//
//  SKIAdInterstitialViewController.m
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import "SKIAdInterstitialViewController.h"

#import "SKIAdReportViewController.h"

#import <AVKit/AVKit.h>

#import "SKIVAST.h"

#import "SKIVASTUrl.h"

#import "SKIAsync.h"
#import "SKIObserver.h"

#import "SKIVASTCompressedCreative.h"

#import "SKIRes.h"
#import "SKIConstants.h"
#import "SKIAdInterstitial.h"
#import "SKIAdInterstitial_Private.h"
#import "SKIAdRequestResponse.h"
#import "SKIAdRequestError_Private.h"
#import "SKIAdEventTracker.h"

@interface SKIAdInterstitialViewLayer : UIView

+ (instancetype)layer;

@property (strong, nonatomic) UIView *skipView;
@property (strong, nonatomic) UILabel *skipLabelView;

@property (strong, nonatomic) UIView *durationView;
@property (strong, nonatomic) UILabel *durationLabelView;

@property (strong, nonatomic) UIImageView *videoControlView;

@property (strong, nonatomic) UILabel *reportLabelView;

@property (strong, nonatomic) UIImageView *soundToggleImageView;

@property (copy, nonatomic) void (^tapCallback)(void);
@property (copy, nonatomic) void (^skipCallback)(void);
@property (copy, nonatomic) void (^closeCallback)(void);
@property (copy, nonatomic) void (^reportCallback)(void);
@property (copy, nonatomic) bool (^soundToggleCallback)(void);
@property (copy, nonatomic) bool (^playToggleCallback)(void);

- (void)updateDurationTimeLabelWithDuration:(NSTimeInterval)duration currentTime:(NSTimeInterval)currentTime;
- (void)updateSkipTimeLabelWithOffset:(NSTimeInterval)skipOffset currentTime:(NSTimeInterval)currentTime;

- (void)updateVideoControlView:(BOOL)paused;

- (void)showSkip;
- (void)showClose;

@end

static BOOL muted = NO;

@interface SKIAdInterstitialViewController () <AVPlayerViewControllerDelegate>

@property (strong, nonatomic) AVPlayer *avPlayer;
@property (strong, nonatomic) AVPlayerViewController *avPlayerController;
@property (strong, nonatomic) SKIAdInterstitialViewLayer *avPlayerControllerLayer;

@property (assign, nonatomic, readonly) SKIVASTCompressedCreative *compressedCreative;

@property (strong, nonatomic) NSPointerArray *avPlayerTimeTokens;
@property (strong, nonatomic) NSMutableArray<id<NSObject>> *avPlayerNotificationTokens;

@property (assign, nonatomic) BOOL viewShownOnce;
@property (assign, nonatomic) BOOL isPlaying;

@end

@implementation SKIAdInterstitialViewController

+ (instancetype)viewController {
	return [[self alloc] initWithNibName:nil bundle:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self) {
		self.avPlayerTimeTokens = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsOpaqueMemory | NSPointerFunctionsStrongMemory];
		self.avPlayerNotificationTokens = [NSMutableArray array];
	}

	return self;
}

bool compareNearlyEqual(CGFloat a, CGFloat b) {
	float epsilon;
	/* May as well do the easy check first. */
	if (a == b)
		return true;
	
	if (a > b) {
		epsilon = a * FLT_EPSILON;
	} else {
		epsilon = b * FLT_EPSILON;
	}
	
	return fabs (a - b) < epsilon;
}

- (void)setAd:(SKIAdInterstitial *)ad {
	_ad = ad;
}

- (SKIVASTCompressedCreative *)compressedCreative {
	return self.ad.response.compressedCreative;
}

- (void)prepareAdPlayer {
	SKIAsyncOnMain(^{
		[self prepareAdPlayerWithFail:YES];
	});
//	[self prepareAdPlayerWithFail:NO];
}

- (void)prepareAdPlayerWithFail:(BOOL)fail {
	__weak typeof(self) wSelf = self;
	SKIVASTCompressedCreative *compressedCreative = self.compressedCreative;
	NSArray *errorTrackings = compressedCreative.errorTrackings;
	
	NSURL *mediaUrl = self.compressedCreative.localMediaUrl ?: compressedCreative.mediaFile.value;
	self.avPlayer = [AVPlayer playerWithURL:mediaUrl];
	self.avPlayer.allowsExternalPlayback = NO;
	self.avPlayer.muted = muted;
	
	[SKIAsync waterfall:@[
						  ^(id _Nullable result, SKIAsyncWaterfallCallback callback) {
		[SKIObserver observeObject:self.avPlayer
						forKeyPath:@"status"
						  callback:^(SKIObserver *observer, NSDictionary<NSKeyValueChangeKey, id> *change) {
							  if (wSelf.avPlayer.status == AVPlayerStatusReadyToPlay) {
								  [observer remove];
								  
								  callback(nil, nil);
								  
								  return;
							  } else if (wSelf.avPlayer.status == AVPlayerStatusFailed) {
								  [observer remove];
								  
								  callback([SKIAdRequestError errorReceivedInvalidResponseWithUserInfo:@{
																										 NSLocalizedDescriptionKey : @"Video data is invalid."
																										 }], nil);
								  
								  return;
							  } else {
								  DLog(@"self.avPlayer");
							  }
						  } timeout:^(SKIObserver *observer) {
							  [observer remove];
							  callback([SKIAdRequestError errorInternalErrorWithUserInfo:@{
																						   NSLocalizedDescriptionKey : @"Video failed to prepare."
																						   }], nil);
							  DLog(@"self.avPlayer status timeouted");
						  }];
	},
						   ^(id _Nullable result, SKIAsyncWaterfallCallback callback) {
		[SKIObserver observeObject:self.avPlayer.currentItem
						forKeyPath:@"status"
						  callback:^(SKIObserver *observer, NSDictionary<NSKeyValueChangeKey, id> *change) {
							  if (wSelf.avPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay) {
								  [observer remove];
								  
								  callback(nil, nil);
								  
								  return;
							  } else if (wSelf.avPlayer.currentItem.status == AVPlayerItemStatusFailed) {
								  [observer remove];
								  
								  callback([SKIAdRequestError errorReceivedInvalidResponseWithUserInfo:@{
																										 NSLocalizedDescriptionKey : @"Video data is invalid."
																										 }], nil);
								  
								  return;
							  } else {
								  DLog(@"self.avPlayer.currentItem");
							  }
						  } timeout:^(SKIObserver *observer) {
							  [observer remove];
							  callback([SKIAdRequestError errorInternalErrorWithUserInfo:@{
																						   NSLocalizedDescriptionKey : @"Video failed to prepare."
																						   }], nil);
							  
							  DLog(@"self.avPlayer.currentItem status timeouted");
						  }];
	}
						   ]
			 completion:^(NSError *_Nullable error, id _Nullable result) {
				 if (error) {
					 //posibile race condition in observers
					 //do another check))
					 if (wSelf.avPlayer.status != AVPlayerStatusReadyToPlay || wSelf.avPlayer.currentItem.status != AVPlayerStatusReadyToPlay) {
						 DLog(@"sec check");
						 if (fail) {
							 DLog(@"self.avPlayer error");
							 [wSelf trackErrorUrls:errorTrackings errorCode:SKIVASTMediaFileDisplayErrorCode];
							 SKIAsyncOnMain(^{
								 [wSelf closeInterstitial];
							 });
						 } else {
							 DLog(@"self.avPlayer error retry on main");
							 SKIAsyncOnMain(^{
								 [wSelf prepareAdPlayerWithFail:YES];
							 });
						 }
						 return;
					 }
				 }
				 
				 SKIAsyncOnMain(^{
					 [wSelf prepareAdView];
				 });
			 }];
}

- (void)prepareAdView {
	if (@available(iOS 9.0, *)) {
		[self loadViewIfNeeded];
	} else {
		[self view];
	}

	__weak typeof(self) wSelf = self;
	SKIVASTCompressedCreative *compressedCreative = self.compressedCreative;

	NSDate *duration = compressedCreative.duration ?: [NSDate dateWithTimeIntervalSinceReferenceDate:0];
	NSTimeInterval durationInterval = SKIIntervalFromDurationDate(duration);
	NSTimeInterval skipoffset = SKITrackingEventWithOffsetInterval(compressedCreative.skipoffset, duration);
	if (skipoffset > durationInterval || compareNearlyEqual(skipoffset, durationInterval)) {
		skipoffset = -1;
	}
	if (skipoffset >= 0.) {
		if (skipoffset > 0.) {
			id token = [self.avPlayer addBoundaryTimeObserverForTimes:@[ [NSValue valueWithCMTime:CMTimeMakeWithSeconds(skipoffset, 1000)] ]
																queue:nil
														   usingBlock:^{
															   DLog(@"Event: %@, %f : %@", @"SKIP", skipoffset, [NSDate date]);
															   [wSelf.avPlayerControllerLayer showSkip];
														   }];
			
			[self.avPlayerTimeTokens addPointer:(__bridge void *)token];
		} else {
			[self.avPlayerControllerLayer showSkip];
		}
	}

	NSMutableArray<NSURL *> *skipTrackingUrls = [NSMutableArray array];
	NSArray<SKIVASTTracking *> *trackings = [compressedCreative.trackings ?: @[] arrayByAddingObjectsFromArray:compressedCreative.additionalTrackings ?: @[]];
	for (SKIVASTTracking *tracking in trackings) {
		NSString *eventName = tracking.event;
		NSURL *trackUrl = tracking.value;
		NSTimeInterval eventInterval = 0.;
		if ([eventName isEqualToString:@"start"]) {
			eventInterval = SKITrackingEventWithOffsetInterval(tracking.offset, duration);
#if DEBUG
			if (eventInterval < 0) {
				eventInterval = 0.001;
			}

			if (eventInterval >= 0.) {
				[self addPlayerBoundaryObserver:eventInterval usingBlock:^{
					[wSelf trackUrl:trackUrl playhead:eventInterval];

					DLog(@"Event: %@, %f : %@, %@", eventName, eventInterval, [NSDate date], trackUrl.absoluteString);
				}];
			}
#endif
		} else if ([eventName isEqualToString:@"firstQuartile"]) {
			eventInterval = SKITrackingEventFirstQuartileInterval(duration);

			if (eventInterval >= 0.) {
				[self addPlayerBoundaryObserver:eventInterval usingBlock:^{
					[wSelf trackUrl:trackUrl playhead:eventInterval];

					DLog(@"Event: %@, %f : %@, %@", eventName, eventInterval, [NSDate date], trackUrl.absoluteString);
				}];
			}
		} else if ([eventName isEqualToString:@"midpoint"]) {
			eventInterval = SKITrackingEventMidpointInterval(duration);

			if (eventInterval >= 0.) {
				[self addPlayerBoundaryObserver:eventInterval usingBlock:^{
					[wSelf trackUrl:trackUrl playhead:eventInterval];

					DLog(@"Event: %@, %f : %@, %@", eventName, eventInterval, [NSDate date], trackUrl.absoluteString);
				}];
			}
		} else if ([eventName isEqualToString:@"thirdQuartile"]) {
			eventInterval = SKITrackingEventThirdQuartileInterval(duration);

			if (eventInterval >= 0.) {
				[self addPlayerBoundaryObserver:eventInterval usingBlock:^{
					[wSelf trackUrl:trackUrl playhead:eventInterval];

					DLog(@"Event: %@, %f : %@, %@", eventName, eventInterval, [NSDate date], trackUrl.absoluteString);
				}];
			}
		} else if ([eventName isEqualToString:@"complete"]) {
			eventInterval = SKITrackingEventWithOffsetInterval(@"100%", duration) - 0.9;

			if (eventInterval >= 0.) {
				[self addPlayerBoundaryObserver:eventInterval usingBlock:^{
					[wSelf trackUrl:trackUrl playhead:eventInterval];

					DLog(@"Event: %@, %f : %@, %@", eventName, eventInterval, [NSDate date], trackUrl.absoluteString);
				}];
			}
		} else if ([eventName isEqualToString:@"progress"]) {
			eventInterval = SKITrackingEventWithOffsetInterval(@"100%", duration) - 0.9;
			
			if (eventInterval >= 0.) {
				[self addPlayerBoundaryObserver:eventInterval usingBlock:^{
					[wSelf trackUrl:trackUrl playhead:eventInterval];

					DLog(@"Event: %@, %f : %@, %@", eventName, eventInterval, [NSDate date], trackUrl.absoluteString);
				}];
			}
		} else if ([eventName isEqualToString:@"skip"]) {
			[skipTrackingUrls addObject:trackUrl];
		}
	}
	
	compressedCreative.skipTrackingUrls = skipTrackingUrls;
	{
		AVPlayerItem *playerItem = self.avPlayer.currentItem;
		[self addPlayerPeriodicObserver:1. usingBlock:^(CMTime time) {
			NSTimeInterval duration = CMTimeGetSeconds(playerItem.duration);
			NSTimeInterval currentTime = CMTimeGetSeconds(playerItem.currentTime);
			if (isnan(duration) || isnan(currentTime)) {
				return;
			}
			[wSelf.avPlayerControllerLayer updateDurationTimeLabelWithDuration:duration currentTime:currentTime];
			
			if (skipoffset > 0. && skipoffset - currentTime >= 0.) {
				[wSelf.avPlayerControllerLayer updateSkipTimeLabelWithOffset:skipoffset currentTime:currentTime];
			}
		}];
	}

	[self addNotificationsForPlayer:self.avPlayer];
	self.avPlayerController.player = self.avPlayer;

	[self displayPlayerController];
	
	[self.avPlayerControllerLayer updateDurationTimeLabelWithDuration:durationInterval currentTime:0.];
	[self.avPlayerControllerLayer updateSkipTimeLabelWithOffset:skipoffset currentTime:0.];
	
	[self.ad interstitialViewControllerDidFinishLoading:self];
}

- (void)addPlayerPeriodicObserver:(NSTimeInterval)seconds usingBlock:(void (^)(CMTime time))block {
	id token = [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(seconds, 1) queue:nil usingBlock:block];

	[self.avPlayerTimeTokens addPointer:(__bridge void *)token];
}

- (void)addPlayerBoundaryObserver:(NSTimeInterval)seconds usingBlock:(void (^)(void))block {
	id token = [self.avPlayer addBoundaryTimeObserverForTimes:@[ [NSValue valueWithCMTime:CMTimeMakeWithSeconds(seconds, 1000)] ]
	                                                    queue:nil
	                                               usingBlock:block];

	[self.avPlayerTimeTokens addPointer:(__bridge void *)token];
}

- (AVPlayerViewController *)avPlayerController {
	if (!_avPlayerController) {
		_avPlayerController = [[AVPlayerViewController alloc] initWithNibName:nil bundle:nil];
		_avPlayerController.player = self.avPlayer;
		_avPlayerController.delegate = self;
		_avPlayerController.showsPlaybackControls = NO;

		__weak typeof(self) wSelf = self;
		self.avPlayerControllerLayer = [SKIAdInterstitialViewLayer layer];
		[self.avPlayerControllerLayer setTapCallback:^{
			if ([wSelf handleClickThrough]) {
				wSelf.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
				[wSelf closeInterstitial];
			}
		}];
		[self.avPlayerControllerLayer setSkipCallback:^{
			if (wSelf.compressedCreative.skipTrackingUrls.count > 0) {
				NSTimeInterval contentPlayhead = CMTimeGetSeconds(wSelf.avPlayer.currentItem.currentTime);
				for (NSURL *url in wSelf.compressedCreative.skipTrackingUrls) {
					[wSelf trackUrl:url playhead:contentPlayhead];
				}
			}
			[wSelf closeInterstitial];
		}];
		[self.avPlayerControllerLayer setCloseCallback:^{
			[wSelf closeInterstitial];
		}];
		[self.avPlayerControllerLayer setReportCallback:^{
			if (wSelf) {
				[SKIAdReportViewController showFromViewController:wSelf callback:^(BOOL canceled, NSString * _Nullable email, NSString * _Nullable message) {
					if (canceled) {
						return;
					}
					
					[[SKIAdEventTracker defaultTracker] sendReportWithDeviceData:wSelf.ad.response.deviceInfo adId:wSelf.compressedCreative.adId adUnitId:wSelf.ad.adUnitID email:email message:message];
					
					SKIAsyncOnMain(^{
						[wSelf closeInterstitial];
					});
				}];
			}
		}];
		[self.avPlayerControllerLayer setSoundToggleCallback:^bool{
			if (!wSelf.avPlayer) {
				return false;
			}
			
			muted = !muted;
			wSelf.avPlayer.muted = muted;
			
			return true;
		}];
		[self.avPlayerControllerLayer setPlayToggleCallback:^bool{
			if (!wSelf.avPlayer) {
				return false;
			}
			
			if (wSelf.isPlaying) {
				wSelf.isPlaying = NO;
				[wSelf.avPlayer pause];
				return true;
			}
			
			wSelf.isPlaying = YES;
			[wSelf.avPlayer play];
			return false;
		}];

		if (@available(iOS 9.0, *)) {
			_avPlayerController.allowsPictureInPicturePlayback = NO;
		}

		if (@available(iOS 10.0, *)) {
			_avPlayerController.updatesNowPlayingInfoCenter = NO;
		}
	}

	return _avPlayerController;
}

- (void)displayPlayerController {
	[self addChildViewController:self.avPlayerController];
	self.avPlayerController.view.frame = self.view.bounds;
	
	[self.view addSubview:self.avPlayerController.view];
	[self.avPlayerController didMoveToParentViewController:self];
	
	[self.view addSubview:self.avPlayerControllerLayer];
}

- (void)removePlayerController {
	[self.avPlayerController willMoveToParentViewController:nil];
	[self.avPlayerController.view removeFromSuperview];
	[self.avPlayerController removeFromParentViewController];
	
	[self.avPlayerControllerLayer removeFromSuperview];
}

- (void)addNotificationsForPlayer:(AVPlayer *)avPlayer {
	__weak typeof(self) wSelf = self;
	AVPlayerItem *playerItem = avPlayer.currentItem;
	id<NSObject> token = nil;
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	{
		token = [center addObserverForName:AVPlayerItemTimeJumpedNotification
		                            object:avPlayer.currentItem
		                             queue:[NSOperationQueue mainQueue]
		                        usingBlock:^(NSNotification *_Nonnull note) {
			                        if (note.object != playerItem) {
				                        return;
			                        }
									DLog(@"AVPlayerItemTimeJumpedNotification: %@", note.userInfo);
			                    }];
		[self.avPlayerNotificationTokens addObject:token];
	}
	{
		token = [center addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
		                            object:avPlayer.currentItem
		                             queue:[NSOperationQueue mainQueue]
		                        usingBlock:^(NSNotification *_Nonnull note) {
			                        if (note.object != playerItem) {
				                        return;
			                        }
									DLog(@"AVPlayerItemDidPlayToEndTimeNotification: %@", note.userInfo);

			                        [wSelf.avPlayerControllerLayer showClose];
			                    }];
		[self.avPlayerNotificationTokens addObject:token];
	}
	{
		token = [center addObserverForName:AVPlayerItemFailedToPlayToEndTimeNotification
		                            object:avPlayer.currentItem
		                             queue:[NSOperationQueue mainQueue]
		                        usingBlock:^(NSNotification *_Nonnull note) {
			                        if (note.object != playerItem) {
				                        return;
			                        }
									[wSelf reportPlayerErrorAndCLose];
									DLog(@"AVPlayerItemFailedToPlayToEndTimeNotification: %@", note.userInfo);
			                    }];
		[self.avPlayerNotificationTokens addObject:token];
	}
	{
		token = [center addObserverForName:AVPlayerItemPlaybackStalledNotification
		                            object:avPlayer.currentItem
		                             queue:[NSOperationQueue mainQueue]
		                        usingBlock:^(NSNotification *_Nonnull note) {
			                        if (note.object != playerItem) {
				                        return;
			                        }
									DLog(@"AVPlayerItemPlaybackStalledNotification: %@", note.userInfo);
			                    }];
		[self.avPlayerNotificationTokens addObject:token];
	}
	{
		token = [center addObserverForName:AVPlayerItemNewAccessLogEntryNotification
		                            object:avPlayer.currentItem
		                             queue:[NSOperationQueue mainQueue]
		                        usingBlock:^(NSNotification *_Nonnull note) {
			                        if (note.object != playerItem) {
				                        return;
			                        }
									DLog(@"AVPlayerItemNewAccessLogEntryNotification: %@", note.userInfo);
			                    }];
		[self.avPlayerNotificationTokens addObject:token];
	}
	{
		token = [center addObserverForName:AVPlayerItemNewErrorLogEntryNotification
		                            object:avPlayer.currentItem
		                             queue:[NSOperationQueue mainQueue]
		                        usingBlock:^(NSNotification *_Nonnull note) {
			                        if (note.object != playerItem) {
				                        return;
			                        }
									DLog(@"AVPlayerItemNewErrorLogEntryNotification: %@", note.userInfo);
			                    }];
		[self.avPlayerNotificationTokens addObject:token];
	}
}

- (void)removeNotificationsForPlayer:(AVPlayer *)player {
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	for (id<NSObject> token in self.avPlayerNotificationTokens) {
		[center removeObserver:token];
	}

	[self.avPlayerNotificationTokens removeAllObjects];

	for (id token in self.avPlayerTimeTokens) {
		if (token != nil) {
			[self.avPlayer removeTimeObserver:token];
		}
	}

	for (NSInteger i = self.avPlayerTimeTokens.count - 1; i >= 0; i--) {
		[self.avPlayerTimeTokens removePointerAtIndex:i];
	}
}

- (BOOL)handleClickThrough {
	SKIVASTCompressedCreative *creative = self.compressedCreative;
	if (creative.clickTrackings.count > 0) {
		NSTimeInterval contentPlayhead = CMTimeGetSeconds(self.avPlayer.currentItem.currentTime);
		for (SKIVASTClickTracking *clickTracking in creative.clickTrackings) {
			NSURL *url = clickTracking.value;
			if (!url) {
				continue;
			}
			
			[self trackUrl:url playhead:contentPlayhead];
		}
	}
	
	NSURL *url = creative.clickThrough.value;
	if (!url) {
		return NO;
	}
	
	if ([[UIApplication sharedApplication] openURL:url]) {
		if ([self.ad.delegate respondsToSelector:@selector(skiInterstitialWillLeaveApplication:)]) {
			[self.ad.delegate skiInterstitialWillLeaveApplication:self.ad];
		}
		
		return YES;
	}
	
	return NO;
}

- (void)reportPlayerErrorAndCLose {
	[self closeInterstitial];
}

- (void)closeInterstitial {
	if ([self.ad.delegate respondsToSelector:@selector(skiInterstitialWillDismiss:)]) {
		[self.ad.delegate skiInterstitialWillDismiss:self.ad];
	}
	
	NSURL *localUrl = self.compressedCreative.localMediaUrl;
	
	__weak typeof(self) wSelf = self;
	[self dismissViewControllerAnimated:YES
							 completion:^{
								 [wSelf removeNotificationsForPlayer:wSelf.avPlayer];
								 [wSelf removePlayerController];
								 
								 if ([wSelf.ad.delegate respondsToSelector:@selector(skiInterstitialDidDismiss:)]) {
									 [wSelf.ad.delegate skiInterstitialDidDismiss:self.ad];
								 }
								 
								 if (localUrl) {
									 SKIAsyncOnBackground(^{
										 NSError *error = nil;
										 if (![[NSFileManager defaultManager] removeItemAtURL:localUrl error:&error]) {
											 DLog(@"Failed to delete local media url: %@", error);
										 }
									 });
								 }
							 }];
}

- (void)trackUrl:(NSURL *)url playhead:(NSTimeInterval)playhead {
	NSURL *assetUrl = self.compressedCreative.mediaFile.value;
	NSURL *macrosed = [SKIVASTUrl urlFromUrlAfterReplacingMacros:url
														 builder:^(SKIVASTUrlMacroValues *_Nonnull macroValues) {
															 macroValues.contentPlayhead = playhead;
															 macroValues.assetUrl = assetUrl;
														 }];
	if (macrosed) {
		[[SKIAdEventTracker defaultTracker] trackEventRequestWithUrl:macrosed];
	}
}

- (void)trackErrorUrl:(NSURL *)url errorCode:(SKIVASTErrorCode)errorCode {
	if (!url) {
		return;
	}
	
	NSURL *macrosed = [SKIVASTUrl urlFromUrlAfterReplacingMacros:url
														 builder:^(SKIVASTUrlMacroValues *_Nonnull macroValues) {
															 macroValues.errorCode = errorCode;
														 }];
	if (macrosed) {
		[[SKIAdEventTracker defaultTracker] trackErrorRequestWithUrl:macrosed];
	}
}

- (void)trackErrorUrls:(NSArray<NSURL *> *)urls errorCode:(SKIVASTErrorCode)errorCode {
	if (urls.count == 0) {
		return;
	}
	
	for (NSURL *url in urls) {
		[self trackErrorUrl:url errorCode:errorCode];
	}
}

- (void)setIsPlaying:(BOOL)isPlaying {
	_isPlaying = isPlaying;
	
	[self.avPlayerControllerLayer updateVideoControlView:!isPlaying];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (!_viewShownOnce) {
		[self prepareAdPlayer];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (!_viewShownOnce) {
		[self.avPlayer play];
		self.isPlaying = YES;
		
		_viewShownOnce = YES;
		for (NSURL *url in self.compressedCreative.impressionUrls) {
			[self trackUrl:url playhead:0.0f];
		}
		
		for (NSURL *url in self.compressedCreative.additionalImpressionUrls) {
			[self trackUrl:url playhead:0.0f];
		}
	}
	
	DLog(@"");
}

- (void)applicationDidBecomeActive:(BOOL)previouslyVisible {
	[super applicationDidBecomeActive:previouslyVisible];
	
//	if (previouslyVisible) {
//		[self.avPlayer play];
//	}
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	
	if (@available(iOS 11.0, *)) {
		CGRect insets = self.view.safeAreaLayoutGuide.layoutFrame;
		if (insets.size.height > 0) {
			self.avPlayerControllerLayer.frame = insets;
		}
	} else {
		self.avPlayerControllerLayer.frame = self.view.bounds;
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[self.avPlayer pause];
	self.isPlaying = NO;
}

- (void)applicationWillResignActive:(BOOL)previouslyVisible {
	[super applicationWillResignActive:previouslyVisible];
	
	
	[self.avPlayer pause];
	self.isPlaying = NO;
//	if (previouslyVisible) {
//		[self.avPlayer pause];
//	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
	return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
	return UIStatusBarAnimationFade;
}

- (BOOL)shouldAutorotate {
//	if (SKIiSiPhone()) {
		if (self.compressedCreative.maybeShownInLandscape) {
			return SKIiSPortrait();
		}
	
		return SKIiSLandscape();
//	}
	
//	return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//	if (SKIiSiPhone()) {
		if (self.compressedCreative.maybeShownInLandscape) {
			return UIInterfaceOrientationMaskAllButUpsideDown;
		}
		
		return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
//	}
	
//	return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//	if (SKIiSiPhone()) {
		if (!self.compressedCreative.maybeShownInLandscape) {
			return UIInterfaceOrientationPortrait;
		}
//	}
	
	return SKICurrentOrientation();
}

- (void)dealloc {
	
}

@end

@implementation SKIAdInterstitialViewLayer

+ (instancetype)layer {
	return [[self alloc] initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.userInteractionEnabled = YES;
//		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;// | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;

		self.skipView = [[UIView alloc] initWithFrame:(CGRect){{0.f, 0.f}, {100.f, 40.f}}];
		self.skipView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:0.7f];
		self.skipView.userInteractionEnabled = NO;

		self.skipLabelView = [[UILabel alloc] initWithFrame:(CGRect){{8.f, 0.f}, {84.f, 40.f}}];
		self.skipLabelView.textColor = [UIColor colorWithWhite:0.6 alpha:1.f];
		self.skipLabelView.font = [UIFont monospacedDigitSystemFontOfSize:17 weight:UIFontWeightRegular];

		UITapGestureRecognizer *skipTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
		[self.skipView addGestureRecognizer:skipTapGesture];

		[self.skipView addSubview:self.skipLabelView];
		[self addSubview:self.skipView];

		self.durationView = [[UIView alloc] initWithFrame:(CGRect){{0.f, 0.f}, {100.f, 40.f}}];
		self.durationView.backgroundColor = [UIColor colorWithWhite:0.1f alpha:0.7f];
		self.durationView.userInteractionEnabled = NO;

		self.durationLabelView = [[UILabel alloc] initWithFrame:(CGRect){{8.f, 0.f}, {84.f, 40.f}}];
		self.durationLabelView.textColor = [UIColor whiteColor];
		self.durationLabelView.font = [UIFont monospacedDigitSystemFontOfSize:17 weight:UIFontWeightRegular];
		self.durationLabelView.textAlignment = NSTextAlignmentCenter;
		
		self.videoControlView = [[UIImageView alloc] initWithFrame:(CGRect){CGPointZero, {40.f, 40.f}}];
		self.videoControlView.tintColor = [UIColor whiteColor];
		self.videoControlView.contentMode = UIViewContentModeCenter;
		self.videoControlView.userInteractionEnabled = YES;
		self.videoControlView.backgroundColor = [UIColor colorWithWhite:0.1f alpha:0.7f];
		
		UITapGestureRecognizer *videoControlTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
		[self.videoControlView addGestureRecognizer:videoControlTapGesture];
		
		[self updateVideoControlView:NO];
		
		[self addSubview:self.videoControlView];

		UITapGestureRecognizer *closeTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
		[self.durationView addGestureRecognizer:closeTapGesture];

		[self.durationView addSubview:self.durationLabelView];
		[self addSubview:self.durationView];

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
		
		[self addSubview:self.reportLabelView];
		
		self.soundToggleImageView = [[UIImageView alloc] initWithFrame:(CGRect){CGPointZero, {40.f, 40.f}}];
		self.soundToggleImageView.tintColor = [UIColor whiteColor];
		self.soundToggleImageView.contentMode = UIViewContentModeCenter;
		self.soundToggleImageView.userInteractionEnabled = YES;
		self.soundToggleImageView.backgroundColor = [UIColor colorWithWhite:0.1f alpha:0.7f];;
		
		[self updateToggleSoundImage];
		
		[self addSubview:self.soundToggleImageView];
		
		UITapGestureRecognizer *soundToggleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
		[self.soundToggleImageView addGestureRecognizer:soundToggleTapGesture];
		
		UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
		[tapGesture requireGestureRecognizerToFail:skipTapGesture];
		[tapGesture requireGestureRecognizerToFail:closeTapGesture];
		[tapGesture requireGestureRecognizerToFail:reportTapGesture];
		[tapGesture requireGestureRecognizerToFail:soundToggleTapGesture];
		[tapGesture requireGestureRecognizerToFail:videoControlTapGesture];
		[self addGestureRecognizer:tapGesture];
		
		UITapGestureRecognizer *tapDoubleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
		tapDoubleGesture.numberOfTapsRequired = 2;
		[self addGestureRecognizer:tapDoubleGesture];
	}
	
	return self;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];

	CGRect durationFrame = self.durationView.frame;
	durationFrame.origin.y = frame.size.height - durationFrame.size.height;
	self.durationView.frame = durationFrame;
	
	CGRect skipFrame = self.skipView.frame;
	skipFrame.origin.x = frame.size.width - skipFrame.size.width;
	skipFrame.origin.y = frame.size.height * .75f;
	self.skipView.frame = skipFrame;
	
	CGRect reportFrame = self.reportLabelView.frame;
	reportFrame.origin.x = frame.size.width - reportFrame.size.width;
	reportFrame.origin.y = 0;
	self.reportLabelView.frame = reportFrame;
	
	CGRect soundFrame = self.soundToggleImageView.frame;
	soundFrame.origin.x = frame.size.width - soundFrame.size.width;
	soundFrame.origin.y = frame.size.height - soundFrame.size.height;
	self.soundToggleImageView.frame = soundFrame;
	
	CGRect controlFrame = self.videoControlView.frame;
	controlFrame.origin.x = durationFrame.origin.x + durationFrame.size.width;
	controlFrame.origin.y = durationFrame.origin.y;
	self.videoControlView.frame = controlFrame;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture {
	if (gesture.view == self.skipView) {
		if (self.skipCallback != nil) {
			self.skipCallback();
		}
	} else if (gesture.view == self.durationView) {
		if (self.closeCallback != nil) {
			self.closeCallback();
		}
	} else if (gesture.view == self.reportLabelView) {
		if (self.reportCallback != nil) {
			self.reportCallback();
		}
	} else if (gesture.view == self.soundToggleImageView) {
		if (self.soundToggleCallback != nil) {
			bool success = self.soundToggleCallback();
			if (success) {
				[self updateToggleSoundImage];
			}
		}
	} else if (gesture.view == self.videoControlView) {
		if (self.playToggleCallback != nil) {
			bool paused = self.playToggleCallback();
			[self updateVideoControlView:paused];
		}
	} else {
		if (self.tapCallback != nil) {
			self.tapCallback();
		}
	}
}

- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)gesture {
}

- (void)updateVideoControlView:(BOOL)paused {
	CGSize size = (CGSize){20.f, 20.f};
	UIImage *image = [(paused ? SKIPlayImageWithSize(size) : SKIPauseImageWithSize(size))  imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	self.videoControlView.image = image;
}

- (void)updateToggleSoundImage {
	CGSize size = (CGSize){20.f, 20.f};
	UIImage *image = [(muted ? SKIMuteImageWithSize(size) : SKIVolumeImageWithSize(size))  imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	
	self.soundToggleImageView.image = image;
}

- (void)updateDurationTimeLabelWithDuration:(NSTimeInterval)duration currentTime:(NSTimeInterval)currentTime {
	NSTimeInterval remaining = ceil(duration - currentTime);

	NSString *durationString = [NSString stringWithFormat:@"%02d:%02d", (int)(remaining / 60) % 60, (int)remaining % 60];
	self.durationLabelView.text = durationString;
}

- (void)updateSkipTimeLabelWithOffset:(NSTimeInterval)skipOffset currentTime:(NSTimeInterval)currentTime {
//	if (skipOffset < 0.) {
//		[self hideSkip];
//		return;
//	} else
		if (skipOffset < 1.) {
		[self showSkip];
		return;
	}
	NSTimeInterval remaining = ceil(skipOffset - currentTime);
	if (remaining < 60.) {
		NSString *durationString = [NSString stringWithFormat:@"Skip in %d", (int)remaining];
		self.skipLabelView.text = durationString;
	} else {
		NSString *durationString = [NSString stringWithFormat:@"Skip in %d:%02d", (int)(remaining / 60) % 60, (int)remaining % 60];
		self.skipLabelView.text = durationString;
	}
}

- (void)showSkip {
	self.skipLabelView.text = @"Skip";
	self.skipLabelView.textColor = [UIColor whiteColor];
	
	self.skipView.userInteractionEnabled = YES;
	[self showReport];
}

- (void)hideSkip {
	self.skipView.hidden = YES;
	self.skipView.userInteractionEnabled = NO;
}

- (void)showClose {
	[UIView animateWithDuration:UINavigationControllerHideShowBarDuration
	    animations:^{
//		    self.skipView.alpha = 0.0f;
		    self.durationLabelView.alpha = 0.0f;
			self.videoControlView.alpha = 0.0f;
		}
	    completion:^(BOOL finished) {
//		    self.skipView.hidden = YES;
		    self.skipView.alpha = 1.0f;
		    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration
		        animations:^{
			        self.durationLabelView.alpha = 1.0f;
			        self.durationLabelView.text = @"Close";
			    }
		        completion:^(BOOL finished) {
			        self.durationView.userInteractionEnabled = YES;
					[self showReport];
			    }];
		}];
}

- (void)showReport {
	self.reportLabelView.hidden = NO;
}

@end

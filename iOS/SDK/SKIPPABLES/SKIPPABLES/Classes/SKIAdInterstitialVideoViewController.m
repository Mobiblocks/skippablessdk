//
//  SKIAdInterstitialViewController.m
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import "SKIAdInterstitialVideoViewController.h"

#import "SKIAdReportViewController.h"

#import <AVKit/AVKit.h>

#import "NSArray+Util.h"

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

@interface SKIAdInterstitialVideoViewLayer : UIView

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

@interface SKIAdInterstitialVideoViewController () <AVPlayerViewControllerDelegate>

@property (strong, nonatomic) AVPlayer *avPlayer;
@property (strong, nonatomic) AVPlayerViewController *avPlayerController;
@property (strong, nonatomic) SKIAdInterstitialVideoViewLayer *avPlayerControllerLayer;

@property (assign, nonatomic, readonly) SKICompactVast *compactVast;

@property (strong, nonatomic) NSPointerArray *avPlayerTimeTokens;
@property (strong, nonatomic) NSMutableArray<id<NSObject>> *avPlayerNotificationTokens;

@property (strong, nonatomic) NSMutableArray<NSURL *> *impressionTrackings;
@property (strong, nonatomic) NSMutableArray<SKICompactTrackingEvent *> *skipTrackingUrls;
@property (strong, nonatomic) NSMutableArray<SKICompactTrackingEvent *> *completeTrackingUrls;
@property (strong, nonatomic) NSMutableArray<SKICompactTrackingEvent *> *playerTrackings;

@property (assign, nonatomic) BOOL viewShownOnce;
@property (assign, nonatomic) BOOL isPlaying;
@property (assign, nonatomic) CMTime didDisappearOnTime;

@end

@implementation SKIAdInterstitialVideoViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self) {
		self.avPlayerTimeTokens = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsOpaqueMemory | NSPointerFunctionsStrongMemory];
		self.avPlayerNotificationTokens = [NSMutableArray array];
		self.impressionTrackings = [NSMutableArray array];
		self.skipTrackingUrls = [NSMutableArray array];
		self.completeTrackingUrls = [NSMutableArray array];
		self.playerTrackings = [NSMutableArray array];
		self.didDisappearOnTime = kCMTimeZero;
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

//- (void)setAd:(SKIAdInterstitial *)ad {
//	self.ad = ad
//}

- (SKICompactVast *)compactVast {
	return self.ad.response.compactVast;
}

- (void)prepareAdPlayer {
	SKIAsyncOnMain(^{
		[self prepareAdPlayerWithFail:YES];
	});
//	[self prepareAdPlayerWithFail:NO];
}

- (void)prepareAdPlayerWithFail:(BOOL)fail {
	[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
		log.idenitifier = @"adInterstitialVideoView.preparePlayer";
	}];
	
	__weak typeof(self) wSelf = self;
	SKICompactVast *compact = self.compactVast;
	SKICompactMediaFile *media = compact.ad.bestMediaFile;
	NSArray *errorTrackings = compact.inlineErrors;
	
	NSURL *mediaUrl = media.localMediaUrl ?: media.url;
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
																										 NSLocalizedDescriptionKey : @"Video data is invalid.",
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
					 //posibile race condition in observers, do another check))
					 if (wSelf.avPlayer.status != AVPlayerStatusReadyToPlay || wSelf.avPlayer.currentItem.status != AVPlayerStatusReadyToPlay) {
						 DLog(@"sec check");
						 if (fail) {
							 
							 [wSelf.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
								 log.idenitifier = @"adInterstitialVideoView.preparePlayer.error";
								 log.desc = @"Player failed to be ready in 5 seconds.";
								 log.error = error;
							 }];
							 
							 DLog(@"self.avPlayer error");
							 [wSelf trackErrorUrls:errorTrackings errorCode:SKIVASTMediaFileDisplayErrorCode];
							 [wSelf.ad.errorCollector collect:^(SKIErrorCollectorBuilder * _Nonnull err) {
								 err.type = SKIErrorCollectorTypePlayer;
								 err.place = @"prepareAdPlayerWithFail";
								 err.underlyingError = wSelf.avPlayer.error;
							 }];
							 SKIAsyncOnMain(^{
								 [wSelf closeInterstitial];
							 });
						 } else {
							 DLog(@"self.avPlayer error retry on main");
							 
							 [wSelf.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
								 log.idenitifier = @"adInterstitialVideoView.preparePlayer.error";
								 log.desc = @"Player failed to be ready in 5 seconds. Retry!!!";
								 log.error = error;
							 }];
							 
							 SKIAsyncOnMain(^{
								 [wSelf prepareAdPlayerWithFail:YES];
							 });
						 }
						 return;
					 }
				 }
				 
				 [wSelf.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
					 log.idenitifier = @"adInterstitialVideoView.preparePlayer.success";
				 }];
				 
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
	
	[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
		log.idenitifier = @"adInterstitialVideoView.preparePlayerView";
	}];

	__weak typeof(self) wSelf = self;
	SKICompactVast *compact = self.compactVast;

	NSTimeInterval durationInterval = compact.ad.duration.timeInterval;
	NSTimeInterval skipoffset = [compact.ad.skipoffset intervalOffsetFromInterval:durationInterval];
	if (skipoffset > durationInterval || compareNearlyEqual(skipoffset, durationInterval)) {
		skipoffset = -1;
		[self.avPlayerControllerLayer showSkip];
	}
	
	for (SKICompactTrackingEvent *tracking in self.playerTrackings) {
		NSString *eventName = tracking.event;

		if ([eventName isEqualToString:@"complete"]) {
			[self.completeTrackingUrls addObject:tracking];
		} else if ([eventName isEqualToString:@"skip"]) {
			[self.skipTrackingUrls addObject:tracking];
		}
	}
	
	[self.playerTrackings removeObjectsInArray:self.skipTrackingUrls];
	[self.playerTrackings removeObjectsInArray:self.completeTrackingUrls];
	
	{
		AVPlayerItem *playerItem = self.avPlayer.currentItem;
		[self addPlayerPeriodicObserver:0.5 usingBlock:^(CMTime time) {
			NSTimeInterval duration = CMTimeGetSeconds(playerItem.duration);
			NSTimeInterval currentTime = CMTimeGetSeconds(playerItem.currentTime);
			if (isnan(duration) || isnan(currentTime)) {
				return;
			}
			
			wSelf.didDisappearOnTime = time;
			
			[wSelf handlePlayerEventTick:playerItem];
			
			[wSelf.avPlayerControllerLayer updateDurationTimeLabelWithDuration:duration currentTime:currentTime];
			
			if (skipoffset > 0. && skipoffset - currentTime >= 0.) {
				[wSelf.avPlayerControllerLayer updateSkipTimeLabelWithOffset:skipoffset currentTime:currentTime];
			} else {
				[wSelf.avPlayerControllerLayer showSkip];
			}
		}];
	}

	[self addNotificationsForPlayer:self.avPlayer];
	self.avPlayerController.player = self.avPlayer;

	[self displayPlayerController];
	
	[self.avPlayerControllerLayer updateDurationTimeLabelWithDuration:durationInterval currentTime:0.];
	[self.avPlayerControllerLayer updateSkipTimeLabelWithOffset:skipoffset currentTime:0.];
	
	[self.ad interstitialViewControllerDidFinishLoading:self];
	
	[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
		log.idenitifier = @"adInterstitialVideoView.preparePlayerView.success";
	}];
}

- (void)sendInitialEvents {
	NSMutableArray *ident = [NSMutableArray array];
	for (NSURL *url in self.impressionTrackings) {
		NSString *identifier = SKIUUID();
		[ident addObject:@{
						   @"identifier": identifier,
						   @"url": url.absoluteString ?: [NSNull null]
						   }];
		[self trackUrl:url playhead:0.0 identifier:identifier];
	}
	
	[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
		log.idenitifier = @"adInterstitialVideoView.sendImpressions";
		log.info = @{
					 @"impressions": ident ?: [NSNull null]
					 };
	}];
	[self.impressionTrackings removeAllObjects];
}

- (void)handlePlayerEventTick:(AVPlayerItem *)playerItem {
	NSTimeInterval duration = CMTimeGetSeconds(playerItem.duration);
	NSTimeInterval currentTime = CMTimeGetSeconds(playerItem.currentTime);
	if (isnan(duration) || isnan(currentTime)) {
		return;
	}
	
	NSMutableArray<SKICompactTrackingEvent *> *removeTrackings = [NSMutableArray array];
	for (SKICompactTrackingEvent *tracking in self.playerTrackings) {
		NSURL *eventUrl = tracking.url;
		if (eventUrl == nil) {
			[removeTrackings addObject:tracking];
			continue;
			
		}
		NSString *eventName = tracking.event;
		NSString *eventOffset = tracking.offset;
		NSDate *durationDate = [NSDate dateWithTimeIntervalSinceReferenceDate:duration];
		
		NSTimeInterval eventInterval = 0.;
		if ([eventName isEqualToString:@"start"]) {
			eventInterval = SKITrackingEventWithOffsetInterval(eventOffset, durationDate);
			if (eventInterval < 0.0) {
				eventInterval = 0.0;
			}
		} else if ([eventName isEqualToString:@"firstQuartile"]) {
			eventInterval = SKITrackingEventFirstQuartileInterval(durationDate);
		} else if ([eventName isEqualToString:@"midpoint"]) {
			eventInterval = SKITrackingEventMidpointInterval(durationDate);
		} else if ([eventName isEqualToString:@"thirdQuartile"]) {
			eventInterval = SKITrackingEventThirdQuartileInterval(durationDate);
		} else if ([eventName isEqualToString:@"progress"]) {
			eventInterval = SKITrackingEventWithOffsetInterval(eventOffset, durationDate);
			if (eventInterval < 0.0) {
				[removeTrackings addObject:tracking];
				continue;
			}
		} else {
			continue;
		}
		
		if (currentTime >= eventInterval) {
			
			DLog(@"%@\t%.02f : %.02f : %.02f\t%@", eventName, (float)duration, (float)currentTime, (float)eventInterval, eventOffset);
			NSString *identifier = SKIUUID();
			[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
				log.idenitifier = @"adInterstitialVideoView.sendEvent";
				log.info = @{
							 @"events": @[@{
										 @"identifier": identifier,
										 @"event": eventName ?: [NSNull null],
										 @"url": eventUrl.absoluteString ?: [NSNull null]
										 }],
							 @"contentPlayhead": @(eventInterval)
							 };
			}];
			
			[removeTrackings addObject:tracking];
			
			[self trackUrl:eventUrl playhead:eventInterval identifier:identifier];
		}
	}
	
	[self.playerTrackings removeObjectsInArray:removeTrackings];
}

- (void)sendSkipEvents {
	NSTimeInterval contentPlayhead = CMTimeGetSeconds(self.avPlayer.currentItem.currentTime);
	NSMutableArray *ident = [NSMutableArray array];
	
	if (self.skipTrackingUrls.count > 0) {
		for (SKICompactTrackingEvent *tracking in self.skipTrackingUrls) {
			NSURL *eventUrl = tracking.url;
			if (eventUrl == nil) {
				continue;
				
			}
			NSString *identifier = SKIUUID();
			[ident addObject:@{
							   @"identifier": identifier,
							   @"url": eventUrl.absoluteString ?: [NSNull null]
							   }];
			[self trackUrl:eventUrl playhead:contentPlayhead identifier:identifier];
		}
		
		[self.skipTrackingUrls removeAllObjects];
	}
	
	[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
		log.idenitifier = @"adInterstitialVideoView.sendSkips";
		log.info = @{
					 @"skips": ident ?: [NSNull null],
					 @"contentPlayhead": @(contentPlayhead)
					 };
	}];
}

- (void)sendCompletedEvents {
	NSMutableArray *ident = [NSMutableArray array];
	NSTimeInterval contentPlayhead = CMTimeGetSeconds(self.avPlayer.currentItem.currentTime);
	
	if (self.completeTrackingUrls.count > 0) {
		for (SKICompactTrackingEvent *tracking in self.completeTrackingUrls) {
			NSURL *eventUrl = tracking.url;
			if (eventUrl == nil) {
				continue;
				
			}
			NSString *identifier = SKIUUID();
			[ident addObject:@{
							   @"identifier": identifier,
							   @"url": eventUrl.absoluteString ?: [NSNull null]
							   }];
			[self trackUrl:eventUrl playhead:contentPlayhead identifier:identifier];
		}
		
		[self.completeTrackingUrls removeAllObjects];
	}
	
	[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
		log.idenitifier = @"adInterstitialVideoView.sendCompleted";
		log.info = @{
					 @"completed": ident ?: [NSNull null],
					 @"contentPlayhead": @(contentPlayhead)
					 };
	}];
}

- (void)addPlayerPeriodicObserver:(NSTimeInterval)seconds usingBlock:(void (^)(CMTime time))block {
	id token = [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(seconds, 1000) queue:nil usingBlock:block];

	[self.avPlayerTimeTokens addPointer:(__bridge void *)token];
}

- (AVPlayerViewController *)avPlayerController {
	if (!_avPlayerController) {
		_avPlayerController = [[AVPlayerViewController alloc] initWithNibName:nil bundle:nil];
		_avPlayerController.player = self.avPlayer;
		_avPlayerController.delegate = self;
		_avPlayerController.showsPlaybackControls = NO;

		__weak typeof(self) wSelf = self;
		self.avPlayerControllerLayer = [SKIAdInterstitialVideoViewLayer layer];
		[self.avPlayerControllerLayer setTapCallback:^{
			[wSelf.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
				log.idenitifier = @"adInterstitialVideoView.userClick";
			}];
			if ([wSelf handleClickThrough]) {
				wSelf.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
				[wSelf closeInterstitial];
			}
		}];
		[self.avPlayerControllerLayer setSkipCallback:^{
			[wSelf.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
				log.idenitifier = @"adInterstitialVideoView.userSkip";
			}];
			[wSelf sendSkipEvents];
			[wSelf closeInterstitial];
		}];
		[self.avPlayerControllerLayer setCloseCallback:^{
			[wSelf.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
				log.idenitifier = @"adInterstitialVideoView.userClose";
			}];
			[wSelf closeInterstitial];
		}];
		[self.avPlayerControllerLayer setReportCallback:^{
			[wSelf.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
				log.idenitifier = @"adInterstitialVideoView.userReport";
			}];
			if (wSelf) {
				[SKIAdReportViewController showFromViewController:wSelf callback:^(BOOL canceled, NSString * _Nullable email, NSString * _Nullable message) {
					if (canceled) {
						return;
					}
					
					[[SKIAdEventTracker defaultTracker] sendReportWithDeviceData:wSelf.ad.response.deviceInfo
																			adId:wSelf.compactVast.ad.identifier
																		adUnitId:wSelf.ad.adUnitID
																		   email:email
																		 message:message];
					
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
			
			[wSelf.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
				log.idenitifier = [NSString stringWithFormat:@"adInterstitialVideoView.player.user%@", muted ? @"Mute" : @"Unmute"];
			}];
			
			return true;
		}];
		[self.avPlayerControllerLayer setPlayToggleCallback:^bool{
			if (!wSelf.avPlayer) {
				return false;
			}
			
			if (wSelf.isPlaying) {
				wSelf.isPlaying = NO;
				[wSelf.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
					log.idenitifier = @"adInterstitialVideoView.player.userPause";
				}];
				[wSelf.avPlayer pause];
				return true;
			}
			
			wSelf.isPlaying = YES;
			[wSelf.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
				log.idenitifier = @"adInterstitialVideoView.player.userPlay";
			}];
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
									[wSelf.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
										log.idenitifier = @"adInterstitialVideoView.player.completed";
									}];
									wSelf.didDisappearOnTime = kCMTimeZero;
									DLog(@"AVPlayerItemDidPlayToEndTimeNotification: %@", note.userInfo);
									[wSelf sendCompletedEvents];
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
									id obj = note.userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey];
									if ([obj isKindOfClass:[NSError class]]) {
										[wSelf.ad.errorCollector collect:^(SKIErrorCollectorBuilder * _Nonnull err) {
											err.type = SKIErrorCollectorTypePlayer;
											err.place = @"AVPlayerItemFailedToPlayToEndTimeNotification";
											err.underlyingError = (NSError *)obj;
										}];
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
	SKICompactVast *compact = self.compactVast;
	NSTimeInterval contentPlayhead = CMTimeGetSeconds(self.avPlayer.currentItem.currentTime);
	
	NSMutableArray *ident = [NSMutableArray array];
	if (compact.ad.videoClicks.count > 0) {
		for (NSURL *url in compact.ad.videoClicks) {
			NSString *identifier = SKIUUID();
			[ident addObject:@{
							   @"identifier": identifier,
							   @"url": url.absoluteString ?: [NSNull null]
							   }];
			[self trackUrl:url playhead:contentPlayhead identifier:identifier];
		}
	}
	
	[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
		log.idenitifier = @"adInterstitialVideoView.sendClicks";
		log.info = @{
					 @"clicks": ident ?: [NSNull null],
					 @"contentPlayhead": @(contentPlayhead)
					 };
	}];
	
	NSURL *url = compact.ad.clickThrough;
	if (!url) {
		return NO;
	}
	
	if ([[UIApplication sharedApplication] openURL:url]) {
		if ([self.ad.delegate respondsToSelector:@selector(skiInterstitialWillLeaveApplication:)]) {
			[self.ad.delegate skiInterstitialWillLeaveApplication:self.ad];
		}
		[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
			log.idenitifier = @"adInterstitialVideoView.openClickThrough";
			log.desc = @"Report to user.";
			log.info = @{
						 @"url": url.absoluteString ?: [NSNull null],
						 @"method": @"skiInterstitialWillLeaveApplication:",
						 @"delegateIsSet": @(self.ad.delegate != nil)
						 };
		}];
		
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
	[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
		log.idenitifier = @"adInterstitialVideoView.close";
		log.desc = @"Report to user.";
		log.info = @{
					 @"method": @"skiInterstitialWillDismiss:",
					 @"delegateIsSet": @(self.ad.delegate != nil)
					 };
	}];
	
	NSURL *localUrl = self.compactVast.ad.bestMediaFile.localMediaUrl;
	
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

- (void)trackUrl:(NSURL *)url playhead:(NSTimeInterval)playhead identifier:(NSString *)str {
	NSURL *assetUrl = self.compactVast.ad.bestMediaFile.url;
	NSURL *macrosed = [SKIVASTUrl urlFromUrlAfterReplacingMacros:url
														 builder:^(SKIVASTUrlMacroValues *_Nonnull macroValues) {
															 macroValues.contentPlayhead = playhead;
															 macroValues.assetUrl = assetUrl;
														 }];
	if (macrosed) {
		[[SKIAdEventTracker defaultTracker] trackEvent:^(SKIAdEventTrackerBuilder * _Nonnull e) {
			e.url = macrosed;
			e.logError = self.ad.logErrors;
			e.logSession = self.ad.sessionLogger.canLog;
			e.identifier = str;
			e.sessionID = self.ad.errorCollector.sessionID;
		}];
	} else {
		[self.ad.errorCollector collect:^(SKIErrorCollectorBuilder * _Nonnull err) {
			err.type = SKIErrorCollectorTypeOther;
			err.place = @"trackUrl.macros";
			err.desc = @"Failed to apply macros";
			err.otherInfo = @{
							  @"url": url ?: [NSNull null],
							  @"assetUrl": assetUrl ?: [NSNull null]
							  };
		}];
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
		[[SKIAdEventTracker defaultTracker] trackEvent:^(SKIAdEventTrackerBuilder * _Nonnull e) {
			e.url = macrosed;
			e.logError = self.ad.logErrors;
			e.logSession = self.ad.sessionLogger.canLog;
			e.sessionID = self.ad.errorCollector.sessionID;
		}];
	} else {
		[self.ad.errorCollector collect:^(SKIErrorCollectorBuilder * _Nonnull err) {
			err.type = SKIErrorCollectorTypeOther;
			err.place = @"trackErrorUrl.macros";
			err.desc = @"Failed to apply macros";
			err.otherInfo = @{
							  @"url": url ?: [NSNull null],
							  @"errorCode": @(errorCode)
							  };
		}];
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

	if (self.compactVast.impressions) {
		[self.impressionTrackings addObjectsFromArray:self.compactVast.impressions];
	}
	
	if (self.compactVast.ad.trackingEvents) {
		[self.playerTrackings addObjectsFromArray:self.compactVast.ad.trackingEvents];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (!_viewShownOnce) {
		[self prepareAdPlayer];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
		log.idenitifier = @"adInterstitialVideoView.didAppear";
	}];
	
	if (!_viewShownOnce) {
		[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
			log.idenitifier = @"adInterstitialVideoView.player.play";
		}];
		[self.avPlayer play];
		self.isPlaying = YES;
		
		_viewShownOnce = YES;
		[self sendInitialEvents];
	} else {
		//		wSelf.didDisappearOnTime = kCMTimeZero;
		if (CMTimeCompare(self.didDisappearOnTime, kCMTimeZero) != NO) {
			[self.avPlayer seekToTime:self.didDisappearOnTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
			self.didDisappearOnTime = kCMTimeZero;
		}
	}
	
	DLog(@"");
}

- (void)applicationDidBecomeActive:(BOOL)previouslyVisible {
	[super applicationDidBecomeActive:previouslyVisible];
	
	[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
		log.idenitifier = @"adInterstitialVideoView.applicationDidBecomeActive";
	}];
	
	if (_viewShownOnce) {
		if (CMTimeCompare(self.didDisappearOnTime, kCMTimeZero) != NO) {
			CMTime newTime = CMTimeSubtract(self.didDisappearOnTime, CMTimeMakeWithSeconds(0.5, 1000));
			if (CMTIME_IS_VALID(newTime)) {
				[self.avPlayer seekToTime:newTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
			} else {
				[self.avPlayer seekToTime:self.didDisappearOnTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
			}
			
			self.didDisappearOnTime = kCMTimeZero;
		}
	}
	
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
	
	[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
		log.idenitifier = @"adInterstitialVideoView.willDisappear";
	}];
	
	if (self.isPlaying) {
		[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
			log.idenitifier = @"adInterstitialVideoView.player.pause";
		}];
	}

	[self.avPlayer pause];
	self.isPlaying = NO;
}

- (void)applicationWillResignActive:(BOOL)previouslyVisible {
	[super applicationWillResignActive:previouslyVisible];
	
	[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
		log.idenitifier = @"adInterstitialVideoView.applicationWillResignActive";
	}];
	if (self.isPlaying) {
		[self.ad.sessionLogger build:^(SKISDKSessionLog * _Nonnull log) {
			log.idenitifier = @"adInterstitialVideoView.player.pause";
		}];
	}
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
		if (self.compactVast.ad.maybeShownInLandscape) {
			return SKIiSPortrait();
		}
	
		return SKIiSLandscape();
//	}
	
//	return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//	if (SKIiSiPhone()) {
		if (self.compactVast.ad.maybeShownInLandscape) {
			return UIInterfaceOrientationMaskAllButUpsideDown;
		}
		
		return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
//	}
	
//	return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//	if (SKIiSiPhone()) {
		if (!self.compactVast.ad.maybeShownInLandscape) {
			return UIInterfaceOrientationPortrait;
		}
//	}
	
	return SKICurrentOrientation();
}

- (void)dealloc {
	
}

@end

@implementation SKIAdInterstitialVideoViewLayer

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
	NSTimeInterval remaining = ceil(skipOffset - MAX(currentTime, 0));
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

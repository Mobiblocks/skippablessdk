//
//  SKIVASTCompressedCreative.m
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import "SKIVASTCompressedCreative.h"

#import "SKIConstants.h"
#import "NSArray+Util.h"

//@implementation SKIVASTCompressedCreative
//
//+ (instancetype)compressed {
//	return [[self alloc] init];
//}
//
//- (BOOL)maybeShownInLandscape {
//	if (!SKIMaybeSupportsLanscapeOrientation()) {
//		return NO;
//	}
//	
//	CGFloat mediaWidth = self.mediaFile.width.floatValue;
//	CGFloat mediaHeight = self.mediaFile.height.floatValue;
//	
//	if (mediaWidth > mediaHeight) {
////		CGFloat ratio = mediaWidth / mediaHeight;
////		if (ratio > 1.50) {
//			return YES;
////		}
//	}
//	
//	return NO;
//}
//
//- (BOOL)hasLandscapeOrientation:(NSArray<NSString *> *)orientations {
//	for (NSString *orientationString in orientations) {
//		if ([orientationString isEqualToString:@"UIInterfaceOrientationLandscapeLeft"]) {
//			return YES;
//		} else if ([orientationString isEqualToString:@"UIInterfaceOrientationLandscapeRight"]) {
//			return YES;
//		}
//	}
//	
//	return NO;
//}
//
//- (NSDate *)duration {
//	if (self.nonLinear) {
//		return nil;
//	}
//	
//	SKIVASTCreativeInlineChild *creativeInline = (SKIVASTCreativeInlineChild *)self.creative;
//	
//	return creativeInline.linear.duration;
//}
//
//- (NSString *)skipoffset {
//	if (self.nonLinear) {
//		return nil;
//	}
//	
//	SKIVASTCreativeInlineChild *creativeInline = (SKIVASTCreativeInlineChild *)self.creative;
//	
//	return creativeInline.linear.skipoffset;
//}
//
//- (NSArray<SKIVASTTracking *> *)trackings {
//	if (self.nonLinear) {
//		return nil;
//	}
//	
//	SKIVASTCreativeInlineChild *creativeInline = (SKIVASTCreativeInlineChild *)self.creative;
//	
//	return creativeInline.linear.trackingEvents.trackings;
//}
//
//- (SKIVASTClickThrough *)clickThrough {
//	if (self.nonLinear) {
//		return nil;
//	}
//	
//	SKIVASTCreativeInlineChild *creativeInline = (SKIVASTCreativeInlineChild *)self.creative;
//	
//	return creativeInline.linear.videoClicks.clickThrough;
//}
//
//- (NSArray<SKIVASTClickTracking *> *)clickTrackings {
//	if (self.nonLinear) {
//		return nil;
//	}
//	
//	SKIVASTCreativeInlineChild *creativeInline = (SKIVASTCreativeInlineChild *)self.creative;
//	
//	return creativeInline.linear.videoClicks.clickTrackings;
//}
//
//@end

@interface SKICompactVast ()

+ (instancetype)defaults;

@property (strong, nonatomic, readwrite, nullable) NSArray<NSURL *> *errors;
@property (strong, nonatomic, readwrite, nullable) NSArray<NSURL *> *inlineErrors;
@property (strong, nonatomic, readwrite, nullable) NSArray<NSURL *> *impressions;
@property (assign, nonatomic, readwrite) BOOL isWrapper;
@property (strong, nonatomic, readwrite) SKICompactVastAd* ad;

@end

@interface SKICompactVastAd ()

+ (instancetype)defaults;

@property (strong, nonatomic, readwrite, nullable) SKICompactMediaFile *_bestMediaFile;

@property (copy, nonatomic, readwrite, nullable) NSString *identifier;
@property (strong, nonatomic, readwrite, nonnull) SKIVastTime *duration;
@property (strong, nonatomic, readwrite, nullable) SKIVastTime *skipoffset;

@property (strong, nonatomic, readwrite, nullable) NSURL *clickThrough;
@property (strong, nonatomic, readwrite, nullable) NSArray<NSURL *> *videoClicks;
@property (strong, nonatomic, readwrite, nullable) NSArray<SKICompactMediaFile *> *mediaFiles;
@property (strong, nonatomic, readwrite, nullable) NSArray<SKICompactTrackingEvent *> *trackingEvents;

@end

@interface SKICompactMediaFile ()

@property (copy, nonatomic, readwrite, nullable) NSString *identifier; // id
@property (copy, nonatomic, readwrite) NSString *type;
@property (copy, nonatomic, readwrite) NSString *delivery;
@property (assign, nonatomic, readwrite) CGFloat width;
@property (assign, nonatomic, readwrite) CGFloat height;
@property (strong, nonatomic, readwrite) NSURL *url;

@end

@interface SKICompactTrackingEvent ()

@property (copy, nonatomic, readwrite, nullable) NSString *event;
@property (copy, nonatomic, readwrite, nullable) NSString *offset;
@property (copy, nonatomic, readwrite) NSURL *url;

@end

@interface SKIVastTime ()

@property (strong, nonatomic, readwrite, nullable) NSNumber *percents;
@property (strong, nonatomic, readwrite, nullable) NSDate *timeDate;

@end

@implementation SKICompactVast

SKICompactVast *compact(SKIVASTVAST *vast, NSError **error);
SKICompactVast *_compact(SKIVASTVAST *vast, SKICompactVast *compact, NSError **error);

SKICompactVast *compact(SKIVASTVAST *vast, NSError **error) {
	SKICompactVast *compact = [SKICompactVast defaults];
	
	// -- case where the first vast does not containe and ad -> SKIVASTNoErrorCode
	//    other cases will have -> SKIVASTGeneralWrapperErrorCode
	SKIVASTAd *ad = vast.ads.firstObject;
	if (ad == nil || (ad.inLine == nil && ad.wrapper == nil)) {
		if (vast.error) {
			compact.errors = [compact.errors arrayByAddingObject:vast.error];
		}
		if (error != nil) {
			*error = [[NSError alloc] initWithDomain:@"com.mobiblocks.skippables" code:SKIVASTNoErrorCode userInfo:nil];
		}
		
		return compact;
	}
	// --
	
	compact.ad.identifier = ad.identifier;
	
	return _compact(vast, compact, error);
}
SKICompactVast *_compact(SKIVASTVAST *vast, SKICompactVast *compact, NSError **error) {
	if (vast.error) {
		compact.errors = [compact.errors arrayByAddingObject:vast.error];
	}
	
	SKIVASTAd *ad = vast.ads.firstObject;
	if (ad == nil) {
		if (error != nil) {
			*error = [[NSError alloc] initWithDomain:@"com.mobiblocks.skippables" code:SKIVASTGeneralWrapperErrorCode userInfo:nil];
		}
		return compact;
	}
	
	if (ad.inLine != nil) {
		SKIVASTInline *inl = ad.inLine;
		
		if (inl.error) {
			compact.inlineErrors = [compact.inlineErrors arrayByAddingObject:inl.error];
		}
		if (inl.impressions.count > 0) {
			NSArray *impressions = [inl.impressions _skiCompactMap:^NSObject *(SKIVASTImpression *obj) {
				return obj.value;
			}];
			
			compact.impressions = [compact.impressions arrayByAddingObjectsFromArray:impressions];
		}
		
		SKIVASTLinearInlineChild *linear = inl.creatives.creatives.firstObject.linear;
		if (linear == nil) {
			return compact;
		}
		
		compact.ad.skipoffset = [SKIVastTime vastTimeFromString:linear.skipoffset];
		compact.ad.duration = [SKIVastTime vastTimeFromDate:linear.duration];
		if (linear.mediaFiles.mediaFiles) {
			compact.ad.mediaFiles = [linear.mediaFiles.mediaFiles _skiCompactMap:^NSObject *(SKIVASTMediaFile *obj) {
				if (obj.value == nil || obj.type == nil) {
					return nil;
				}
				
				SKICompactMediaFile *media = [[SKICompactMediaFile alloc] init];
				media.identifier = obj.identifier;
				media.type = obj.type;
				media.delivery = obj.delivery;
				media.width = obj.width.floatValue;
				media.height = obj.height.floatValue;
				media.url = obj.value;
				
				return media;
			}];
			
			if (compact.ad.mediaFiles.count == 0) {
				if (error != nil) {
					*error = [[NSError alloc] initWithDomain:@"com.mobiblocks.skippables" code:SKIVASTMediaFileNotSupportedErrorCode userInfo:nil];
				}
				
				return compact;
			}
		}
		if (linear.trackingEvents.trackings) {
			NSArray *trackings = [linear.trackingEvents.trackings _skiCompactMap:^NSObject *(SKIVASTTracking *obj) {
				if (obj.value == nil) {
					return nil;
				}
				
				SKICompactTrackingEvent *event = [[SKICompactTrackingEvent alloc] init];
				event.event = obj.event;
				event.offset = obj.offset;
				event.url = obj.value;
				
				return event;
			}];
			
			compact.ad.trackingEvents = [compact.ad.trackingEvents arrayByAddingObjectsFromArray:trackings];
		}
		if (linear.videoClicks) {
			compact.ad.clickThrough = linear.videoClicks.clickThrough.value;
			if (linear.videoClicks.clickTrackings) {
				NSArray *trackings = [linear.videoClicks.clickTrackings _skiCompactMap:^NSObject *(SKIVASTClickTracking *obj) {
					return obj.value;
				}];
				
				compact.ad.videoClicks = [compact.ad.videoClicks arrayByAddingObjectsFromArray:trackings];
			}
		}
	} else if (ad.wrapper) {
		SKIVASTWrapper *wrapper = ad.wrapper;
		if (wrapper.error) {
			compact.inlineErrors = [compact.inlineErrors arrayByAddingObject:wrapper.error];
		}
		if (wrapper.impressions.count > 0) {
			NSArray *impressions = [wrapper.impressions _skiCompactMap:^NSObject *(SKIVASTImpression *obj) {
				return obj.value;
			}];
			
			compact.impressions = [compact.impressions arrayByAddingObjectsFromArray:impressions];
		}
		
		SKIVASTLinearInlineChild *linear = wrapper.creatives.creatives.firstObject.linear;
		if (linear.trackingEvents.trackings) {
			NSArray *trackings = [linear.trackingEvents.trackings _skiCompactMap:^NSObject *(SKIVASTTracking *obj) {
				if (obj.value == nil) {
					return nil;
				}
				
				SKICompactTrackingEvent *event = [[SKICompactTrackingEvent alloc] init];
				event.event = obj.event;
				event.offset = obj.offset;
				event.url = obj.value;
				
				return event;
			}];
			
			compact.ad.trackingEvents = [compact.ad.trackingEvents arrayByAddingObjectsFromArray:trackings];
		}
		if (linear.videoClicks) {
			if (linear.videoClicks.clickTrackings) {
				NSArray *trackings = [linear.videoClicks.clickTrackings _skiCompactMap:^NSObject *(SKIVASTClickTracking *obj) {
					return obj.value;
				}];
				
				compact.ad.videoClicks = [compact.ad.videoClicks arrayByAddingObjectsFromArray:trackings];
			}
		}
		
		if (wrapper.wrappedVast) {
			compact = _compact(wrapper.wrappedVast, compact, error);
		} else {
			if (error != nil) {
				*error = [[NSError alloc] initWithDomain:@"com.mobiblocks.skippables" code:SKIVASTWrapperNoVastErrorCode userInfo:nil];
			}
			
			return compact;
		}
	} else {
		if (error != nil) {
			*error = [[NSError alloc] initWithDomain:@"com.mobiblocks.skippables" code:SKIVASTGeneralWrapperErrorCode userInfo:nil];
		}
	}
	
	return compact;
}

+ (instancetype)defaults {
	SKICompactVast *compact = [[SKICompactVast alloc] init];
	compact.errors = @[];
	compact.inlineErrors = @[];
	compact.impressions = @[];
	compact.ad = [SKICompactVastAd defaults];
	
	return compact;
}

+ (SKICompactVast *)compact:(SKIVASTVAST *)vast error:(NSError *__autoreleasing *)error {
	if (vast == nil) {
		if (error != nil) {
			*error = [[NSError alloc] initWithDomain:@"com.mobiblocks.general" code:-1000 userInfo:nil];
		}
		
		return nil;
	}
	
	return compact(vast, error);
}

- (NSDictionary *)dictionaryValue {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	dict[@"errors"] = [self.errors _skiCompactMap:^NSObject *(NSURL *obj) {
		return obj.absoluteString;
	}] ?: [NSNull null];
	dict[@"inlineErrors"] = [self.inlineErrors _skiCompactMap:^NSObject *(NSURL *obj) {
		return obj.absoluteString;
	}] ?: [NSNull null];
	dict[@"impressions"] = [self.impressions _skiCompactMap:^NSObject *(NSURL *obj) {
		return obj.absoluteString;
	}] ?: [NSNull null];
	dict[@"isWrapper"] = @(self.isWrapper);
	
	dict[@"ad"] = self.ad.dictionaryValue ?: [NSNull null];
	
	return dict;
}

@end

@implementation SKICompactVastAd

+ (instancetype)defaults {
	SKICompactVastAd *ad = [[SKICompactVastAd alloc] init];
	ad.videoClicks = @[];
	ad.mediaFiles = @[];
	ad.trackingEvents = @[];
	
	return ad;
}

- (BOOL)maybeShownInLandscape {
	if (!SKIMaybeSupportsLanscapeOrientation() || self.bestMediaFile == nil) {
		return NO;
	}
	
	CGFloat mediaWidth = self.bestMediaFile.width;
	CGFloat mediaHeight = self.bestMediaFile.height;
	
	if (mediaWidth > mediaHeight) {
		return YES;
	}
	
	return NO;
}

- (NSDictionary *)dictionaryValue {
	NSMutableDictionary *addict = [NSMutableDictionary dictionary];
	
	if (self.duration) {
		addict[@"duration"] = self.duration.asJSONValue ?: [NSNull null];
	}
	if (self.skipoffset) {
		addict[@"skipoffset"] = self.skipoffset.asJSONValue ?: [NSNull null];
	}
	if (self.clickThrough) {
		addict[@"clickThrough"] = self.clickThrough.absoluteString ?: [NSNull null];
	}
	if (self.videoClicks.count > 0) {
		addict[@"videoClicks"] = [self.videoClicks _skiCompactMap:^NSObject *(NSURL *obj) {
			return obj.absoluteString;
		}];
	}
	if (self.mediaFiles.count > 0) {
		addict[@"mediaFiles"] = [self.mediaFiles _skiCompactMap:^NSObject *(SKICompactMediaFile *obj) {
			return obj.dictionaryValue;
		}];
	}
	if (self.trackingEvents.count > 0) {
		addict[@"trackingEvents"] = [self.trackingEvents _skiCompactMap:^NSObject *(SKICompactTrackingEvent *obj) {
			return obj.dictionaryValue;
		}];
	}
	
	return addict;
}

- (SKICompactMediaFile *)bestMediaFile {
	if (__bestMediaFile) {
		return __bestMediaFile;
	}
	
	static NSArray *supportedMimes = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		supportedMimes = @[@"video/mp4", @"video/quicktime", @"video/x-m4v", @"video/3gpp", @"video/3gpp2"];
	});
	
	NSArray<SKICompactMediaFile *> *usable = [[self.mediaFiles _skiCompactMap:^NSObject * _Nonnull(SKICompactMediaFile * _Nonnull obj) {
		if (obj.type && [supportedMimes containsObject:obj.type]) {
			return obj;
		}
		
		return nil;
	}] sortedArrayUsingComparator:^NSComparisonResult(SKICompactMediaFile *_Nonnull obj1, SKICompactMediaFile *_Nonnull obj2) {
		CGFloat m1 = obj1.width * obj1.height;
		CGFloat m2 = obj2.width * obj2.height;
		
		if (m1 == m2) {
			return NSOrderedSame;
		} else if (m1 > m2) {
			return NSOrderedDescending;
		} else if (m1 < m2) {
			return NSOrderedAscending;
		} else {
			return NSOrderedSame; // LOL))
		}
	}];
	
	if (usable.count < 2) {
		return usable.firstObject;
	}
	
	CGFloat screenScale = 1;//[[UIScreen mainScreen] scale];
	CGSize screenSize = CGSizeZero;
	if (SKISupportsPortraitOnlyOrientation() || SKIiSPortrait()) {
		screenSize = SKIScreenBounds().size;
	} else if (SKISupportsLanscapeOnlyOrientation() || SKIiSLandscape()) {
		screenSize = SKIScreenBounds().size;
	} else {
		screenSize = SKIOrientationIndependentScreenBounds().size;
	}
	
	//	kSKIRTBConnectionTypeUnknown         = 0,   ///< Unknown.
	//	kSKIRTBConnectionTypeEthernet        = 1,   ///< Ethernet.
	//	kSKIRTBConnectionTypeWIFI            = 2,   ///< WiFi.
	//	kSKIRTBConnectionTypeCellularUnknown = 3,   ///< Cellular Network – Unknown Generation.
	//	kSKIRTBConnectionTypeCellular2G      = 4,   ///< Cellular Network – 2G.
	//	kSKIRTBConnectionTypeCellular3G      = 5,   ///< Cellular Network – 3G.
	//	kSKIRTBConnectionTypeCellular4G      = 6,   ///< Cellular Network – 4G.
	SKIRTBConnectionType connectionType = SKIConnectionType();
	switch (connectionType) {
		case kSKIRTBConnectionTypeEthernet:
		case kSKIRTBConnectionTypeWIFI:
			screenSize.width *= screenScale;
			screenSize.height *= screenScale;
			break;
		case kSKIRTBConnectionTypeCellular4G:
			if (screenScale > 1.) {
				screenSize.width *= 1.5;
				screenSize.height *= 1.5;
			}
			break;
			
		default:
			break;
	}
	
	CGFloat widthWeight = 1;
	CGFloat heightWeight = 1;
	if (screenSize.width > screenSize.height) {
		heightWeight = 1.5f;
	} else if (screenSize.width < screenSize.height) {
		widthWeight = 1.5f;
	}
	
	NSMutableDictionary<NSNumber *, SKICompactMediaFile *> *pointedMediaFiles = [NSMutableDictionary dictionary];
	
	CGFloat screenRatio = MAX(screenSize.width, screenSize.height) / MIN(screenSize.width, screenSize.height);
	CGFloat screenPixels = screenSize.width - screenSize.height;
	
#ifdef DEBUG
	NSMutableString *pointLogger = [NSMutableString string];
	[pointLogger appendString:@"\n-----------------\n"];
	[pointLogger appendFormat:@"%dx%d %d - w:%f h:%f r:%f\n", (int)screenSize.width, (int)screenSize.height, (int)screenPixels, widthWeight, heightWeight, screenRatio];
#endif
	
	for (SKICompactMediaFile *mediaFile in usable) {
		CGFloat currentWidth = mediaFile.width;
		CGFloat currentHeight = mediaFile.height;
		
		CGFloat currentRatio = MAX(currentWidth, currentHeight) / MIN(currentWidth, currentHeight);
		CGFloat currentPixels = currentWidth - currentHeight;
		
		CGFloat ratioDiff = ABS(screenRatio - currentRatio);
		CGFloat widthDiff = ABS(screenSize.width - currentWidth);
		CGFloat heightDiff = ABS(screenSize.height - currentHeight);
		CGFloat pixelsDiff = ABS(screenPixels - currentPixels);
		
		NSInteger pointRatio = round(ratioDiff * 100.);
		NSInteger pointWidth = round(widthDiff / 100. * widthWeight);
		NSInteger pointHeight = round(heightDiff / 100. * heightWeight);
		NSInteger pointPixels = round(pixelsDiff / 100. * 1);
		
		NSInteger pointAcumm = pointRatio + pointWidth + pointHeight + pointPixels;
		pointedMediaFiles[@(pointAcumm)] = mediaFile;
		
#ifdef DEBUG
		[pointLogger appendString:@"-----------------\n"];
		[pointLogger appendFormat:@"%dx%d p:%d pd:%d - r:%f rd:%f wd:%f hd:%f rp:%d rpw:%d, rph:%d ppx:%d pa:%d\n", (int)currentWidth, (int)currentHeight, (int)currentPixels, (int)pixelsDiff, currentRatio, ratioDiff, screenSize.width - currentWidth, screenSize.height - currentHeight, (int)pointRatio, (int)pointWidth, (int)pointHeight, (int)pointPixels, (int)pointAcumm];
		[pointLogger appendString:@"-----------------\n"];
#endif
	}
	
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
	NSArray *sortedKeys = [pointedMediaFiles.allKeys sortedArrayUsingDescriptors:@[sortDescriptor]];
	SKICompactMediaFile *mediaFile = pointedMediaFiles[sortedKeys.firstObject];
	
#ifdef DEBUG
	[pointLogger appendString:@"-----------------\n"];
	[pointLogger appendString:mediaFile.debugDescription];
	[pointLogger appendString:@"\n-----------------\n"];
	DLog(@"%@", pointLogger);
#endif
	
	__bestMediaFile = mediaFile;
	
	return mediaFile;
}

@end

@implementation SKICompactMediaFile

- (NSDictionary *)dictionaryValue {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	if (self.identifier) {
		dict[@"identifier"] = self.identifier;
	}
	if (self.type) {
		dict[@"type"] = self.type;
	}
	if (self.delivery) {
		dict[@"delivery"] = self.delivery;
	}
	if (self.width) {
		dict[@"width"] = @(self.width);
	}
	if (self.height) {
		dict[@"height"] = @(self.height);
	}
	if (self.url) {
		dict[@"url"] = self.url.absoluteString ?: [NSNull null];
	}
	
	return dict;
}

@end

@implementation SKICompactTrackingEvent

- (NSDictionary *)dictionaryValue {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	if (self.event) {
		dict[@"event"] = self.event;
	}
	if (self.offset) {
		dict[@"offset"] = self.offset;
	}
	if (self.url) {
		dict[@"url"] = self.url.absoluteString ?: [NSNull null];
	}
	
	return dict;
}

@end

@implementation SKIVastTime

NSDateFormatter *SKISKIVastTimeDateFormatter() {
	static NSDateFormatter *timeFormatter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		timeFormatter = [[NSDateFormatter alloc] init];
		timeFormatter.defaultDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
		timeFormatter.dateFormat = @"HH:mm:ss";
		timeFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
		timeFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
	});
	
	return timeFormatter;
}

NSDateFormatter *SKISKIVastTimeDateFormatterMillis() {
	static NSDateFormatter *timeFormatter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		timeFormatter = [[NSDateFormatter alloc] init];
		timeFormatter.defaultDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
		timeFormatter.dateFormat = @"HH:mm:ss.SSS";
		timeFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
		timeFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
	});
	
	return timeFormatter;
}

+ (instancetype)vastTimeFromDate:(NSDate *)date {
	SKIVastTime *vastTime = [[SKIVastTime alloc] init];
	vastTime.timeDate = date;
	return vastTime;
}

+ (instancetype)vastTimeFromString:(NSString *)string {
	string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (string.length == 0) {
		return nil;
	}
	
	if ([string hasSuffix:@"%"]) {
		NSString *percentString = [string substringToIndex:string.length - 1];
		CGFloat percents = percentString.floatValue;
		if (percents > 100.) {
			return nil;
		}
		
		SKIVastTime *vastTime = [[SKIVastTime alloc] init];
		vastTime.percents = @(percents);
		return vastTime;
	} else {
		NSDate *date = [SKISKIVastTimeDateFormatter() dateFromString:string];
		if (!date) {
			date = [SKISKIVastTimeDateFormatterMillis() dateFromString:string];
		}
		
		if (!date) {
			return nil;
		}
		
		SKIVastTime *vastTime = [[SKIVastTime alloc] init];
		vastTime.timeDate = date;
		return vastTime;
	}
}

- (NSTimeInterval)intervalOffsetFromDate:(NSDate *)date {
	if (self.percents) {
		return date.timeIntervalSinceReferenceDate * (self.percents.floatValue / 100.f);
	} else if (self.timeDate) {
		NSTimeInterval duration = date.timeIntervalSinceReferenceDate;
		NSTimeInterval offset = self.timeDate.timeIntervalSinceReferenceDate;
		if (offset > duration) {
			return -1;
		}
		
		return offset;
	}
	
	return -1;
}

- (NSTimeInterval)intervalOffsetFromInterval:(NSTimeInterval)interval {
	if (self.percents) {
		return interval * (self.percents.floatValue / 100.f);
	} else if (self.timeDate) {
		NSTimeInterval offset = self.timeDate.timeIntervalSinceReferenceDate;
		if (offset > interval) {
			return -1;
		}
		
		return offset;
	}
	
	return -1;
}

- (NSTimeInterval)timeInterval {
	if (self.timeDate == nil) {
		return -1;
	}
	
	NSTimeInterval interval = self.timeDate.timeIntervalSinceReferenceDate;
	
	DCAssert(interval >= 0., "invalid duration");
	if (interval < 0) {
		// in case our VAST gen did not set correct default date to 'reference date' fallback to extracting the components
		NSCalendar *calendar = [NSCalendar currentCalendar];
		NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:self.timeDate];
		interval = components.hour * 60. * 60.;
		interval += (components.minute * 60.);
		interval += components.second;
	}
	
	return interval;
}

- (NSString *)asJSONValue {
	if (self.percents) {
		return [NSString stringWithFormat:@"%.02f%%", self.percents.floatValue];
	} else if (self.timeDate) {
		return [SKISKIVastTimeDateFormatterMillis() stringFromDate:self.timeDate];
	}
	
	return nil;
}

@end

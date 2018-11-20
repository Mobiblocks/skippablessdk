//
//  SKIVASTCompressedCreative.h
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SKIVAST.h"

@class SKIErrorCollector;

//@interface SKIVASTCompressedCreative : NSObject
//
//+ (instancetype)compressed;
//
//@property (copy, nonatomic) NSString *adId;
//
//@property (assign, nonatomic) BOOL nonLinear;
//
//@property (assign, nonatomic, readonly) BOOL maybeShownInLandscape;
//
//@property (strong, nonatomic) SKIVASTCreativeBase *creative;
//@property (strong, nonatomic) SKIVASTMediaFile *mediaFile;
//
//@property (strong, nonatomic) NSURL *localMediaUrl;
//
//@property (weak, nonatomic, readonly) NSDate *duration;
//@property (weak, nonatomic, readonly) NSString *skipoffset;
//
//@property (strong, nonatomic) NSArray<NSURL *> *errorTrackings;
//
//@property (strong, nonatomic) NSArray<SKIVASTTracking *> *skipTrackingUrls;
//@property (strong, nonatomic) NSArray<SKIVASTTracking *> *completeTrackingUrls;
//
//@property (strong, nonatomic) NSArray<NSURL *> *impressionUrls;
//@property (strong, nonatomic) NSArray<NSURL *> *additionalImpressionUrls;
//
//@property (weak, nonatomic, readonly) NSArray<SKIVASTTracking *> *trackings;
//@property (strong, nonatomic) NSArray<SKIVASTTracking *> *additionalTrackings;
//
//@property (weak, nonatomic, readonly) SKIVASTClickThrough *clickThrough;
//@property (weak, nonatomic, readonly) NSArray<SKIVASTClickTracking *> *clickTrackings;
//
//@end

@class SKICompactVastAd, SKICompactMediaFile, SKICompactTrackingEvent, SKIVastTime;

@interface SKICompactVast : NSObject

+ (nullable instancetype)compact:(SKIVASTVAST *)vast error:(NSError **)error;

@property (strong, nonatomic, readonly, nullable) NSArray<NSURL *> *errors;
@property (strong, nonatomic, readonly, nullable) NSArray<NSURL *> *inlineErrors;
@property (strong, nonatomic, readonly, nullable) NSArray<NSURL *> *impressions;
@property (assign, nonatomic, readonly) BOOL isWrapper;
@property (strong, nonatomic, readonly) SKICompactVastAd* ad;

@property (assign, nonatomic, readonly) NSDictionary *dictionaryValue;

@end

@interface SKICompactVastAd : NSObject

- (nullable SKICompactMediaFile *)bestMediaFile;

@property (copy, nonatomic, readonly, nullable) NSString *identifier;
@property (strong, nonatomic, readonly, nonnull) SKIVastTime *duration;
@property (strong, nonatomic, readonly, nullable) SKIVastTime *skipoffset;

@property (strong, nonatomic, readonly, nullable) NSURL *clickThrough;
@property (strong, nonatomic, readonly, nullable) NSArray<NSURL *> *videoClicks;
@property (strong, nonatomic, readonly, nullable) NSArray<SKICompactMediaFile *> *mediaFiles;
@property (strong, nonatomic, readonly, nullable) NSArray<SKICompactTrackingEvent *> *trackingEvents;

@property (assign, nonatomic, readonly) BOOL maybeShownInLandscape;
@property (assign, nonatomic, readonly) NSDictionary *dictionaryValue;

@end

@interface SKICompactMediaFile : NSObject

@property (copy, nonatomic, readonly, nullable) NSString *identifier; // id
@property (copy, nonatomic, readonly) NSString *type;
@property (copy, nonatomic, readonly) NSString *delivery;
@property (assign, nonatomic, readonly) CGFloat width;
@property (assign, nonatomic, readonly) CGFloat height;
@property (strong, nonatomic, readonly) NSURL *url;


@property (strong, nonatomic, readwrite, nullable) NSURL *localMediaUrl;
@property (assign, nonatomic, readonly) NSDictionary *dictionaryValue;

@end

@interface SKICompactTrackingEvent : NSObject

@property (copy, nonatomic, readonly, nullable) NSString *event;
@property (copy, nonatomic, readonly, nullable) NSString *offset;
@property (copy, nonatomic, readonly) NSURL *url;

@property (assign, nonatomic, readonly) NSDictionary *dictionaryValue;

@end

@interface SKIVastTime : NSObject

+ (nullable instancetype)vastTimeFromString:(NSString *)string;
+ (nonnull instancetype)vastTimeFromDate:(NSDate *)date;

- (NSTimeInterval)intervalOffsetFromDate:(NSDate *)date;
- (NSTimeInterval)intervalOffsetFromInterval:(NSTimeInterval)interval;

@property (assign, nonatomic, readonly) NSTimeInterval timeInterval;
@property (assign, nonatomic, nullable, readonly) NSString *asJSONValue;

@end

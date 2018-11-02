//
//  SKIVASTCompressedCreative.h
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SKIVAST.h"

@class SKIErrorCollector;

@interface SKIVASTCompressedCreative : NSObject

+ (instancetype)compressed;

@property (copy, nonatomic) NSString *adId;

@property (assign, nonatomic) BOOL nonLinear;

@property (assign, nonatomic, readonly) BOOL maybeShownInLandscape;

@property (strong, nonatomic) SKIVASTCreativeBase *creative;
@property (strong, nonatomic) SKIVASTMediaFile *mediaFile;

@property (strong, nonatomic) NSURL *localMediaUrl;

@property (weak, nonatomic, readonly) NSDate *duration;
@property (weak, nonatomic, readonly) NSString *skipoffset;

@property (strong, nonatomic) NSArray<NSURL *> *errorTrackings;

@property (strong, nonatomic) NSArray<SKIVASTTracking *> *skipTrackingUrls;
@property (strong, nonatomic) NSArray<SKIVASTTracking *> *completeTrackingUrls;

@property (strong, nonatomic) NSArray<NSURL *> *impressionUrls;
@property (strong, nonatomic) NSArray<NSURL *> *additionalImpressionUrls;

@property (weak, nonatomic, readonly) NSArray<SKIVASTTracking *> *trackings;
@property (strong, nonatomic) NSArray<SKIVASTTracking *> *additionalTrackings;

@property (weak, nonatomic, readonly) SKIVASTClickThrough *clickThrough;
@property (weak, nonatomic, readonly) NSArray<SKIVASTClickTracking *> *clickTrackings;

@end

//
//  SKIAdEventTracker.h
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SKIAdEventTrackerBuilder : NSObject

@property (strong, nonatomic) NSURL *url;
@property (assign, nonatomic) BOOL expires; // default: YES

@property (copy, nonatomic) NSString *sessionID; // default: nil
@property (copy, nonatomic) NSString *identifier; // default: nil
@property (assign, nonatomic) BOOL logError; // default: NO
@property (assign, nonatomic) BOOL logSession; // default: NO
@property (strong, nonatomic) NSDictionary *info; // default: nil

@end

@interface SKIAdEventTracker : NSObject

+ (instancetype)defaultTracker;

- (void)trackEvent:(void (^)(SKIAdEventTrackerBuilder *e))block;

- (void)sendReportWithDeviceData:(NSDictionary *)deviceInfo adId:(NSString *)adId adUnitId:(NSString *)adUnitId email:(NSString *)email message:(NSString *)message;

@end

typedef enum : NSInteger {
	SKIErrorCollectorTypeHTTP,
	SKIErrorCollectorTypeVAST,
	SKIErrorCollectorTypePlayer,
	SKIErrorCollectorTypeOther
} SKIErrorCollectorType;

@interface SKIErrorCollectorBuilder : NSObject

@property (assign, nonatomic) SKIErrorCollectorType type;
@property (copy, nonatomic, nonnull) NSString *place;
@property (copy, nonatomic) NSString *desc;
@property (strong, nonatomic) NSError *underlyingError;
@property (strong, nonatomic) NSDictionary *otherInfo;

@property (copy, nonatomic, readonly) NSDictionary *dictionaryValue;
@property (copy, nonatomic, readonly, nullable) NSData *jsonDataValue;
@property (copy, nonatomic, readonly, nullable) NSString *jsonStringValue;

+ (instancetype)build:(void (^)(SKIErrorCollectorBuilder *e))block;

@end

@interface SKIErrorCollector : NSObject

- (void)collect:(void (^)(SKIErrorCollectorBuilder *err))block;

@property (copy, nonatomic) NSString *sessionID;

@end

NS_ASSUME_NONNULL_END

@interface SKISDKSessionLog : NSObject

+ (nonnull instancetype)log;
+ (nonnull instancetype)build:(void (^)(SKISDKSessionLog * _Nonnull log))block;

@property (copy, nonatomic, nonnull) NSString *idenitifier;
@property (copy, nonatomic, nonnull) NSDate *date;
@property (copy, nonatomic) NSString *desc;
@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) NSDictionary *info;

@end

@interface SKISDKSessionLogger : NSObject

+ (nonnull instancetype)logger;
+ (nonnull instancetype)loggerWithSessionID:(NSString *)sessionID;

- (nonnull instancetype)build:(void (^__nonnull)(SKISDKSessionLog * _Nonnull log))block;
- (void)report;

@property (copy, nonatomic) NSString *sessionID;
@property (assign, nonatomic) BOOL canLog;

@end


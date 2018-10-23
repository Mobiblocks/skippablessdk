//
//  SKIAdEventTracker.h
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SKIAdEventTracker : NSObject

+ (instancetype)defaultTracker;

- (void)trackEventRequestWithUrl:(NSURL *)url;
- (void)trackErrorRequestWithUrl:(NSURL *)url;

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
@property (copy, nonatomic) NSString *place;
@property (copy, nonatomic) NSString *desc;
@property (strong, nonatomic) NSError *underlyingError;
@property (strong, nonatomic) NSDictionary *otherInfo;

@property (copy, nonatomic, readonly) NSData *jsonDataValue;
@property (copy, nonatomic, readonly) NSString *jsonStringValue;

@end

@interface SKIErrorCollector : NSObject

- (void)collect:(void (^)(SKIErrorCollectorBuilder *err))block;

@property (copy, nonatomic) NSString *sessionID;
@property (assign, nonatomic, readonly) NSSet *reportURLS;

@end

NS_ASSUME_NONNULL_END

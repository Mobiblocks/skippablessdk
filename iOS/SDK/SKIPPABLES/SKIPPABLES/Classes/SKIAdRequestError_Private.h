//
//  SKIAdRequestError_Private.h
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#ifndef SKIAdRequestError_Private_h
#define SKIAdRequestError_Private_h

#import "SKIAdRequestError.h"

NS_ASSUME_NONNULL_BEGIN

@interface SKIAdRequestError (Private)

+ (instancetype)errorWithCode:(NSInteger)code userInfo:(nullable NSDictionary<NSErrorUserInfoKey, id> *)dict;

+ (instancetype)errorInvalidRequestWithUserInfo:(nullable NSDictionary<NSErrorUserInfoKey, id> *)dict;

+ (instancetype)errorNoFillWithUserInfo:(nullable NSDictionary<NSErrorUserInfoKey, id> *)dict;

+ (instancetype)errorNetworkErrorWithUserInfo:(nullable NSDictionary<NSErrorUserInfoKey, id> *)dict;

+ (instancetype)errorServerErrorWithUserInfo:(nullable NSDictionary<NSErrorUserInfoKey, id> *)dict;

+ (instancetype)errorOSVersionTooLowWithUserInfo:(nullable NSDictionary<NSErrorUserInfoKey, id> *)dict;

+ (instancetype)errorTimeoutWithUserInfo:(nullable NSDictionary<NSErrorUserInfoKey, id> *)dict;

+ (instancetype)errorInternalErrorWithUserInfo:(nullable NSDictionary<NSErrorUserInfoKey, id> *)dict;

+ (instancetype)errorInvalidArgumentWithUserInfo:(nullable NSDictionary<NSErrorUserInfoKey, id> *)dict;

+ (instancetype)errorReceivedInvalidResponseWithUserInfo:(nullable NSDictionary<NSErrorUserInfoKey, id> *)dict;

@end

NS_ASSUME_NONNULL_END

#endif /* SKIAdRequestError_Private_h */

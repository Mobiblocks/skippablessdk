//
//  SKIAdRequestError.m
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import "SKIAdRequestError.h"

NSString *const kSKIAdErrorDomain = @"com.mobiblocks.skippables";

@implementation SKIAdRequestError

+ (instancetype)errorWithCode:(NSInteger)code userInfo:(NSDictionary<NSErrorUserInfoKey, id> *)dict {
	return [[self alloc] initWithDomain:kSKIAdErrorDomain code:code userInfo:dict];
}

+ (instancetype)errorInvalidRequestWithUserInfo:(NSDictionary<NSErrorUserInfoKey, id> *)dict {
	return [self errorWithCode:kSKIErrorInvalidRequest userInfo:dict];
}

+ (instancetype)errorNoFillWithUserInfo:(NSDictionary<NSErrorUserInfoKey, id> *)dict {
	return [self errorWithCode:kSKIErrorNoFill userInfo:dict];
}

+ (instancetype)errorNetworkErrorWithUserInfo:(NSDictionary<NSErrorUserInfoKey, id> *)dict {
	return [self errorWithCode:kSKIErrorNetworkError userInfo:dict];
}

+ (instancetype)errorServerErrorWithUserInfo:(NSDictionary<NSErrorUserInfoKey, id> *)dict {
	return [self errorWithCode:kSKIErrorServerError userInfo:dict];
}

+ (instancetype)errorOSVersionTooLowWithUserInfo:(NSDictionary<NSErrorUserInfoKey, id> *)dict {
	return [self errorWithCode:kSKIErrorOSVersionTooLow userInfo:dict];
}

+ (instancetype)errorTimeoutWithUserInfo:(NSDictionary<NSErrorUserInfoKey, id> *)dict {
	return [self errorWithCode:kSKIErrorTimeout userInfo:dict];
}

+ (instancetype)errorInternalErrorWithUserInfo:(NSDictionary<NSErrorUserInfoKey, id> *)dict {
	return [self errorWithCode:kSKIErrorInternalError userInfo:dict];
}

+ (instancetype)errorInvalidArgumentWithUserInfo:(NSDictionary<NSErrorUserInfoKey, id> *)dict {
	return [self errorWithCode:kSKIErrorInvalidArgument userInfo:dict];
}

+ (instancetype)errorReceivedInvalidResponseWithUserInfo:(NSDictionary<NSErrorUserInfoKey, id> *)dict {
	return [self errorWithCode:kSKIErrorReceivedInvalidResponse userInfo:dict];
}

@end

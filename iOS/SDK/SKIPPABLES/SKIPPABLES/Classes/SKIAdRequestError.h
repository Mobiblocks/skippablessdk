//
//  SKIAdRequestError.h
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kSKIAdErrorDomain;

typedef NS_ENUM(NSInteger, SKIErrorCode) {
	/// The ad request is invalid. The localizedFailureReason error description will have more
	/// details. Typically this is because the ad did not have the ad unit ID or root view
	/// controller set.
	kSKIErrorInvalidRequest = 1,
	
	/// The ad request was successful, but no ad was returned.
	kSKIErrorNoFill = 2,
	
	/// There was an error loading data from the network.
	kSKIErrorNetworkError = 3,
	
	/// The ad server experienced a failure processing the request.
	kSKIErrorServerError = 4,
	
	/// The current device's OS is below the minimum required version.
	kSKIErrorOSVersionTooLow = 5,
	
	/// The request was unable to be loaded before being timed out.
	kSKIErrorTimeout = 6,
	
	/// Internal error.
	kSKIErrorInternalError = 7,
	
	/// Invalid argument error.
	kSKIErrorInvalidArgument = 8,
	
	/// Received invalid response.
	kSKIErrorReceivedInvalidResponse = 9
};

@interface SKIAdRequestError : NSError

@end

NS_ASSUME_NONNULL_END

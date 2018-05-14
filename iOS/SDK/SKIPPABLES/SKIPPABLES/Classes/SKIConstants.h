//
//  SKIConstants.h
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import <netinet/in.h>
#import <sys/sysctl.h>

#import "SKIAdSize.h"

#ifndef SKIConstants_h
#define SKIConstants_h

#ifdef DEBUG
//#define LOCAL
//#define TEST
#endif

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif

#ifdef DEBUG
#   define SDLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define SDLog(fmt, ...) NSLog(fmt, ##__VA_ARGS__)
#endif

#ifdef DEBUG
#   define DCAssert(cond, comment) assert(cond && comment)
#else
#   define DCAssert(cond, comment)
#endif

//#ifndef SYSTEM_VERSION_EQUAL_TO
//#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
//#endif
//
//#ifndef SYSTEM_VERSION_GREATER_THAN
//#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
//#endif
//
//#ifndef SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO
//#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
//#endif
//
//#ifndef SYSTEM_VERSION_LESS_THAN
//#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
//#endif
//
//#ifndef SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO
//#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
//#endif

//#ifdef LOCAL
//#define SKIPPABLES_API_BANNER_URL @"http://10.0.0.35/ad/AdServer/GetBanner"
//#define SKIPPABLES_API_VIDEO_URL @"http://10.0.0.35/ad/AdServer/GetVideo"
//#define SKIPPABLES_INSTALL_URL @"http://10.0.0.35/ad/InstallServer/Track"
//#define SKIPPABLES_REPORT_URL @"http://10.0.0.35/ad/api/Feedback/InfringementReport"

//#else
#define SKIPPABLES_API_BANNER_URL @"https://www.skippables.com/x/srv/GetImage"
#define SKIPPABLES_API_VIDEO_URL @"https://www.skippables.com/x/srv/GetVideo"
#define SKIPPABLES_INSTALL_URL @"https://www.skippables.com/x/InstallServer/Track"
#define SKIPPABLES_REPORT_URL @"https://www.skippables.com/x/api/Feedback/InfringementReport"


//#define SKIPPABLES_API_BANNER_URL @"http://test.skippables.com/x/srv/GetImage"
//#define SKIPPABLES_API_VIDEO_URL @"http://test.skippables.com/x/srv/GetVideo"
//#define SKIPPABLES_INSTALL_URL @"http://test.skippables.com/x/InstallServer/Track"
//#define SKIPPABLES_REPORT_URL @"http://test.skippables.com/x/api/Feedback/InfringementReport"
//#endif

typedef NS_ENUM(NSInteger, SKIRTBDeviceType) {
	kSKIRTBDeviceTypeUnknown          = 0,   ///< Unknown.
	kSKIRTBDeviceTypeMobileTablet     = 1,   ///< Mobile/Tablet.
	kSKIRTBDeviceTypePersonalComputer = 2,   ///< Personal Computer.
	kSKIRTBDeviceTypeConnectedTV      = 3,   ///< Connected TV.
	kSKIRTBDeviceTypePhone            = 4,   ///< Phone.
	kSKIRTBDeviceTypeTablet           = 5,   ///< Tablet.
	kSKIRTBDeviceTypeConnectedDevice  = 6,   ///< Connected Device.
	kSKIRTBDeviceTypeSetTopBox        = 7,   ///< Set Top Box.
};

typedef NS_ENUM(NSInteger, SKIRTBLocationType) {
	kSKIRTBLocationTypeUnknown             = 0,   ///< Unknown. Used to specify invalid location.
	kSKIRTBLocationTypeGPSLocationServices = 1,   ///< GPS/Location Services.
	kSKIRTBLocationTypeIPAddress           = 2,   ///< IP Address.
	kSKIRTBLocationTypeUserProvided        = 3,   ///< User provided (e.g., registration data).
};

typedef NS_ENUM(NSInteger, SKIRTBConnectionType) {
	kSKIRTBConnectionTypeUnknown         = 0,   ///< Unknown.
	kSKIRTBConnectionTypeEthernet        = 1,   ///< Ethernet.
	kSKIRTBConnectionTypeWIFI            = 2,   ///< WiFi.
	kSKIRTBConnectionTypeCellularUnknown = 3,   ///< Cellular Network – Unknown Generation.
	kSKIRTBConnectionTypeCellular2G      = 4,   ///< Cellular Network – 2G.
	kSKIRTBConnectionTypeCellular3G      = 5,   ///< Cellular Network – 3G.
	kSKIRTBConnectionTypeCellular4G      = 6,   ///< Cellular Network – 4G.
};

NS_ASSUME_NONNULL_BEGIN

extern NSString *SKIDevicePlatform(void);

extern NSString *SKIDeviceName(void);

extern NSString *SKIDeviceModelName(void);

extern NSString *SKIUserAgent(void);

extern SKIRTBDeviceType SKIDeviceType(void);

extern SKIRTBConnectionType SKIConnectionType(void);

extern NSInteger SKIUTCOffset(void);

static inline BOOL SKIiSiPhone() {
	return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
};

extern BOOL SKIiSSmallScreen(void);

extern NSString *SKIFormattedTimestampString(void);

extern NSString *SKIFormattedStringFromInterval(NSTimeInterval interval);

extern NSTimeInterval SKIIntervalFromDurationDate(NSDate *durationDate);

extern NSTimeInterval SKITrackingEventFirstQuartileInterval(NSDate *durationDate);

extern NSTimeInterval SKITrackingEventMidpointInterval(NSDate *durationDate);

extern NSTimeInterval SKITrackingEventThirdQuartileInterval(NSDate *durationDate);

extern NSTimeInterval SKITrackingEventWithOffsetInterval(NSString *string, NSDate *durationDate);

extern UIInterfaceOrientation SKICurrentOrientation(void);

extern BOOL SKIMaybeSupportsLanscapeOrientation(void);

extern BOOL SKISupportsPortraitOnlyOrientation(void);

extern BOOL SKISupportsLanscapeOnlyOrientation(void);

static inline CGRect SKIScreenBounds(void) {
	return [[UIScreen mainScreen] bounds];
}

extern CGRect SKIOrientationIndependentScreenBounds(void);

extern SKIAdSize SKIAdSizeFromCGSize(CGSize size);

static inline BOOL SKIiSPortrait() {
	return UIInterfaceOrientationIsPortrait(SKICurrentOrientation());
}

static inline BOOL SKIiSLandscape() {
	return UIInterfaceOrientationIsLandscape(SKICurrentOrientation());
}

extern NSString *SKIUnique(void);

extern NSString *SKICachePath(void);

extern NSString *SKIDocumentsPath(void);

extern NSString *SKIMimeToExtension(NSString *mime);

static inline void SKISyncOnMain(dispatch_block_t block) {
	if ([NSThread isMainThread]) {
		block();
	} else {
		dispatch_sync(dispatch_get_main_queue(), block);
	}
}

static inline void SKIAsyncOnMain(dispatch_block_t block) {
	dispatch_async(dispatch_get_main_queue(), block);
}

static inline void SKISyncAsyncOnMain(dispatch_block_t block) {
	if ([NSThread isMainThread]) {
		block();
	} else {
		dispatch_async(dispatch_get_main_queue(), block);
	}
}

static inline void SKIAsyncOnBackground(dispatch_block_t block) {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

static inline void SKIRunLoopBlock(dispatch_block_t block) {
	CFRunLoopPerformBlock(CFRunLoopGetCurrent(), kCFRunLoopDefaultMode, ^{
		block();
		CFRunLoopStop(CFRunLoopGetCurrent());
	});
	
	CFRunLoopRun();
}

extern NSString *SKImd5(NSString *string);

static inline NSString *SKIUUID() {
	return [[[NSUUID UUID] UUIDString] lowercaseString];
}

extern NSString *SKIDeviceSession(void);

extern NSString *_Nullable SKIIABCategoryFromAppleID(NSInteger aid);

extern NSArray<NSString *> *SKIIABCategoriesFromAppleIDS(NSArray<NSString *> *ids);

NS_ASSUME_NONNULL_END

#endif /* SKIConstants_h */


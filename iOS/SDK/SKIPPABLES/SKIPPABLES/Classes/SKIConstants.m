//
//  SKIConstants.m
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <WebKit/WebKit.h>

#import "SKIConstants.h"

typedef NS_ENUM(NSInteger, SKICategory) {
	kSKICategoryBusiness							= 6000, /// Business
	kSKICategoryWeather								= 6001, /// Weather
	kSKICategoryUtilities							= 6002, /// Utilities
	kSKICategoryTravel								= 6003, /// Travel
	kSKICategorySports								= 6004, /// Sports
	kSKICategorySocialNetworking					= 6005, /// SocialNetworking
	kSKICategoryReference							= 6006, /// Reference
	kSKICategoryProductivity						= 6007, /// Productivity
	kSKICategoryPhotoVideo							= 6008, /// PhotoVideo
	kSKICategoryNews								= 6009, /// News
	kSKICategoryNavigation							= 6010, /// Navigation
	kSKICategoryMusic								= 6011, /// Music
	kSKICategoryLifestyle							= 6012, /// Lifestyle
	kSKICategoryHealthFitness						= 6013, /// HealthFitness
	kSKICategoryGames								= 6014, /// Games
	kSKICategoryGamesAction							= 7001, /// Games Action
	kSKICategoryGamesAdventure						= 7002, /// Games Adventure
	kSKICategoryGamesArcade							= 7003, /// Games Arcade
	kSKICategoryGamesBoard							= 7004, /// Games Board
	kSKICategoryGamesCard							= 7005, /// Games Card
	kSKICategoryGamesCasino							= 7006, /// Games Casino
	kSKICategoryGamesDice							= 7007, /// Games Dice
	kSKICategoryGamesEducational					= 7008, /// Games Educational
	kSKICategoryGamesFamily							= 7009, /// Games Family
	kSKICategoryGamesKids							= 7010, /// Games Kids
	kSKICategoryGamesMusic							= 7011, /// Games Music
	kSKICategoryGamesPuzzle							= 7012, /// Games Puzzle
	kSKICategoryGamesRacing							= 7013, /// Games Racing
	kSKICategoryGamesRolePlaying					= 7014, /// Games RolePlaying
	kSKICategoryGamesSimulation						= 7015, /// Games Simulation
	kSKICategoryGamesSports							= 7016, /// Games Sports
	kSKICategoryGamesStrategy						= 7017, /// Games Strategy
	kSKICategoryGamesTrivia							= 7018, /// Games Trivia
	kSKICategoryGamesWord							= 7019, /// Games Word
	kSKICategoryFinance								= 6015, /// Finance
	kSKICategoryEntertainment						= 6016, /// Entertainment
	kSKICategoryEducation							= 6017, /// Education
	kSKICategoryBooks								= 6018, /// Books
	kSKICategoryMedical								= 6020, /// Medical
	kSKICategoryNewsstand							= 6021, /// Newsstand
	kSKICategoryNewsstandNewsPolitics				= 13001, /// NewsPolitics
	kSKICategoryNewsstandFashionStyle				= 13002, /// FashionStyle
	kSKICategoryNewsstandHomeGarden					= 13003, /// HomeGarden
	kSKICategoryNewsstandOutdoorsNature				= 13004, /// OutdoorsNature
	kSKICategoryNewsstandSportsLeisure				= 13005, /// SportsLeisure
	kSKICategoryNewsstandAutomotive					= 13006, /// Automotive
	kSKICategoryNewsstandArtsPhotography			= 13007, /// ArtsPhotography
	kSKICategoryNewsstandBridesWeddings				= 13008, /// BridesWeddings
	kSKICategoryNewsstandBusinessInvesting			= 13009, /// BusinessInvesting
	kSKICategoryNewsstandChildrensMagazines			= 13010, /// ChildrensMagazines
	kSKICategoryNewsstandComputersInternet			= 13011, /// ComputersInternet
	kSKICategoryNewsstandCookingFoodDrink			= 13012, /// CookingFoodDrink
	kSKICategoryNewsstandCraftsHobbies				= 13013, /// CraftsHobbies
	kSKICategoryNewsstandElectronicsAudio			= 13014, /// ElectronicsAudio
	kSKICategoryNewsstandEntertainment				= 13015, /// Entertainment
	kSKICategoryNewsstandHealthMindBody				= 13017, /// HealthMindBody
	kSKICategoryNewsstandHistory					= 13018, /// History
	kSKICategoryNewsstandLiteraryMagazinesJournals	= 13019, /// LiteraryMagazinesJournals
	kSKICategoryNewsstandMensInterest				= 13020, /// MensInterest
	kSKICategoryNewsstandMoviesMusic				= 13021, /// MoviesMusic
	kSKICategoryNewsstandParentingFamily			= 13023, /// ParentingFamily
	kSKICategoryNewsstandPets						= 13024, /// Pets
	kSKICategoryNewsstandProfessionalTrade			= 13025, /// ProfessionalTrade
	kSKICategoryNewsstandRegionalNews				= 13026, /// RegionalNews
	kSKICategoryNewsstandScience					= 13027, /// Science
	kSKICategoryNewsstandTeens						= 13028, /// Teens
	kSKICategoryNewsstandTravelRegional				= 13029, /// TravelRegional
	kSKICategoryNewsstandWomensInterest				= 13030, /// WomensInterest
	kSKICategoryCatalogs							= 6022, /// Catalogs
};

NSString *SKIApiUrlForAdType(SKIAdType adType) {
	switch (adType) {
		case kSKIAdTypeBannerText:
		case kSKIAdTypeBannerImage:
		case kSKIAdTypeBannerRichmedia:
			return SKIPPABLES_API_BANNER_URL;
		case kSKIAdTypeInterstitial:
			return SKIPPABLES_API_INTERSTITIAL_URL;
		case kSKIAdTypeInterstitialVideo:
			return SKIPPABLES_API_VIDEO_URL;
	}
}

NSString *SKIDevicePlatform() {
	static NSString *platform = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		size_t size;
		sysctlbyname("hw.machine", NULL, &size, NULL, 0);
		char *machine = malloc(size);
		sysctlbyname("hw.machine", machine, &size, NULL, 0);
		
		platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
		
		free(machine);
	});
	
	return platform;
}

NSString *SKIDeviceName() {
	static NSString *deviceName = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSString *platform = SKIDevicePlatform();
		if ([platform hasPrefix:@"iPhone"]) {
			deviceName = @"iPhone";
		} else if ([platform hasPrefix:@"iPod"]) {
			deviceName = @"iPod";
		} else if ([platform hasPrefix:@"iPad"]) {
			deviceName = @"iPad";
		} else if ([platform hasPrefix:@"AppleTV"]) {
			deviceName = @"AppleTV";
		} else if ([platform hasPrefix:@"Watch"]) {
			deviceName = @"Watch";
		} else if ([platform hasPrefix:@"i386"] || [platform hasPrefix:@"x86_64"]) {
			deviceName = @"Simulator";
		} else {
			deviceName = @"Unknown";
		}
	});
	
	return deviceName;
}

NSString *SKIDeviceModelName() {
	static NSString *deviceModelName = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSString *platform = SKIDevicePlatform();
			 if ([platform isEqualToString:@"iPhone1,1"])    {deviceModelName = @"1G";}
		else if ([platform isEqualToString:@"iPhone1,2"])    {deviceModelName = @"3G";}
		else if ([platform isEqualToString:@"iPhone2,1"])    {deviceModelName = @"3GS";}
		else if ([platform isEqualToString:@"iPhone3,1"])    {deviceModelName = @"4 (GSM)";}
		else if ([platform isEqualToString:@"iPhone3,2"])    {deviceModelName = @"4 (GSM, 2nd revision)";}
		else if ([platform isEqualToString:@"iPhone3,3"])    {deviceModelName = @"4 (Verizon)";}
		else if ([platform isEqualToString:@"iPhone4,1"])    {deviceModelName = @"4S";}
		else if ([platform isEqualToString:@"iPhone5,1"])    {deviceModelName = @"5 (GSM)";}
		else if ([platform isEqualToString:@"iPhone5,2"])    {deviceModelName = @"5 (GSM+CDMA)";}
		else if ([platform isEqualToString:@"iPhone5,3"])    {deviceModelName = @"5c (GSM)";}
		else if ([platform isEqualToString:@"iPhone5,4"])    {deviceModelName = @"5c (GSM+CDMA)";}
		else if ([platform isEqualToString:@"iPhone6,1"])    {deviceModelName = @"5s (GSM)";}
		else if ([platform isEqualToString:@"iPhone6,2"])    {deviceModelName = @"5s (GSM+CDMA)";}
		else if ([platform isEqualToString:@"iPhone7,2"])    {deviceModelName = @"6";}
		else if ([platform isEqualToString:@"iPhone7,1"])    {deviceModelName = @"6 Plus";}
		else if ([platform isEqualToString:@"iPhone8,1"])    {deviceModelName = @"6s";}
		else if ([platform isEqualToString:@"iPhone8,2"])    {deviceModelName = @"6s Plus";}
		else if ([platform isEqualToString:@"iPhone8,4"])    {deviceModelName = @"SE";}
		else if ([platform isEqualToString:@"iPhone9,1"])    {deviceModelName = @"7 (GSM+CDMA)";}
		else if ([platform isEqualToString:@"iPhone9,3"])    {deviceModelName = @"7 (GSM)";}
		else if ([platform isEqualToString:@"iPhone9,2"])    {deviceModelName = @"7 Plus (GSM+CDMA)";}
		else if ([platform isEqualToString:@"iPhone9,4"])    {deviceModelName = @"7 Plus (GSM)";}
		else if ([platform isEqualToString:@"iPhone10,1"])    {deviceModelName = @"8 (GSM+CDMA)";}
		else if ([platform isEqualToString:@"iPhone10,4"])    {deviceModelName = @"8 (GSM)";}
		else if ([platform isEqualToString:@"iPhone10,2"])    {deviceModelName = @"8 Plus (GSM+CDMA)";}
		else if ([platform isEqualToString:@"iPhone10,5"])    {deviceModelName = @"8 Plus (GSM)";}
		else if ([platform isEqualToString:@"iPhone10,3"])    {deviceModelName = @"X (GSM+CDMA)";}
		else if ([platform isEqualToString:@"iPhone10,6"])    {deviceModelName = @"X (GSM)";}
		
		//iPod Touch
		else if ([platform isEqualToString:@"iPod1,1"])      {deviceModelName = @"1G";}
		else if ([platform isEqualToString:@"iPod2,1"])      {deviceModelName = @"2G";}
		else if ([platform isEqualToString:@"iPod3,1"])      {deviceModelName = @"3G";}
		else if ([platform isEqualToString:@"iPod4,1"])      {deviceModelName = @"4G";}
		else if ([platform isEqualToString:@"iPod5,1"])      {deviceModelName = @"5G";}
		else if ([platform isEqualToString:@"iPod7,1"])      {deviceModelName = @"6G";}
		
		//iPad
		else if ([platform isEqualToString:@"iPad1,1"])      {deviceModelName = @"1";}
		else if ([platform isEqualToString:@"iPad2,1"])      {deviceModelName = @"2 (Wi-Fi)";}
		else if ([platform isEqualToString:@"iPad2,2"])      {deviceModelName = @"2 (GSM)";}
		else if ([platform isEqualToString:@"iPad2,3"])      {deviceModelName = @"2 (CDMA)";}
		else if ([platform isEqualToString:@"iPad2,4"])      {deviceModelName = @"2 (Wi-Fi, Mid 2012)";}
		else if ([platform isEqualToString:@"iPad2,5"])      {deviceModelName = @"Mini (Wi-Fi)";}
		else if ([platform isEqualToString:@"iPad2,6"])      {deviceModelName = @"Mini (GSM)";}
		else if ([platform isEqualToString:@"iPad2,7"])      {deviceModelName = @"Mini (GSM+CDMA)";}
		else if ([platform isEqualToString:@"iPad3,1"])      {deviceModelName = @"3 (Wi-Fi)";}
		else if ([platform isEqualToString:@"iPad3,2"])      {deviceModelName = @"3 (GSM+CDMA)";}
		else if ([platform isEqualToString:@"iPad3,3"])      {deviceModelName = @"3 (GSM)";}
		else if ([platform isEqualToString:@"iPad3,4"])      {deviceModelName = @"4 (Wi-Fi)";}
		else if ([platform isEqualToString:@"iPad3,5"])      {deviceModelName = @"4 (GSM)";}
		else if ([platform isEqualToString:@"iPad3,6"])      {deviceModelName = @"4 (GSM+CDMA)";}
		else if ([platform isEqualToString:@"iPad4,1"])      {deviceModelName = @"Air (Wi-Fi)";}
		else if ([platform isEqualToString:@"iPad4,2"])      {deviceModelName = @"Air (Cellular)";}
		else if ([platform isEqualToString:@"iPad4,3"])      {deviceModelName = @"Air (China)";}
		else if ([platform isEqualToString:@"iPad4,4"])      {deviceModelName = @"Mini 2 (Wi-Fi)";}
		else if ([platform isEqualToString:@"iPad4,5"])      {deviceModelName = @"Mini 2 (Cellular)";}
		else if ([platform isEqualToString:@"iPad4,6"])      {deviceModelName = @"Mini 2 (China)";}
		else if ([platform isEqualToString:@"iPad4,7"])      {deviceModelName = @"Mini 3 (Wi-Fi)";}
		else if ([platform isEqualToString:@"iPad4,8"])      {deviceModelName = @"Mini 3 (Cellular)";}
		else if ([platform isEqualToString:@"iPad4,9"])      {deviceModelName = @"Mini 3 (China)";}
		else if ([platform isEqualToString:@"iPad5,1"])      {deviceModelName = @"Mini 4 (Wi-Fi)";}
		else if ([platform isEqualToString:@"iPad5,2"])      {deviceModelName = @"Mini 4 (Cellular)";}
		else if ([platform isEqualToString:@"iPad5,3"])      {deviceModelName = @"Air 2 (Wi-Fi)";}
		else if ([platform isEqualToString:@"iPad5,4"])      {deviceModelName = @"Air 2 (Cellular)";}
		else if ([platform isEqualToString:@"iPad6,3"])      {deviceModelName = @"Pro 9.7\" (Wi-Fi)";}
		else if ([platform isEqualToString:@"iPad6,4"])      {deviceModelName = @"Pro 9.7\" (Cellular)";}
		else if ([platform isEqualToString:@"iPad6,7"])      {deviceModelName = @"Pro 12.9\" (Wi-Fi)";}
		else if ([platform isEqualToString:@"iPad6,8"])      {deviceModelName = @"Pro 12.9\" (Cellular)";}
		else if ([platform isEqualToString:@"iPad6,11"])     {deviceModelName = @"(5th generation) (Wi-Fi)";}
		else if ([platform isEqualToString:@"iPad6,12"])     {deviceModelName = @"(5th generation) (Cellular)";}
		else if ([platform isEqualToString:@"iPad7,1"])      {deviceModelName = @"Pro 12.9\" (2nd generation) (Wi-Fi)";}
		else if ([platform isEqualToString:@"iPad7,2"])      {deviceModelName = @"Pro 12.9\" (2nd generation) (Cellular)";}
		else if ([platform isEqualToString:@"iPad7,3"])      {deviceModelName = @"Pro 10.5\" (Wi-Fi)";}
		else if ([platform isEqualToString:@"iPad7,4"])      {deviceModelName = @"Pro 10.5\" (Cellular)";}
		
		//Apple TV
		else if ([platform isEqualToString:@"AppleTV2,1"])   {deviceModelName = @"2G";}
		else if ([platform isEqualToString:@"AppleTV3,1"])   {deviceModelName = @"3";}
		else if ([platform isEqualToString:@"AppleTV3,2"])   {deviceModelName = @"3 (2013)";}
		else if ([platform isEqualToString:@"AppleTV5,3"])   {deviceModelName = @"4";}
		else if ([platform isEqualToString:@"AppleTV6,2"])   {deviceModelName = @"4K";}
		
		//Apple Watch
		else if ([platform isEqualToString:@"Watch1,1"])     {deviceModelName = @"1 (38mm)";}
		else if ([platform isEqualToString:@"Watch1,2"])     {deviceModelName = @"1 (42mm)";}
		else if ([platform isEqualToString:@"Watch2,6"])     {deviceModelName = @"Series 1 (38mm)";}
		else if ([platform isEqualToString:@"Watch2,7"])     {deviceModelName = @"Series 1 (42mm)";}
		else if ([platform isEqualToString:@"Watch2,3"])     {deviceModelName = @"Series 2 (38mm)";}
		else if ([platform isEqualToString:@"Watch2,4"])     {deviceModelName = @"Series 2 (42mm)";}
		else if ([platform isEqualToString:@"Watch3,1"])     {deviceModelName = @"Series 3 (38mm Cellular)";}
		else if ([platform isEqualToString:@"Watch3,2"])     {deviceModelName = @"Series 3 (42mm Cellular)";}
		else if ([platform isEqualToString:@"Watch3,3"])     {deviceModelName = @"Series 3 (38mm)";}
		else if ([platform isEqualToString:@"Watch3,4"])     {deviceModelName = @"Series 3 (42mm)";}
		
		//x86_64
		else if ([platform isEqualToString:@"x86_64"])     {deviceModelName = @"x86_64";}
	});
	
	return deviceModelName;
}

NSString *SKIUserAgent() {
	static NSString *ua = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		SKISyncOnMain(^{
			WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero];
			[webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
				if (result != nil) {
					ua = [result stringValue];
				}
			}];
		});
	});
	
	return ua;
}

SKIRTBDeviceType SKIDeviceType() {
	switch (UI_USER_INTERFACE_IDIOM()) {
		case UIUserInterfaceIdiomUnspecified:
			return kSKIRTBDeviceTypeConnectedDevice;
		case UIUserInterfaceIdiomPhone:
			return kSKIRTBDeviceTypePhone;
		case UIUserInterfaceIdiomPad:
			return kSKIRTBDeviceTypeTablet;
		case UIUserInterfaceIdiomTV:
			return kSKIRTBDeviceTypeConnectedTV;
		case UIUserInterfaceIdiomCarPlay:
			return kSKIRTBDeviceTypeConnectedDevice;
			
		default:
			return kSKIRTBDeviceTypeConnectedDevice;
	}
}

SKIRTBConnectionType SKIConnectionType() {
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zeroAddress);
	SCNetworkReachabilityFlags flags;
	BOOL success = SCNetworkReachabilityGetFlags(reachability, &flags);
	CFRelease(reachability);
	if (!success) {
		return kSKIRTBConnectionTypeUnknown;
	}
	BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
	BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
	BOOL isNetworkReachable = (isReachable && !needsConnection);
	
	if (!isNetworkReachable) {
		return kSKIRTBConnectionTypeUnknown;
	} else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
		CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
		NSString *technology = netinfo.currentRadioAccessTechnology;
		if ([technology isEqualToString:CTRadioAccessTechnologyLTE]) {
			return kSKIRTBConnectionTypeCellular4G;
		} else if ([technology isEqualToString:CTRadioAccessTechnologyGPRS] ||
				   [technology isEqualToString:CTRadioAccessTechnologyEdge] ||
				   [technology isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
			return kSKIRTBConnectionTypeCellular2G;
		} else {
			return kSKIRTBConnectionTypeCellular3G;
		}
	} else {
		return kSKIRTBConnectionTypeWIFI;
	}
	
	return 0;
}

NSInteger SKIUTCOffset() {
	NSTimeZone *localTZ = [NSTimeZone localTimeZone];
	return localTZ.secondsFromGMT / 60;
}

BOOL SKIiSSmallScreen() {
	switch (UI_USER_INTERFACE_IDIOM()) {
		case UIUserInterfaceIdiomUnspecified:
			return YES;
		case UIUserInterfaceIdiomPhone:
			return YES;
		case UIUserInterfaceIdiomPad:
			return NO;
		case UIUserInterfaceIdiomTV:
			return NO;
		case UIUserInterfaceIdiomCarPlay:
			return YES;
			
		default:
			return YES;
	}
}

NSTimeInterval SKIIntervalFromDurationDate(NSDate *durationDate) {
	NSTimeInterval interval = durationDate.timeIntervalSinceReferenceDate;
	
	DCAssert(interval >= 0., "invalid duration");
	if (interval < 0) {
		// in case our VAST gen did not set correct default date to 'reference date' fallback to extracting the components
		NSCalendar *calendar = [NSCalendar currentCalendar];
		NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:durationDate];
		interval = components.hour * 60. * 60.;
		interval += (components.minute * 60.);
		interval += components.second;
	}
	
	return interval;
}

NSDateFormatter *SKIOffsetFormatter() {
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

NSDateFormatter *SKIOffsetFormatterMillis() {
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

NSString *SKIFormattedTimestampString() {
	static NSDateFormatter *dateFormatter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		dateFormatter = [[NSDateFormatter alloc] init];
		dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ";
		dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
		dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
	});
	
	return [dateFormatter stringFromDate:[NSDate date]];
}

NSString *SKIFormattedStringFromInterval(NSTimeInterval interval) {
	NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:interval];
	NSDateFormatter *formatter = SKIOffsetFormatter();
	
	return [formatter stringFromDate:date];
}

/// Values can be time in the format HH:MM:SS or HH:MM:SS.mmm or a percentage value in the format n%.
NSTimeInterval SKITrackingEventWithOffsetInterval(NSString *offsetString, NSDate *durationDate) {
	offsetString = [offsetString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (offsetString.length == 0) {
		return -1.;
	}
	
	if ([offsetString hasSuffix:@"%"]) {
		NSString *percentString = [offsetString substringToIndex:offsetString.length - 1];
		CGFloat percents = percentString.floatValue;
		if (percents > 100.) {
			return -1;
		}
		
		NSTimeInterval duration = SKIIntervalFromDurationDate(durationDate);
		if (percents > 0.) {
			return duration * (percents / 100.f);
		}
	} else {
		NSDateFormatter *offsetFormatter = SKIOffsetFormatter();
		NSDate *date = [offsetFormatter dateFromString:offsetString];
		if (!date) {
			offsetFormatter = SKIOffsetFormatterMillis();
			date = [offsetFormatter dateFromString:offsetString];
		}
		
		if (!date) {
			return -1.;
		}
		
		NSTimeInterval duration = SKIIntervalFromDurationDate(durationDate);
		NSTimeInterval offset = SKIIntervalFromDurationDate(date);
		if (offset > duration) {
			return -1;
		}
		
		return offset;
	}
	
	return -1.;
}

NSTimeInterval SKITrackingEventFirstQuartileInterval(NSDate *durationDate) {
	NSTimeInterval duration = SKIIntervalFromDurationDate(durationDate);
	return duration * .25;
}

NSTimeInterval SKITrackingEventMidpointInterval(NSDate *durationDate) {
	NSTimeInterval duration = SKIIntervalFromDurationDate(durationDate);
	return duration * .50;
}

NSTimeInterval SKITrackingEventThirdQuartileInterval(NSDate *durationDate) {
	NSTimeInterval duration = SKIIntervalFromDurationDate(durationDate);
	return duration * .75;
}

SKIAdSize SKIAdSizeFromCGSize(CGSize size) {
	return (SKIAdSize){size.width, size.height};
}

BOOL SKIMaybeSupportsLanscapeOrientation() {
	static BOOL support = NO;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSArray *orientations = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportedInterfaceOrientations"];
		if (orientations == nil) {
			support = YES;
		} else {
			for (NSString *orientationString in orientations) {
				if ([orientationString isEqualToString:@"UIInterfaceOrientationLandscapeLeft"]) {
					support = YES;
					break;
				} else if ([orientationString isEqualToString:@"UIInterfaceOrientationLandscapeRight"]) {
					support = YES;
					break;
				}
			}
		}
	});
	
	return support;
}

BOOL SKISupportsPortraitOnlyOrientation(void) {
	static BOOL support = YES;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSArray *orientations = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportedInterfaceOrientations"];
		if (orientations == nil) {
			support = NO;
		} else {
			for (NSString *orientationString in orientations) {
				if ([orientationString isEqualToString:@"UIInterfaceOrientationLandscapeLeft"]) {
					support = NO;
					break;
				} else if ([orientationString isEqualToString:@"UIInterfaceOrientationLandscapeRight"]) {
					support = NO;
					break;
				}
			}
		}
	});
	
	return support;
}

BOOL SKISupportsLanscapeOnlyOrientation(void) {
	static BOOL support = YES;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSArray *orientations = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportedInterfaceOrientations"];
		if (orientations == nil) {
			support = NO;
		} else {
			for (NSString *orientationString in orientations) {
				if ([orientationString isEqualToString:@"UIDeviceOrientationPortrait"]) {
					support = NO;
					break;
				} else if ([orientationString isEqualToString:@"UIDeviceOrientationPortraitUpsideDown"]) {
					support = NO;
					break;
				}
			}
		}
	});
	
	return support;
}

UIInterfaceOrientation SKICurrentOrientation() {
	__block UIInterfaceOrientation orientation = UIInterfaceOrientationUnknown;
	SKISyncOnMain(^{
		orientation = [[UIApplication sharedApplication] statusBarOrientation];
	});
	return orientation;
}

CGRect SKIOrientationIndependentScreenBounds() {
	CGRect bounds = [[UIScreen mainScreen] bounds];
	if (SKIiSLandscape()) {
		return (CGRect){{bounds.origin.y, bounds.origin.x}, {bounds.size.height, bounds.size.width}};
	}
	
	return bounds;
}

static NSMutableDictionary *SKIUniqueDictionary() {
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	[dictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	
	NSData *encodedKey = [@"uid" dataUsingEncoding:NSUTF8StringEncoding];
	[dictionary setObject:encodedKey forKey:(__bridge id)kSecAttrGeneric];
	[dictionary setObject:encodedKey forKey:(__bridge id)kSecAttrAccount];
	[dictionary setObject:@"com.mobiblocks.skippables" forKey:(__bridge id)kSecAttrService];
	[dictionary setObject:(__bridge id)kSecAttrAccessibleAlwaysThisDeviceOnly forKey:(__bridge id)kSecAttrAccessible];
	
	return dictionary;
}

static NSMutableDictionary *SKIUniqueDictionaryFind() {
	NSMutableDictionary *dictionary = SKIUniqueDictionary();
	[dictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
	[dictionary setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
	
	return dictionary;
}

static NSMutableDictionary *SKIUniqueDictionaryAdd(NSData *data) {
	NSMutableDictionary *dictionary = SKIUniqueDictionary();
	[dictionary setObject:data forKey:(__bridge id)kSecValueData];
	
	return dictionary;
}

NSString *SKIUniqueAdd(void) {
	NSString *unique = SKIUUID();
	NSMutableDictionary *dictionary = SKIUniqueDictionaryAdd([unique dataUsingEncoding:NSUTF8StringEncoding]);
	
	OSStatus status = SecItemAdd((__bridge CFDictionaryRef)dictionary, NULL);
	if(errSecSuccess != status) {
		DLog(@"Unable add item with error: %i", (int)status);
		
		return nil;
	}
	
	return unique;
}

NSString *SKIUniqueFind(void) {
	NSMutableDictionary *dictionary = SKIUniqueDictionaryFind();
	
	CFTypeRef result = NULL;
	OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)dictionary, &result);
	if( status != errSecSuccess) {
		DLog(@"Unable to fetch item error: %i", (int)status);
		return nil;
	}
	
	return [[NSString alloc] initWithData:(__bridge NSData *)result encoding:NSUTF8StringEncoding];
}

NSString *SKIUnique(void) {
	static NSString *unique = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		unique = SKIUniqueFind();
		if (!unique) {
			unique = SKIUniqueAdd();
		}
		
		if (!unique) {
			unique = SKIUUID();
		}
	});
	
	return unique;
}

NSString *SKICachePath() {
	NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cachePath = [paths.firstObject stringByAppendingPathComponent:SKIUnique()];
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
	});
	
	return cachePath;
}

NSString *SKIDocumentsPath() {
	NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths.firstObject stringByAppendingPathComponent:SKIUnique()];
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[[NSFileManager defaultManager] createDirectoryAtPath:documentsPath withIntermediateDirectories:YES attributes:nil error:nil];
	});
	
	return documentsPath;
}

NSString *SKIMimeToExtension(NSString *mime) {
	if (!mime) {
		return @"mp4";
	}
	
	if ([mime isEqualToString:@"video/mp4"] || [mime isEqualToString:@"video/mpeg"]) {
		return @"mp4";
	} else if ([mime isEqualToString:@"video/x-m4v"]) {
		return @"m4v";
	} else if ([mime isEqualToString:@"video/3gpp"] || [mime isEqualToString:@"video/3gpp2"]) {
		return @"3gp";
	} else if ([mime isEqualToString:@"video/quicktime"]) {
		return @"mov";
	} else {
		return @"mp4";
	}
}

NSString *SKImd5(NSString *string) {
	const char *cStr = string.UTF8String;
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, (int)strlen(cStr), result ); // This is the md5 call
	return [NSString stringWithFormat:
			@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3],
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];
}

NSString *SKIDeviceSession(void) {
	static NSString *session = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		session = SKImd5(SKIUUID());
	});
	
	return session;
}

NSArray<NSString *> *SKIIABCategoriesFromAppleIDS(NSArray<NSString *> *ids) {
	NSMutableArray *iabs = [NSMutableArray array];
	
	for (NSString *aid in ids) {
		// just in case
		if (![aid respondsToSelector:@selector(integerValue)]) {
			continue;
		}
		
		NSString *iabCat = SKIIABCategoryFromAppleID([aid integerValue]);
		if (iabCat) {
			[iabs addObject:iabCat];
		}
	}
	
	return iabs;
}

NSString *SKIIABCategoryFromAppleID(NSInteger aid) {
	switch (aid) {
		case kSKICategoryBusiness:
			return @"IAB3";
		case kSKICategoryWeather:
			return nil;
		case kSKICategoryUtilities:
			return nil;
		case kSKICategoryTravel:
			return @"IAB20";
		case kSKICategorySports:
			return @"IAB17";
		case kSKICategorySocialNetworking:
			return nil;
		case kSKICategoryReference:
			return nil;
		case kSKICategoryProductivity:
			return nil;
		case kSKICategoryPhotoVideo:
			return @"IAB9-23";
		case kSKICategoryNews:
			return @"IAB12";
		case kSKICategoryNavigation:
			return nil;
		case kSKICategoryMusic:
			return @"IAB1-6";
		case kSKICategoryLifestyle:
			return nil;
		case kSKICategoryHealthFitness:
			return @"IAB7";
		case kSKICategoryGames:
			return @"IAB9-30";
		case kSKICategoryGamesAction:
			return nil;
		case kSKICategoryGamesAdventure:
			return nil;
		case kSKICategoryGamesArcade:
			return nil;
		case kSKICategoryGamesBoard:
			return @"IAB9-5";
		case kSKICategoryGamesCard:
			return @"IAB9-7";
		case kSKICategoryGamesCasino:
			return nil;
		case kSKICategoryGamesDice:
			return nil;
		case kSKICategoryGamesEducational:
			return nil;
		case kSKICategoryGamesFamily:
			return nil;
		case kSKICategoryGamesKids:
			return nil;
		case kSKICategoryGamesMusic:
			return nil;
		case kSKICategoryGamesPuzzle:
			return @"IAB9-5";
		case kSKICategoryGamesRacing:
			return nil;
		case kSKICategoryGamesRolePlaying:
			return @"IAB9-25";
		case kSKICategoryGamesSimulation:
			return nil;
		case kSKICategoryGamesSports:
			return nil;
		case kSKICategoryGamesStrategy:
			return nil;
		case kSKICategoryGamesTrivia:
			return nil;
		case kSKICategoryGamesWord:
			return nil;
		case kSKICategoryFinance:
			return @"IAB13";
		case kSKICategoryEntertainment:
			return @"IAB1";
		case kSKICategoryEducation:
			return @"IAB5";
		case kSKICategoryBooks:
			return @"IAB1-1";
		case kSKICategoryMedical:
			return nil;
		case kSKICategoryNewsstand:
			return @"IAB12";
		case kSKICategoryNewsstandNewsPolitics:
			return @"IAB11-4";
		case kSKICategoryNewsstandFashionStyle:
			return @"IAB18-3";
		case kSKICategoryNewsstandHomeGarden:
			return @"IAB10";
		case kSKICategoryNewsstandOutdoorsNature:
			return nil;
		case kSKICategoryNewsstandSportsLeisure:
			return nil;
		case kSKICategoryNewsstandAutomotive:
			return @"IAB2";
		case kSKICategoryNewsstandArtsPhotography:
			return nil;
		case kSKICategoryNewsstandBridesWeddings:
			return @"IAB14-7";
		case kSKICategoryNewsstandBusinessInvesting:
			return @"IAB13-7";
		case kSKICategoryNewsstandChildrensMagazines:
			return nil;
		case kSKICategoryNewsstandComputersInternet:
			return nil;
		case kSKICategoryNewsstandCookingFoodDrink:
			return nil;
		case kSKICategoryNewsstandCraftsHobbies:
			return @"IAB9-2";
		case kSKICategoryNewsstandElectronicsAudio:
			return nil;
		case kSKICategoryNewsstandEntertainment:
			return nil;
		case kSKICategoryNewsstandHealthMindBody:
			return nil;
		case kSKICategoryNewsstandHistory:
			return nil;
		case kSKICategoryNewsstandLiteraryMagazinesJournals:
			return nil;
		case kSKICategoryNewsstandMensInterest:
			return nil;
		case kSKICategoryNewsstandMoviesMusic:
			return nil;
		case kSKICategoryNewsstandParentingFamily:
			return nil;
		case kSKICategoryNewsstandPets:
			return nil;
		case kSKICategoryNewsstandProfessionalTrade:
			return nil;
		case kSKICategoryNewsstandRegionalNews:
			return nil;
		case kSKICategoryNewsstandScience:
			return @"IAB15";
		case kSKICategoryNewsstandTeens:
			return nil;
		case kSKICategoryNewsstandTravelRegional:
			return nil;
		case kSKICategoryNewsstandWomensInterest:
			return nil;
		case kSKICategoryCatalogs:
			return nil;
			
		default:
			return nil;
	}
}

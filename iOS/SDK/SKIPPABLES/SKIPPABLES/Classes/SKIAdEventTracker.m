//
//  SKIAdEventTracker.m
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import "SKIAdEventTracker.h"

#import "SKIConstants.h"
#import "NSArray+Util.h"
#import "SkippablesSDK.h"

#import <AdSupport/ASIdentifierManager.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

static void *event_dispatch_queue_tag = NULL;
dispatch_queue_t get_event_dispatch_queue() {
	static dispatch_queue_t _queue;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_queue = dispatch_queue_create("com.skippables.event", DISPATCH_QUEUE_SERIAL);
		event_dispatch_queue_tag = &event_dispatch_queue_tag;
		dispatch_queue_set_specific(_queue, event_dispatch_queue_tag, event_dispatch_queue_tag, NULL);
	});
	
	return _queue;
}

NSArray *SKIUtilReplaceNonJSONArray(NSArray *other);
NSDictionary *SKIUtilReplaceNonJSONDictionary(NSDictionary *other);

@interface SKIAdEventData : NSObject <NSCoding>

+ (instancetype)build:(void (^)(SKIAdEventData *event))block;

@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSData *data;

@property (copy, nonatomic) NSString *identifier;
@property (copy, nonatomic) NSString *sessionID;
@property (assign, nonatomic) BOOL logError;
@property (assign, nonatomic) BOOL logSession;

@end

@interface SKIAdEventTracker () {
	SCNetworkReachabilityRef reachability;
}

@property (assign, nonatomic) BOOL isReachable;
@property (strong, nonatomic) NSString *saveEventsPath;
@property (strong, nonatomic) NSMutableDictionary<NSString *, SKIAdEventData *> *eventDictionary;

@end

@interface SKIErrorCollector ()

+ (NSURL *)urlWithSessionID:(NSString *)sessionID;

@property (strong, atomic) NSMutableArray<SKIErrorCollectorBuilder *> *errorInfos;

@end

@implementation SKIAdEventTracker

static bool SKIAdEventTrackerIsReachable(SCNetworkReachabilityFlags flags) {
	bool isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
	bool needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
	bool isNetworkReachable = (isReachable && !needsConnection);
	
	return isNetworkReachable;
}

static void SKIAdEventTrackerReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
	
#pragma unused (target, flags)
	
	NSCAssert(info != NULL, @"info was NULL in SKIAdEventTrackerReachabilityCallback");
	
	NSCAssert([(__bridge NSObject*) info isKindOfClass: [SKIAdEventTracker class]], @"info was wrong class in SKIAdEventTrackerReachabilityCallback");
	
	
	
	SKIAdEventTracker* noteObject = (__bridge SKIAdEventTracker *)info;
	noteObject.isReachable = SKIAdEventTrackerIsReachable(flags);
	
	// Post a notification to notify the client that the network reachability changed.
	
//	[[NSNotificationCenter defaultCenter] postNotificationName: kReachabilityChangedNotification object: noteObject];
	
}

+ (void)load {
	[super load];
	
	[[self defaultTracker] registerApplicationNotifications];
}

+ (instancetype)defaultTracker {
	static SKIAdEventTracker *defaultTracker = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		defaultTracker = [[self alloc] init];
	});
	
	return defaultTracker;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		struct sockaddr_in zeroAddress;
		bzero(&zeroAddress, sizeof(zeroAddress));
		zeroAddress.sin_len = sizeof(zeroAddress);
		zeroAddress.sin_family = AF_INET;
		
		reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zeroAddress);
		SCNetworkReachabilityFlags flags;
		if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
			_isReachable = SKIAdEventTrackerIsReachable(flags);
		}
		SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
		if (SCNetworkReachabilitySetCallback(reachability, SKIAdEventTrackerReachabilityCallback, &context)) {
			SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
		}
	}
	return self;
}

- (NSString *)saveEventsPath {
	if (!_saveEventsPath) {
		NSString *skiCachePath = SKICachePath();
		
		self.saveEventsPath = [skiCachePath stringByAppendingPathComponent:@"skie"];
	}
	
	return _saveEventsPath;
}

- (void)loadEvents {
	NSString *eventsPath = self.saveEventsPath;
	if ([[NSFileManager defaultManager] fileExistsAtPath:eventsPath]) {
		@try {
			self.eventDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:eventsPath];
		} @catch(NSException *e) {
			
		}
	}
	
	if (!self.eventDictionary) {
		self.eventDictionary = [NSMutableDictionary dictionary];
	} else {
		NSDate *now = [NSDate date];
		for (NSString *identifier in self.eventDictionary.allKeys) {
			SKIAdEventData *info = self.eventDictionary[identifier];
			NSDate *expiration = info.date;
			if ([now compare:expiration] == NSOrderedDescending) {
				[self.eventDictionary removeObjectForKey:identifier];
				[self saveEvents];
				
				continue;
			}
			
			[self requestEventWithIdentifier:identifier callback:nil];
		}
	}
}

- (void)saveEvents {
	NSString *eventsPath = self.saveEventsPath;
	if (event_dispatch_queue_tag != NULL && dispatch_get_specific(event_dispatch_queue_tag)) {
		[NSKeyedArchiver archiveRootObject:self.eventDictionary toFile:eventsPath];
	} else {
		dispatch_async(get_event_dispatch_queue(), ^{
			[NSKeyedArchiver archiveRootObject:self.eventDictionary toFile:eventsPath];
		});
	}
}

- (void)registerApplicationNotifications {
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	
	[center addObserver:self selector:@selector(applicationDidFinishLaunchingNotification:) name:UIApplicationDidFinishLaunchingNotification object:nil];
	[center addObserver:self selector:@selector(applicationWillTerminateNotification:) name:UIApplicationWillTerminateNotification object:nil];
}

- (void)applicationDidFinishLaunchingNotification:(NSNotification *)notification {
	[self loadEvents];
	
	NSString *installPath = [SKIDocumentsPath() stringByAppendingPathComponent:@"install"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:installPath]) {
		if ([[NSFileManager defaultManager] createFileAtPath:installPath contents:nil attributes:nil]) {
			[self trackEvent:^(SKIAdEventTrackerBuilder * _Nonnull e) {
				e.url = [NSURL URLWithString:SKIPPABLES_INSTALL_URL];
				e.expires = NO;
				e.info = [self installData];
			}];
		}
	}
}

- (void)applicationWillTerminateNotification:(NSNotification *)notification {
	[self saveEvents];
}

- (NSDictionary *)installData {
	NSMutableDictionary *data = [NSMutableDictionary dictionary];
	
	NSString *bundle = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleIdentifierKey];
	NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString] ?: @"00000000-0000-0000-0000-000000000000";
	
	data[@"event_unix"] = [NSString stringWithFormat:@"%.f", [[NSDate date] timeIntervalSince1970]];
	
	data[@"bundle"] = bundle;
	data[@"ifa"] = idfa;
	data[@"ua"] = SKIUserAgent();
	
	NSString *deviceName = SKIDeviceName();
	if (deviceName) {
		data[@"model"] = deviceName;
		
		NSString *deviceModelName = SKIDeviceModelName();
		if (deviceModelName) {
			data[@"hwv"] = deviceModelName;
		}
	}
	
	data[@"os"] = @"iOS";
	data[@"osv"] = [[UIDevice currentDevice] systemVersion];
	data[@"devicetype"] = @(SKIDeviceType());
	
	CGSize screenSize = SKIOrientationIndependentScreenBounds().size;
	CGFloat scale = [[UIScreen mainScreen] scale];
	data[@"screen"] = @{@"w": @(screenSize.width), @"h": @(screenSize.height), @"s":@(scale)};
	
	CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
	CTCarrier *carrier = [networkInfo subscriberCellularProvider];
	
	NSString *carrierName = carrier.carrierName;
	if (carrierName) {
		data[@"carrier"] = carrierName;
	}
	
	NSString *mcc = carrier.mobileCountryCode;
	NSString *mnc = carrier.mobileNetworkCode;
	if (mcc && mnc) {
		data[@"carriercode"] = [mcc stringByAppendingString:mnc];
	}
	
	data[@"utcoffset"] = @(SKIUTCOffset());
	
	return data;
}

- (void)setIsReachable:(BOOL)isReachable {
	if (!_isReachable && isReachable) {
		[self resendEvents];
	}
	
	_isReachable = isReachable;
}

- (void)resendEvents {
	for (NSString *identifier in self.eventDictionary.allKeys) {
		dispatch_async(get_event_dispatch_queue(), ^{
			[self requestEventWithIdentifier:identifier callback:nil];
		});
	}
}

- (void)trackEvent:(void (^)(SKIAdEventTrackerBuilder * _Nonnull))block {
	SKIAdEventTrackerBuilder *build = [[SKIAdEventTrackerBuilder alloc] init];
	block(build);
	
	SKIAdEventData *event = [SKIAdEventData build:^(SKIAdEventData *event) {
		event.url = build.url;
		event.sessionID = build.sessionID;
		event.identifier = build.identifier;
		event.logError = build.logError;
		event.logSession = build.logSession;
		event.date = build.expires ? [[NSDate date] dateByAddingTimeInterval:86400] : [NSDate distantFuture];
		
		if (build.info) {
			NSDictionary *sani = SKIUtilReplaceNonJSONDictionary(build.info);
			event.data = [NSJSONSerialization dataWithJSONObject:sani options:0 error:nil];
		}
	}];
	
	
	NSString *identifier = SKIUUID();
	[self.eventDictionary setObject:event forKey:identifier];
	[self saveEvents];
	
	[self requestEventWithIdentifier:identifier callback:nil];
}

- (void)sendReportWithDeviceData:(NSDictionary *)deviceInfo adId:(NSString *)adId adUnitId:(NSString *)adUnitId email:(NSString *)email message:(NSString *)message {
	if (!adId || !adUnitId) {
		return;
	}
	
	NSMutableDictionary *data = [NSMutableDictionary dictionary];
	if (adId) {
		data[@"adid"] = adId;
	}
	data[@"adunitid"] = adUnitId;
	data[@"email"] = email;
	data[@"message"] = message;
	
	if (deviceInfo.count > 0) {
		NSString *deviceInfoString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:deviceInfo options:0 error:nil] encoding:NSUTF8StringEncoding];
		if (deviceInfoString) {
			data[@"deviceinfo"] = deviceInfoString;
		}
	}
	
	[self trackEvent:^(SKIAdEventTrackerBuilder * _Nonnull e) {
		e.url = [NSURL URLWithString:SKIPPABLES_REPORT_URL];
		e.info = data;
	}];
}

- (void)requestEventWithIdentifier:(NSString *)identifier callback:(void (^_Nullable)(BOOL success))callback {
	SKIAdEventData *info = self.eventDictionary[identifier];
	if (!info) {
		return;
	}
	
	NSURL *url = info.url;
	if (!url) {
		return;
	}
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	request.timeoutInterval = 15;
	request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
	
	if (info.data.length > 0) {
		request.HTTPMethod = @"POST";
		request.HTTPBody = info.data;
		[request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	} else {
		request.HTTPMethod = @"GET";
	}
	
	DLog(@"send request: %@", url.absoluteString);
	
	NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		if (error) {
			DLog(@"Event: %@ failed with error: %@", identifier, error);
			if ([error.domain isEqualToString:NSURLErrorDomain] &&
				(error.code == NSURLErrorAppTransportSecurityRequiresSecureConnection || error.code == NSURLErrorCannotFindHost)) {
				[self.eventDictionary removeObjectForKey:identifier];
				[self saveEvents];
			}
			
			if (info.logError) {
				[self trackEvent:^(SKIAdEventTrackerBuilder * _Nonnull e) {
					e.url = [SKIErrorCollector urlWithSessionID:info.sessionID];// TODO: temp [NSURL URLWithString:SKIPPABLES_SDK_EVENT_REPORT_URL];
					e.sessionID = info.sessionID;
					e.info = [[SKIErrorCollectorBuilder build:^(SKIErrorCollectorBuilder * _Nonnull e) {
						e.type = SKIErrorCollectorTypeHTTP;
						e.place = @"requestEventWithIdentifier";
						e.underlyingError = error;
						e.otherInfo = @{
										@"url": info.url ?: [NSNull null]
										};
					}] dictionaryValue];
				}];
			}
			if (info.logSession && info.sessionID && info.identifier) {
				[[[SKISDKSessionLogger loggerWithSessionID:info.sessionID] build:^(SKISDKSessionLog * _Nonnull log) {
					log.idenitifier = @"trackUrl.report";
					log.info = @{
								 @"sessionID": info.sessionID ?: [NSNull null],
								 @"identifier": info.identifier ?: [NSNull null],
								 @"url": info.url ?: [NSNull null]
								 };
					log.error = error;
				}] report];
			}
			
			if (callback != nil) {
				callback(NO);
			}
			return;
		}
		
		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
		if (info.logSession && info.sessionID && info.identifier) {
			NSString *res = nil;
			if (data.length > 0) {
				res = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			}
			[[[SKISDKSessionLogger loggerWithSessionID:info.sessionID] build:^(SKISDKSessionLog * _Nonnull log) {
				log.idenitifier = @"trackUrl.report";
				log.info = @{
							 @"sessionID": info.sessionID ?: [NSNull null],
							 @"identifier": info.identifier ?: [NSNull null],
							 @"url": info.url ?: [NSNull null],
							 @"statusCode": @(httpResponse.statusCode),
							 @"headers": SKIUtilReplaceNonJSONDictionary(httpResponse.allHeaderFields ?: @{}),
							 @"response": res ?: [NSNull null]
							 };
			}] report];
		}
		if (httpResponse.statusCode != 200 && info.logError) { // TODO: temp non 200 only
			NSString *res = @"";
			if (data.length > 0) {
				res = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			}
			[self trackEvent:^(SKIAdEventTrackerBuilder * _Nonnull e) {
				e.url = [SKIErrorCollector urlWithSessionID:info.sessionID];// TODO: temp[NSURL URLWithString:SKIPPABLES_SDK_EVENT_REPORT_URL];
				e.sessionID = info.sessionID;
				e.info = [[SKIErrorCollectorBuilder build:^(SKIErrorCollectorBuilder * _Nonnull e) {
					e.type = SKIErrorCollectorTypeHTTP;
					e.place = @"requestEventWithIdentifier";
					e.otherInfo = @{
									@"url": info.url ?: [NSNull null],
									@"statusCode": @(httpResponse.statusCode),
									@"headers": SKIUtilReplaceNonJSONDictionary(httpResponse.allHeaderFields ?: @{}),
									@"response": res ?: [NSNull null]
									};
				}] dictionaryValue];
			}];
		}
		
		if (httpResponse.statusCode != 200) {
			DLog(@"Event: %@ failed with status code: %i, %@", identifier, (int)httpResponse.statusCode, httpResponse.URL.absoluteString);
//			if (httpResponse.statusCode != 404) {
//				if (callback != nil) {
//					callback(NO);
//				}
//				return;
//			}
		}
		
		[self.eventDictionary removeObjectForKey:identifier];
		[self saveEvents];
		
		if (callback != nil) {
			callback(YES);
		}
	}];
	[task resume];
}

@end

@implementation SKIAdEventData

+ (instancetype)build:(void (^)(SKIAdEventData *))block {
	SKIAdEventData *event = [[SKIAdEventData alloc] init];
	block(event);
	return event;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
	self = [super init];
	if (self) {
		_url = [aDecoder decodeObjectForKey:@"url"];
		_date = [aDecoder decodeObjectForKey:@"date"];
		_data = [aDecoder decodeObjectForKey:@"data"];
		_identifier = [aDecoder decodeObjectForKey:@"identifier"];
		_sessionID = [aDecoder decodeObjectForKey:@"sessionID"];
		_logError = [aDecoder decodeBoolForKey:@"logError"];
		_logSession = [aDecoder decodeBoolForKey:@"logSession"];
	}
	return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
	[aCoder encodeObject:_url forKey:@"url"];
	[aCoder encodeObject:_date forKey:@"date"];
	[aCoder encodeObject:_data forKey:@"data"];
	[aCoder encodeObject:_identifier forKey:@"identifier"];
	[aCoder encodeObject:_sessionID forKey:@"sessionID"];
	[aCoder encodeBool:_logError forKey:@"logError"];
	[aCoder encodeBool:_logSession forKey:@"logSession"];
}

@end

@implementation SKIErrorCollector

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.errorInfos = [NSMutableArray array];
	}
	return self;
}

+ (NSURL *)urlWithSessionID:(NSString *)sessionID {
	NSURL *url = nil;
	if (sessionID) {
		NSURLComponents *components = [NSURLComponents componentsWithString:SKIPPABLES_SDK_ERROR_REPORT_URL];
		NSMutableArray<NSURLQueryItem *> *query = components.queryItems.mutableCopy ?: [NSMutableArray array];
		[query addObject:[NSURLQueryItem queryItemWithName:@"sessionID" value:sessionID]];
		components.queryItems = query;
		url = components.URL;
	}
	
	return url ?: [NSURL URLWithString:SKIPPABLES_ERROR_REPORT_URL];
}

- (void)collect:(void (^)(SKIErrorCollectorBuilder *))block {
	SKIErrorCollectorBuilder *build = [[SKIErrorCollectorBuilder alloc] init];
	block(build);
	
	NSURL *url = [SKIErrorCollector urlWithSessionID:self.sessionID];
	
	NSData *data = build.jsonDataValue;
	if (data) {
		[[SKIAdEventTracker defaultTracker] trackEvent:^(SKIAdEventTrackerBuilder * _Nonnull e) {
			e.url = url;
			e.info = build.dictionaryValue;
			e.sessionID = self.sessionID;
		}];
	}
}

@end

NSDictionary *SKIUtilReplaceNonJSONDictionary(NSDictionary *other) {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	for (NSString *key in other) {
		id value = other[key];
		if ([value isKindOfClass:[NSString class]] ||
			[value isKindOfClass:[NSNumber class]] ||
			[value isKindOfClass:[NSNull class]]) {
			dict[key] = value;
		} else if ([value isKindOfClass:[NSURL class]]) {
			dict[key] = [(NSURL *)value absoluteString];
		} else if ([value isKindOfClass:[NSDictionary class]]) {
			dict[key] = SKIUtilReplaceNonJSONDictionary(value);
		} else if ([value isKindOfClass:[NSArray class]]) {
			dict[key] = SKIUtilReplaceNonJSONArray(value);
		}
	}
	
	return dict;
}

NSArray *SKIUtilReplaceNonJSONArray(NSArray *other) {
	NSMutableArray *arr = [NSMutableArray array];
	for (id value in other) {
		if ([value isKindOfClass:[NSString class]] ||
			[value isKindOfClass:[NSNumber class]] ||
			[value isKindOfClass:[NSNull class]]) {
			[arr addObject:value];
		} else if ([value isKindOfClass:[NSURL class]]) {
			[arr addObject:[(NSURL *)value absoluteString]];
		} else if ([value isKindOfClass:[NSDictionary class]]) {
			[arr addObject:SKIUtilReplaceNonJSONDictionary(value)];
		} else if ([value isKindOfClass:[NSArray class]]) {
			[arr addObject:SKIUtilReplaceNonJSONArray(value)];
		}
	}
	
	return arr;
}

@implementation SKIErrorCollectorBuilder

+ (instancetype)build:(void (^)(SKIErrorCollectorBuilder * _Nonnull))block {
	SKIErrorCollectorBuilder *build = [[SKIErrorCollectorBuilder alloc] init];
	block(build);
	return build;
}

- (NSDictionary *)dictionaryValue {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	dict[@"type"] = @(self.type);
	if (_place.length > 0) {
		dict[@"place"] = _place;
	}
	if (_desc.length > 0) {
		dict[@"description"] = _desc;
	}
	if (_underlyingError) {
		dict[@"underlyingError"] = @{
									 @"domain": _underlyingError.domain,
									 @"code": @(_underlyingError.code),
									 @"description": _underlyingError.localizedDescription,
									 @"userInfo": SKIUtilReplaceNonJSONDictionary(_underlyingError.userInfo)
									 };
	}
	if (_otherInfo.count > 0) {
		dict[@"info"] = SKIUtilReplaceNonJSONDictionary(_otherInfo);
	}
	
	return dict;
}

- (NSString *)jsonStringValue {
	NSData *data = self.jsonDataValue;
	if (data) {
		NSString *stringValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		return  stringValue;
	}
	
	return nil;
}

- (NSData *)jsonDataValue {
	return [NSJSONSerialization dataWithJSONObject:self.dictionaryValue options:0 error:nil];
}

@end

@implementation SKIAdEventTrackerBuilder

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.expires = YES;
	}
	return self;
}

@end

@implementation SKISDKSessionLog

+ (nonnull instancetype)log {
	return [[SKISDKSessionLog alloc] init];
}

+ (nonnull instancetype)build:(void (^__nonnull)(SKISDKSessionLog * _Nonnull))block {
	SKISDKSessionLog *log = [[SKISDKSessionLog alloc] init];
	block(log);
	
	return log;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.date = [NSDate date];
	}
	return self;
}

@end

@interface SKISDKSessionLogger ()

@property (strong, nonatomic) NSMutableArray<SKISDKSessionLog *> *logs;

@end

@implementation SKISDKSessionLogger

+ (instancetype)logger {
	return [[SKISDKSessionLogger alloc] init];
}

+ (instancetype)loggerWithSessionID:(NSString *)sessionID {
	SKISDKSessionLogger *logger = [[SKISDKSessionLogger alloc] init];
	logger.sessionID = sessionID;
	
	return logger;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.logs = [NSMutableArray array];
		self.canLog = YES;
	}
	return self;
}

- (void)setCanLog:(BOOL)canLog {
	_canLog = canLog;
	if (_canLog == NO) {
		[self.logs removeAllObjects];
	}
}

- (instancetype)build:(void (^)(SKISDKSessionLog * _Nonnull))block {
	if (_canLog == NO) {
		return self;
	}
	
	SKISDKSessionLog *log = [SKISDKSessionLog build:block];
	[self.logs addObject:log];
	
	return self;
}

- (void)report {
	if (_canLog == NO) {
		return;
	}
	
	NSArray *logs = [self.logs _skiCompactMap:^NSObject * _Nonnull(SKISDKSessionLog * _Nonnull obj) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		if (obj.idenitifier) {
			dict[@"identifier"] = obj.idenitifier;
		}
		if (obj.date) {
			dict[@"timestamp"] = @(obj.date.timeIntervalSince1970);
		}
		if (obj.desc) {
			dict[@"description"] = obj.desc;
		}
		if (obj.error.userInfo) {
			dict[@"error"] =  @{
								@"domain": obj.error.domain ?: [NSNull null],
								@"code": @(obj.error.code),
								@"description": obj.error.localizedDescription ?: [NSNull null],
								@"userInfo": SKIUtilReplaceNonJSONDictionary(obj.error.userInfo) ?: [NSNull null]
								};
		}
		if (obj.info.count > 0) {
			dict[@"info"] = SKIUtilReplaceNonJSONDictionary(obj.info);
		}
		
		return dict;
	}];
	
	[self.logs removeAllObjects];
	
	NSDictionary *log = @{
						  @"sessionID": self.sessionID ?: [NSNull null],
						  @"unique": SKIUnique() ?: [NSNull null],
						  @"session": SKIDeviceSession(),
						  @"ifa": [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString] ?: @"00000000-0000-0000-0000-000000000000",
						  @"sdkVersion": kSKISDKVersion,
						  @"logs": logs ?: [NSNull null]
						  };
	NSData *data = [NSJSONSerialization dataWithJSONObject:log options:NSJSONWritingPrettyPrinted error:nil];
	if (data) {
		NSURL *url = [NSURL URLWithString:SKIPPABLES_SDK_EVENT_REPORT_URL];
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
		request.timeoutInterval = 15;
		request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
		
		request.HTTPMethod = @"POST";
		request.HTTPBody = data;
		[request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
		[[[NSURLSession sharedSession] dataTaskWithRequest:request] resume];
	}
	
#if DEBUG
	DLog(@"----------------------------");
	DLog(@"report: \n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
	DLog(@"----------------------------");
#endif
}

@end

//
//  SKIAdEventTracker.m
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import "SKIAdEventTracker.h"

#import "SKIConstants.h"

#import <AdSupport/ASIdentifierManager.h>

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

@interface SKIAdEventData : NSObject <NSCoding>

+ (instancetype)dataWithUrl:(NSURL *)url expiration:(NSDate *)expiration data:(NSData *)data;

@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSData *data;

@end

@interface SKIAdEventTracker () {
	SCNetworkReachabilityRef reachability;
}

@property (assign, nonatomic) BOOL isReachable;
@property (strong, nonatomic) NSString *saveEventsPath;
@property (strong, nonatomic) NSMutableDictionary<NSString *, SKIAdEventData *> *eventDictionary;

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
			NSString *bundle = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleIdentifierKey];
			NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString] ?: @"00000000-0000-0000-0000-000000000000";
			NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"bundle" : bundle ?: @"", @"idfa" : bundle ?: idfa} options:0 error:nil];
			[self trackEventRequestWithUrl:[NSURL URLWithString:SKIPPABLES_INSTALL_URL] expirationDate:[NSDate distantFuture] data:data];
		}
	}
}

- (void)applicationWillTerminateNotification:(NSNotification *)notification {
	[self saveEvents];
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

- (void)trackEventRequestWithUrl:(NSURL *)url {
	NSString *identifier = SKIUUID();
	[self.eventDictionary setObject:[SKIAdEventData dataWithUrl:url expiration:[[NSDate date] dateByAddingTimeInterval:86400] data:nil] forKey:identifier];
	[self saveEvents];
	
	[self requestEventWithIdentifier:identifier callback:nil];
}

- (void)trackEventRequestWithUrl:(NSURL *)url expirationDate:(NSDate *)date {
	NSString *identifier = SKIUUID();
	[self.eventDictionary setObject:[SKIAdEventData dataWithUrl:url expiration:date data:nil] forKey:identifier];
	[self saveEvents];
	
	[self requestEventWithIdentifier:identifier callback:nil];
}

- (void)trackEventRequestWithUrl:(NSURL *)url expirationDate:(NSDate *)date data:(NSData *)data {
	NSString *identifier = SKIUUID();
	[self.eventDictionary setObject:[SKIAdEventData dataWithUrl:url expiration:date data:data] forKey:identifier];
	[self saveEvents];
	
	[self requestEventWithIdentifier:identifier callback:nil];
}

- (void)trackErrorRequestWithUrl:(NSURL *)url {
	[self trackEventRequestWithUrl:url];
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
	
	NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		if (error) {
			DLog(@"Event: %@ failed with error: %@", identifier, error);
			if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorAppTransportSecurityRequiresSecureConnection) {
				[self.eventDictionary removeObjectForKey:identifier];
				[self saveEvents];
			}
			
			if (callback != nil) {
				callback(NO);
			}
			return;
		}
		
		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
		if (httpResponse.statusCode != 200) {
			DLog(@"Event: %@ failed with status code: %i", identifier, (int)httpResponse.statusCode);
			if (httpResponse.statusCode != 404 ) {
				if (callback != nil) {
					callback(NO);
				}
				return;
			}
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

+ (instancetype)dataWithUrl:(NSURL *)url expiration:(NSDate *)expiration data:(NSData *)data {
	SKIAdEventData *event = [[SKIAdEventData alloc] init];
	event.url = url;
	event.date = expiration;
	event.data = data;
	
	return event;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
	self = [super init];
	if (self) {
		_url = [aDecoder decodeObjectForKey:@"url"];
		_date = [aDecoder decodeObjectForKey:@"date"];
		_data = [aDecoder decodeObjectForKey:@"data"];
	}
	return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
	[aCoder encodeObject:_url forKey:@"url"];
	[aCoder encodeObject:_date forKey:@"date"];
	[aCoder encodeObject:_data forKey:@"data"];
}

@end
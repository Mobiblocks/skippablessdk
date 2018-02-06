//
//  SKIGeo.m
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import "SKIGeo.h"

#import <CoreLocation/CoreLocation.h>

#import "SKIConstants.h"

#if DEBUG
#define LOCATION_INTERVAL (0.5 * 60)
#else
#define LOCATION_INTERVAL (10 * 60)
#endif

@interface SKIGeo () <CLLocationManagerDelegate>

@property (strong, atomic) NSMutableDictionary *addressCache;
@property (strong, nonatomic) CLLocationManager *manager;
@property (assign, atomic) BOOL requestInProcess;
@property (strong, atomic) NSMutableArray *callbacks;

@end

@implementation SKIGeo

+ (instancetype)defaultGeo {
	static SKIGeo *defaultGeo = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		defaultGeo = [[self alloc] init];
	});
	
	return defaultGeo;
}

+ (void)geoLocationWithCallback:(SKIGeoLocationCallback)callbackBlock {
	[[SKIGeo defaultGeo] geoLocationWithCallback:callbackBlock];
}

+ (void)geocodeAddressString:(NSString *)addressString callback:(void (^)(CLLocation *_Nullable location))callbackBlock {
	[[SKIGeo defaultGeo] geocodeAddressString:addressString callback:callbackBlock];
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.addressCache = [NSMutableDictionary dictionary];
		self.callbacks = [NSMutableArray array];
		
		SKISyncOnMain(^{
			self.manager = [[CLLocationManager alloc]  init];
			self.manager.delegate = self;
			self.manager.distanceFilter = kCLDistanceFilterNone;
			self.manager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
		});
	}
	
	return self;
}

- (void)geoLocationWithCallback:(SKIGeoLocationCallback)callbackBlock {
	if (![CLLocationManager locationServicesEnabled]) {
		callbackBlock(nil);
		return;
	}
	
	if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
		callbackBlock(nil);
		return;
	}
	
	CLLocation *lastLocation = self.manager.location;
	if (lastLocation) {
		NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:lastLocation.timestamp];
		if (interval > LOCATION_INTERVAL) {
			[self.callbacks addObject:[callbackBlock copy]];
			[self maybeRequestLocation];
		} else {
			callbackBlock(lastLocation);
		}
	} else {
		[self.callbacks addObject:[callbackBlock copy]];
		[self maybeRequestLocation];
	}
}

- (void)maybeRequestLocation {
//	if (self.requestInProcess) {
//		return;
//	}
	
	self.requestInProcess = YES;
	SKIAsyncOnMain(^{
		[self.manager requestLocation];
	});
}

- (void)geocodeAddressString:(NSString *)addressString callback:(void (^)(CLLocation *_Nullable location))callbackBlock {
	if (!addressString) {
#if DEBUG
		NSAssert(addressString != nil, @"address string should not be nil");
#endif
		
		callbackBlock(nil);
		return;
	}
	
	NSObject *locationObject = self.addressCache[addressString];
	if (locationObject == [NSNull null]) {
		callbackBlock(nil);
		return;
	} else if ([locationObject isKindOfClass:[CLLocation class]]) {
		callbackBlock((CLLocation *)locationObject);
		return;
	}
	
	CLGeocoder *geoc = [[CLGeocoder alloc] init];
	[geoc geocodeAddressString:addressString completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
		if (error) {
			callbackBlock(nil);
			return;
		}
		if (placemarks.count == 0) {
			self.addressCache[addressString] = [NSNull null];
			callbackBlock(nil);
			return;
		}
		
		CLPlacemark *placemark = nil;
		for (CLPlacemark *mark in placemarks) {
			if (mark.location) {
				placemark = mark;
				break;
			}
		}
		
		if (placemark.location) {
			self.addressCache[addressString] = placemark.location;
			callbackBlock(placemark.location);
			return;
		}
		
		self.addressCache[addressString] = [NSNull null];
		callbackBlock(nil);
	}];
}

#pragma mark - Location Delegates

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
	CLLocation *lastLocation = locations.lastObject;
	
	NSArray *callbacks = self.callbacks.copy;
	[self.callbacks removeAllObjects];
	for (SKIGeoLocationCallback callback in callbacks) {
		callback(lastLocation);
	}
	
	self.requestInProcess = NO;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSArray *callbacks = self.callbacks.copy;
	
	[self.callbacks removeAllObjects];
	for (SKIGeoLocationCallback callback in callbacks) {
		callback(nil);
	}
	
	self.requestInProcess = NO;
}

@end

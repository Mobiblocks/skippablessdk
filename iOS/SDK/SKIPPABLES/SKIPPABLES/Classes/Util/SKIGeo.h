//
//  SKIGeo.h
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CLLocation;

typedef void(^SKIGeoLocationCallback)(CLLocation *_Nullable location);

@interface SKIGeo : NSObject

//+ (instancetype)defaultGeo;
//- (void)geoLocationWithCallback:(SKIGeoLocationCallback)callbackBlock;
//- (void)geocodeAddressString:(NSString *)addressString callback:(void (^)(CLLocation *_Nullable location))callbackBlock;

+ (void)geoLocationWithCallback:(SKIGeoLocationCallback)callbackBlock;
+ (void)geocodeAddressString:(NSString *)addressString callback:(void (^)(CLLocation *_Nullable location))callbackBlock;

@end

NS_ASSUME_NONNULL_END

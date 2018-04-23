//
//  SKIAdRequest.m
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import <sys/sysctl.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <AdSupport/ASIdentifierManager.h>
#import <CoreLocation/CoreLocation.h>

#import "SKIAdRequest.h"
#import "SKIAdRequest_Private.h"
#import "SKIAdRequestError_Private.h"
#import "SKIAdRequestResponse.h"

#import "SKIVASTUrl.h"
#import "SKIVASTCompressedCreative.h"

#import "SKIAdEventTracker.h"

#import "SKIConstants.h"
#import "SKIGeo.h"
#import "SKIAsync.h"
#import "SKIAdSize.h"

SKIAdSize const kSKIAdSizeFullscreen = {CGFLOAT_MAX, CGFLOAT_MAX};

struct SKIAdGeoLocation {
	SKIRTBLocationType type;
	CGFloat latitude;
	CGFloat longitude;
	CGFloat accuracyInMeters;
};
typedef struct CG_BOXABLE SKIAdGeoLocation SKIAdGeoLocation;

const SKIAdGeoLocation SKIAdGeoLocationZero = {kSKIRTBLocationTypeUnknown, 0.f, 0.f, 0.f};

bool SKIAdGeoLocationEqualToLocation(SKIAdGeoLocation l1, SKIAdGeoLocation l2) {
	return l1.latitude == l2.latitude && l1.longitude == l2.longitude;
}

bool SKIAdGeoLocationIsZero(SKIAdGeoLocation l) {
	return l.type == kSKIRTBLocationTypeUnknown;
}

NSString *SKIGenderToString(SKIGender gender) {
	switch (gender) {
		case kSKIGenderUnknown:
			return nil;
		case kSKIGenderMale:
			return @"M";
		case kSKIGenderFemale:
			return @"F";
		case kSKIGenderOther:
			return @"O";
			
		default:
			return nil;
	}
}

NSString *SKIUserAgent() {
	static NSString *ua = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		SKISyncOnMain(^{
			UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
			ua = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
		});
	});
	
	return ua;
}

@interface SKIAdRequest ()

@property (copy, nonatomic) NSString *adUnitID;

#pragma mark Banner

@property (assign, nonatomic) SKIAdType adType;
@property (assign, nonatomic) SKIAdSize adSize;

@property (assign, nonatomic) SKIAdGeoLocation geoGPSLocation;
@property (assign, nonatomic) SKIAdGeoLocation geoProvidedLocation;
@property (assign, nonatomic) SKIAdGeoLocation geoProvidedByDescriptionLocation;

@property (weak, nonatomic) id<SKIAdRequestDelegate> delegate;

@end

@implementation SKIAdRequest

+ (instancetype)request {
	return [[self alloc] init];
}

- (instancetype)init {
	self = [super init];
	if (self) {
		self.geoGPSLocation = SKIAdGeoLocationZero;
		self.geoProvidedLocation = SKIAdGeoLocationZero;
		self.geoProvidedByDescriptionLocation = SKIAdGeoLocationZero;
	}
	return self;
}

- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude accuracy:(CGFloat)accuracyInMeters {
	self.geoProvidedLocation = (SKIAdGeoLocation){kSKIRTBLocationTypeUserProvided, latitude, longitude, accuracyInMeters};
}

- (void)setLocationWithDescription:(NSString *)locationWithDescription {
	_locationWithDescription = locationWithDescription.copy;
	
	self.geoProvidedByDescriptionLocation = SKIAdGeoLocationZero;
	
	if (!locationWithDescription) {
		return;
	}

	CLGeocoder *geoc = [[CLGeocoder alloc] init];
	[geoc geocodeAddressString:locationWithDescription completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
		if (error || placemarks.count == 0) {
			return;
		}

		for (CLPlacemark *mark in placemarks) {
			if (mark.location) {
				CLLocation *location = mark.location;
				CLLocationCoordinate2D coord = location.coordinate;
				self.geoProvidedByDescriptionLocation = (SKIAdGeoLocation){kSKIRTBLocationTypeUserProvided, coord.latitude, coord.longitude, MAX(location.horizontalAccuracy, location.verticalAccuracy)};
				break;
			}
		}
	}];
}

#pragma mark Serialization

- (NSDictionary<NSString *, NSObject *> *)initialDictionaryValue {
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	dictionary[@"test"] = @(self.test);

	if (self.adUnitID) {
#ifdef SC_BUILD
		dictionary[@"scAppId"] = self.adUnitID;
#else
		dictionary[@"adUnitId"] = self.adUnitID;
#endif
	}
	
	SKIAdSize adSize = self.adSize;
	if (SKIAdSizeEqualToSize(adSize, kSKIAdSizeFullscreen)) {
		adSize = SKIAdSizeFromCGSize(SKIOrientationIndependentScreenBounds().size);
	}
	switch (self.adType) {
		case kSKIAdTypeBannerText:
			dictionary[@"banner"] = @{ @"type" : @"txt", @"w" : @(adSize.width), @"h" : @(adSize.height) };
			break;
		case kSKIAdTypeBannerImage:
			dictionary[@"banner"] = @{ @"type" : @"img", @"w" : @(adSize.width), @"h" : @(adSize.height) };
			break;
		case kSKIAdTypeBannerRichmedia:
			dictionary[@"banner"] = @{ @"type" : @"richmedia", @"w" : @(adSize.width), @"h" : @(adSize.height) };
			break;
		case kSKIAdTypeInterstitialVideo: {
			dictionary[@"video"] = @{
				@"w" : @(adSize.width),
				@"h" : @(adSize.height),
				@"mimes" : @[ @"video/mp4", @"video/quicktime", @"video/x-m4v", @"video/3gpp", @"video/3gpp2" ],
				@"protocols" : @[ @(3), @(6), @(7) ],
				@"linearity" : @(1),
				@"skip" : @(1)
			};
			break;
		}
			
		case kSKIAdTypeInterstitial:
		default:
			NSAssert(NO, @"invalid ad type");
			break;
	}
	
	NSMutableDictionary *app = [NSMutableDictionary dictionary];
	
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleNameKey];
	if (appName.length > 0) {
		app[@"name"] = appName;
	}
	
	NSString *appBundle = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleIdentifierKey];
	if (appBundle.length > 0) {
		app[@"bundle"] = appBundle;
	}
	
	NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleVersionKey];
	if (appVersion.length > 0) {
		app[@"ver"] = appVersion;
	}
	
	if (app.count > 0) {
		dictionary[@"app"] = app;
	}

	NSMutableDictionary *device = [NSMutableDictionary dictionary];
	device[@"ua"] = SKIUserAgent();
	
//	NSMutableDictionary *geo = [NSMutableDictionary dictionary];
//	geo[@"utcoffset"] = @(SKIUTCOffset());
//
//	SKIAdGeoLocation geoLocation = [self bestGeoLocation];
//	if (!SKIAdGeoLocationIsZero(geoLocation)) {
//		geo[@"type"] = @(geoLocation.type);
//		geo[@"lat"] = @(geoLocation.latitude);
//		geo[@"lon"] = @(geoLocation.longitude);
//		geo[@"accuracy"] = @(geoLocation.accuracyInMeters);
//	}
//
//	device[@"geo"] = geo;

	device[@"lmt"] = @(![[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]);
	device[@"make"] = @"Apple";

	NSString *deviceName = SKIDeviceName();
	if (deviceName) {
		device[@"model"] = deviceName;

		NSString *deviceModelName = SKIDeviceModelName();
		if (deviceModelName) {
			device[@"hwv"] = deviceModelName;
		}
	}
	
	CGSize screenSize = SKIOrientationIndependentScreenBounds().size;
	device[@"os"] = @"iOS";
	device[@"osv"] = [[UIDevice currentDevice] systemVersion];
	device[@"devicetype"] = @(SKIDeviceType());
	
	CGFloat scale = [[UIScreen mainScreen] scale];
	device[@"w"] = @(screenSize.width * scale);
	device[@"h"] = @(screenSize.height * scale);
	device[@"pxratio"] = @(scale);

	CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
	CTCarrier *carrier = [networkInfo subscriberCellularProvider];
	
	NSString *carrierName = carrier.carrierName;
	if (carrierName) {
		device[@"carrier"] = carrierName;
	}
	
	NSString *mcc = carrier.mobileCountryCode;
	NSString *mnc = carrier.mobileNetworkCode;
	if (mcc && mnc) {
		device[@"carriercode"] = [mcc stringByAppendingString:mnc];
	}


	// TODO: find areacode ???????
	//	if (areacode) {
	//		dictionary[@"areacode"] = areacode;
	//	}
	
	SKIRTBConnectionType connectionType = SKIConnectionType();
	if (connectionType != kSKIRTBConnectionTypeUnknown) {
		device[@"connectiontype"] = @(connectionType);
	}
	
	device[@"session"] = SKIDeviceSession();
	device[@"ifa"] = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString] ?: @"00000000-0000-0000-0000-000000000000";

	dictionary[@"device"] = device;

	dictionary[@"regs"] = @{ @"coppa" : self.childDirectedTreatment ? @1 : @0 };
	
	
	NSMutableDictionary<NSString *, NSObject *> *user = [NSMutableDictionary dictionary];
	NSString *genderString = SKIGenderToString(self.gender);
	if (genderString) {
		user[@"gender"] = genderString;
	}
	if (self.yearOfBirth) {
		user[@"yob"] = @(self.yearOfBirth);
	}
	if (self.keywords.count > 0) {
		user[@"keywords"] = [self.keywords componentsJoinedByString:@","];
	}
	
	if (user.count > 0) {
		dictionary[@"user"] = user;
	}

	return dictionary;
}

//- (NSString *)stringJSONValue {
//	NSDictionary *dictionary = [self initialDictionaryValue];
//
//	NSError *error = nil;
//	NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
//	if (error) {
//		DLog("%@", error.description);
//		return nil;
//	}
//
//	return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//}
//
//- (NSData *)dataJSONValue {
//	NSDictionary *dictionary = [self initialDictionaryValue];
//
//	NSError *error = nil;
//	NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
//	if (error) {
//		DLog("%@", error.description);
//		return nil;
//	}
//
//	return data;
//}

- (SKIAdGeoLocation)bestGeoLocation {
	if (!SKIAdGeoLocationIsZero(self.geoGPSLocation)) {
		return self.geoGPSLocation;
	}
	if (!SKIAdGeoLocationIsZero(self.geoProvidedLocation)) {
		return self.geoProvidedLocation;
	}
	if (!SKIAdGeoLocationIsZero(self.geoProvidedByDescriptionLocation)) {
		return self.geoProvidedByDescriptionLocation;
	}
	
	return SKIAdGeoLocationZero;
}

#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone {
	SKIAdRequest *request = [[SKIAdRequest allocWithZone:zone] init];
	request.test = self.test;
	request.adUnitID = self.adUnitID;
	request.adType = self.adType;
	request.adSize = self.adSize;
	
	request.locationWithDescription = self.locationWithDescription;
	
	request.geoGPSLocation = self.geoGPSLocation;
	request.geoProvidedLocation = self.geoProvidedLocation;
	request.geoProvidedByDescriptionLocation = self.geoProvidedByDescriptionLocation;
	
	request.gender = self.gender;
	request.yearOfBirth = self.yearOfBirth;
	request.keywords = self.keywords;
	request.childDirectedTreatment = self.childDirectedTreatment;
	
	// TODO: do not forget to implement missing props

	return request;
}

- (void)loadAvailableDataWitchCompletion:(void (^_Nonnull)(NSDictionary<NSString *, NSObject *> *dictionary))completionBlock {
	__weak typeof(self) wSelf = self;
	[SKIAsync parallel:@[^(SKIAsyncParallelCallback callback) {
		callback([self initialDictionaryValue]);
	}, ^(SKIAsyncParallelCallback callback) {
		[SKIGeo geoLocationWithCallback:^(CLLocation * _Nullable location) {
			if (location) {
				CLLocationCoordinate2D coord = location.coordinate;
				wSelf.geoGPSLocation = (SKIAdGeoLocation){kSKIRTBLocationTypeGPSLocationServices, coord.latitude, coord.longitude, MAX(location.horizontalAccuracy, location.verticalAccuracy)};
			}
			callback(location ?: [NSNull null]);
		}];
	}, ^(SKIAsyncParallelCallback callback) {
		if (self.locationWithDescription.length > 0 && SKIAdGeoLocationIsZero(self.geoProvidedByDescriptionLocation)) {
			[SKIGeo geocodeAddressString:self.locationWithDescription callback:^(CLLocation * _Nullable location) {
				if (location) {
					CLLocationCoordinate2D coord = location.coordinate;
					wSelf.geoProvidedByDescriptionLocation = (SKIAdGeoLocation){kSKIRTBLocationTypeUserProvided, coord.latitude, coord.longitude, MAX(location.horizontalAccuracy, location.verticalAccuracy)};

				}
				callback(location ?: [NSNull null]);
			}];
//			CLGeocoder *geoc = [[CLGeocoder alloc] init];
//			[geoc geocodeAddressString:self.locationWithDescription completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
//				if (error || placemarks.count == 0) {
//					callback([NSNull null]);
//					return;
//				}
//
//				CLPlacemark *placemark = nil;
//				for (CLPlacemark *mark in placemarks) {
//					if (mark.location) {
//						CLLocation *location = mark.location;
//						CLLocationCoordinate2D coord = location.coordinate;
//						self.geoProvidedByDescriptionLocation = (SKIAdGeoLocation){kSKIRTBLocationTypeUserProvided, coord.latitude, coord.longitude, MAX(location.horizontalAccuracy, location.verticalAccuracy)};
//
//						placemark = mark;
//						break;
//					}
//				}
//
//				callback(placemark ?: [NSNull null]);
//			}];
		} else {
			callback([NSNull null]);
		}
	}, ^(SKIAsyncParallelCallback callback) {
#if DEBUG
		callback([NSNull null]);
		return;
#endif
		NSString *appBundle = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleIdentifierKey];
		if (appBundle.length == 0) {
			callback([NSNull null]);
			return;
		}
#ifdef TEST
		appBundle = @"com.mobiblocks.seattleclouds";
#endif
		
		NSString *urlString = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@", appBundle];
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
		[[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
			NSHTTPURLResponse *httpReponse = (NSHTTPURLResponse *)response;
			if (error || httpReponse.statusCode != 200) {
				DLog(@"lookup failed with status code: %i error: %@", (int)httpReponse.statusCode, error.description);
				callback([NSNull null]);
				return;
			}
			
			NSError *serializationError = nil;
			NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializationError];
			if (serializationError) {
				DLog(@"lookup serializationError: %@", serializationError.description);
				callback([NSNull null]);
				return;
			}
			
			NSDictionary *appInfo = nil;
			NSArray *results = responseData[@"results"];
			if (results.count > 0) {
				for (NSDictionary *info in results) {
					if (![@"software" isEqualToString:info[@"kind"]]) {
						continue;
					}
					
					appInfo = info;
					break;
				}
			}
			if (appInfo) {
				callback(appInfo);
			} else {
				callback([NSNull null]);
			}
		}] resume];
	}] completion:^(NSArray * _Nonnull results) {
		NSObject *firstResult = results[0];
		NSObject *lookupResult = results[3];
		
		NSMutableDictionary *requestData = [firstResult isKindOfClass:[NSMutableDictionary class]] ? (NSMutableDictionary *)firstResult : [(NSDictionary *)firstResult mutableCopy];
		
		NSMutableDictionary *geo = [NSMutableDictionary dictionary];
		geo[@"utcoffset"] = @(SKIUTCOffset());
		
		SKIAdGeoLocation geoLocation = [self bestGeoLocation];
		if (!SKIAdGeoLocationIsZero(geoLocation)) {
			geo[@"type"] = @(geoLocation.type);
			geo[@"lat"] = @(geoLocation.latitude);
			geo[@"lon"] = @(geoLocation.longitude);
			geo[@"accuracy"] = @(geoLocation.accuracyInMeters);
		}
		
		requestData[@"geo"] = geo;
		
		if (lookupResult != [NSNull null] && [lookupResult isKindOfClass:[NSDictionary class]]) {
			NSMutableDictionary *app = [requestData[@"app"] mutableCopy] ?: [NSMutableDictionary dictionary];
			
			NSDictionary *appInfo = (NSDictionary *)lookupResult;
			NSString *storeUrlString = appInfo[@"trackViewUrl"];
			if (storeUrlString.length > 0) {
				app[@"storeurl"] = storeUrlString;
			}
			NSObject *storePriceObject = appInfo[@"price"];
			if ([storePriceObject isKindOfClass:[NSNumber class]]) {
				CGFloat storePrice = [(NSNumber *)storePriceObject floatValue];
				app[@"paid"] = storePrice > 0.1f ? @1 : @0;
			} else if ([storePriceObject isKindOfClass:[NSString class]]) {
				CGFloat storePrice = [(NSString *)storePriceObject floatValue];
				app[@"paid"] = storePrice > 0.1f ? @1 : @0;
			}
			
			NSArray *storeGenreIds = appInfo[@"genreIds"];
			if (storeGenreIds.count > 0) {
				NSArray *iabCats = SKIIABCategoriesFromAppleIDS(storeGenreIds);
				if (iabCats.count > 0) {
					app[@"cat"] = iabCats;
				}
			}
			
			NSMutableDictionary *publisher = [NSMutableDictionary dictionary];
			NSString *storeSellerName = appInfo[@"sellerName"];
			if (storeSellerName.length > 0) {
				publisher[@"name"] = storeSellerName;
			}
			
			NSString *storeSellerUrl = appInfo[@"sellerUrl"];
			if (storeSellerUrl.length > 0) {
				NSURL *url = [NSURL URLWithString:storeSellerUrl];
				NSString *host = url.host;
				if (host.length > 0) {
					publisher[@"domain"] = host;
				}
			}
			
			if (publisher.count > 0) {
				app[@"publisher"] = publisher;
			}
			
			if (app.count > 0) {
				requestData[@"app"] = app;
			}
		}
		
		DLog(@"%@", requestData);
		
		completionBlock(requestData);
	}];
}

- (void)load {
	NSAssert(_delegate != nil, @"delegate shold not be nil");
	
	__weak typeof(self) wSelf = self;
	[self loadAvailableDataWitchCompletion:^(NSDictionary<NSString *,NSObject *> *dictionary) {
		[wSelf loadRequestWithData:dictionary];
	}];
}

- (void)loadRequestWithData:(NSDictionary *)dictionary {
	NSError *error = nil;
	NSData *requestData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
	if (error) {
		SKIAdRequestResponse *requestResponse = [SKIAdRequestResponse response];
		requestResponse.error = [SKIAdRequestError errorInternalErrorWithUserInfo:@{NSUnderlyingErrorKey : error}];
		
		SKIAsyncOnMain(^{
			[self.delegate skiAdRequest:self didReceiveResponse:requestResponse];
		});
		DLog("%@", error.description);
		return;
	}
	
	__weak typeof(self) wSelf = self;
	NSString *urlString = self.adType == kSKIAdTypeInterstitialVideo ? SKIPPABLES_API_VIDEO_URL : SKIPPABLES_API_BANNER_URL;
	NSURL *url = [NSURL URLWithString:urlString];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	request.HTTPMethod = @"POST";
	request.HTTPBody = requestData;
	request.timeoutInterval = 15;
	request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
	[request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	
	NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		DLog(@"resp: %@, err: %@", response, error);
		DLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
		
		if (error) {
			SKIAdRequestResponse *requestResponse = [SKIAdRequestResponse response];
			requestResponse.error = [SKIAdRequestError errorWithCode:kSKIErrorNetworkError
															userInfo:@{NSUnderlyingErrorKey : error}];
			
			SKIAsyncOnMain(^{
				[wSelf.delegate skiAdRequest:wSelf didReceiveResponse:requestResponse];
			});
			return;
		}
		
		NSHTTPURLResponse *httpReponse = (NSHTTPURLResponse *)response;
		if (httpReponse.statusCode == 400) {
			NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
			SKIAdRequestResponse *requestResponse = [SKIAdRequestResponse response];
			requestResponse.error = [SKIAdRequestError errorWithCode:kSKIErrorInvalidRequest
															userInfo:@{
																	   NSLocalizedDescriptionKey : responseData[@"Message"] ?: @""
																	   }];
			
			SKIAsyncOnMain(^{
				[wSelf.delegate skiAdRequest:wSelf didReceiveResponse:requestResponse];
			});
			
			return;
		}
		
		if (httpReponse.statusCode == 500) {
			SKIAdRequestResponse *requestResponse = [SKIAdRequestResponse response];
			requestResponse.error = [SKIAdRequestError errorWithCode:kSKIErrorServerError
															userInfo:nil];
			
			SKIAsyncOnMain(^{
				[wSelf.delegate skiAdRequest:wSelf didReceiveResponse:requestResponse];
			});
			
			return;
		}
		
		NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
		if (error) {
			DLog(@"err: %@", error);
			
			SKIAdRequestResponse *requestResponse = [SKIAdRequestResponse response];
			requestResponse.error = [SKIAdRequestError errorWithCode:kSKIErrorReceivedInvalidResponse
															userInfo:@{NSUnderlyingErrorKey : error}];
			
			SKIAsyncOnMain(^{
				[wSelf.delegate skiAdRequest:wSelf didReceiveResponse:requestResponse];
			});
			return;
		}
		
		[self processResponseData:responseData deviceInfo:dictionary];
	}];
	[task resume];
}

- (void)processResponseData:(NSDictionary *)responseData deviceInfo:(NSDictionary *)deviceInfo {
	SKIAdRequestResponse *requestResponse = [SKIAdRequestResponse response];
	requestResponse.deviceInfo = deviceInfo[@"device"];
	requestResponse.rawResponse = responseData;

	if (self.adType == kSKIAdTypeInterstitialVideo) {
		NSString *videoVast = responseData[@"content"] ?: responseData[@"Content"];
		if ([[NSNull null] isEqual:videoVast] || videoVast.length == 0) {
			requestResponse.error = [SKIAdRequestError errorWithCode:kSKIErrorNoFill userInfo:nil];

			SKIAsyncOnMain(^{
				[self.delegate skiAdRequest:self didReceiveResponse:requestResponse];
			});

			return;
		} else {
			// TODO: temp here
			requestResponse.videoVast = videoVast;
			//--
			__weak typeof(self) wSelf = self;
			[SKIAsync waterfall:@[
				^(id _Nullable result, SKIAsyncWaterfallCallback callback) {
				    [self loadVastFromXmlString:videoVast
				                       callback:^(SKIVASTVAST *vast, SKIAdRequestError *error) {
					                       callback(error, vast);
					                   }];
				},
				^(SKIVASTVAST *result, SKIAsyncWaterfallCallback callback) {
				    [wSelf processVAST:result
				              callback:^(SKIVASTCompressedCreative *creative, SKIAdRequestError *error) {
					              callback(error, creative);
					          }];
				},
				^(SKIVASTCompressedCreative *_Nullable creative, SKIAsyncWaterfallCallback callback) {
				    NSURL *mediaUrl = creative.mediaFile.value;
				    NSURLSessionDownloadTask *task = [[NSURLSession sharedSession]
				        downloadTaskWithURL:mediaUrl
				          completionHandler:^(NSURL *_Nullable location, NSURLResponse *_Nullable response, NSError *_Nullable error) {
					          if (error) {
						          callback([SKIAdRequestError errorNetworkErrorWithUserInfo:@{
							                   NSLocalizedDescriptionKey : @"Could not load video.",
							                   NSUnderlyingErrorKey : error
							               }],
						                   creative);
						          return;
					          }

					          NSHTTPURLResponse *httpReponse = (NSHTTPURLResponse *)response;
					          if (httpReponse.statusCode != 200) {
						          callback([SKIAdRequestError errorNetworkErrorWithUserInfo:@{
							                   NSLocalizedDescriptionKey : @"Could not load video."
							               }],
						                   creative);
						          return;
					          }

					          NSString *ext = SKIMimeToExtension(httpReponse.MIMEType);
					          NSString *cachePath = SKICachePath();
					          NSString *localPath =
					              [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [[NSUUID UUID] UUIDString], ext]];
					          NSURL *localUrl = [NSURL fileURLWithPath:localPath];

					          NSError *localError = NULL;
					          if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
						          if (![[NSFileManager defaultManager] removeItemAtURL:localUrl error:&localError]) {
							          callback([SKIAdRequestError errorInternalErrorWithUserInfo:@{NSUnderlyingErrorKey : localError}], creative);
							          return;
						          }
					          }
					          if (![[NSFileManager defaultManager] moveItemAtURL:location toURL:localUrl error:&localError]) {
						          callback([SKIAdRequestError errorInternalErrorWithUserInfo:@{NSUnderlyingErrorKey : localError}], creative);
						          return;
					          }

					          DLog(@"localUrl: %@", localUrl.path);

					          creative.localMediaUrl = localUrl;

					          callback(nil, creative);
					      }];
				    [task resume];
				}
			] completion:^(NSError *_Nullable error, SKIVASTCompressedCreative *creative) {
				  requestResponse.error = (SKIAdRequestError *)error;
				  requestResponse.compressedCreative = creative;
				  SKIAsyncOnMain(^{
				 	 [wSelf.delegate skiAdRequest:wSelf didReceiveResponse:requestResponse];
				  });
			  }];
		}
	} else {
		NSString *maybeHtml = responseData[@"data"] ?: responseData[@"Data"];
		if ([[NSNull null] isEqual:maybeHtml] || maybeHtml.length == 0) {
			requestResponse.error = [SKIAdRequestError errorWithCode:kSKIErrorNoFill userInfo:nil];

			SKIAsyncOnMain(^{
				[self.delegate skiAdRequest:self didReceiveResponse:requestResponse];
			});

			return;
		} else {
			requestResponse.htmlSnippet = maybeHtml;

			SKIAsyncOnMain(^{
				[self.delegate skiAdRequest:self didReceiveResponse:requestResponse];
			});
		}
	}
}

- (void)loadVastFromXmlString:(NSString *)xmlString callback:(void (^_Nonnull)(SKIVASTVAST *vast, SKIAdRequestError *error))callback {
	NSData *xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
	SKIVASTVAST *vast = [SKIVASTVAST VASTFromData:xmlData];
	if (!vast) {
		callback(nil, [SKIAdRequestError errorReceivedInvalidResponseWithUserInfo:@{
																					NSLocalizedDescriptionKey : @"Video data is invalid."
																					}]);
		return;
	}
	
	if (vast.ads.firstObject.wrapper.vASTAdTagURI) {
		[self loadVastFromUrlString:vast.ads.firstObject.wrapper.vASTAdTagURI.absoluteString
						   callback:^(SKIVASTVAST *innerVast, SKIAdRequestError *error) {
							   vast.ads.firstObject.wrapper.wrappedVast = innerVast;
							   callback(vast, error);
						   }];
	} else {
		callback(vast, nil);
	}
}

- (void)loadVastFromUrlString:(NSString *)urlString callback:(void (^_Nonnull)(SKIVASTVAST *vast, SKIAdRequestError *error))callback {
	NSURL *url = [NSURL URLWithString:urlString];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	request.HTTPMethod = @"GET";
	request.timeoutInterval = 15;
	request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
	
	NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		if (error) {
			callback(nil, [SKIAdRequestError errorNetworkErrorWithUserInfo:@{
																			 NSLocalizedDescriptionKey : @"Could not load video.",
																			 NSUnderlyingErrorKey : error
																			 }]);
			return;
		}
		
		NSHTTPURLResponse *httpReponse = (NSHTTPURLResponse *)response;
		if (httpReponse.statusCode != 200 || data.length == 0) {
			callback(nil, [SKIAdRequestError errorNetworkErrorWithUserInfo:@{
																			 NSLocalizedDescriptionKey : @"Could not load video."
																			 }]);
			return;
		}
		
		SKIVASTVAST *vast = [SKIVASTVAST VASTFromData:data];
		if (!vast) {
			callback(nil, [SKIAdRequestError errorNetworkErrorWithUserInfo:@{
																			 NSLocalizedDescriptionKey : @"Could not load video."
																			 }]);
			return;
		}
		
		if (vast.ads.firstObject.wrapper.vASTAdTagURI) {
			[self loadVastFromUrlString:vast.ads.firstObject.wrapper.vASTAdTagURI.absoluteString
							   callback:^(SKIVASTVAST *innerVast, SKIAdRequestError *error) {
								   vast.ads.firstObject.wrapper.wrappedVast = innerVast;
								   callback(vast, error);
							   }];
		} else {
			callback(vast, nil);
		}
	}];
	[task resume];
}

- (void)processVAST:(SKIVASTVAST *)vast callback:(void (^_Nonnull)(SKIVASTCompressedCreative *creative, SKIAdRequestError *error))callback {
	SKIVASTAd *ad = vast.ads.firstObject;
	if (!ad) {
		callback(nil, [SKIAdRequestError errorReceivedInvalidResponseWithUserInfo:@{ NSLocalizedDescriptionKey : @"Response does not contain an ad." }]);
		return;
	}
	
	DLog(@"%@", ad.debugDescription);
	
	NSMutableArray *errorTrackings = [NSMutableArray array];
	NSMutableArray *additionalTrackings = [NSMutableArray array];
	NSMutableArray *impressionUrls = [NSMutableArray array];
	NSMutableArray *additionalImpressionUrls = [NSMutableArray array];
	
	SKIVASTInline *inLine = ad.inLine;
	if (!inLine) {
		SKIVASTWrapper *wrapper = ad.wrapper;
		if (wrapper.error) {
			[errorTrackings addObject:wrapper.error];
		}
		
		for (SKIVASTImpression *impression in wrapper.impressions) {
			if (impression.value) {
				[additionalImpressionUrls addObject:impression.value];
			}
		}
		
		for (NSInteger i = 0; i < 20; i++) {
			SKIVASTAd *wrappedAd = [[[wrapper wrappedVast] ads] firstObject];
			NSArray *trackings = wrapper.creatives.creatives.firstObject.linear.trackingEvents.trackings;
			if (trackings.count > 0) {
				[additionalTrackings addObjectsFromArray:trackings];
			}
			
			wrapper = wrappedAd.wrapper;
			
			if (wrapper == nil) {
				inLine = wrappedAd.inLine;
				break;
			}
		}
	}
	
	if (!inLine) {
		[self trackErrorUrls:errorTrackings errorCode:SKIVASTWrapperNoVastErrorCode];
		
		callback(nil, [SKIAdRequestError errorReceivedInvalidResponseWithUserInfo:@{ NSLocalizedDescriptionKey : @"Response does not contain an ad." }]);
		return;
	}
	
	if (inLine.error) {
		[errorTrackings addObject:inLine.error];
	}
	
	for (SKIVASTImpression *impression in inLine.impressions) {
		if (impression.value) {
			[impressionUrls addObject:impression.value];
		}
	}
	
	NSArray *creatives = inLine.creatives.creatives;
	if (!creatives) {
		[self trackErrorUrls:errorTrackings errorCode:SKIVASTUndefinedErrorCode];
		
		callback(nil, [SKIAdRequestError errorReceivedInvalidResponseWithUserInfo:@{ NSLocalizedDescriptionKey : @"Response does not contain an ad." }]);
		return;
	}
	
	SKIVASTCompressedCreative *compressedCreative = nil;
	for (SKIVASTCreativeBase *creativeBase in creatives) {
		if ([creativeBase isKindOfClass:[SKIVASTCreativeInlineChild class]]) {
			SKIVASTCreativeInlineChild *creative = (SKIVASTCreativeInlineChild *)creativeBase;
			if (!creative.linear) {
				continue;
			}
			
			SKIVASTMediaFile *bestMediaFile = [self mediaFileToFitScreen:creative.linear.mediaFiles.mediaFiles];
			if (!bestMediaFile) {
				[self trackErrorUrls:errorTrackings errorCode:SKIVASTMediaFileNotSupportedErrorCode];
				callback(nil, [SKIAdRequestError errorReceivedInvalidResponseWithUserInfo:@{
																					   NSLocalizedDescriptionKey : @"Response does not contain an ad."
																					   }]);
				return;
			}
			
			compressedCreative = [SKIVASTCompressedCreative compressed];
			compressedCreative.adId = ad.identifier;
			compressedCreative.errorTrackings = errorTrackings;
			compressedCreative.impressionUrls = impressionUrls;
			compressedCreative.additionalImpressionUrls = additionalImpressionUrls;
			compressedCreative.creative = creativeBase;
			compressedCreative.mediaFile = bestMediaFile;
			if (additionalTrackings.count > 0) {
				compressedCreative.additionalTrackings = additionalTrackings;
			}
			//TODO: add click trackings
		}
		//		else if ([creativeBase isKindOfClass:[SKIVASTCreativeWrapperChild class]]) {
		//			SKIVASTCreativeWrapperChild *creative = (SKIVASTCreativeWrapperChild *)creativeBase;
		//		}
		else {
			continue;
		}
	}
	
	if (compressedCreative) {
		callback(compressedCreative, nil);
	} else {
		[self trackErrorUrls:errorTrackings errorCode:SKIVASTMediaFileNotSupportedErrorCode];
		callback(nil, [SKIAdRequestError errorReceivedInvalidResponseWithUserInfo:@{
																			   NSLocalizedDescriptionKey : @"Response does not contain any playable media."
																			   }]);
	}
}

- (SKIVASTMediaFile *)mediaFileToFitScreen:(NSArray<SKIVASTMediaFile *> *)mediaFiles {
	mediaFiles = [self usableMediaFilesSortedBySize:mediaFiles];
	if (mediaFiles.count == 0) {
		return nil;
	} else if (mediaFiles.count == 1) {
		return mediaFiles.firstObject;
	}
	
	CGFloat screenScale = 1;//[[UIScreen mainScreen] scale];
	CGSize screenSize = CGSizeZero;
	if (SKISupportsPortraitOnlyOrientation() || SKIiSPortrait()) {
		screenSize = SKIScreenBounds().size;
		//		NSArray<SKIVASTMediaFile *> *portraitMediaFiles = [self mediaFilesForPortrait:mediaFiles];
		//		if (portraitMediaFiles.count > 0) {
		//			mediaFiles = portraitMediaFiles;
		//		}
	} else if (SKISupportsLanscapeOnlyOrientation() || SKIiSLandscape()) {
		screenSize = SKIScreenBounds().size;
		//		NSArray<SKIVASTMediaFile *> *landscapeMediaFiles = [self mediaFilesForLandscape:mediaFiles];
		//		if (landscapeMediaFiles.count > 0) {
		//			mediaFiles = landscapeMediaFiles;
		//		}
	} else {
		screenSize = SKIOrientationIndependentScreenBounds().size;
	}
	
	//	kSKIRTBConnectionTypeUnknown         = 0,   ///< Unknown.
	//	kSKIRTBConnectionTypeEthernet        = 1,   ///< Ethernet.
	//	kSKIRTBConnectionTypeWIFI            = 2,   ///< WiFi.
	//	kSKIRTBConnectionTypeCellularUnknown = 3,   ///< Cellular Network – Unknown Generation.
	//	kSKIRTBConnectionTypeCellular2G      = 4,   ///< Cellular Network – 2G.
	//	kSKIRTBConnectionTypeCellular3G      = 5,   ///< Cellular Network – 3G.
	//	kSKIRTBConnectionTypeCellular4G      = 6,   ///< Cellular Network – 4G.
	SKIRTBConnectionType connectionType = SKIConnectionType();
	switch (connectionType) {
		case kSKIRTBConnectionTypeEthernet:
		case kSKIRTBConnectionTypeWIFI:
			screenSize.width *= screenScale;
			screenSize.height *= screenScale;
			break;
		case kSKIRTBConnectionTypeCellular4G:
			if (screenScale > 1.) {
				screenSize.width *= 1.5;
				screenSize.height *= 1.5;
			}
			break;
			
		default:
			break;
	}
	
	CGFloat widthWeight = 1;
	CGFloat heightWeight = 1;
	if (screenSize.width > screenSize.height) {
		heightWeight = 1.5f;
	} else if (screenSize.width < screenSize.height) {
		widthWeight = 1.5f;
	}
	
	NSMutableDictionary<NSNumber *, SKIVASTMediaFile*> *pointedMediaFiles = [NSMutableDictionary dictionary];
	
	CGFloat screenRatio = MAX(screenSize.width, screenSize.height) / MIN(screenSize.width, screenSize.height);
	CGFloat screenPixels = screenSize.width - screenSize.height;
	
#ifdef DEBUG
	NSMutableString *pointLogger = [NSMutableString string];
	[pointLogger appendString:@"\n-----------------\n"];
	[pointLogger appendFormat:@"%dx%d %d - w:%f h:%f r:%f\n", (int)screenSize.width, (int)screenSize.height, (int)screenPixels, widthWeight, heightWeight, screenRatio];
#endif
	
	for (SKIVASTMediaFile *mediaFile in mediaFiles) {
		CGFloat currentWidth = mediaFile.width.floatValue;
		CGFloat currentHeight = mediaFile.height.floatValue;
		
		CGFloat currentRatio = MAX(currentWidth, currentHeight) / MIN(currentWidth, currentHeight);
		CGFloat currentPixels = currentWidth - currentHeight;
		
		CGFloat ratioDiff = ABS(screenRatio - currentRatio);
		CGFloat widthDiff = ABS(screenSize.width - currentWidth);
		CGFloat heightDiff = ABS(screenSize.height - currentHeight);
		CGFloat pixelsDiff = ABS(screenPixels - currentPixels);
		
		NSInteger pointRatio = round(ratioDiff * 100.);
		NSInteger pointWidth = round(widthDiff / 100. * widthWeight);
		NSInteger pointHeight = round(heightDiff / 100. * heightWeight);
		NSInteger pointPixels = round(pixelsDiff / 100. * 1);
		
		NSInteger pointAcumm = pointRatio + pointWidth + pointHeight + pointPixels;
		pointedMediaFiles[@(pointAcumm)] = mediaFile;
		
#ifdef DEBUG
		[pointLogger appendString:@"-----------------\n"];
		[pointLogger appendFormat:@"%dx%d p:%d pd:%d - r:%f rd:%f wd:%f hd:%f rp:%d rpw:%d, rph:%d ppx:%d pa:%d\n", (int)currentWidth, (int)currentHeight, (int)currentPixels, (int)pixelsDiff, currentRatio, ratioDiff, screenSize.width - currentWidth, screenSize.height - currentHeight, (int)pointRatio, (int)pointWidth, (int)pointHeight, (int)pointPixels, (int)pointAcumm];
		[pointLogger appendString:@"-----------------\n"];
#endif
	}
	
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
	NSArray *sortedKeys = [pointedMediaFiles.allKeys sortedArrayUsingDescriptors:@[sortDescriptor]];
	SKIVASTMediaFile *mediaFile = pointedMediaFiles[sortedKeys.firstObject];
	
#ifdef DEBUG
	[pointLogger appendString:@"-----------------\n"];
	[pointLogger appendString:mediaFile.debugDescription];
	[pointLogger appendString:@"\n-----------------\n"];
	DLog(@"%@", pointLogger);
#endif
	
	return mediaFile;
}

- (NSArray<SKIVASTMediaFile *> *)usableMediaFilesSortedBySize:(NSArray<SKIVASTMediaFile *> *)mediaFiles {
	NSMutableArray *usable = [NSMutableArray arrayWithCapacity:mediaFiles.count];
	
	static NSArray *supportedMimes = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		supportedMimes = @[@"video/mp4", @"video/quicktime", @"video/x-m4v", @"video/3gpp", @"video/3gpp2"];
	});
	
	for (SKIVASTMediaFile *media in mediaFiles) {
		if (media.type && [supportedMimes containsObject:media.type]) {
			[usable addObject:media];
		}
	}
	
	[usable sortUsingComparator:^NSComparisonResult(SKIVASTMediaFile *_Nonnull obj1, SKIVASTMediaFile *_Nonnull obj2) {
		CGFloat m1 = obj1.width.floatValue * obj1.height.floatValue;
		CGFloat m2 = obj2.width.floatValue * obj2.height.floatValue;
		
		if (m1 == m2) {
			return NSOrderedSame;
		} else if (m1 > m2) {
			return NSOrderedDescending;
		} else if (m1 < m2) {
			return NSOrderedAscending;
		} else {
			return NSOrderedSame; // LOL))
		}
	}];
	
	return usable;
}

- (NSArray<SKIVASTMediaFile *> *)mediaFilesForPortrait:(NSArray<SKIVASTMediaFile *> *)mediaFiles {
	NSMutableArray *usable = [NSMutableArray arrayWithCapacity:mediaFiles.count];
	
	for (SKIVASTMediaFile *media in mediaFiles) {
		CGFloat mediaWidth = media.width.floatValue;
		CGFloat mediaHeight = media.height.floatValue;
		
		if (mediaHeight >= mediaWidth) {
			[usable addObject:media];
		} else {
			CGFloat ratio = MAX(mediaWidth, mediaHeight) / MIN(mediaWidth, mediaHeight);
			if (ratio <= 1.55) {
				[usable addObject:media];
			}
		}
	}
	
	return usable;
}

- (NSArray<SKIVASTMediaFile *> *)mediaFilesForLandscape:(NSArray<SKIVASTMediaFile *> *)mediaFiles {
	NSMutableArray *usable = [NSMutableArray arrayWithCapacity:mediaFiles.count];
	
	for (SKIVASTMediaFile *media in mediaFiles) {
		CGFloat mediaWidth = media.width.floatValue;
		CGFloat mediaHeight = media.height.floatValue;
		
		if (mediaWidth >= mediaHeight) {
			[usable addObject:media];
		} else {
			CGFloat ratio = MAX(mediaWidth, mediaHeight) / MIN(mediaWidth, mediaHeight);
			if (ratio >= 1.55) {
				[usable addObject:media];
			}
		}
	}
	
	return usable;
}

- (void)trackErrorUrl:(NSURL *)url errorCode:(SKIVASTErrorCode)errorCode {
	if (!url) {
		return;
	}
	
	NSURL *macrosed = [SKIVASTUrl urlFromUrlAfterReplacingMacros:url
														 builder:^(SKIVASTUrlMacroValues *_Nonnull macroValues) {
															 macroValues.errorCode = errorCode;
														 }];
	if (macrosed) {
		[[SKIAdEventTracker defaultTracker] trackErrorRequestWithUrl:macrosed];
	}
}

- (void)trackErrorUrls:(NSArray<NSURL *> *)urls errorCode:(SKIVASTErrorCode)errorCode {
	if (urls.count == 0) {
		return;
	}
	
	for (NSURL *url in urls) {
		[self trackErrorUrl:url errorCode:errorCode];
	}
}

- (void)cancel {
	
}

@end


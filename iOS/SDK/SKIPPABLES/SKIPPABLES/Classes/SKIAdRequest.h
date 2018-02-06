//
//  SKIAdRequest.h
//  SKIPPABLES
//
//  Copyright © 2017 Mobiblocks. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SKIGender) {
	kSKIGenderUnknown = 0,  ///< Unknown gender.
	kSKIGenderMale    = 1,  ///< Male gender.
	kSKIGenderFemale  = 2,  ///< Female gender.
	kSKIGenderOther   = 3,  ///< Other gender.
};

@interface SKIAdRequest : NSObject<NSCopying>

+ (instancetype)request;

/// Enables/Disables test mode.
@property (assign, nonatomic) BOOL test;

#pragma mark Device
/// Location of the device assumed to be the user’s current location. However do not use Core
/// Location just for advertising, make sure it is used for more beneficial reasons as well. It is
/// both a good idea and part of Apple's guidelines.
- (void)setLocationWithLatitude:(CGFloat)latitude
					  longitude:(CGFloat)longitude
					   accuracy:(CGFloat)accuracyInMeters;

/// When Core Location isn't available but the user's location is known supplying it here may
/// deliver more relevant ads. It can be any free-form text such as @"Champs-Elysees Paris" or
/// @"94041 US".
@property (copy, nonatomic) NSString *locationWithDescription;


#pragma mark User Information

/// Provide the user's gender to increase ad relevancy.
@property (assign, nonatomic) SKIGender gender;

/// Year of birth as a 4-digit integer to increase ad relevancy.
@property (assign, nonatomic) NSInteger yearOfBirth;

/// List of keywords, interests or intent.
@property (copy, nonatomic) NSArray<NSString *> *keywords;


#pragma mark Regulations

/// Flag indicating if this request is subject to the COPPA regulations established by the USA FTC
@property (assign, nonatomic) BOOL childDirectedTreatment;

@end

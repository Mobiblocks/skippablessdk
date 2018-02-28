
/**
* SKIVASTCompanionAd.h

*/

#import <Foundation/Foundation.h>
#import "SKIVASTCreativeResourceNonVideo.h"
@class SKIVASTCompanionClickTracking;
@class SKIVASTAdParameters;
@class SKIVASTCreativeExtensions;
@class SKIVASTTrackingEvents;

@interface SKIVASTCompanionAd : SKIVASTCreativeResourceNonVideo

- (void)initProperties;
- (void)parseWithReader:(void *) reader;
- (void)handleElementName:(NSString *)_currentElementName reader:(void *) reader readerOk:(int *)_readerOk currentNodeType:(int *)_currentNodeType currentXmlDept:(int *)_currentXmlDept handledInChild:(BOOL *)handledInChild;

/**
Optional identifier
*/
@property (nonatomic, readonly) NSString *identifier;
/**
Pixel dimensions of companion slot
*/
@property (nonatomic, readonly) NSNumber *width;
/**
Pixel dimensions of companion slot
*/
@property (nonatomic, readonly) NSNumber *height;
/**
Pixel dimensions of the companion asset
*/
@property (nonatomic, readonly) NSNumber *assetWidth;
/**
Pixel dimensions of the companion asset
*/
@property (nonatomic, readonly) NSNumber *assetHeight;
/**
Pixel dimensions of expanding companion ad when in expanded state
*/
@property (nonatomic, readonly) NSNumber *expandedWidth;
/**
Pixel dimensions of expanding companion ad when in expanded state
*/
@property (nonatomic, readonly) NSNumber *expandedHeight;
/**
The apiFramework defines the method to use for communication with the companion
*/
@property (nonatomic, readonly) NSString *apiFramework;
/**
Used to match companion creative to publisher placement areas on the page.
*/
@property (nonatomic, readonly) NSString *adSlotID;
/**
The pixel ratio for which the icon creative is intended.
The pixel ratio is the ratio of physical pixels on the device to the device-independent pixels.
An ad intended for display on a device with a pixel ratio that is twice that of a standard 1:1
pixel ratio would use the value "2" Default value is "1"
*/
@property (nonatomic, readonly) NSNumber *pxratio;

/**
Data to be passed into the companion ads. The apiFramework defines the method to use for communication (e.g. “FlashVar”)
*/
@property (nonatomic, readonly) SKIVASTAdParameters *adParameters;
/**
Alt text to be displayed when companion is rendered in HTML environment.
*/
@property (nonatomic, readonly) NSString *altText;
/**
URL to open as destination page when user clicks on the the companion banner ad.
*/
@property (nonatomic, readonly) NSURL *companionClickThrough;
/**
A URI to a tracking resource file used to track a companion clickthrough.
*/
@property (nonatomic, readonly) NSMutableArray<SKIVASTCompanionClickTracking *> *companionClickTrackings;

@property (nonatomic, readonly) SKIVASTCreativeExtensions *creativeExtensions;
/**
The creativeView should always be requested when present. For Companions creativeView is the only supported event.
*/
@property (nonatomic, readonly) SKIVASTTrackingEvents *trackingEvents;

/** Returns a dictionary representation of this class (recursivly making dictionaries of properties) */
@property (nonatomic, readonly) NSDictionary* dictionary;

@end

@interface SKIVASTCompanionAd (Reading)

/** The class's initializer used by the reader to build the object structure during parsing (xmlTextReaderPtr at the moment) */
- (id)initWithReader:(void*) reader;

/** Method that is overidden by subclasses that want to extend the base type (xmlTextReaderPtr at the moment) */
- (void)readAttributes:(void*) reader;

/** Property that sets the NSLocale used by formatters of this type. It defaults to enUSPOSIX */
@property (strong, nonatomic) NSLocale *locale;

@end


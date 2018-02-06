
/**
* SKIVASTIcon.h

*/

#import <Foundation/Foundation.h>
#import "SKIVASTCreativeResourceNonVideo.h"
@class SKIVASTIconClicks;

@interface SKIVASTIcon : SKIVASTCreativeResourceNonVideo

- (void)initProperties;
- (void)parseWithReader:(void *) reader;
- (void)handleElementName:(NSString *)_currentElementName reader:(void *) reader readerOk:(int *)_readerOk currentNodeType:(int *)_currentNodeType currentXmlDept:(int *)_currentXmlDept handledInChild:(BOOL *)handledInChild;

/**
Program represented in the Icon.
*/
@property (nonatomic, readonly) NSString *program;
/**
Pixel dimensions of icon.
*/
@property (nonatomic, readonly) NSNumber *width;
/**
Pixel dimensions of icon.
*/
@property (nonatomic, readonly) NSNumber *height;
/**
The x-cooridinate of the top, left corner of the icon asset relative to the ad display area
*/
@property (nonatomic, readonly) NSString *xPosition;
/**
The y-cooridinate of the top left corner of the icon asset relative to the ad display area.
*/
@property (nonatomic, readonly) NSString *yPosition;
/**
The duration for which the player must display the icon. Expressed in standard time format hh:mm:ss.
*/
@property (nonatomic, readonly) NSDate *duration;
/**
Start time at which the player should display the icon. Expressed in standard time format hh:mm:ss.
*/
@property (nonatomic, readonly) NSDate *offset;
/**
The apiFramework defines the method to use for communication with the icon element
*/
@property (nonatomic, readonly) NSString *apiFramework;
/**
The pixel ratio for which the icon creative is intended.
The pixel ratio is the ratio of physical pixels on the device to the device-independent pixels.
An ad intended for display on a device with a pixel ratio that is twice that of a standard 1:1
pixel ratio would use the value "2" Default value is "1"
*/
@property (nonatomic, readonly) NSNumber *pxratio;

@property (nonatomic, readonly) SKIVASTIconClicks *iconClicks;
/**
A URI for the tracking resource file to be called when the icon creative is displayed.
*/
@property (nonatomic, readonly) NSMutableArray<NSURL *> *iconViewTrackings;

/** Returns a dictionary representation of this class (recursivly making dictionaries of properties) */
@property (nonatomic, readonly) NSDictionary* dictionary;

@end

@interface SKIVASTIcon (Reading)

/** The class's initializer used by the reader to build the object structure during parsing (xmlTextReaderPtr at the moment) */
- (id)initWithReader:(void*) reader;

/** Method that is overidden by subclasses that want to extend the base type (xmlTextReaderPtr at the moment) */
- (void)readAttributes:(void*) reader;

/** Property that sets the NSLocale used by formatters of this type. It defaults to enUSPOSIX */
@property (strong, nonatomic) NSLocale *locale;

@end



/**
* SKIVASTLinearInlineChild.h

*/

#import <Foundation/Foundation.h>
#import "SKIVASTLinearBase.h"
@class SKIVASTVideoClicksInlineChild;
@class SKIVASTAdParameters;
@class SKIVASTMediaFiles;

/**
Video formatted ad that plays linearly */

/**
Video formatted ad that plays linearly
*/
@interface SKIVASTLinearInlineChild : SKIVASTLinearBase

- (void)initProperties;
- (void)parseWithReader:(void *) reader;
- (void)handleElementName:(NSString *)_currentElementName reader:(void *) reader readerOk:(int *)_readerOk currentNodeType:(int *)_currentNodeType currentXmlDept:(int *)_currentXmlDept handledInChild:(BOOL *)handledInChild;

/**
Data to be passed into the video ad. Used to pass VAST info to VPAID object.
*/
@property (nonatomic, readonly) SKIVASTAdParameters *adParameters;
/**
Duration in standard time format, hh:mm:ss
*/
@property (nonatomic, readonly) NSDate *duration;

@property (nonatomic, readonly) SKIVASTMediaFiles *mediaFiles;

@property (nonatomic, readonly) SKIVASTVideoClicksInlineChild *videoClicks;

/** Returns a dictionary representation of this class (recursivly making dictionaries of properties) */
@property (nonatomic, readonly) NSDictionary* dictionary;

@end

@interface SKIVASTLinearInlineChild (Reading)

/** The class's initializer used by the reader to build the object structure during parsing (xmlTextReaderPtr at the moment) */
- (id)initWithReader:(void*) reader;

/** Method that is overidden by subclasses that want to extend the base type (xmlTextReaderPtr at the moment) */
- (void)readAttributes:(void*) reader;

/** Property that sets the NSLocale used by formatters of this type. It defaults to enUSPOSIX */
@property (strong, nonatomic) NSLocale *locale;

@end


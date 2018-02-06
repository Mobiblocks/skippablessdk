
/**
* SKIVASTNonLinearAdInlineChild.h

*/

#import <Foundation/Foundation.h>
#import "SKIVASTCreativeResourceNonVideo.h"
@class SKIVASTAdParameters;
@class SKIVASTNonLinearClickTracking;

/**
An ad that is overlain on top of video content during playback */

/**
An ad that is overlain on top of video content during playback
*/
@interface SKIVASTNonLinearAdInlineChild : SKIVASTCreativeResourceNonVideo

- (void)initProperties;
- (void)parseWithReader:(void *) reader;
- (void)handleElementName:(NSString *)_currentElementName reader:(void *) reader readerOk:(int *)_readerOk currentNodeType:(int *)_currentNodeType currentXmlDept:(int *)_currentXmlDept handledInChild:(BOOL *)handledInChild;

/**
Custom content used to pass information to ad unit
*/
@property (nonatomic, readonly) SKIVASTAdParameters *adParameters;
/**
URI to advertiser page opened on viewer clicks through.
*/
@property (nonatomic, readonly) NSURL *nonLinearClickThrough;
/**
URLs to ping when user clicks on the the non-linear ad unit.
*/
@property (nonatomic, readonly) NSMutableArray<SKIVASTNonLinearClickTracking *> *nonLinearClickTrackings;

/** Returns a dictionary representation of this class (recursivly making dictionaries of properties) */
@property (nonatomic, readonly) NSDictionary* dictionary;

@end

@interface SKIVASTNonLinearAdInlineChild (Reading)

/** The class's initializer used by the reader to build the object structure during parsing (xmlTextReaderPtr at the moment) */
- (id)initWithReader:(void*) reader;

/** Method that is overidden by subclasses that want to extend the base type (xmlTextReaderPtr at the moment) */
- (void)readAttributes:(void*) reader;

/** Property that sets the NSLocale used by formatters of this type. It defaults to enUSPOSIX */
@property (strong, nonatomic) NSLocale *locale;

@end


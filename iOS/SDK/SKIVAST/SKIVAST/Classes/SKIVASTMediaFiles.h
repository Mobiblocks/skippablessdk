
/**
* SKIVASTMediaFiles.h

*/

#import <Foundation/Foundation.h>

@class SKIVASTMediaFile;
@class SKIVASTInteractiveCreativeFile;

@interface SKIVASTMediaFiles : NSObject

- (void)initProperties;
- (void)parseWithReader:(void *) reader;
- (void)handleElementName:(NSString *)_currentElementName reader:(void *) reader readerOk:(int *)_readerOk currentNodeType:(int *)_currentNodeType currentXmlDept:(int *)_currentXmlDept handledInChild:(BOOL *)handledInChild;

/**
URI location of linear file. Content must be wrapped in CDATA tag.
*/
@property (nonatomic, readonly) NSMutableArray<SKIVASTMediaFile *> *mediaFiles;
/**
URI location to raw, high-quality media file for high-resolution environments.
Content must be wrapped in CDATA tag.
*/
@property (nonatomic, readonly) NSURL *mezzanine;
/**
For any media file that uses APIs for advanced creative functionality, the
InteractivityCreativeFile element is used to identify the file and framework needed to
execute advanced functions for the ad.
*/
@property (nonatomic, readonly) NSMutableArray<SKIVASTInteractiveCreativeFile *> *interactiveCreativeFiles;

/** Returns a dictionary representation of this class (recursivly making dictionaries of properties) */
@property (nonatomic, readonly) NSDictionary* dictionary;

@end

@interface SKIVASTMediaFiles (Reading)

/** The class's initializer used by the reader to build the object structure during parsing (xmlTextReaderPtr at the moment) */
- (id)initWithReader:(void*) reader;

/** Method that is overidden by subclasses that want to extend the base type (xmlTextReaderPtr at the moment) */
- (void)readAttributes:(void*) reader;

/** Property that sets the NSLocale used by formatters of this type. It defaults to enUSPOSIX */
@property (strong, nonatomic) NSLocale *locale;

@end


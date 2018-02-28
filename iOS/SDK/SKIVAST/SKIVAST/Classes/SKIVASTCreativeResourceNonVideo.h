
/**
* SKIVASTCreativeResourceNonVideo.h

*/

#import <Foundation/Foundation.h>

@class SKIVASTStaticResource;
@class SKIVASTHTMLResource;

/**
A base creative resource type (sec 3.13) for non-video creative content.
This specifies static, IFrame, or HTML content, or a combination thereof */

/**
A base creative resource type (sec 3.13) for non-video creative content.
This specifies static, IFrame, or HTML content, or a combination thereof
*/
@interface SKIVASTCreativeResourceNonVideo : NSObject

- (void)initProperties;
- (void)parseWithReader:(void *) reader;
- (void)handleElementName:(NSString *)_currentElementName reader:(void *) reader readerOk:(int *)_readerOk currentNodeType:(int *)_currentNodeType currentXmlDept:(int *)_currentXmlDept handledInChild:(BOOL *)handledInChild;

/**
HTML to display the companion element.
This can occur zero to many times, but order should not be important.
*/
@property (nonatomic, readonly) NSMutableArray<SKIVASTHTMLResource *> *hTMLResources;
/**
URI source for an IFrame to display the companion element.
This can occur zero to many times, but order should not be important.
*/
@property (nonatomic, readonly) NSMutableArray<NSURL *> *iFrameResources;
/**
URI to a static file, such as an image or SWF file.
This can occur zero to many times, but order should not be important.
*/
@property (nonatomic, readonly) NSMutableArray<SKIVASTStaticResource *> *staticResources;

/** Returns a dictionary representation of this class (recursivly making dictionaries of properties) */
@property (nonatomic, readonly) NSDictionary* dictionary;

@end

@interface SKIVASTCreativeResourceNonVideo (Reading)

/** The class's initializer used by the reader to build the object structure during parsing (xmlTextReaderPtr at the moment) */
- (id)initWithReader:(void*) reader;

/** Method that is overidden by subclasses that want to extend the base type (xmlTextReaderPtr at the moment) */
- (void)readAttributes:(void*) reader;

/** Property that sets the NSLocale used by formatters of this type. It defaults to enUSPOSIX */
@property (strong, nonatomic) NSLocale *locale;

@end


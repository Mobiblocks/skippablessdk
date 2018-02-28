
/**
* SKIVASTVerificationInline.h

*/

#import <Foundation/Foundation.h>

@class SKIVASTJavaScriptResource;
@class SKIVASTViewableImpression;
@class SKIVASTFlashResource;

/**
Verification elements are nested under AdVerifications. The Verification element is used to contain the
JavaScript or Flash code used to collect data. Multiple Verification elements may be used in
cases where more than one verification vendor needs to collect data or when different API
frameworks are used.

When included, verification contents must be executed (if possible) BEFORE the
media file or interactive creative file is executed, to ensure verification can track ad
play as intended. */

/**
Verification elements are nested under AdVerifications. The Verification element is used to contain the
JavaScript or Flash code used to collect data. Multiple Verification elements may be used in
cases where more than one verification vendor needs to collect data or when different API
frameworks are used.

When included, verification contents must be executed (if possible) BEFORE the
media file or interactive creative file is executed, to ensure verification can track ad
play as intended.
*/
@interface SKIVASTVerificationInline : NSObject

- (void)initProperties;
- (void)parseWithReader:(void *) reader;
- (void)handleElementName:(NSString *)_currentElementName reader:(void *) reader readerOk:(int *)_readerOk currentNodeType:(int *)_currentNodeType currentXmlDept:(int *)_currentXmlDept handledInChild:(BOOL *)handledInChild;

/**
The home page URL for the verification service provider that supplies the resource file.
*/
@property (nonatomic, readonly) NSString *vendor;

@property (nonatomic, readonly) NSMutableArray<SKIVASTFlashResource *> *flashResources;

@property (nonatomic, readonly) NSMutableArray<SKIVASTJavaScriptResource *> *javaScriptResources;
/**
The name of the event to track for the element.
The creativeView should always be requested when present.
*/
@property (nonatomic, readonly) SKIVASTViewableImpression *viewableImpression;

/** Returns a dictionary representation of this class (recursivly making dictionaries of properties) */
@property (nonatomic, readonly) NSDictionary* dictionary;

@end

@interface SKIVASTVerificationInline (Reading)

/** The class's initializer used by the reader to build the object structure during parsing (xmlTextReaderPtr at the moment) */
- (id)initWithReader:(void*) reader;

/** Method that is overidden by subclasses that want to extend the base type (xmlTextReaderPtr at the moment) */
- (void)readAttributes:(void*) reader;

/** Property that sets the NSLocale used by formatters of this type. It defaults to enUSPOSIX */
@property (strong, nonatomic) NSLocale *locale;

@end


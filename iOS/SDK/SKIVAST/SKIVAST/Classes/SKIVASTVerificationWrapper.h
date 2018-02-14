
/**
* SKIVASTVerificationWrapper.h

*/

#import <Foundation/Foundation.h>

@class SKIVASTViewableImpression;

/**
Verification elements are nested under AdVerifications. The Verification element is used to contain the
JavaScript or Flash code used to collect data. Multiple Verification elements may be used in
cases where more than one verification vendor needs to collect data or when different API
frameworks are used. */

/**
Verification elements are nested under AdVerifications. The Verification element is used to contain the
JavaScript or Flash code used to collect data. Multiple Verification elements may be used in
cases where more than one verification vendor needs to collect data or when different API
frameworks are used.
*/
@interface SKIVASTVerificationWrapper : NSObject

- (void)initProperties;
- (void)parseWithReader:(void *) reader;
- (void)handleElementName:(NSString *)_currentElementName reader:(void *) reader readerOk:(int *)_readerOk currentNodeType:(int *)_currentNodeType currentXmlDept:(int *)_currentXmlDept handledInChild:(BOOL *)handledInChild;

@property (nonatomic, readonly) NSString *vendor;

/**
The name of the event to track for the element.
The creativeView should always be requested when present.
*/
@property (nonatomic, readonly) SKIVASTViewableImpression *viewableImpression;

/** Returns a dictionary representation of this class (recursivly making dictionaries of properties) */
@property (nonatomic, readonly) NSDictionary* dictionary;

@end

@interface SKIVASTVerificationWrapper (Reading)

/** The class's initializer used by the reader to build the object structure during parsing (xmlTextReaderPtr at the moment) */
- (id)initWithReader:(void*) reader;

/** Method that is overidden by subclasses that want to extend the base type (xmlTextReaderPtr at the moment) */
- (void)readAttributes:(void*) reader;

/** Property that sets the NSLocale used by formatters of this type. It defaults to enUSPOSIX */
@property (strong, nonatomic) NSLocale *locale;

@end

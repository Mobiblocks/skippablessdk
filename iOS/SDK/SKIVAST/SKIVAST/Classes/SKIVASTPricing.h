
/**
* SKIVASTPricing.h

*/

#import <Foundation/Foundation.h>

@interface SKIVASTPricing : NSObject

- (void)initProperties;
- (void)parseWithReader:(void *) reader;
- (void)handleElementName:(NSString *)_currentElementName reader:(void *) reader readerOk:(int *)_readerOk currentNodeType:(int *)_currentNodeType currentXmlDept:(int *)_currentXmlDept handledInChild:(BOOL *)handledInChild;

/**
The pricing model used.
*/
@property (nonatomic, readonly) NSString *model;
/**
Three letter ISO-4217 currency symbol that identifies the currency of the value provied.
Ex: USD, GBP, etc.
*/
@property (nonatomic, readonly) NSString *currency;

/**
the type's underlying value
*/
@property (nonatomic, readonly) NSNumber *value;

/** Returns a dictionary representation of this class (recursivly making dictionaries of properties) */
@property (nonatomic, readonly) NSDictionary* dictionary;

@end

@interface SKIVASTPricing (Reading)

/** The class's initializer used by the reader to build the object structure during parsing (xmlTextReaderPtr at the moment) */
- (id)initWithReader:(void*) reader;

/** Method that is overidden by subclasses that want to extend the base type (xmlTextReaderPtr at the moment) */
- (void)readAttributes:(void*) reader;

/** Property that sets the NSLocale used by formatters of this type. It defaults to enUSPOSIX */
@property (strong, nonatomic) NSLocale *locale;

@end


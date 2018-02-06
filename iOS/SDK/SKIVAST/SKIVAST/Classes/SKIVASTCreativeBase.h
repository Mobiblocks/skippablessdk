
/**
* SKIVASTCreativeBase.h

*/

#import <Foundation/Foundation.h>

@interface SKIVASTCreativeBase : NSObject

- (void)initProperties;
- (void)parseWithReader:(void *) reader;
- (void)handleElementName:(NSString *)_currentElementName reader:(void *) reader readerOk:(int *)_readerOk currentNodeType:(int *)_currentNodeType currentXmlDept:(int *)_currentXmlDept handledInChild:(BOOL *)handledInChild;

/**
The preferred order in which multiple Creatives should be displayed
*/
@property (nonatomic, readonly) NSNumber *sequence;
/**
Identifies an API needed to execute the creative
*/
@property (nonatomic, readonly) NSString *apiFramework;
/**
A string used to identify the ad server that provides the creative.
*/
@property (nonatomic, readonly) NSString *identifier;
/**
To be deprecated in future version of VAST. Ad-ID for the creative (formerly ISCI)
*/
@property (nonatomic, readonly) NSString *adId;

/** Returns a dictionary representation of this class (recursivly making dictionaries of properties) */
@property (nonatomic, readonly) NSDictionary* dictionary;

@end

@interface SKIVASTCreativeBase (Reading)

/** The class's initializer used by the reader to build the object structure during parsing (xmlTextReaderPtr at the moment) */
- (id)initWithReader:(void*) reader;

/** Method that is overidden by subclasses that want to extend the base type (xmlTextReaderPtr at the moment) */
- (void)readAttributes:(void*) reader;

/** Property that sets the NSLocale used by formatters of this type. It defaults to enUSPOSIX */
@property (strong, nonatomic) NSLocale *locale;

@end


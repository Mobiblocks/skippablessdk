
/**
* SKIVASTAd.h

*/

#import <Foundation/Foundation.h>

@class SKIVASTWrapper;
@class SKIVASTInline;

@interface SKIVASTAd : NSObject

- (void)initProperties;
- (void)parseWithReader:(void *) reader;
- (void)handleElementName:(NSString *)_currentElementName reader:(void *) reader readerOk:(int *)_readerOk currentNodeType:(int *)_currentNodeType currentXmlDept:(int *)_currentXmlDept handledInChild:(BOOL *)handledInChild;

@property (nonatomic, readonly) NSString *identifier;
/**
Identifies the sequence of multiple Ads that are part of an Ad Pod.
*/
@property (nonatomic, readonly) NSNumber *sequence;
/**
A Boolean value that identifies a conditional ad.
*/
@property (nonatomic, readonly) NSNumber *conditionalAd;

/**
Second-level element surrounding complete ad data for a single ad
*/
@property (nonatomic, readonly) SKIVASTInline *inLine;
/**
Second-level element surrounding wrapper ad pointing to Secondary ad server.
*/
@property (nonatomic, readonly) SKIVASTWrapper *wrapper;

/** Returns a dictionary representation of this class (recursivly making dictionaries of properties) */
@property (nonatomic, readonly) NSDictionary* dictionary;

@end

@interface SKIVASTAd (Reading)

/** The class's initializer used by the reader to build the object structure during parsing (xmlTextReaderPtr at the moment) */
- (id)initWithReader:(void*) reader;

/** Method that is overidden by subclasses that want to extend the base type (xmlTextReaderPtr at the moment) */
- (void)readAttributes:(void*) reader;

/** Property that sets the NSLocale used by formatters of this type. It defaults to enUSPOSIX */
@property (strong, nonatomic) NSLocale *locale;

@end


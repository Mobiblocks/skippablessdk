
/**
* SKIVASTAdDefinitionBase.h

*/

#import <Foundation/Foundation.h>

@class SKIVASTImpression;
@class SKIVASTAdSystem;
@class SKIVASTPricing;
@class SKIVASTViewableImpression;
@class SKIVASTExtensions;

/**
Base type structure used by Inline or Wrapper ad content element types */

/**
Base type structure used by Inline or Wrapper ad content element types
*/
@interface SKIVASTAdDefinitionBase : NSObject

- (void)initProperties;
- (void)parseWithReader:(void *) reader;
- (void)handleElementName:(NSString *)_currentElementName reader:(void *) reader readerOk:(int *)_readerOk currentNodeType:(int *)_currentNodeType currentXmlDept:(int *)_currentXmlDept handledInChild:(BOOL *)handledInChild;

/**
Indicates source ad server
*/
@property (nonatomic, readonly) SKIVASTAdSystem *adSystem;
/**
URL to request if ad does not play due to error
*/
@property (nonatomic, readonly) NSURL *error;
/**
XML node for custom extensions, as defined by the ad server. When used, a custom
element should be nested under <Extensions> to help separate custom XML elements from VAST elements.
*/
@property (nonatomic, readonly) SKIVASTExtensions *extensions;
/**
URI for impression tracking
*/
@property (nonatomic, readonly) NSMutableArray<SKIVASTImpression *> *impressions;
/**
The price of the ad that can be used in real time bidding systems.
*/
@property (nonatomic, readonly) SKIVASTPricing *pricing;

@property (nonatomic, readonly) SKIVASTViewableImpression *viewableImpression;

/** Returns a dictionary representation of this class (recursivly making dictionaries of properties) */
@property (nonatomic, readonly) NSDictionary* dictionary;

@end

@interface SKIVASTAdDefinitionBase (Reading)

/** The class's initializer used by the reader to build the object structure during parsing (xmlTextReaderPtr at the moment) */
- (id)initWithReader:(void*) reader;

/** Method that is overidden by subclasses that want to extend the base type (xmlTextReaderPtr at the moment) */
- (void)readAttributes:(void*) reader;

/** Property that sets the NSLocale used by formatters of this type. It defaults to enUSPOSIX */
@property (strong, nonatomic) NSLocale *locale;

@end


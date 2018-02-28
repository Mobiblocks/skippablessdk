
/**
* SKIVASTWrapper.h

*/

#import <Foundation/Foundation.h>
#import "SKIVASTAdDefinitionBase.h"
@class SKIVASTCreatives;
@class SKIVASTAdVerificationsWrapper;

@interface SKIVASTWrapper : SKIVASTAdDefinitionBase

- (void)initProperties;
- (void)parseWithReader:(void *) reader;
- (void)handleElementName:(NSString *)_currentElementName reader:(void *) reader readerOk:(int *)_readerOk currentNodeType:(int *)_currentNodeType currentXmlDept:(int *)_currentXmlDept handledInChild:(BOOL *)handledInChild;

/**
a Boolean value that identifies whether subsequent wrappers after a requested VAST response is allowed.
*/
@property (nonatomic, readonly) NSNumber *followAdditionalWrappers;
/**
a Boolean value that identifies whether multiple ads are allowed in the requested VAST response.
*/
@property (nonatomic, readonly) NSNumber *allowMultipleAds;
/**
a Boolean value that provides instruction for using an available Ad when the requested VAST response returns no ads.
*/
@property (nonatomic, readonly) NSNumber *fallbackOnNoAd;

@property (nonatomic, readonly) SKIVASTAdVerificationsWrapper *adVerifications;
/**
A container for one or more Creative elements used to provide creative files for ad.
*/
@property (nonatomic, readonly) SKIVASTCreatives *creatives;
/**
A URI to another VAST response that may be another VAST Wrapper or a VAST InLine ad.
*/
@property (nonatomic, readonly) NSURL *vASTAdTagURI;

/** Returns a dictionary representation of this class (recursivly making dictionaries of properties) */
@property (nonatomic, readonly) NSDictionary* dictionary;

@end

@interface SKIVASTWrapper (Reading)

/** The class's initializer used by the reader to build the object structure during parsing (xmlTextReaderPtr at the moment) */
- (id)initWithReader:(void*) reader;

/** Method that is overidden by subclasses that want to extend the base type (xmlTextReaderPtr at the moment) */
- (void)readAttributes:(void*) reader;

/** Property that sets the NSLocale used by formatters of this type. It defaults to enUSPOSIX */
@property (strong, nonatomic) NSLocale *locale;

@end



/**
* SKIVASTCreativeWrapperChild.h

*/

#import <Foundation/Foundation.h>
#import "SKIVASTCreativeBase.h"
@class SKIVASTNonLinearAds;
@class SKIVASTCompanionAdsCollection;
@class SKIVASTLinearWrapperChild;

@interface SKIVASTCreativeWrapperChild : SKIVASTCreativeBase

- (void)initProperties;
- (void)parseWithReader:(void *) reader;
- (void)handleElementName:(NSString *)_currentElementName reader:(void *) reader readerOk:(int *)_readerOk currentNodeType:(int *)_currentNodeType currentXmlDept:(int *)_currentXmlDept handledInChild:(BOOL *)handledInChild;

@property (nonatomic, readonly) SKIVASTCompanionAdsCollection *companionAds;

@property (nonatomic, readonly) SKIVASTLinearWrapperChild *linear;

@property (nonatomic, readonly) SKIVASTNonLinearAds *nonLinearAds;

/** Returns a dictionary representation of this class (recursivly making dictionaries of properties) */
@property (nonatomic, readonly) NSDictionary* dictionary;

@end

@interface SKIVASTCreativeWrapperChild (Reading)

/** The class's initializer used by the reader to build the object structure during parsing (xmlTextReaderPtr at the moment) */
- (id)initWithReader:(void*) reader;

/** Method that is overidden by subclasses that want to extend the base type (xmlTextReaderPtr at the moment) */
- (void)readAttributes:(void*) reader;

/** Property that sets the NSLocale used by formatters of this type. It defaults to enUSPOSIX */
@property (strong, nonatomic) NSLocale *locale;

@end


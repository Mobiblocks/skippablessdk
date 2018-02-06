
/**
* SKIVASTInline.h

*/

#import <Foundation/Foundation.h>
#import "SKIVASTAdDefinitionBase.h"
@class SKIVASTSurvey;
@class SKIVASTAdVerificationsInline;
@class SKIVASTCreatives;
@class SKIVASTCategory;

@interface SKIVASTInline : SKIVASTAdDefinitionBase

- (void)initProperties;
- (void)parseWithReader:(void *) reader;
- (void)handleElementName:(NSString *)_currentElementName reader:(void *) reader readerOk:(int *)_readerOk currentNodeType:(int *)_currentNodeType currentXmlDept:(int *)_currentXmlDept handledInChild:(BOOL *)handledInChild;

/**
Common name of ad
*/
@property (nonatomic, readonly) NSString *adTitle;

@property (nonatomic, readonly) SKIVASTAdVerificationsInline *adVerifications;
/**
Name of advertiser as defined by the ad serving party
*/
@property (nonatomic, readonly) NSString *advertiser;
/**
A string that provides a category code or label that identifies the ad content.
*/
@property (nonatomic, readonly) NSMutableArray<SKIVASTCategory *> *categories;
/**
A container for one or more Creative elements used to provide creative files for ad.
*/
@property (nonatomic, readonly) SKIVASTCreatives *creatives;
/**
Longer description of ad
*/
@property (nonatomic, readonly) NSString *elementDescription;
/**
URL of request to survey vendor
*/
@property (nonatomic, readonly) SKIVASTSurvey *survey;

/** Returns a dictionary representation of this class (recursivly making dictionaries of properties) */
@property (nonatomic, readonly) NSDictionary* dictionary;

@end

@interface SKIVASTInline (Reading)

/** The class's initializer used by the reader to build the object structure during parsing (xmlTextReaderPtr at the moment) */
- (id)initWithReader:(void*) reader;

/** Method that is overidden by subclasses that want to extend the base type (xmlTextReaderPtr at the moment) */
- (void)readAttributes:(void*) reader;

/** Property that sets the NSLocale used by formatters of this type. It defaults to enUSPOSIX */
@property (strong, nonatomic) NSLocale *locale;

@end



/**
* SKIVASTVAST.h

*/

#import <Foundation/Foundation.h>

@class SKIVASTAd;

@interface SKIVASTVAST : NSObject

- (void)initProperties;
- (void)parseWithReader:(void *) reader;
- (void)handleElementName:(NSString *)_currentElementName reader:(void *) reader readerOk:(int *)_readerOk currentNodeType:(int *)_currentNodeType currentXmlDept:(int *)_currentXmlDept handledInChild:(BOOL *)handledInChild;

/**
Current version is 4.0
*/
@property (nonatomic, readonly) NSString *version;

/**
Top-level element, wraps each ad in the response or ad unit in an ad pod.
This MUST be present unless an Error element is present.
*/
@property (nonatomic, readonly) NSMutableArray<SKIVASTAd *> *ads;
/**
Used when there is no ad response. When the ad server does not or cannot return an Ad.
If included the video player must send a request to the URI provided (Sec 3.2.1).
*/
@property (nonatomic, readonly) NSURL *error;

/** Returns a dictionary representation of this class (recursivly making dictionaries of properties) */
@property (nonatomic, readonly) NSDictionary* dictionary;

@end

@interface SKIVASTVAST (Reading)

/** The class's initializer used by the reader to build the object structure during parsing (xmlTextReaderPtr at the moment) */
- (id)initWithReader:(void*) reader;

/** Method that is overidden by subclasses that want to extend the base type (xmlTextReaderPtr at the moment) */
- (void)readAttributes:(void*) reader;

/** Property that sets the NSLocale used by formatters of this type. It defaults to enUSPOSIX */
@property (strong, nonatomic) NSLocale *locale;

@end


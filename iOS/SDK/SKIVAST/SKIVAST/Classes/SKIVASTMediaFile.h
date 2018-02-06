
/**
* SKIVASTMediaFile.h

*/

#import <Foundation/Foundation.h>

@interface SKIVASTMediaFile : NSObject

- (void)initProperties;
- (void)parseWithReader:(void *) reader;
- (void)handleElementName:(NSString *)_currentElementName reader:(void *) reader readerOk:(int *)_readerOk currentNodeType:(int *)_currentNodeType currentXmlDept:(int *)_currentXmlDept handledInChild:(BOOL *)handledInChild;

/**
Optional identifier
*/
@property (nonatomic, readonly) NSString *identifier;
/**
Either "progressive" for progressive download protocols (such as HTTP) or
"streaming" for streaming protocols.
*/
@property (nonatomic, readonly) NSString *delivery;
/**
MIME type. Popular MIME types include, but are not limited to "video/x-ms-wmv" for Windows Media, and "video/x-flv" for Flash Video.
Image ads or interactive ads can be included in the MediaFiles section with appropriate Mime
types
*/
@property (nonatomic, readonly) NSString *type;
/**
Pixel dimensions of video
*/
@property (nonatomic, readonly) NSNumber *width;
/**
Pixel dimensions of video
*/
@property (nonatomic, readonly) NSNumber *height;
/**
The codec used to produce the media file as specified in RFC 4281.
*/
@property (nonatomic, readonly) NSString *codec;
/**
Bitrate of encoded video in Kbps. If bitrate is supplied, minBitrate and maxBitrate should not be supplied.
*/
@property (nonatomic, readonly) NSNumber *bitrate;
/**
Minimum bitrate of an adaptive stream in Kbps. If minBitrate is supplied, maxBitrate must be supplied and bitrate should not be supplied.
*/
@property (nonatomic, readonly) NSNumber *minBitrate;
/**
Maximum bitrate of an adaptive stream in Kbps. If maxBitrate is supplied, minBitrate must be supplied and bitrate should not be supplied.
*/
@property (nonatomic, readonly) NSNumber *maxBitrate;
/**
Whether it is acceptable to scale the image.
*/
@property (nonatomic, readonly) NSNumber *scalable;
/**
Whether the ad must have its aspect ratio maintained when scales
*/
@property (nonatomic, readonly) NSNumber *maintainAspectRatio;
/**
identifies the API needed to execute an interactive media file, but current
support is for backward compatibility. Please use the
<InteractiveCreativeFile> element to include files that require an API for execution.
*/
@property (nonatomic, readonly) NSString *apiFramework;

/**
the type's underlying value
*/
@property (nonatomic, readonly) NSURL *value;

/** Returns a dictionary representation of this class (recursivly making dictionaries of properties) */
@property (nonatomic, readonly) NSDictionary* dictionary;

@end

@interface SKIVASTMediaFile (Reading)

/** The class's initializer used by the reader to build the object structure during parsing (xmlTextReaderPtr at the moment) */
- (id)initWithReader:(void*) reader;

/** Method that is overidden by subclasses that want to extend the base type (xmlTextReaderPtr at the moment) */
- (void)readAttributes:(void*) reader;

/** Property that sets the NSLocale used by formatters of this type. It defaults to enUSPOSIX */
@property (strong, nonatomic) NSLocale *locale;

@end



#import "SKIVASTLinearInlineChild.h"
#import <libxml/xmlreader.h>
#import "SKILog.h"

#import "SKIVASTMediaFiles.h"
#import "SKIVASTVideoClicksInlineChild.h"
#import "SKIVASTAdParameters.h"

@interface SKIVASTLinearInlineChild ()

@property (nonatomic, readwrite) SKIVASTAdParameters *adParameters;
@property (nonatomic, readwrite) NSDate *duration;
@property (nonatomic, readwrite) SKIVASTMediaFiles *mediaFiles;
@property (nonatomic, readwrite) SKIVASTVideoClicksInlineChild *videoClicks;

@end

@implementation SKIVASTLinearInlineChild

/**
* Name:        readAttributes
* Parameters:  (void *) - the Libxml's xmlTextReader pointer
* Returns:     (void)
* Description: Read the attributes for the current XML element
*/
- (void) readAttributes:(void*) reader {
    [super readAttributes:reader];
    NSDate *(^timeFormatter)(NSString *string) = ^NSDate *(NSString *string) {
        static NSDateFormatter* timeFormatter;
        static NSDateFormatter* timeFormatterMillis;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            timeFormatter = [[NSDateFormatter alloc] init];
            timeFormatter.defaultDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
            timeFormatter.dateFormat = @"HH:mm:ss";
            timeFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
            timeFormatter.locale = self.locale;
            
            timeFormatterMillis = [[NSDateFormatter alloc] init];
            timeFormatterMillis.defaultDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
            timeFormatterMillis.dateFormat = @"HH:mm:ss.SSS";
            timeFormatterMillis.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
            timeFormatterMillis.locale = self.locale;
        });
        
        return [timeFormatter dateFromString:string] ?: [timeFormatterMillis dateFromString:string];
    };
    
}

/**
* Name:        initWithReader
* Parameters:  (void *) - the Libxml's xmlTextReader pointer
* Returns:     returns the classes created object
* Description: Iterate through the XML and create the SKIVASTLinearInlineChild object
*/
- (id) initWithReader:(void *) reader {
    self = [super init];
    /* Customize the object */
    if(self) {
        
        [self initProperties];
        [self parseWithReader:reader];
    }
    
    return self;
}

- (void)initProperties {
    [super initProperties];
    
}

- (void)parseWithReader:(void *) reader {
    int _complexTypeXmlDept = xmlTextReaderDepth(reader);
    
    [super parseWithReader:reader];
    
    int _readerOk __attribute__ ((unused)) = 1;
    int _currentNodeType __attribute__ ((unused)) = xmlTextReaderNodeType(reader);
    int _currentXmlDept = xmlTextReaderDepth(reader);
    while(_readerOk == 1 && _currentNodeType != XML_READER_TYPE_NONE && _complexTypeXmlDept < _currentXmlDept) {
        BOOL handledInChild = NO;
        if(_currentNodeType == XML_READER_TYPE_ELEMENT || _currentNodeType == XML_READER_TYPE_TEXT) {
            NSString* _currentElementName = [NSString stringWithCString:(const char*) xmlTextReaderConstLocalName(reader) encoding:NSUTF8StringEncoding];
            [self handleElementName:_currentElementName reader:reader readerOk:&_readerOk currentNodeType:&_currentNodeType currentXmlDept:&_currentXmlDept handledInChild:&handledInChild];
        }
        
        _readerOk = handledInChild ? xmlTextReaderReadState(reader) : xmlTextReaderRead(reader);
        _currentNodeType = xmlTextReaderNodeType(reader);
        _currentXmlDept = xmlTextReaderDepth(reader);
    }
}

- (void)handleElementName:(NSString *)_currentElementName reader:(void *) reader readerOk:(int *)_readerOk currentNodeType:(int *)_currentNodeType currentXmlDept:(int *)_currentXmlDept handledInChild:(BOOL *)handledInChild {
    
    NSDate *(^timeFormatter)(NSString *string) = ^NSDate *(NSString *string) {
        static NSDateFormatter* timeFormatter;
        static NSDateFormatter* timeFormatterMillis;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            timeFormatter = [[NSDateFormatter alloc] init];
            timeFormatter.defaultDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
            timeFormatter.dateFormat = @"HH:mm:ss";
            timeFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
            timeFormatter.locale = self.locale;
            
            timeFormatterMillis = [[NSDateFormatter alloc] init];
            timeFormatterMillis.defaultDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
            timeFormatterMillis.dateFormat = @"HH:mm:ss.SSS";
            timeFormatterMillis.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
            timeFormatterMillis.locale = self.locale;
        });
        
        return [timeFormatter dateFromString:string] ?: [timeFormatterMillis dateFromString:string];
    };
    
    if([@"AdParameters" isEqualToString:_currentElementName]) {
        
        self.adParameters = [[SKIVASTAdParameters alloc] initWithReader:reader];
        *handledInChild = YES;
        
    } else if([@"Duration" isEqualToString:_currentElementName]) {
        
        *_readerOk = xmlTextReaderRead(reader);
        *_currentNodeType = xmlTextReaderNodeType(reader);
        if (*_currentNodeType != XML_READER_TYPE_END_ELEMENT) {
            const char *DurationElementValue = (const char*) xmlTextReaderConstValue(reader);
            if(DurationElementValue) {
                
                self.duration = timeFormatter([NSString stringWithCString:DurationElementValue encoding:NSUTF8StringEncoding]);
                
            }
            *_readerOk = xmlTextReaderRead(reader);
            *_currentNodeType = xmlTextReaderNodeType(reader);
        }
        
    } else if([@"MediaFiles" isEqualToString:_currentElementName]) {
        
        self.mediaFiles = [[SKIVASTMediaFiles alloc] initWithReader:reader];
        *handledInChild = YES;
        
    } else if([@"VideoClicks" isEqualToString:_currentElementName]) {
        
        self.videoClicks = [[SKIVASTVideoClicksInlineChild alloc] initWithReader:reader];
        *handledInChild = YES;
        
    } else  {
        
        [super handleElementName:_currentElementName reader:reader readerOk:_readerOk currentNodeType:_currentNodeType currentXmlDept:_currentXmlDept handledInChild:handledInChild];
        
    }
}

/**
* Name:            dictionary
* Parameters:
* Returns:         Populated dictionary
* Description:     Populate the dictionary from the simpleType names within our XSD
*/
- (NSDictionary *)dictionary {
    /* Initial setup */
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValuesForKeysWithDictionary:[super dictionary]];
    
    /* Populate the dictionary */
    
    if(self.adParameters != nil) {
        NSDictionary *adParametersDict = [self.adParameters valueForKeyPath:@"dictionary"];
        [dict setObject:adParametersDict forKey:@"adParameters"];
    }
    
    if(self.duration != nil) {
        [dict setObject:self.duration forKey:@"duration"];
        
    }
    
    if(self.mediaFiles != nil) {
        NSDictionary *mediaFilesDict = [self.mediaFiles valueForKeyPath:@"dictionary"];
        [dict setObject:mediaFilesDict forKey:@"mediaFiles"];
    }
    
    if(self.videoClicks != nil) {
        NSDictionary *videoClicksDict = [self.videoClicks valueForKeyPath:@"dictionary"];
        [dict setObject:videoClicksDict forKey:@"videoClicks"];
    }
    
    return dict;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@\n%@", [super debugDescription], [self dictionary]];
}

@end


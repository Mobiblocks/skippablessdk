
#import "SKIVASTIcon.h"
#import <libxml/xmlreader.h>
#import "SKILog.h"

#import "SKIVASTIconClicks.h"

@interface SKIVASTIcon ()
@property (nonatomic, readwrite) NSString *program;
@property (nonatomic, readwrite) NSNumber *width;
@property (nonatomic, readwrite) NSNumber *height;
@property (nonatomic, readwrite) NSString *xPosition;
@property (nonatomic, readwrite) NSString *yPosition;
@property (nonatomic, readwrite) NSDate *duration;
@property (nonatomic, readwrite) NSDate *offset;
@property (nonatomic, readwrite) NSString *apiFramework;
@property (nonatomic, readwrite) NSNumber *pxratio;

@property (nonatomic, readwrite) SKIVASTIconClicks *iconClicks;
@property (nonatomic, readwrite) NSMutableArray<NSURL *> *iconViewTrackings;

@end

@implementation SKIVASTIcon

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
    
    NSNumberFormatter* decFormatter = [[NSNumberFormatter alloc] init];
    decFormatter.locale = self.locale;
    decFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    NSNumberFormatter* numFormatter = [[NSNumberFormatter alloc] init];
    numFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numFormatter.locale = self.locale;
    char* programAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"program");
    if(programAttrValue) {
        self.program = [NSString
        stringWithCString:programAttrValue
        encoding:NSUTF8StringEncoding];
        xmlFree(programAttrValue);
    }
    char* widthAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"width");
    if(widthAttrValue) {
        self.width = [numFormatter numberFromString:[NSString stringWithCString:widthAttrValue encoding:NSUTF8StringEncoding]];
        xmlFree(widthAttrValue);
    }
    char* heightAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"height");
    if(heightAttrValue) {
        self.height = [numFormatter numberFromString:[NSString stringWithCString:heightAttrValue encoding:NSUTF8StringEncoding]];
        xmlFree(heightAttrValue);
    }
    char* xPositionAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"xPosition");
    if(xPositionAttrValue) {
        self.xPosition = [NSString
        stringWithCString:xPositionAttrValue
        encoding:NSUTF8StringEncoding];
        xmlFree(xPositionAttrValue);
    }
    char* yPositionAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"yPosition");
    if(yPositionAttrValue) {
        self.yPosition = [NSString
        stringWithCString:yPositionAttrValue
        encoding:NSUTF8StringEncoding];
        xmlFree(yPositionAttrValue);
    }
    char* durationAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"duration");
    if(durationAttrValue) {
        self.duration = timeFormatter([NSString stringWithCString:durationAttrValue encoding:NSUTF8StringEncoding]);
        xmlFree(durationAttrValue);
    }
    char* offsetAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"offset");
    if(offsetAttrValue) {
        self.offset = timeFormatter([NSString stringWithCString:offsetAttrValue encoding:NSUTF8StringEncoding]);
        xmlFree(offsetAttrValue);
    }
    char* apiFrameworkAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"apiFramework");
    if(apiFrameworkAttrValue) {
        self.apiFramework = [NSString
        stringWithCString:apiFrameworkAttrValue
        encoding:NSUTF8StringEncoding];
        xmlFree(apiFrameworkAttrValue);
    }
    char* pxratioAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"pxratio");
    if(pxratioAttrValue) {
        self.pxratio = [decFormatter numberFromString:[NSString stringWithCString:pxratioAttrValue encoding:NSUTF8StringEncoding]];
        xmlFree(pxratioAttrValue);
    }
}

/**
* Name:        initWithReader
* Parameters:  (void *) - the Libxml's xmlTextReader pointer
* Returns:     returns the classes created object
* Description: Iterate through the XML and create the SKIVASTIcon object
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
    
    self.iconViewTrackings = [NSMutableArray array];
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
        
        _readerOk = /* handledInChild ? xmlTextReaderReadState(reader) : */xmlTextReaderRead(reader);
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
    
    NSNumberFormatter* decFormatter = [[NSNumberFormatter alloc] init];
    decFormatter.locale = self.locale;
    decFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    NSNumberFormatter* numFormatter = [[NSNumberFormatter alloc] init];
    numFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numFormatter.locale = self.locale;
    if([@"IconClicks" isEqualToString:_currentElementName]) {
        
        self.iconClicks = [[SKIVASTIconClicks alloc] initWithReader:reader];
        *handledInChild = YES;
        
    } else if([@"IconViewTracking" isEqualToString:_currentElementName]) {
        
        *_readerOk = xmlTextReaderRead(reader);
        *_currentNodeType = xmlTextReaderNodeType(reader);
        if (*_currentNodeType != XML_READER_TYPE_END_ELEMENT) {
            const char *IconViewTrackingElementValue = (const char*) xmlTextReaderConstValue(reader);
            if(IconViewTrackingElementValue) {
                NSString *iconViewTrackingsStringValue = [[NSString stringWithCString:IconViewTrackingElementValue encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                [self.iconViewTrackings addObject:[NSURL URLWithString:iconViewTrackingsStringValue]];
                
            }
            *_readerOk = xmlTextReaderRead(reader);
            *_currentNodeType = xmlTextReaderNodeType(reader);
        }
        
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
    
    if(self.program != nil) {
        [dict setObject:self.program forKey:@"program"];
    }
    
    if(self.width != nil) {
        [dict setObject:self.width forKey:@"width"];
    }
    
    if(self.height != nil) {
        [dict setObject:self.height forKey:@"height"];
    }
    
    if(self.xPosition != nil) {
        [dict setObject:self.xPosition forKey:@"xPosition"];
    }
    
    if(self.yPosition != nil) {
        [dict setObject:self.yPosition forKey:@"yPosition"];
    }
    
    if(self.duration != nil) {
        [dict setObject:self.duration forKey:@"duration"];
    }
    
    if(self.offset != nil) {
        [dict setObject:self.offset forKey:@"offset"];
    }
    
    if(self.apiFramework != nil) {
        [dict setObject:self.apiFramework forKey:@"apiFramework"];
    }
    
    if(self.pxratio != nil) {
        [dict setObject:self.pxratio forKey:@"pxratio"];
    }
    
    if(self.iconClicks != nil) {
        NSDictionary *iconClicksDict = [self.iconClicks valueForKeyPath:@"dictionary"];
        [dict setObject:iconClicksDict forKey:@"iconClicks"];
    }
    
    if(self.iconViewTrackings != nil) {
        [dict setObject:self.iconViewTrackings forKey:@"iconViewTrackings"];
        
    }
    
    return dict;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@\n%@", [super debugDescription], [self dictionary]];
}

@end


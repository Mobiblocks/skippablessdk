
#import "SKIVASTMediaFile.h"
#import <libxml/xmlreader.h>
#import "SKILog.h"

@interface SKIVASTMediaFile ()
@property (nonatomic, readwrite) NSString *identifier;
@property (nonatomic, readwrite) NSString *delivery;
@property (nonatomic, readwrite) NSString *type;
@property (nonatomic, readwrite) NSNumber *width;
@property (nonatomic, readwrite) NSNumber *height;
@property (nonatomic, readwrite) NSString *codec;
@property (nonatomic, readwrite) NSNumber *bitrate;
@property (nonatomic, readwrite) NSNumber *minBitrate;
@property (nonatomic, readwrite) NSNumber *maxBitrate;
@property (nonatomic, readwrite) NSNumber *scalable;
@property (nonatomic, readwrite) NSNumber *maintainAspectRatio;
@property (nonatomic, readwrite) NSString *apiFramework;

@property (nonatomic, readwrite) NSURL *value;

@end

@implementation SKIVASTMediaFile {
    NSLocale *_locale;
}
/**
* the type's locale. We need this often so we put it here
*/
- (NSLocale*)locale {
    if(!_locale) {
        _locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    }
    return _locale;
}
- (void)setLocale:(NSLocale*)locale {
    _locale = locale;
}

/**
* Name:        readAttributes
* Parameters:  (void *) - the Libxml's xmlTextReader pointer
* Returns:     (void)
* Description: Read the attributes for the current XML element
*/
- (void) readAttributes:(void*) reader {
    NSNumberFormatter* numFormatter = [[NSNumberFormatter alloc] init];
    numFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numFormatter.locale = self.locale;
    char* idAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"id");
    if(idAttrValue) {
        self.identifier = [NSString
        stringWithCString:idAttrValue
        encoding:NSUTF8StringEncoding];
        xmlFree(idAttrValue);
    }
    char* deliveryAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"delivery");
    if(deliveryAttrValue) {
        self.delivery = [NSString
        stringWithCString:deliveryAttrValue
        encoding:NSUTF8StringEncoding];
        xmlFree(deliveryAttrValue);
    }
    char* typeAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"type");
    if(typeAttrValue) {
        self.type = [NSString
        stringWithCString:typeAttrValue
        encoding:NSUTF8StringEncoding];
        xmlFree(typeAttrValue);
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
    char* codecAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"codec");
    if(codecAttrValue) {
        self.codec = [NSString
        stringWithCString:codecAttrValue
        encoding:NSUTF8StringEncoding];
        xmlFree(codecAttrValue);
    }
    char* bitrateAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"bitrate");
    if(bitrateAttrValue) {
        self.bitrate = [numFormatter numberFromString:[NSString stringWithCString:bitrateAttrValue encoding:NSUTF8StringEncoding]];
        xmlFree(bitrateAttrValue);
    }
    char* minBitrateAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"minBitrate");
    if(minBitrateAttrValue) {
        self.minBitrate = [numFormatter numberFromString:[NSString stringWithCString:minBitrateAttrValue encoding:NSUTF8StringEncoding]];
        xmlFree(minBitrateAttrValue);
    }
    char* maxBitrateAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"maxBitrate");
    if(maxBitrateAttrValue) {
        self.maxBitrate = [numFormatter numberFromString:[NSString stringWithCString:maxBitrateAttrValue encoding:NSUTF8StringEncoding]];
        xmlFree(maxBitrateAttrValue);
    }
    char* scalableAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"scalable");
    if(scalableAttrValue) {
        self.scalable = [NSNumber numberWithBool:[[NSString stringWithCString:scalableAttrValue encoding:NSUTF8StringEncoding] isEqualToString:@"true"]];
        xmlFree(scalableAttrValue);
    }
    char* maintainAspectRatioAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"maintainAspectRatio");
    if(maintainAspectRatioAttrValue) {
        self.maintainAspectRatio = [NSNumber numberWithBool:[[NSString stringWithCString:maintainAspectRatioAttrValue encoding:NSUTF8StringEncoding] isEqualToString:@"true"]];
        xmlFree(maintainAspectRatioAttrValue);
    }
    char* apiFrameworkAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"apiFramework");
    if(apiFrameworkAttrValue) {
        self.apiFramework = [NSString
        stringWithCString:apiFrameworkAttrValue
        encoding:NSUTF8StringEncoding];
        xmlFree(apiFrameworkAttrValue);
    }
}

/**
* Name:        initWithReader
* Parameters:  (void *) - the Libxml's xmlTextReader pointer
* Returns:     returns the classes created object
* Description: Iterate through the XML and create the SKIVASTMediaFile object
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
    
}

- (void)parseWithReader:(void *) reader {
    int _complexTypeXmlDept = xmlTextReaderDepth(reader);
    
    [self readAttributes:reader];
    
    int _readerOk __attribute__ ((unused)) = xmlTextReaderRead(reader);
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
    
    NSNumberFormatter* numFormatter = [[NSNumberFormatter alloc] init];
    numFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numFormatter.locale = self.locale;
    if([@"#text" isEqualToString:_currentElementName]){
        const char* contentValue = (const char*) xmlTextReaderConstValue(reader);
        if(contentValue) {
            NSString *value = [NSString stringWithCString:contentValue encoding:NSUTF8StringEncoding];
            value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            self.value = [NSURL URLWithString:value];
        }
    } else  {
        
        DVLog(@"Ignoring unexpected: %@", _currentElementName);
        
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
    
    /* Populate the dictionary */
    
    if(self.identifier != nil) {
        [dict setObject:self.identifier forKey:@"identifier"];
    }
    
    if(self.delivery != nil) {
        [dict setObject:self.delivery forKey:@"delivery"];
    }
    
    if(self.type != nil) {
        [dict setObject:self.type forKey:@"type"];
    }
    
    if(self.width != nil) {
        [dict setObject:self.width forKey:@"width"];
    }
    
    if(self.height != nil) {
        [dict setObject:self.height forKey:@"height"];
    }
    
    if(self.codec != nil) {
        [dict setObject:self.codec forKey:@"codec"];
    }
    
    if(self.bitrate != nil) {
        [dict setObject:self.bitrate forKey:@"bitrate"];
    }
    
    if(self.minBitrate != nil) {
        [dict setObject:self.minBitrate forKey:@"minBitrate"];
    }
    
    if(self.maxBitrate != nil) {
        [dict setObject:self.maxBitrate forKey:@"maxBitrate"];
    }
    
    if(self.scalable != nil) {
        [dict setObject:self.scalable forKey:@"scalable"];
    }
    
    if(self.maintainAspectRatio != nil) {
        [dict setObject:self.maintainAspectRatio forKey:@"maintainAspectRatio"];
    }
    
    if(self.apiFramework != nil) {
        [dict setObject:self.apiFramework forKey:@"apiFramework"];
    }
    
    if(self.value != nil) {
        [dict setObject:self.value forKey:@"value"];
    }
    
    return dict;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@\n%@", [super debugDescription], [self dictionary]];
}

@end


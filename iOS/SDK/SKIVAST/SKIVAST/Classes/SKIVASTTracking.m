
#import "SKIVASTTracking.h"
#import <libxml/xmlreader.h>
#import "SKILog.h"

@interface SKIVASTTracking ()
@property (nonatomic, readwrite) NSString *event;
@property (nonatomic, readwrite) NSString *offset;

@property (nonatomic, readwrite) NSURL *value;

@end

@implementation SKIVASTTracking {
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
    char* eventAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"event");
    if(eventAttrValue) {
        self.event = [NSString
        stringWithCString:eventAttrValue
        encoding:NSUTF8StringEncoding];
        xmlFree(eventAttrValue);
    }
    char* offsetAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"offset");
    if(offsetAttrValue) {
        self.offset = [NSString
        stringWithCString:offsetAttrValue
        encoding:NSUTF8StringEncoding];
        xmlFree(offsetAttrValue);
    }
}

/**
* Name:        initWithReader
* Parameters:  (void *) - the Libxml's xmlTextReader pointer
* Returns:     returns the classes created object
* Description: Iterate through the XML and create the SKIVASTTracking object
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
    
    if(self.event != nil) {
        [dict setObject:self.event forKey:@"event"];
    }
    
    if(self.offset != nil) {
        [dict setObject:self.offset forKey:@"offset"];
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


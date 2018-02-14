
#import "SKIVASTInteractiveCreativeFile.h"
#import <libxml/xmlreader.h>
#import "SKILog.h"

@interface SKIVASTInteractiveCreativeFile ()
@property (nonatomic, readwrite) NSString *type;
@property (nonatomic, readwrite) NSString *apiFramework;

@property (nonatomic, readwrite) NSURL *value;

@end

@implementation SKIVASTInteractiveCreativeFile {
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
    char* typeAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"type");
    if(typeAttrValue) {
        self.type = [NSString
        stringWithCString:typeAttrValue
        encoding:NSUTF8StringEncoding];
        xmlFree(typeAttrValue);
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
* Description: Iterate through the XML and create the SKIVASTInteractiveCreativeFile object
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
    
    if(self.type != nil) {
        [dict setObject:self.type forKey:@"type"];
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

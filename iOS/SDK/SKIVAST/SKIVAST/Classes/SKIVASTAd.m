
#import "SKIVASTAd.h"
#import <libxml/xmlreader.h>
#import "SKILog.h"

#import "SKIVASTWrapper.h"
#import "SKIVASTInline.h"

@interface SKIVASTAd ()
@property (nonatomic, readwrite) NSString *identifier;
@property (nonatomic, readwrite) NSNumber *sequence;
@property (nonatomic, readwrite) NSNumber *conditionalAd;

@property (nonatomic, readwrite) SKIVASTInline *inLine;
@property (nonatomic, readwrite) SKIVASTWrapper *wrapper;

@end

@implementation SKIVASTAd {
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
    char* sequenceAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"sequence");
    if(sequenceAttrValue) {
        self.sequence = [numFormatter numberFromString:[NSString stringWithCString:sequenceAttrValue encoding:NSUTF8StringEncoding]];
        xmlFree(sequenceAttrValue);
    }
    char* conditionalAdAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"conditionalAd");
    if(conditionalAdAttrValue) {
        self.conditionalAd = [NSNumber numberWithBool:[[NSString stringWithCString:conditionalAdAttrValue encoding:NSUTF8StringEncoding] isEqualToString:@"true"]];
        xmlFree(conditionalAdAttrValue);
    }
}

/**
* Name:        initWithReader
* Parameters:  (void *) - the Libxml's xmlTextReader pointer
* Returns:     returns the classes created object
* Description: Iterate through the XML and create the SKIVASTAd object
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
        
        _readerOk = /* handledInChild ? xmlTextReaderReadState(reader) : */xmlTextReaderRead(reader);
        _currentNodeType = xmlTextReaderNodeType(reader);
        _currentXmlDept = xmlTextReaderDepth(reader);
    }
}

- (void)handleElementName:(NSString *)_currentElementName reader:(void *) reader readerOk:(int *)_readerOk currentNodeType:(int *)_currentNodeType currentXmlDept:(int *)_currentXmlDept handledInChild:(BOOL *)handledInChild {
    
    NSNumberFormatter* numFormatter = [[NSNumberFormatter alloc] init];
    numFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numFormatter.locale = self.locale;
    if([@"InLine" isEqualToString:_currentElementName]) {
        
        self.inLine = [[SKIVASTInline alloc] initWithReader:reader];
        *handledInChild = YES;
        
    } else if([@"Wrapper" isEqualToString:_currentElementName]) {
        
        self.wrapper = [[SKIVASTWrapper alloc] initWithReader:reader];
        *handledInChild = YES;
        
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
    
    if(self.sequence != nil) {
        [dict setObject:self.sequence forKey:@"sequence"];
    }
    
    if(self.conditionalAd != nil) {
        [dict setObject:self.conditionalAd forKey:@"conditionalAd"];
    }
    
    if(self.inLine != nil) {
        NSDictionary *inLineDict = [self.inLine valueForKeyPath:@"dictionary"];
        [dict setObject:inLineDict forKey:@"inLine"];
    }
    
    if(self.wrapper != nil) {
        NSDictionary *wrapperDict = [self.wrapper valueForKeyPath:@"dictionary"];
        [dict setObject:wrapperDict forKey:@"wrapper"];
    }
    
    return dict;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@\n%@", [super debugDescription], [self dictionary]];
}

@end


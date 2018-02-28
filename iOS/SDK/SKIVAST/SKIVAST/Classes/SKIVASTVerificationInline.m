
#import "SKIVASTVerificationInline.h"
#import <libxml/xmlreader.h>
#import "SKILog.h"

#import "SKIVASTJavaScriptResource.h"
#import "SKIVASTViewableImpression.h"
#import "SKIVASTFlashResource.h"

@interface SKIVASTVerificationInline ()
@property (nonatomic, readwrite) NSString *vendor;

@property (nonatomic, readwrite) NSMutableArray<SKIVASTFlashResource *> *flashResources;
@property (nonatomic, readwrite) NSMutableArray<SKIVASTJavaScriptResource *> *javaScriptResources;
@property (nonatomic, readwrite) SKIVASTViewableImpression *viewableImpression;

@end

@implementation SKIVASTVerificationInline {
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
    char* vendorAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"vendor");
    if(vendorAttrValue) {
        self.vendor = [NSString
        stringWithCString:vendorAttrValue
        encoding:NSUTF8StringEncoding];
        xmlFree(vendorAttrValue);
    }
}

/**
* Name:        initWithReader
* Parameters:  (void *) - the Libxml's xmlTextReader pointer
* Returns:     returns the classes created object
* Description: Iterate through the XML and create the SKIVASTVerificationInline object
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
    
    self.flashResources = [NSMutableArray array];
    self.javaScriptResources = [NSMutableArray array];
    
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
    
    if([@"FlashResource" isEqualToString:_currentElementName]) {
        
        [self.flashResources addObject:[[SKIVASTFlashResource alloc] initWithReader:reader]];
        *handledInChild = YES;
        
    } else if([@"JavaScriptResource" isEqualToString:_currentElementName]) {
        
        [self.javaScriptResources addObject:[[SKIVASTJavaScriptResource alloc] initWithReader:reader]];
        *handledInChild = YES;
        
    } else if([@"ViewableImpression" isEqualToString:_currentElementName]) {
        
        self.viewableImpression = [[SKIVASTViewableImpression alloc] initWithReader:reader];
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
    
    if(self.vendor != nil) {
        [dict setObject:self.vendor forKey:@"vendor"];
    }
    
    if(self.flashResources != nil) {
        NSDictionary *flashResourcesDict = [self.flashResources valueForKeyPath:@"dictionary"];
        [dict setObject:flashResourcesDict forKey:@"flashResources"];
    }
    
    if(self.javaScriptResources != nil) {
        NSDictionary *javaScriptResourcesDict = [self.javaScriptResources valueForKeyPath:@"dictionary"];
        [dict setObject:javaScriptResourcesDict forKey:@"javaScriptResources"];
    }
    
    if(self.viewableImpression != nil) {
        NSDictionary *viewableImpressionDict = [self.viewableImpression valueForKeyPath:@"dictionary"];
        [dict setObject:viewableImpressionDict forKey:@"viewableImpression"];
    }
    
    return dict;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@\n%@", [super debugDescription], [self dictionary]];
}

@end


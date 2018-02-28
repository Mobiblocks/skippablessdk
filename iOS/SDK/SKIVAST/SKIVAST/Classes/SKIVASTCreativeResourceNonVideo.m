
#import "SKIVASTCreativeResourceNonVideo.h"
#import <libxml/xmlreader.h>
#import "SKILog.h"

#import "SKIVASTStaticResource.h"
#import "SKIVASTHTMLResource.h"

@interface SKIVASTCreativeResourceNonVideo ()

@property (nonatomic, readwrite) NSMutableArray<SKIVASTHTMLResource *> *hTMLResources;
@property (nonatomic, readwrite) NSMutableArray<NSURL *> *iFrameResources;
@property (nonatomic, readwrite) NSMutableArray<SKIVASTStaticResource *> *staticResources;

@end

@implementation SKIVASTCreativeResourceNonVideo {
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
}

/**
* Name:        initWithReader
* Parameters:  (void *) - the Libxml's xmlTextReader pointer
* Returns:     returns the classes created object
* Description: Iterate through the XML and create the SKIVASTCreativeResourceNonVideo object
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
    
    self.hTMLResources = [NSMutableArray array];
    self.iFrameResources = [NSMutableArray array];
    self.staticResources = [NSMutableArray array];
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
    
    if([@"HTMLResource" isEqualToString:_currentElementName]) {
        
        [self.hTMLResources addObject:[[SKIVASTHTMLResource alloc] initWithReader:reader]];
        *handledInChild = YES;
        
    } else if([@"IFrameResource" isEqualToString:_currentElementName]) {
        
        *_readerOk = xmlTextReaderRead(reader);
        *_currentNodeType = xmlTextReaderNodeType(reader);
        if (*_currentNodeType != XML_READER_TYPE_END_ELEMENT) {
            const char *IFrameResourceElementValue = (const char*) xmlTextReaderConstValue(reader);
            if(IFrameResourceElementValue) {
                NSString *iFrameResourcesStringValue = [[NSString stringWithCString:IFrameResourceElementValue encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                [self.iFrameResources addObject:[NSURL URLWithString:iFrameResourcesStringValue]];
                
            }
            *_readerOk = xmlTextReaderRead(reader);
            *_currentNodeType = xmlTextReaderNodeType(reader);
        }
        
    } else if([@"StaticResource" isEqualToString:_currentElementName]) {
        
        [self.staticResources addObject:[[SKIVASTStaticResource alloc] initWithReader:reader]];
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
    
    if(self.hTMLResources != nil) {
        NSDictionary *hTMLResourcesDict = [self.hTMLResources valueForKeyPath:@"dictionary"];
        [dict setObject:hTMLResourcesDict forKey:@"hTMLResources"];
    }
    
    if(self.iFrameResources != nil) {
        [dict setObject:self.iFrameResources forKey:@"iFrameResources"];
        
    }
    
    if(self.staticResources != nil) {
        NSDictionary *staticResourcesDict = [self.staticResources valueForKeyPath:@"dictionary"];
        [dict setObject:staticResourcesDict forKey:@"staticResources"];
    }
    
    return dict;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@\n%@", [super debugDescription], [self dictionary]];
}

@end


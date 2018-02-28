
#import "SKIVASTMediaFiles.h"
#import <libxml/xmlreader.h>
#import "SKILog.h"

#import "SKIVASTInteractiveCreativeFile.h"
#import "SKIVASTMediaFile.h"

@interface SKIVASTMediaFiles ()

@property (nonatomic, readwrite) NSMutableArray<SKIVASTMediaFile *> *mediaFiles;
@property (nonatomic, readwrite) NSURL *mezzanine;
@property (nonatomic, readwrite) NSMutableArray<SKIVASTInteractiveCreativeFile *> *interactiveCreativeFiles;

@end

@implementation SKIVASTMediaFiles {
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
* Description: Iterate through the XML and create the SKIVASTMediaFiles object
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
    
    self.mediaFiles = [NSMutableArray array];
    
    self.interactiveCreativeFiles = [NSMutableArray array];
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
    
    if([@"MediaFile" isEqualToString:_currentElementName]) {
        
        [self.mediaFiles addObject:[[SKIVASTMediaFile alloc] initWithReader:reader]];
        *handledInChild = YES;
        
    } else if([@"Mezzanine" isEqualToString:_currentElementName]) {
        
        *_readerOk = xmlTextReaderRead(reader);
        *_currentNodeType = xmlTextReaderNodeType(reader);
        if (*_currentNodeType != XML_READER_TYPE_END_ELEMENT) {
            const char *MezzanineElementValue = (const char*) xmlTextReaderConstValue(reader);
            if(MezzanineElementValue) {
                NSString *mezzanineStringValue = [[NSString stringWithCString:MezzanineElementValue encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                self.mezzanine = [NSURL URLWithString:mezzanineStringValue];
                
            }
            *_readerOk = xmlTextReaderRead(reader);
            *_currentNodeType = xmlTextReaderNodeType(reader);
        }
        
    } else if([@"InteractiveCreativeFile" isEqualToString:_currentElementName]) {
        
        [self.interactiveCreativeFiles addObject:[[SKIVASTInteractiveCreativeFile alloc] initWithReader:reader]];
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
    
    if(self.mediaFiles != nil) {
        NSDictionary *mediaFilesDict = [self.mediaFiles valueForKeyPath:@"dictionary"];
        [dict setObject:mediaFilesDict forKey:@"mediaFiles"];
    }
    
    if(self.mezzanine != nil) {
        [dict setObject:self.mezzanine forKey:@"mezzanine"];
        
    }
    
    if(self.interactiveCreativeFiles != nil) {
        NSDictionary *interactiveCreativeFilesDict = [self.interactiveCreativeFiles valueForKeyPath:@"dictionary"];
        [dict setObject:interactiveCreativeFilesDict forKey:@"interactiveCreativeFiles"];
    }
    
    return dict;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@\n%@", [super debugDescription], [self dictionary]];
}

@end


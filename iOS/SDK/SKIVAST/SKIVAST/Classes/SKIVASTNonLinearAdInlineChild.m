
#import "SKIVASTNonLinearAdInlineChild.h"
#import <libxml/xmlreader.h>
#import "SKILog.h"

#import "SKIVASTNonLinearClickTracking.h"
#import "SKIVASTAdParameters.h"

@interface SKIVASTNonLinearAdInlineChild ()

@property (nonatomic, readwrite) SKIVASTAdParameters *adParameters;
@property (nonatomic, readwrite) NSURL *nonLinearClickThrough;
@property (nonatomic, readwrite) NSMutableArray<SKIVASTNonLinearClickTracking *> *nonLinearClickTrackings;

@end

@implementation SKIVASTNonLinearAdInlineChild

/**
* Name:        readAttributes
* Parameters:  (void *) - the Libxml's xmlTextReader pointer
* Returns:     (void)
* Description: Read the attributes for the current XML element
*/
- (void) readAttributes:(void*) reader {
    [super readAttributes:reader];
}

/**
* Name:        initWithReader
* Parameters:  (void *) - the Libxml's xmlTextReader pointer
* Returns:     returns the classes created object
* Description: Iterate through the XML and create the SKIVASTNonLinearAdInlineChild object
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
    
    self.nonLinearClickTrackings = [NSMutableArray array];
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
    
    if([@"AdParameters" isEqualToString:_currentElementName]) {
        
        self.adParameters = [[SKIVASTAdParameters alloc] initWithReader:reader];
        *handledInChild = YES;
        
    } else if([@"NonLinearClickThrough" isEqualToString:_currentElementName]) {
        
        *_readerOk = xmlTextReaderRead(reader);
        *_currentNodeType = xmlTextReaderNodeType(reader);
        if (*_currentNodeType != XML_READER_TYPE_END_ELEMENT) {
            const char *NonLinearClickThroughElementValue = (const char*) xmlTextReaderConstValue(reader);
            if(NonLinearClickThroughElementValue) {
                NSString *nonLinearClickThroughStringValue = [[NSString stringWithCString:NonLinearClickThroughElementValue encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                self.nonLinearClickThrough = [NSURL URLWithString:nonLinearClickThroughStringValue];
                
            }
            *_readerOk = xmlTextReaderRead(reader);
            *_currentNodeType = xmlTextReaderNodeType(reader);
        }
        
    } else if([@"NonLinearClickTracking" isEqualToString:_currentElementName]) {
        
        [self.nonLinearClickTrackings addObject:[[SKIVASTNonLinearClickTracking alloc] initWithReader:reader]];
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
    
    if(self.nonLinearClickThrough != nil) {
        [dict setObject:self.nonLinearClickThrough forKey:@"nonLinearClickThrough"];
        
    }
    
    if(self.nonLinearClickTrackings != nil) {
        NSDictionary *nonLinearClickTrackingsDict = [self.nonLinearClickTrackings valueForKeyPath:@"dictionary"];
        [dict setObject:nonLinearClickTrackingsDict forKey:@"nonLinearClickTrackings"];
    }
    
    return dict;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@\n%@", [super debugDescription], [self dictionary]];
}

@end


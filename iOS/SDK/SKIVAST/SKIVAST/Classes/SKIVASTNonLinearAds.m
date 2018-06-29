
#import "SKIVASTNonLinearAds.h"
#import <libxml/xmlreader.h>
#import "SKILog.h"

#import "SKIVASTNonLinearAdInlineChild.h"
#import "SKIVASTTrackingEvents.h"

@interface SKIVASTNonLinearAds ()

@property (nonatomic, readwrite) SKIVASTTrackingEvents *trackingEvents;
@property (nonatomic, readwrite) NSMutableArray<SKIVASTNonLinearAdInlineChild *> *nonLinears;

@end

@implementation SKIVASTNonLinearAds {
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
* Description: Iterate through the XML and create the SKIVASTNonLinearAds object
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
    
    self.nonLinears = [NSMutableArray array];
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
    
    if([@"TrackingEvents" isEqualToString:_currentElementName]) {
        
        self.trackingEvents = [[SKIVASTTrackingEvents alloc] initWithReader:reader];
        *handledInChild = YES;
        
    } else if([@"NonLinear" isEqualToString:_currentElementName]) {
        
        [self.nonLinears addObject:[[SKIVASTNonLinearAdInlineChild alloc] initWithReader:reader]];
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
    
    if(self.trackingEvents != nil) {
        NSDictionary *trackingEventsDict = [self.trackingEvents valueForKeyPath:@"dictionary"];
        [dict setObject:trackingEventsDict forKey:@"trackingEvents"];
    }
    
    if(self.nonLinears != nil) {
        NSDictionary *nonLinearsDict = [self.nonLinears valueForKeyPath:@"dictionary"];
        [dict setObject:nonLinearsDict forKey:@"nonLinears"];
    }
    
    return dict;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@\n%@", [super debugDescription], [self dictionary]];
}

@end


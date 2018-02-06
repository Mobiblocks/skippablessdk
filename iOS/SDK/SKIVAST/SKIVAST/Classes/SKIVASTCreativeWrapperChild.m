
#import "SKIVASTCreativeWrapperChild.h"
#import <libxml/xmlreader.h>
#import "SKILog.h"

#import "SKIVASTNonLinearAds.h"
#import "SKIVASTCompanionAdsCollection.h"
#import "SKIVASTLinearWrapperChild.h"

@interface SKIVASTCreativeWrapperChild ()

@property (nonatomic, readwrite) SKIVASTCompanionAdsCollection *companionAds;
@property (nonatomic, readwrite) SKIVASTLinearWrapperChild *linear;
@property (nonatomic, readwrite) SKIVASTNonLinearAds *nonLinearAds;

@end

@implementation SKIVASTCreativeWrapperChild

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
* Description: Iterate through the XML and create the SKIVASTCreativeWrapperChild object
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
    
    if([@"CompanionAds" isEqualToString:_currentElementName]) {
        
        self.companionAds = [[SKIVASTCompanionAdsCollection alloc] initWithReader:reader];
        *handledInChild = YES;
        
    } else if([@"Linear" isEqualToString:_currentElementName]) {
        
        self.linear = [[SKIVASTLinearWrapperChild alloc] initWithReader:reader];
        *handledInChild = YES;
        
    } else if([@"NonLinearAds" isEqualToString:_currentElementName]) {
        
        self.nonLinearAds = [[SKIVASTNonLinearAds alloc] initWithReader:reader];
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
    
    if(self.companionAds != nil) {
        NSDictionary *companionAdsDict = [self.companionAds valueForKeyPath:@"dictionary"];
        [dict setObject:companionAdsDict forKey:@"companionAds"];
    }
    
    if(self.linear != nil) {
        NSDictionary *linearDict = [self.linear valueForKeyPath:@"dictionary"];
        [dict setObject:linearDict forKey:@"linear"];
    }
    
    if(self.nonLinearAds != nil) {
        NSDictionary *nonLinearAdsDict = [self.nonLinearAds valueForKeyPath:@"dictionary"];
        [dict setObject:nonLinearAdsDict forKey:@"nonLinearAds"];
    }
    
    return dict;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@\n%@", [super debugDescription], [self dictionary]];
}

@end


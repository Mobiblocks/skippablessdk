
#import "SKIVASTWrapper.h"
#import <libxml/xmlreader.h>
#import "SKILog.h"

#import "SKIVASTCreatives.h"
#import "SKIVASTAdVerificationsWrapper.h"

@interface SKIVASTWrapper ()
@property (nonatomic, readwrite) NSNumber *followAdditionalWrappers;
@property (nonatomic, readwrite) NSNumber *allowMultipleAds;
@property (nonatomic, readwrite) NSNumber *fallbackOnNoAd;

@property (nonatomic, readwrite) SKIVASTAdVerificationsWrapper *adVerifications;
@property (nonatomic, readwrite) SKIVASTCreatives *creatives;
@property (nonatomic, readwrite) NSURL *vASTAdTagURI;

@end

@implementation SKIVASTWrapper

/**
* Name:        readAttributes
* Parameters:  (void *) - the Libxml's xmlTextReader pointer
* Returns:     (void)
* Description: Read the attributes for the current XML element
*/
- (void) readAttributes:(void*) reader {
    [super readAttributes:reader];
    char* followAdditionalWrappersAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"followAdditionalWrappers");
    if(followAdditionalWrappersAttrValue) {
        self.followAdditionalWrappers = [NSNumber numberWithBool:[[NSString stringWithCString:followAdditionalWrappersAttrValue encoding:NSUTF8StringEncoding] isEqualToString:@"true"]];
        xmlFree(followAdditionalWrappersAttrValue);
    }
    char* allowMultipleAdsAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"allowMultipleAds");
    if(allowMultipleAdsAttrValue) {
        self.allowMultipleAds = [NSNumber numberWithBool:[[NSString stringWithCString:allowMultipleAdsAttrValue encoding:NSUTF8StringEncoding] isEqualToString:@"true"]];
        xmlFree(allowMultipleAdsAttrValue);
    }
    char* fallbackOnNoAdAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"fallbackOnNoAd");
    if(fallbackOnNoAdAttrValue) {
        self.fallbackOnNoAd = [NSNumber numberWithBool:[[NSString stringWithCString:fallbackOnNoAdAttrValue encoding:NSUTF8StringEncoding] isEqualToString:@"true"]];
        xmlFree(fallbackOnNoAdAttrValue);
    }
}

/**
* Name:        initWithReader
* Parameters:  (void *) - the Libxml's xmlTextReader pointer
* Returns:     returns the classes created object
* Description: Iterate through the XML and create the SKIVASTWrapper object
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
        
        _readerOk = /* handledInChild ? xmlTextReaderReadState(reader) : */xmlTextReaderRead(reader);
        _currentNodeType = xmlTextReaderNodeType(reader);
        _currentXmlDept = xmlTextReaderDepth(reader);
    }
}

- (void)handleElementName:(NSString *)_currentElementName reader:(void *) reader readerOk:(int *)_readerOk currentNodeType:(int *)_currentNodeType currentXmlDept:(int *)_currentXmlDept handledInChild:(BOOL *)handledInChild {
    
    if([@"AdVerifications" isEqualToString:_currentElementName]) {
        
        self.adVerifications = [[SKIVASTAdVerificationsWrapper alloc] initWithReader:reader];
        *handledInChild = YES;
        
    } else if([@"Creatives" isEqualToString:_currentElementName]) {
        
        self.creatives = [[SKIVASTCreatives alloc] initWithReader:reader];
        *handledInChild = YES;
        
    } else if([@"VASTAdTagURI" isEqualToString:_currentElementName]) {
        
        *_readerOk = xmlTextReaderRead(reader);
        *_currentNodeType = xmlTextReaderNodeType(reader);
        if (*_currentNodeType != XML_READER_TYPE_END_ELEMENT) {
            const char *VASTAdTagURIElementValue = (const char*) xmlTextReaderConstValue(reader);
            if(VASTAdTagURIElementValue) {
                NSString *vASTAdTagURIStringValue = [[NSString stringWithCString:VASTAdTagURIElementValue encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                self.vASTAdTagURI = [NSURL URLWithString:vASTAdTagURIStringValue];
                
            }
            *_readerOk = xmlTextReaderRead(reader);
            *_currentNodeType = xmlTextReaderNodeType(reader);
        }
        
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
    
    if(self.followAdditionalWrappers != nil) {
        [dict setObject:self.followAdditionalWrappers forKey:@"followAdditionalWrappers"];
    }
    
    if(self.allowMultipleAds != nil) {
        [dict setObject:self.allowMultipleAds forKey:@"allowMultipleAds"];
    }
    
    if(self.fallbackOnNoAd != nil) {
        [dict setObject:self.fallbackOnNoAd forKey:@"fallbackOnNoAd"];
    }
    
    if(self.adVerifications != nil) {
        NSDictionary *adVerificationsDict = [self.adVerifications valueForKeyPath:@"dictionary"];
        [dict setObject:adVerificationsDict forKey:@"adVerifications"];
    }
    
    if(self.creatives != nil) {
        NSDictionary *creativesDict = [self.creatives valueForKeyPath:@"dictionary"];
        [dict setObject:creativesDict forKey:@"creatives"];
    }
    
    if(self.vASTAdTagURI != nil) {
        [dict setObject:self.vASTAdTagURI forKey:@"vASTAdTagURI"];
        
    }
    
    return dict;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@\n%@", [super debugDescription], [self dictionary]];
}

@end


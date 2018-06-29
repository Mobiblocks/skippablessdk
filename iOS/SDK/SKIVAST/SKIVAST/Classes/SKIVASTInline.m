
#import "SKIVASTInline.h"
#import <libxml/xmlreader.h>
#import "SKILog.h"

#import "SKIVASTSurvey.h"
#import "SKIVASTAdVerificationsInline.h"
#import "SKIVASTCreatives.h"
#import "SKIVASTCategory.h"

@interface SKIVASTInline ()

@property (nonatomic, readwrite) NSString *adTitle;
@property (nonatomic, readwrite) SKIVASTAdVerificationsInline *adVerifications;
@property (nonatomic, readwrite) NSString *advertiser;
@property (nonatomic, readwrite) NSMutableArray<SKIVASTCategory *> *categories;
@property (nonatomic, readwrite) SKIVASTCreatives *creatives;
@property (nonatomic, readwrite) NSString *elementDescription;
@property (nonatomic, readwrite) SKIVASTSurvey *survey;

@end

@implementation SKIVASTInline

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
* Description: Iterate through the XML and create the SKIVASTInline object
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
    
    self.categories = [NSMutableArray array];
    
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
    
    if([@"AdTitle" isEqualToString:_currentElementName]) {
        
        *_readerOk = xmlTextReaderRead(reader);
        *_currentNodeType = xmlTextReaderNodeType(reader);
        if (*_currentNodeType != XML_READER_TYPE_END_ELEMENT) {
            const char *AdTitleElementValue = (const char*) xmlTextReaderConstValue(reader);
            if(AdTitleElementValue) {
                
                self.adTitle = [NSString stringWithCString:AdTitleElementValue encoding:NSUTF8StringEncoding];
                
            }
            *_readerOk = xmlTextReaderRead(reader);
            *_currentNodeType = xmlTextReaderNodeType(reader);
        }
        
    } else if([@"AdVerifications" isEqualToString:_currentElementName]) {
        
        self.adVerifications = [[SKIVASTAdVerificationsInline alloc] initWithReader:reader];
        *handledInChild = YES;
        
    } else if([@"Advertiser" isEqualToString:_currentElementName]) {
        
        *_readerOk = xmlTextReaderRead(reader);
        *_currentNodeType = xmlTextReaderNodeType(reader);
        if (*_currentNodeType != XML_READER_TYPE_END_ELEMENT) {
            const char *AdvertiserElementValue = (const char*) xmlTextReaderConstValue(reader);
            if(AdvertiserElementValue) {
                
                self.advertiser = [NSString stringWithCString:AdvertiserElementValue encoding:NSUTF8StringEncoding];
                
            }
            *_readerOk = xmlTextReaderRead(reader);
            *_currentNodeType = xmlTextReaderNodeType(reader);
        }
        
    } else if([@"Category" isEqualToString:_currentElementName]) {
        
        [self.categories addObject:[[SKIVASTCategory alloc] initWithReader:reader]];
        *handledInChild = YES;
        
    } else if([@"Creatives" isEqualToString:_currentElementName]) {
        
        self.creatives = [[SKIVASTCreatives alloc] initWithReader:reader];
        *handledInChild = YES;
        
    } else if([@"Description" isEqualToString:_currentElementName]) {
        
        *_readerOk = xmlTextReaderRead(reader);
        *_currentNodeType = xmlTextReaderNodeType(reader);
        if (*_currentNodeType != XML_READER_TYPE_END_ELEMENT) {
            const char *DescriptionElementValue = (const char*) xmlTextReaderConstValue(reader);
            if(DescriptionElementValue) {
                
                self.elementDescription = [NSString stringWithCString:DescriptionElementValue encoding:NSUTF8StringEncoding];
                
            }
            *_readerOk = xmlTextReaderRead(reader);
            *_currentNodeType = xmlTextReaderNodeType(reader);
        }
        
    } else if([@"Survey" isEqualToString:_currentElementName]) {
        
        self.survey = [[SKIVASTSurvey alloc] initWithReader:reader];
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
    
    if(self.adTitle != nil) {
        [dict setObject:self.adTitle forKey:@"adTitle"];
        
    }
    
    if(self.adVerifications != nil) {
        NSDictionary *adVerificationsDict = [self.adVerifications valueForKeyPath:@"dictionary"];
        [dict setObject:adVerificationsDict forKey:@"adVerifications"];
    }
    
    if(self.advertiser != nil) {
        [dict setObject:self.advertiser forKey:@"advertiser"];
        
    }
    
    if(self.categories != nil) {
        NSDictionary *categoriesDict = [self.categories valueForKeyPath:@"dictionary"];
        [dict setObject:categoriesDict forKey:@"categories"];
    }
    
    if(self.creatives != nil) {
        NSDictionary *creativesDict = [self.creatives valueForKeyPath:@"dictionary"];
        [dict setObject:creativesDict forKey:@"creatives"];
    }
    
    if(self.elementDescription != nil) {
        [dict setObject:self.elementDescription forKey:@"elementDescription"];
        
    }
    
    if(self.survey != nil) {
        NSDictionary *surveyDict = [self.survey valueForKeyPath:@"dictionary"];
        [dict setObject:surveyDict forKey:@"survey"];
    }
    
    return dict;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@\n%@", [super debugDescription], [self dictionary]];
}

@end


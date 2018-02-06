
#import "SKIVASTCompanionAd.h"
#import <libxml/xmlreader.h>
#import "SKILog.h"

#import "SKIVASTAdParameters.h"
#import "SKIVASTCompanionClickTracking.h"
#import "SKIVASTCreativeExtensions.h"
#import "SKIVASTTrackingEvents.h"

@interface SKIVASTCompanionAd ()
@property (nonatomic, readwrite) NSString *identifier;
@property (nonatomic, readwrite) NSNumber *width;
@property (nonatomic, readwrite) NSNumber *height;
@property (nonatomic, readwrite) NSNumber *assetWidth;
@property (nonatomic, readwrite) NSNumber *assetHeight;
@property (nonatomic, readwrite) NSNumber *expandedWidth;
@property (nonatomic, readwrite) NSNumber *expandedHeight;
@property (nonatomic, readwrite) NSString *apiFramework;
@property (nonatomic, readwrite) NSString *adSlotID;
@property (nonatomic, readwrite) NSNumber *pxratio;

@property (nonatomic, readwrite) SKIVASTAdParameters *adParameters;
@property (nonatomic, readwrite) NSString *altText;
@property (nonatomic, readwrite) NSURL *companionClickThrough;
@property (nonatomic, readwrite) NSMutableArray<SKIVASTCompanionClickTracking *> *companionClickTrackings;
@property (nonatomic, readwrite) SKIVASTCreativeExtensions *creativeExtensions;
@property (nonatomic, readwrite) SKIVASTTrackingEvents *trackingEvents;

@end

@implementation SKIVASTCompanionAd

/**
* Name:        readAttributes
* Parameters:  (void *) - the Libxml's xmlTextReader pointer
* Returns:     (void)
* Description: Read the attributes for the current XML element
*/
- (void) readAttributes:(void*) reader {
    [super readAttributes:reader];
    NSNumberFormatter* numFormatter = [[NSNumberFormatter alloc] init];
    numFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numFormatter.locale = self.locale;
    NSNumberFormatter* decFormatter = [[NSNumberFormatter alloc] init];
    decFormatter.locale = self.locale;
    decFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    char* idAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"id");
    if(idAttrValue) {
        self.identifier = [NSString
        stringWithCString:idAttrValue
        encoding:NSUTF8StringEncoding];
        xmlFree(idAttrValue);
    }
    char* widthAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"width");
    if(widthAttrValue) {
        self.width = [numFormatter numberFromString:[NSString stringWithCString:widthAttrValue encoding:NSUTF8StringEncoding]];
        xmlFree(widthAttrValue);
    }
    char* heightAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"height");
    if(heightAttrValue) {
        self.height = [numFormatter numberFromString:[NSString stringWithCString:heightAttrValue encoding:NSUTF8StringEncoding]];
        xmlFree(heightAttrValue);
    }
    char* assetWidthAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"assetWidth");
    if(assetWidthAttrValue) {
        self.assetWidth = [numFormatter numberFromString:[NSString stringWithCString:assetWidthAttrValue encoding:NSUTF8StringEncoding]];
        xmlFree(assetWidthAttrValue);
    }
    char* assetHeightAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"assetHeight");
    if(assetHeightAttrValue) {
        self.assetHeight = [numFormatter numberFromString:[NSString stringWithCString:assetHeightAttrValue encoding:NSUTF8StringEncoding]];
        xmlFree(assetHeightAttrValue);
    }
    char* expandedWidthAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"expandedWidth");
    if(expandedWidthAttrValue) {
        self.expandedWidth = [numFormatter numberFromString:[NSString stringWithCString:expandedWidthAttrValue encoding:NSUTF8StringEncoding]];
        xmlFree(expandedWidthAttrValue);
    }
    char* expandedHeightAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"expandedHeight");
    if(expandedHeightAttrValue) {
        self.expandedHeight = [numFormatter numberFromString:[NSString stringWithCString:expandedHeightAttrValue encoding:NSUTF8StringEncoding]];
        xmlFree(expandedHeightAttrValue);
    }
    char* apiFrameworkAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"apiFramework");
    if(apiFrameworkAttrValue) {
        self.apiFramework = [NSString
        stringWithCString:apiFrameworkAttrValue
        encoding:NSUTF8StringEncoding];
        xmlFree(apiFrameworkAttrValue);
    }
    char* adSlotIDAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"adSlotID");
    if(adSlotIDAttrValue) {
        self.adSlotID = [NSString
        stringWithCString:adSlotIDAttrValue
        encoding:NSUTF8StringEncoding];
        xmlFree(adSlotIDAttrValue);
    }
    char* pxratioAttrValue = (char*) xmlTextReaderGetAttribute(reader, (xmlChar*)"pxratio");
    if(pxratioAttrValue) {
        self.pxratio = [decFormatter numberFromString:[NSString stringWithCString:pxratioAttrValue encoding:NSUTF8StringEncoding]];
        xmlFree(pxratioAttrValue);
    }
}

/**
* Name:        initWithReader
* Parameters:  (void *) - the Libxml's xmlTextReader pointer
* Returns:     returns the classes created object
* Description: Iterate through the XML and create the SKIVASTCompanionAd object
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
    
    self.companionClickTrackings = [NSMutableArray array];
    
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
    
    NSNumberFormatter* numFormatter = [[NSNumberFormatter alloc] init];
    numFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numFormatter.locale = self.locale;
    NSNumberFormatter* decFormatter = [[NSNumberFormatter alloc] init];
    decFormatter.locale = self.locale;
    decFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    if([@"AdParameters" isEqualToString:_currentElementName]) {
        
        self.adParameters = [[SKIVASTAdParameters alloc] initWithReader:reader];
        *handledInChild = YES;
        
    } else if([@"AltText" isEqualToString:_currentElementName]) {
        
        *_readerOk = xmlTextReaderRead(reader);
        *_currentNodeType = xmlTextReaderNodeType(reader);
        if (*_currentNodeType != XML_READER_TYPE_END_ELEMENT) {
            const char *AltTextElementValue = (const char*) xmlTextReaderConstValue(reader);
            if(AltTextElementValue) {
                
                self.altText = [NSString stringWithCString:AltTextElementValue encoding:NSUTF8StringEncoding];
                
            }
            *_readerOk = xmlTextReaderRead(reader);
            *_currentNodeType = xmlTextReaderNodeType(reader);
        }
        
    } else if([@"CompanionClickThrough" isEqualToString:_currentElementName]) {
        
        *_readerOk = xmlTextReaderRead(reader);
        *_currentNodeType = xmlTextReaderNodeType(reader);
        if (*_currentNodeType != XML_READER_TYPE_END_ELEMENT) {
            const char *CompanionClickThroughElementValue = (const char*) xmlTextReaderConstValue(reader);
            if(CompanionClickThroughElementValue) {
                NSString *companionClickThroughStringValue = [[NSString stringWithCString:CompanionClickThroughElementValue encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                self.companionClickThrough = [NSURL URLWithString:companionClickThroughStringValue];
                
            }
            *_readerOk = xmlTextReaderRead(reader);
            *_currentNodeType = xmlTextReaderNodeType(reader);
        }
        
    } else if([@"CompanionClickTracking" isEqualToString:_currentElementName]) {
        
        [self.companionClickTrackings addObject:[[SKIVASTCompanionClickTracking alloc] initWithReader:reader]];
        *handledInChild = YES;
        
    } else if([@"CreativeExtensions" isEqualToString:_currentElementName]) {
        
        self.creativeExtensions = [[SKIVASTCreativeExtensions alloc] initWithReader:reader];
        *handledInChild = YES;
        
    } else if([@"TrackingEvents" isEqualToString:_currentElementName]) {
        
        self.trackingEvents = [[SKIVASTTrackingEvents alloc] initWithReader:reader];
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
    
    if(self.identifier != nil) {
        [dict setObject:self.identifier forKey:@"identifier"];
    }
    
    if(self.width != nil) {
        [dict setObject:self.width forKey:@"width"];
    }
    
    if(self.height != nil) {
        [dict setObject:self.height forKey:@"height"];
    }
    
    if(self.assetWidth != nil) {
        [dict setObject:self.assetWidth forKey:@"assetWidth"];
    }
    
    if(self.assetHeight != nil) {
        [dict setObject:self.assetHeight forKey:@"assetHeight"];
    }
    
    if(self.expandedWidth != nil) {
        [dict setObject:self.expandedWidth forKey:@"expandedWidth"];
    }
    
    if(self.expandedHeight != nil) {
        [dict setObject:self.expandedHeight forKey:@"expandedHeight"];
    }
    
    if(self.apiFramework != nil) {
        [dict setObject:self.apiFramework forKey:@"apiFramework"];
    }
    
    if(self.adSlotID != nil) {
        [dict setObject:self.adSlotID forKey:@"adSlotID"];
    }
    
    if(self.pxratio != nil) {
        [dict setObject:self.pxratio forKey:@"pxratio"];
    }
    
    if(self.adParameters != nil) {
        NSDictionary *adParametersDict = [self.adParameters valueForKeyPath:@"dictionary"];
        [dict setObject:adParametersDict forKey:@"adParameters"];
    }
    
    if(self.altText != nil) {
        [dict setObject:self.altText forKey:@"altText"];
        
    }
    
    if(self.companionClickThrough != nil) {
        [dict setObject:self.companionClickThrough forKey:@"companionClickThrough"];
        
    }
    
    if(self.companionClickTrackings != nil) {
        NSDictionary *companionClickTrackingsDict = [self.companionClickTrackings valueForKeyPath:@"dictionary"];
        [dict setObject:companionClickTrackingsDict forKey:@"companionClickTrackings"];
    }
    
    if(self.creativeExtensions != nil) {
        NSDictionary *creativeExtensionsDict = [self.creativeExtensions valueForKeyPath:@"dictionary"];
        [dict setObject:creativeExtensionsDict forKey:@"creativeExtensions"];
    }
    
    if(self.trackingEvents != nil) {
        NSDictionary *trackingEventsDict = [self.trackingEvents valueForKeyPath:@"dictionary"];
        [dict setObject:trackingEventsDict forKey:@"trackingEvents"];
    }
    
    return dict;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@\n%@", [super debugDescription], [self dictionary]];
}

@end


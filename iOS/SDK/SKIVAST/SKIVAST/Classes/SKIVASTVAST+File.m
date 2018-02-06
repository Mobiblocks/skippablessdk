
#import "SKIVASTVAST+File.h"
#import <libxml/xmlreader.h>

#define kGlobalElementNamesArray @[@"##elements##",@"VAST"]

@implementation SKIVASTVAST (File)

/**
* Name:            FromURL
* Parameters:      (NSURL*) - the location of the XML file as a NSURL representation
* Returns:         A generated SKIVASTVAST object
* Description:     Generate a SKIVASTVAST object from the path
*                  specified by the user
*/
+ (SKIVASTVAST *)VASTFromURL:(NSURL*) url {
    SKIVASTVAST *obj = nil;
    xmlTextReaderPtr reader = xmlReaderForFile(url.absoluteString.UTF8String,
    NULL,
    (XML_PARSE_NOBLANKS | XML_PARSE_NOCDATA | XML_PARSE_NOERROR | XML_PARSE_NOWARNING));
    int ret;
    if(reader != nil) {
        //find the correct root
        do {
            ret = xmlTextReaderRead(reader);
            if(ret == XML_READER_TYPE_ELEMENT) {
                NSString* elementName = [NSString stringWithCString:(const char*)xmlTextReaderConstLocalName(reader) encoding:NSUTF8StringEncoding];
                id array = kGlobalElementNamesArray;
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", array];
                if([predicate evaluateWithObject:elementName]) {
                    obj = [[SKIVASTVAST alloc] initWithReader:reader];
                    break;
                }
            }
        } while(ret);
        xmlFreeTextReader(reader);
    }
    return obj;
}

/**
* Name:            FromFile
* Parameters:      (NSString*) - the location of the XML file as a string
* Returns:         A generated SKIVASTVAST object
* Description:     Generate a SKIVASTVAST object from the path
*                  specified by the user
*/
+ (SKIVASTVAST *)VASTFromFile:(NSString*) path {
    return [self VASTFromURL:[NSURL fileURLWithPath:path]];
}

/**
* Name:            FromData:
* Parameters:      (NSData *)
* Returns:         A generated SKIVASTVAST object
* Description:     Generate the SKIVASTVAST object from the NSData
*                  object generated from the XML.
*/
+ (SKIVASTVAST *)VASTFromData:(NSData *) data {
    /* Initial Setup */
    SKIVASTVAST *obj = nil;
    /* Create the reader */
    xmlTextReaderPtr reader = xmlReaderForMemory([data bytes],
    (int)[data length],
    NULL,
    NULL,
    (XML_PARSE_NOBLANKS | XML_PARSE_NOCDATA | XML_PARSE_NOERROR | XML_PARSE_NOWARNING));
    
    /* Ensure that we have a reader and the data within it to generate the object */
    if(reader != nil) {
        int ret = xmlTextReaderRead(reader);
        if(ret > 0) {
            obj = [[SKIVASTVAST alloc] initWithReader:reader];
        }
        xmlFreeTextReader(reader);
    }
    
    return obj;
}

@end


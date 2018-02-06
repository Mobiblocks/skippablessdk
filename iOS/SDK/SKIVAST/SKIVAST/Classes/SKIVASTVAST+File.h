
/**
* SKIVASTVAST+File.h
*/
#import <Foundation/Foundation.h>
#import "SKIVASTVAST.h"

@interface SKIVASTVAST (File)

/* Reads a xml file specified by the given url and parses it, returning a SKIVASTVAST */
+ (SKIVASTVAST *)VASTFromURL:(NSURL*)url;

/* Reads a xml file specified by the given file path and parses it, returning a SKIVASTVAST */
+ (SKIVASTVAST *)VASTFromFile:(NSString*)path;

/* Reads xml text specified by the given data and parses it, returning a SKIVASTVAST */
+ (SKIVASTVAST *)VASTFromData:(NSData*)data;

@end


//
//  SLInfo.h
//  SLPOC
//
//  Created by Kelvin Chan on 10/11/12.
//
//

#import <Foundation/Foundation.h>
#import "objc/runtime.h"
#import "NSString+Cleanse.h"
#import "GDataXMLNode.h"

@interface SLInfo : NSObject

@property (nonatomic, retain) GDataXMLDocument *xmlDoc;  // copy and made local
@property (nonatomic, retain) GDataXMLElement *rootXMLElement;  // reference to part of global copy

// This is used to stored dynamics properties that have NSString as their values

@property (nonatomic, retain) NSMutableDictionary *propertiesDictionary;

+(id) loadContentsFromXMLFile:(NSString *)filename;       // from file
+(id) loadContentsFromXMLData:(NSMutableData *)xmlData;   // from NSdata thats XML
+(id) loadContentsFromXMLString:(NSString *)xmlString;    // from NSString thats XML

// The following will establish a shared copy among the entire hierarchy of XML objects
+(id) loadContentsFromGDataXMLElement:(GDataXMLElement *) gDataXMLElement;


// Init
-(id) initWithData:(NSData*)data;
-(id) initWithGDataXMLElement:(GDataXMLElement *)gDataXMLElement;


// Helpers
+(NSMutableData *) getXMLDataFromXMLFile:(NSString *)filename;

// subclass override this
-(void) parseAndBuildObject:(GDataXMLElement *)root;



@end

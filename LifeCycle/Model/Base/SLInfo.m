//
//  SLInfo.m
//  SLPOC
//
//  Created by Kelvin Chan on 10/11/12.
//
//

#import "SLInfo.h"

@implementation SLInfo

-(void) dealloc {
    [_xmlDoc release];
    [_rootXMLElement release];
    [_propertiesDictionary release];
    
    [super dealloc];
}

+ (NSString *)propertyTypeStringOfProperty:(objc_property_t) property {
    const char *attr = property_getAttributes(property);
    NSString *const attributes = [NSString stringWithCString:attr encoding:NSUTF8StringEncoding];
    
    NSRange const typeRangeStart = [attributes rangeOfString:@"T@\""];  // start of type string
    if (typeRangeStart.location != NSNotFound) {
        NSString *const typeStringWithQuote = [attributes substringFromIndex:typeRangeStart.location + typeRangeStart.length];
        NSRange const typeRangeEnd = [typeStringWithQuote rangeOfString:@"\""]; // end of type string
        if (typeRangeEnd.location != NSNotFound) {
            NSString *const typeString = [typeStringWithQuote substringToIndex:typeRangeEnd.location];
            return typeString;
        }
    }
    return nil;
}

+(id) loadContentsFromXMLFile:(NSString *)filename {
    NSMutableData *xmlData = [self getXMLDataFromXMLFile:filename];
    return [self loadContentsFromXMLData:xmlData];
}

+(id) loadContentsFromXMLString:(NSString *)xmlString {
    NSMutableData *xmlData = [[[xmlString dataUsingEncoding:NSUTF8StringEncoding] mutableCopy] autorelease];
    return [self loadContentsFromXMLData:xmlData];
}

+(id) loadContentsFromXMLData:(NSMutableData *)xmlData {
    return [[[self alloc] initWithData:xmlData] autorelease];
}

+(id) loadContentsFromGDataXMLElement:(GDataXMLElement *)gDataXMLElement {
    return [[[self alloc] initWithGDataXMLElement:gDataXMLElement] autorelease];
}

#pragma mark - Helpers
// Helper to extract content of a file as NSData
+(NSMutableData *) getXMLDataFromXMLFile:(NSString *)filename {
    NSString *fullfilename = [[NSBundle mainBundle] pathForResource:filename ofType:@"xml"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullfilename]) {
        return nil;
    }
    
    return [[[NSMutableData alloc] initWithContentsOfFile:fullfilename] autorelease];
}

#pragma mark - Getters & Setters
-(NSMutableDictionary *)propertiesDictionary {
    if (_propertiesDictionary == nil) {
        _propertiesDictionary = [[NSMutableDictionary alloc] init];
    }
    return _propertiesDictionary;
}

#pragma mark - LifeCycles

-(id) initWithData:(NSData*)data {
    self = [super init];
    if (self) {
        NSError *error;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:data options:0 error:&error];
        // FIXME: check for error?
        self.xmlDoc = doc;
        [doc release];
        if (self.xmlDoc == nil)
            return nil;
        else {
            GDataXMLElement *root = self.xmlDoc.rootElement;
            [self parseAndBuildObject:root];
        }

    }
    return self;
}

-(id) initWithGDataXMLElement:(GDataXMLElement *)gDataXMLElement {
    self = [super init];
    if (self) {        
        self.rootXMLElement = gDataXMLElement;
        if (self.rootXMLElement == nil)
            return nil;
        else {
            GDataXMLElement *root = self.rootXMLElement;
            [self parseAndBuildObject:root];
        }

    }
    return self;
}

#pragma mark - The Meat
-(void) parseAndBuildObject:(GDataXMLElement *)root {
    // Subclass should override this
}

#pragma mark - The Deep Meat
// This is to allow Dynamic construction of accessors

+(BOOL) resolveInstanceMethod:(SEL)sel {
    NSString *methodName = NSStringFromSelector(sel);
    NSString *instanceVar;
    
    if ([methodName hasPrefix:@"set"]) {
        NSRange range = [methodName rangeOfString:@"set"];
        instanceVar = [[[methodName stringByReplacingCharactersInRange:range withString:@""] lowercaseString] stringByReplacingOccurrencesOfString:@":" withString:@""];
    }
    else if ([methodName hasPrefix:@"get"]) {
        NSRange range = [methodName rangeOfString:@"get"];
        instanceVar = [[[methodName stringByReplacingCharactersInRange:range withString:@""] lowercaseString] stringByReplacingOccurrencesOfString:@":" withString:@""];
    }
    else {
        instanceVar = methodName;
    }
    
    // Introspect on the instanceVar's datatype
    objc_property_t property = class_getProperty([self class], [instanceVar UTF8String]);
    NSString *propertyType = [SLInfo propertyTypeStringOfProperty:property];
//    const char *type = getPropertyType(property);
//    NSString *propertyType = [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
//    NSLog(@"Property Type = %@", propertyType);

    // system may call instance that may begin with "_", dont interfere with that.
    if (![[instanceVar substringToIndex:1] isEqualToString:@"_"]) {
        
        if ([methodName hasPrefix:@"set"]) {
            if ([propertyType isEqualToString:@"NSMutableArray"]) {
                class_addMethod([self class], sel, (IMP) accessorSetterForNSMutableArray, "v@:@");
                return YES;
            }
            else if ([propertyType hasSuffix:@"Info"]) {
                class_addMethod([self class], sel, (IMP) accessorSetterForInfo, "v@:@");
                return YES;
            }
            else {
                class_addMethod([self class], sel, (IMP) accessorSetter, "v@:@");
                return YES;
            }
        }
        else
        {
            if ([propertyType isEqualToString:@"NSMutableArray"]) {
                class_addMethod([self class], sel, (IMP) accessorGetterForNSMutableArray, "@@:");
                return YES;
            }
            else if ([propertyType hasSuffix:@"Info"]) {
                class_addMethod([self class], sel, (IMP) accessorGetterForInfo, "@@:");
                return YES;
            }
            else {
                class_addMethod([self class], sel, (IMP) accessorGetter, "@@:");
                return YES;
            }
        }
    }
    
    return [super resolveInstanceMethod:sel];
}

void accessorSetter(id self, SEL _cmd, id newValue) {
    
    NSString *method = NSStringFromSelector(_cmd);
    
    NSRange range = [method rangeOfString:@"set"];
    
    NSString *instanceVar = [[[method stringByReplacingCharactersInRange:range withString:@""] lowercaseString] stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    NSMutableDictionary *propertiesFromDictionary = [self propertiesDictionary];
    
    if (newValue != nil) {
        [propertiesFromDictionary setObject:newValue forKey:instanceVar];
    }
    else
        [propertiesFromDictionary removeObjectForKey:instanceVar];
    
}

void accessorSetterForNSMutableArray(id self, SEL _cmd, id newValue) {
    NSString *method = NSStringFromSelector(_cmd);
    
    NSRange range = [method rangeOfString:@"set"];
    
    NSString *instanceVar = [[[method stringByReplacingCharactersInRange:range withString:@""] lowercaseString] stringByReplacingOccurrencesOfString:@":" withString:@""];

    NSMutableDictionary *propertiesFromDictionary = [self propertiesDictionary];
    
    if (newValue != nil)
        [propertiesFromDictionary setObject:newValue forKey:instanceVar];
    else
        [propertiesFromDictionary removeObjectForKey:instanceVar];
}

void accessorSetterForInfo(id self, SEL _cmd, id newValue) {
    NSString *method = NSStringFromSelector(_cmd);
    
    NSRange range = [method rangeOfString:@"set"];
    
    NSString *instanceVar = [[[method stringByReplacingCharactersInRange:range withString:@""] lowercaseString] stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    NSMutableDictionary *propertiesFromDictionary = [self propertiesDictionary];
    
    if (newValue != nil) 
        [propertiesFromDictionary setObject:newValue forKey:instanceVar];
    else
        [propertiesFromDictionary removeObjectForKey:instanceVar];
}

id accessorGetter(id self, SEL _cmd) {
    NSString *method = NSStringFromSelector(_cmd);
    
    NSString *instanceVar = method;
    
    NSMutableDictionary *propertiesFromDictionary = [self propertiesDictionary];
    
    if (propertiesFromDictionary[instanceVar] == nil) {
        // get it from XML root, we need to check both
        //   - xmlDoc.rootElement, initialized from external byte (file, xmlstring, data)
        //   - rootXMLElement, initialized from GDataXMLElement object in memory.

        GDataXMLElement *root, *xmlElem;
        
        if ([self rootXMLElement] != nil)
            root = [self rootXMLElement];
        else if ([self xmlDoc] != nil)
            root = [self xmlDoc].rootElement;
        else
            ;
        
        // For version, and uid, we get this from the element attributes
        id value;
        if ([instanceVar isEqualToString:@"version"])
            value = @([root attributeForName:@"version"].stringValue.cleanse.floatValue);
        else if ([instanceVar isEqualToString:@"uid"])
//            value = @([root attributeForName:@"uid"].stringValue.cleanse.intValue);
            value = [root attributeForName:@"uid"].stringValue.cleanse;
        else {
            xmlElem = [root elementsForName:instanceVar][0];
            if ([xmlElem.stringValue.cleanse isNumeric])
                value = @(xmlElem.stringValue.cleanse.floatValue);
            else {
                // This is a string, format the \n and \t
                value = [[xmlElem.stringValue.cleanse stringByReplacingOccurrencesOfString:@"\\t" withString:@"\t"] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
            }
        }
        if (value != nil)
            propertiesFromDictionary[instanceVar] = value;
    }
    
    return propertiesFromDictionary[instanceVar];
}

id accessorGetterForNSMutableArray(id self, SEL _cmd) {
    NSString *method = NSStringFromSelector(_cmd);
    
    NSString *instanceVar = method;
    
    NSMutableDictionary *propertiesFromDictionary = [self propertiesDictionary];
    
    if (propertiesFromDictionary[instanceVar] == nil) {
        // get it from XML root, we need to check both
        //   - xmlDoc.rootElement, initialized from external byte (file, xmlstring, data)
        //   - rootXMLElement, initialized from GDataXMLElement object in memory.
        
        GDataXMLElement *root;
        
        if ([self rootXMLElement] != nil)
            root = [self rootXMLElement];
        else if ([self xmlDoc] != nil)
            root = [self xmlDoc].rootElement;
        else
            ;
        
        NSString *firstChar = [[instanceVar substringToIndex:1] uppercaseString];
        NSString *tmp = [firstChar stringByAppendingString:[instanceVar substringFromIndex:1]];
        NSString *InstanceVar = [tmp substringToIndex:tmp.length - 1];

        NSString *infoClassStr = [InstanceVar stringByAppendingString:@"Info"];
        
        Class infoClass = NSClassFromString(infoClassStr);
        
        NSString *elemName = [instanceVar substringToIndex:instanceVar.length - 1];
        
        NSArray *xmlElems = [root elementsForName:elemName];
        NSMutableArray *returnArray = [NSMutableArray new];
        for (GDataXMLElement *elem in xmlElems) {
            id v = [infoClass performSelector:@selector(loadContentsFromGDataXMLElement:) withObject:elem];
            
            [returnArray addObject:v];
        }
    
        propertiesFromDictionary[instanceVar] = returnArray;
        [returnArray release];
    
    }
    
    return propertiesFromDictionary[instanceVar];
}

id accessorGetterForInfo(id self, SEL _cmd) {
    NSString *method = NSStringFromSelector(_cmd);
    
    NSString *instanceVar = method;
    
    NSMutableDictionary *propertiesFromDictionary = [self propertiesDictionary];
    
    if (propertiesFromDictionary[instanceVar] == nil) {
        // get it from XML root, we need to check both
        //   - xmlDoc.rootElement, initialized from external byte (file, xmlstring, data)
        //   - rootXMLElement, initialized from GDataXMLElement object in memory.
        
        GDataXMLElement *root;
        
        if ([self rootXMLElement] != nil)
            root = [self rootXMLElement];
        else if ([self xmlDoc] != nil)
            root = [self xmlDoc].rootElement;
        else
            ;
        
//        NSString *firstChar = [[instanceVar substringToIndex:1] uppercaseString];
//        NSString *tmp = [firstChar stringByAppendingString:[instanceVar substringFromIndex:1]];
//        NSString *InstanceVar = [tmp substringToIndex:tmp.length - 1];
        // Introspect on the instanceVar's datatype
        objc_property_t property = class_getProperty([self class], [instanceVar UTF8String]);
//        const char *type = getPropertyType(property);
//        NSString *propertyType = [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
        
        NSString *propertyType = [SLInfo propertyTypeStringOfProperty:property];

//        NSString *infoClassStr = [InstanceVar stringByAppendingString:@"Info"];
        
        Class infoClass = NSClassFromString(propertyType);
        
//        NSString *elemName = [instanceVar substringToIndex:instanceVar.length - 1];
        
        NSArray *xmlElems = [root elementsForName:instanceVar];
        id value;
        if (xmlElems != nil && xmlElems.count == 1) {
            value = [infoClass performSelector:@selector(loadContentsFromGDataXMLElement:) withObject:xmlElems[0]];
            propertiesFromDictionary[instanceVar] = value;
        }
    }
    
    return propertiesFromDictionary[instanceVar];

}

@end

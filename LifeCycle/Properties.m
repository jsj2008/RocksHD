//
//  Properties.m
//  JustSikh
//
//  Created by admin on 9/17/09.
//  Copyright 2009 Livrona.com. All rights reserved.
//

#import "Properties.h"
#import "Constants.h"

@implementation Properties

- (id) init
{
	[super init];
	if (self)
	{
	
		dictionary = [[NSMutableDictionary alloc] init];
	}
	return self;
}


-(NSMutableDictionary*) getDictionary
{
    return dictionary;
}

-(void) load : (NSString *) contents
{
	debugLog(@"[Properties] in : load(...)");
	
	NSArray *configLines = [contents componentsSeparatedByString:@"\n"];
	debugLog(@"Total config lines : %d", [configLines count]);
	
	// loop through parse and add to dictionary
	for(int i = 0; i < [configLines count] ; i++) {
		
		NSString *kvPair = [configLines objectAtIndex:i];
		
		NSInteger equalLocation = [kvPair rangeOfString:@"="].location;
		
		if (equalLocation == NSNotFound)
		{
			debugLog(@"Skip line %d as [=] is not found : %@",i,kvPair);
		}
		else {
			debugLog(@"Valid KVPair in line %d [=] is  found : %@",i,kvPair);
			NSString *key = [kvPair substringToIndex:equalLocation];
			NSString *value = [kvPair substringFromIndex:equalLocation+1];
			[self setProperty: key withValue: value]; 
		}

		debugLog(@"Properties : %@",dictionary);
	}
	
}
-(void) loadFromUrl: (NSString *) url
{
	debugLog(@"[Properties] in : loadFromUrl(...)");
	NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
	NSString* config;
	config = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	
	//NSData* aData;
	//aData = [aStr dataUsingEncoding: NSASCIIStringEncoding];
	
	debugLog(@"Loading properties from url : %@",url);
	debugLog(@"Config: %@",config);
	[self load:config];
		
}

-(NSString*) getProperty : (NSString*) key
{
	return [dictionary objectForKey:key];
}

-(void) setProperty : (NSString*)key withValue : (NSString*)value
{
	[dictionary	setObject:value forKey:key];
}

@end

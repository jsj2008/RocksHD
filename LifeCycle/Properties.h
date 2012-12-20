//
//  Properties.h
//  JustSikh
//
//  Created by admin on 9/17/09.
//  Copyright 2009 Livrona.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Properties : NSObject {

	NSMutableDictionary *dictionary;
}

-(void) load : (NSString *) contents;
-(void) loadFromUrl: (NSString *) url;

-(NSString*) getProperty : (NSString*) key; 
-(void) setProperty : (NSString*)key withValue : (NSString*)value;

-(NSMutableDictionary*) getDictionary;

@end

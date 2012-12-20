//
//  Gallery.m
//  ButterflyHD
//
//  Created by Manpreet Vohra on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Gallery.h"

@implementation Gallery

@synthesize uid,title,items,version, itemMap;

-(void) addItem :(GalleryItem*) item
{
    [items addObject:item];
    [itemMap setObject:item forKey:item.guid];
}

-(id) init
{
      
    self = [super init];
    if (self) {
    items = [[NSMutableArray alloc] init];    
    itemMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}
-(void) dealloc
{

    [uid release];
    [title release];
    [items release];
    [itemMap release];
    [super dealloc];    
}
@end

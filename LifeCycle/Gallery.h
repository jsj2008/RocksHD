//
//  Gallery.h
//  ButterflyHD
//
//  Created by Manpreet Vohra on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GalleryItem.h"


@interface Gallery : NSObject
{
    NSString *uid;
    NSString *title;
    int version;
    
    NSMutableArray *items;
    NSMutableDictionary *itemMap;
}

@property(nonatomic,retain) NSString *uid;
@property(nonatomic,retain) NSString *title;
@property(nonatomic,assign) int version;
@property(nonatomic,assign) NSMutableArray *items;
@property(nonatomic,assign) NSMutableDictionary *itemMap;


-(void) addItem :(GalleryItem*) item;
@end

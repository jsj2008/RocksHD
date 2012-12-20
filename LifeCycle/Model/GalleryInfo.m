//
//  GalleryInfo.m
//  SLPOC
//
//  Created by Kelvin Chan on 10/15/12.
//
//

#import "GalleryInfo.h"
#import "GalleryItemInfo.h"

@implementation GalleryInfo

@dynamic uid;
@dynamic version;
@dynamic title;

-(void) dealloc {
    [_items release];
    
    [super dealloc];
}

#pragma mark - Getters & Setters
-(NSMutableArray *)items {
    if (_items == nil) {
        _items = [[NSMutableArray alloc] init];
    }
    return _items;
}

#pragma mark - the Meat
-(void) parseAndBuildObject:(GDataXMLElement *)root {
    
    for (GDataXMLElement *item in [root elementsForName:@"item"]) {
        GalleryItemInfo *galleryItemInfo = [GalleryItemInfo loadContentsFromGDataXMLElement:item];
        [self.items addObject:galleryItemInfo];
    }
}

@end

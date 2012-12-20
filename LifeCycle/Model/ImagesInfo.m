//
//  ImagesInfo.m
//  SLPOC
//
//  Created by Kelvin Chan on 10/15/12.
//
//

#import "ImagesInfo.h"
#import "ImageInfo.h"

@implementation ImagesInfo

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
        ImageInfo *imgInfo = [ImageInfo loadContentsFromGDataXMLElement:item];
        [self.items addObject:imgInfo];
    }
}


@end

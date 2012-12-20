
//
//  StarterImagesInfo.m
//  SLPOC
//
//  Created by Kelvin Chan on 10/15/12.
//
//

#import "StarterImagesInfo.h"
#import "StarterImageInfo.h"

@implementation StarterImagesInfo

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
        StarterImageInfo *starterImageInfo = [StarterImageInfo loadContentsFromGDataXMLElement:item];
        [self.items addObject:starterImageInfo];
    }
    
}

@end

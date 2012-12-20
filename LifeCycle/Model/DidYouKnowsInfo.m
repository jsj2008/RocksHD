//
//  DidYouKnowsInfo.m
//  SLPOC
//
//  Created by Kelvin Chan on 10/15/12.
//
//

#import "DidYouKnowsInfo.h"
#import "DidYouKnowInfo.h"

@implementation DidYouKnowsInfo

@dynamic didYouKnowTitleImage;
@dynamic didYouKnowLeftImage;
@dynamic didYouKnowRightImage;

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
        DidYouKnowInfo *dykInfo = [DidYouKnowInfo loadContentsFromGDataXMLElement:item];
        [self.items addObject:dykInfo];
    }
    
}


@end

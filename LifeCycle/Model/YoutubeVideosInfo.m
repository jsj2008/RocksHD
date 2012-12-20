//
//  YoutubeVideosInfo.m
//  SLPOC
//
//  Created by Kelvin Chan on 10/15/12.
//
//

#import "YoutubeVideosInfo.h"
#import "YoutubeVideoInfo.h"

@implementation YoutubeVideosInfo

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
        YoutubeVideoInfo *utubeInfo = [YoutubeVideoInfo loadContentsFromGDataXMLElement:item];
        [self.items addObject:utubeInfo];
    }
    
}

@end

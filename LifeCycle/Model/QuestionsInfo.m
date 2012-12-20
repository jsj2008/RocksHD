//
//  QuestionsInfo.m
//  SLPOC
//
//  Created by Kelvin Chan on 10/16/12.
//
//

#import "QuestionsInfo.h"
#import "QuestionItemInfo.h"

@implementation QuestionsInfo

@dynamic version;

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
        QuestionItemInfo *questionItemInfo = [QuestionItemInfo loadContentsFromGDataXMLElement:item];
        [self.items addObject:questionItemInfo];
    }
    
}

@end

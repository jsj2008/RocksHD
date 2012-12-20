//
//  InfoLine.m
//  SLPOC
//
//  Created by Kelvin Chan on 10/14/12.
//
//

#import "IntroTexts.h"

@implementation IntroTexts

@dynamic version;
@dynamic backgroundImage;

-(void) dealloc {
    [_texts release];
    [super dealloc];
}

#pragma mark - Getters & Setters
-(NSMutableArray *)texts {
    if (_texts == nil) {
        _texts = [[NSMutableArray alloc] init];
    }
    return _texts;
}

#pragma mark - the Meat
-(void) parseAndBuildObject:(GDataXMLElement *)root {
    for (GDataXMLElement *item in [root elementsForName:@"item"]) {
        [self.texts addObject:item.stringValue.cleanse];
    }
}

@end

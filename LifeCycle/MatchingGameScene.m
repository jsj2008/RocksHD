//
//  Intro.m
//  PlantHD
//
//  Created by Kelvin Chan on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MatchingGameScene.h"
#import "MatchingGameLayer.h"

@implementation MatchingGameScene

- (id)init
{
    self = [super init];
    if (self) {
        MatchingGameLayer *introLayer = [MatchingGameLayer node];
        [self addChild:introLayer z:0];
    }
    
    return self;
}

@end

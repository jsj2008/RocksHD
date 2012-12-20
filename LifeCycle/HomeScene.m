//
//  Intro.m
//  PlantHD
//
//  Created by Kelvin Chan on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HomeScene.h"

@implementation HomeScene

- (id)init
{
    self = [super init];
    if (self) {
        HomeLayer *introLayer = [HomeLayer node];
        [self addChild:introLayer z:0];
    }
    
    return self;
}

@end

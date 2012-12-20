//
//  Intro.m
//  PlantHD
//
//  Created by Kelvin Chan on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IntroScene.h"

@implementation IntroScene

- (id)init
{
    self = [super init];
    if (self) {
        IntroLayer *introLayer = [IntroLayer node];
        [self addChild:introLayer z:0];
    }
    
    return self;
}

@end

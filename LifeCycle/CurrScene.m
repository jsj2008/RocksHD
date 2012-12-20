//
//  CurrScene.m
//  ButterflyPOC
//
//  Created by Kelvin Chan on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CurrScene.h"

@implementation CurrScene

-(id) init {
    self = [super init];
    if (self) {
        CurrLayer *currLayer = [CurrLayer node];
        [self addChild:currLayer z:0];
    }
    return self;
}

@end

//
//  OtherApps.m
//  ButterflyHD
//
//  Created by Kelvin Chan on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OtherAppsScene.h"

@implementation OtherAppsScene

-(id) init {
    self = [super init];
    if (self) {
        OtherAppsLayer *layer = [OtherAppsLayer node];
        [self addChild:layer z:0];
    }
    return self;
}

@end

//
//  InfoScene.m
//  PlantHD
//
//  Created by Kelvin Chan on 11/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "InfoScene.h"

@implementation InfoScene

- (id)init
{
    self = [super init];
    if (self) {
        InfoLayer *infoLayer = [InfoLayer node];
        [self addChild:infoLayer z:0];
    }
    
    return self;
}

@end

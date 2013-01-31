//
//  SeedScene.m
//  PlantHD
//
//  Created by Kelvin Chan on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Topic1Scene.h"
#import "PlistManager.h"

@implementation Topic1Scene

- (id)init
{
    self = [super init];
    if (self) {
        MainTextImagesLayer *topic1Layer = [MainTextImagesLayer node];


        self.topicInfo = [[PlistManager sharedPlistManager] topic1SpecificsDictionary];
        [self addChild:topic1Layer z:0 tag:1];
    }
        
    return self;
}

-(void)play_great_job {
    PLAYSOUNDEFFECTWITHLOWERVOL(GREAT_JOB_TOPIC1);
}

-(void)play_oops {
    PLAYSOUNDEFFECTWITHLOWERVOL(OOPS_TOPIC1);
}

-(void)play_kaching {
    PLAYSOUNDEFFECTWITHLOWERVOL(KA_CHING_TOPIC1);
}

-(void)play_dyk_scroll_left {
    PLAYSOUNDEFFECTWITHLOWERVOL(FORWARD_TOPIC1);
}

-(void)play_dyk_scroll_right {
    PLAYSOUNDEFFECTWITHLOWERVOL(BACKWARD_TOPIC1);
}

-(void)play_funny {
    int k = (int) floor(5.0f * ((float) random()) / RAND_MAX);
    
    switch (k) {
        case 0:
            PLAYSOUNDEFFECTWITHLOWERVOL(FUNNY_1_TOPIC1);
            break;
        case 1:
            PLAYSOUNDEFFECTWITHLOWERVOL(FUNNY_2_TOPIC1);
            break;
        case 2:
            PLAYSOUNDEFFECTWITHLOWERVOL(FUNNY_3_TOPIC1);
            break;
        case 3:
            PLAYSOUNDEFFECTWITHLOWERVOL(FUNNY_4_TOPIC1);
            break;
        case 4:
            PLAYSOUNDEFFECTWITHLOWERVOL(FUNNY_5_TOPIC1);
            break;
        default:
            break;
    }
}

@end

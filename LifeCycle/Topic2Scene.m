//
//  Dispersal.m
//  PlantHD
//
//  Created by Kelvin Chan on 10/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Topic2Scene.h"
#import "PlistManager.h"

@implementation Topic2Scene

- (id)init
{
    CCLOG(@"Enter: [Topic2Scene init]");

    self = [super init];
    if (self) {
        MainTextImagesLayer *topic2Layer = [MainTextImagesLayer node];
        
//        self.topicInfo = [[FlowAndStateManager sharedFlowAndStateManager] loadBasicInfoForSceneWithID:2];
        self.topicInfo = [[PlistManager sharedPlistManager] topic2SpecificsDictionary];

        [self addChild:topic2Layer z:0 tag:1];
    }
    CCLOG(@"Exit: [Topic2Scene init]");

    return self;
}

-(void)play_great_job {
    PLAYSOUNDEFFECTWITHLOWERVOL(GREAT_JOB_TOPIC2);
}

-(void)play_oops {
    PLAYSOUNDEFFECTWITHLOWERVOL(OOPS_TOPIC2);
}

-(void)play_kaching {
    PLAYSOUNDEFFECTWITHLOWERVOL(KA_CHING_TOPIC2);
}

-(void)play_dyk_scroll_left {
    PLAYSOUNDEFFECTWITHLOWERVOL(FORWARD_TOPIC2);
}

-(void)play_dyk_scroll_right {
    PLAYSOUNDEFFECTWITHLOWERVOL(BACKWARD_TOPIC2);
}

-(void)play_funny {
    int k = (int) floor(5.0f * ((float) random()) / RAND_MAX);
    switch (k) {
        case 0:
            PLAYSOUNDEFFECTWITHLOWERVOL(FUNNY_1_TOPIC2);
            break;
        case 1:
            PLAYSOUNDEFFECTWITHLOWERVOL(FUNNY_2_TOPIC2);
            break;
        case 2:
            PLAYSOUNDEFFECTWITHLOWERVOL(FUNNY_3_TOPIC2);
            break;
        case 3:
            PLAYSOUNDEFFECTWITHLOWERVOL(FUNNY_4_TOPIC2);
            break;
        case 4:
            PLAYSOUNDEFFECTWITHLOWERVOL(FUNNY_5_TOPIC2);
            break;
        default:
            break;
    }
}

@end

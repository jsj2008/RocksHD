//
//  FruitsScene.m
//  PlantHD
//
//  Created by Kelvin Chan on 10/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Topic7Scene.h"
#import "PlistManager.h"

@implementation Topic7Scene

- (id)init
{
    self = [super init];
    if (self) {
        MainTextImagesLayer *topic7Layer = [MainTextImagesLayer node];
        
//        self.topicInfo = [[FlowAndStateManager sharedFlowAndStateManager] loadBasicInfoForSceneWithID:7];
        self.topicInfo = [[PlistManager sharedPlistManager] topic7SpecificsDictionary];

        [self addChild:topic7Layer z:1 tag:1];
    }
    
    return self;
}

-(void)play_great_job {
    PLAYSOUNDEFFECTWITHLOWERVOL(GREAT_JOB_TOPIC7);
}

-(void)play_oops {
    PLAYSOUNDEFFECTWITHLOWERVOL(OOPS_TOPIC7);
}

-(void)play_kaching {
    PLAYSOUNDEFFECTWITHLOWERVOL(KA_CHING_TOPIC7);
}

-(void)play_dyk_scroll_left {
    PLAYSOUNDEFFECTWITHLOWERVOL(FORWARD_TOPIC7);
}

-(void)play_dyk_scroll_right {
    PLAYSOUNDEFFECTWITHLOWERVOL(BACKWARD_TOPIC7);
}

-(void)play_funny {
    int k = (int) floor(5.0f * ((float) random()) / RAND_MAX);
    
    switch (k) {
        case 0:
            PLAYSOUNDEFFECTWITHLOWERVOL(FUNNY_1_TOPIC7);
            break;
        case 1:
            PLAYSOUNDEFFECTWITHLOWERVOL(FUNNY_2_TOPIC7);
            break;
        case 2:
            PLAYSOUNDEFFECTWITHLOWERVOL(FUNNY_3_TOPIC7);
            break;
        case 3:
            PLAYSOUNDEFFECTWITHLOWERVOL(FUNNY_4_TOPIC7);
            break;
        case 4:
            PLAYSOUNDEFFECTWITHLOWERVOL(FUNNY_5_TOPIC7);
            break;
        default:
            break;
    }
}

@end

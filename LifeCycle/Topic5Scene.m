//
//  FlowersScene.m
//  PlantHD
//
//  Created by Kelvin Chan on 10/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Topic5Scene.h"
#import "PlistManager.h"

@implementation Topic5Scene

- (id)init
{
    self = [super init];
    if (self) {
        MainTextImagesLayer *topic5Layer = [MainTextImagesLayer node];
        
//        self.topicInfo = [[FlowAndStateManager sharedFlowAndStateManager] loadBasicInfoForSceneWithID:5];
        self.topicInfo = [[PlistManager sharedPlistManager] topic5SpecificsDictionary];

        [self addChild:topic5Layer z:1 tag:1];        
    }
    
    return self;
}

-(void)play_great_job {
    PLAYSOUNDEFFECTWITHLOWERVOL(GREAT_JOB_TOPIC5);
}

-(void)play_oops {
    PLAYSOUNDEFFECTWITHLOWERVOL(OOPS_TOPIC5);
}

-(void)play_kaching {
    PLAYSOUNDEFFECTWITHLOWERVOL(KA_CHING_TOPIC5);
}

-(void)play_dyk_scroll_left {
    PLAYSOUNDEFFECTWITHLOWERVOL(FORWARD_TOPIC5);
}

-(void)play_dyk_scroll_right {
    PLAYSOUNDEFFECTWITHLOWERVOL(BACKWARD_TOPIC5);
}


-(void)play_funny {
    int k = (int) floor(5.0f * ((float) random()) / RAND_MAX);
    
    switch (k) {
        case 0:
            PLAYSOUNDEFFECTWITHLOWERVOL(FUNNY_1_TOPIC5);
            break;
        case 1:
            PLAYSOUNDEFFECTWITHLOWERVOL(FUNNY_2_TOPIC5);
            break;
        case 2:
            PLAYSOUNDEFFECTWITHLOWERVOL(FUNNY_3_TOPIC5);
            break;
        case 3:
            PLAYSOUNDEFFECTWITHLOWERVOL(FUNNY_4_TOPIC5);
            break;
        case 4:
            PLAYSOUNDEFFECTWITHLOWERVOL(FUNNY_5_TOPIC5);
            break;
        default:
            break;
    }
}

@end

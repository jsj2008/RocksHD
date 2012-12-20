//
//  TreeScene.m
//  PlantHD
//
//  Created by Kelvin Chan on 10/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Topic4Scene.h"
#import "PlistManager.h"

@implementation Topic4Scene

- (id)init
{
    self = [super init];
    if (self) {
        MainTextImagesLayer *topic4Layer = [MainTextImagesLayer node];
        
//        self.topicInfo = [[FlowAndStateManager sharedFlowAndStateManager] loadBasicInfoForSceneWithID:4];
        self.topicInfo = [[PlistManager sharedPlistManager] topic4SpecificsDictionary];

        [self addChild:topic4Layer z:1 tag:1];
    }
    
    return self;
}

-(void)play_great_job {
    PLAYSOUNDEFFECTWITHLOWERVOL(GREAT_JOB_TOPIC4);
}

-(void)play_oops {
    PLAYSOUNDEFFECTWITHLOWERVOL(OOPS_TOPIC4);
}

-(void)play_kaching {
    PLAYSOUNDEFFECTWITHLOWERVOL(KA_CHING_TOPIC4);
}

-(void)play_dyk_scroll_left {
    PLAYSOUNDEFFECTWITHLOWERVOL(FORWARD_TOPIC4);
}

-(void)play_dyk_scroll_right {
    PLAYSOUNDEFFECTWITHLOWERVOL(BACKWARD_TOPIC4);
}

-(void)play_funny {
    int k = (int) floor(5.0f * ((float) random()) / RAND_MAX);
    
    switch (k) {
        case 0:
            PLAYSOUNDEFFECTWITHLOWERVOL(FUNNY_1_TOPIC4);
            break;
        case 1:
            PLAYSOUNDEFFECTWITHLOWERVOL(FUNNY_2_TOPIC4);
            break;
        case 2:
            PLAYSOUNDEFFECTWITHLOWERVOL(FUNNY_3_TOPIC4);
            break;
        case 3:
            PLAYSOUNDEFFECTWITHLOWERVOL(FUNNY_4_TOPIC4);
            break;
        case 4:
            PLAYSOUNDEFFECTWITHLOWERVOL(FUNNY_5_TOPIC4);
            break;
        default:
            break;
    }
}
@end

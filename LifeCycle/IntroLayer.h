//
//  IntroLayer.h
//  PlantHD
//
//  Created by Kelvin Chan on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CCLayer.h"
#import "FlowAndStateManager.h"
#import "EditModeAbler.h"
#import "MiniGame.h"

typedef enum {
    kIntroBackgroundTag=100,
    kIntro3OclockArrowTag=101,
    kIntro4OclockArrowTag=102,
    kIntro6OclockArrowTag=103,
    kIntro9OclockArrowTag=104,
    kIntro10OclockArrowTag=105,
    kIntro12OclockArrowTag=106,
    kIntro2OclockArrowTag=107,
    kIntroInfoButtonTag=108,
    kIntroInfoMenuTag=109,
    kIntroAudioButtonTag=110,
    kIntroAudioMenuTag=111,
    kIntroPlayButtonTag=112,
    kIntroTopic1ButtonTag=113,
    kIntroTopic2ButtonTag=114,
    kIntroTopic3ButtonTag=115,
    kIntroTopic4ButtonTag=116,
    kIntroTopic5ButtonTag=117,
    kIntroTopic6ButtonTag=118,
    kIntroTopic7ButtonTag=119,
    kIntroMainMenuTag=120,
    kIntroHomeButtonTag=121,
    kIntroHomeMenuTag=122,
    kIntroCurriculumButtonTag=123,
    kIntroCurriculumMenuTag=124
} IntroLayerTags;


@interface IntroLayer : CCLayer <CCTargetedTouchDelegate, MiniGameDelegate, EditModeAblerDelegate> {
    
    CGSize screenSize;
    BOOL isGameOn;
    EditModeAbler *editModeAbler;
}

@property (nonatomic, retain) MiniGame *miniGame;

@end

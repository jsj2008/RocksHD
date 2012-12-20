//
//  HomeLayer.h
//  PlantHD
//
//  Created by Kelvin Chan on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CCLayer.h"
#import "FlowAndStateManager.h"
#import "EditModeAbler.h"


typedef enum {
    kHomeBackgroundTag=100,
    kHome3OclockArrowTag=101,
    kHome4OclockArrowTag=102,
    kHome6OclockArrowTag=103,
    kHome9OclockArrowTag=104,
    kHome10OclockArrowTag=105,
    kHome12OclockArrowTag=106,
    kHome2OclockArrowTag=107,
    kHomeInfoButtonTag=108,
    kHomeInfoMenuTag=109,
    kHomeAudioButtonTag=110,
    kHomeAudioMenuTag=111,
    kHomePlayButtonTag=112,
    kHomeTopic1ButtonTag=113,
    kHomeTopic2ButtonTag=114,
    kHomeTopic3ButtonTag=115,
    kHomeTopic4ButtonTag=116,
    kHomeTopic5ButtonTag=117,
    kHomeTopic6ButtonTag=118,
    kHomeTopic7ButtonTag=119,
    kHomeMainMenuTag=120,
    kHomeHomeButtonTag=121,
    kHomeHomeMenuTag=122,
    kHomeCurriculumButtonTag=123,
    kHomeCurriculumMenuTag=124,
    kHomeInfoCurriculumMenuTag=124,
    kHomeDYKRightMenuTag=125,
    kHomeDYKTxtTag=126,
    kHomeDYKPrevTxtTag=127,
    kHomeDYKBackgroundTag=128,
    kIntroAppButtonTag=129,
    kIntroAppMenuTag=130,
    kIntroTopicButtonsMenuTag=131


} HomeLayerTags;


@interface HomeLayer : CCLayer <CCTargetedTouchDelegate, EditModeAblerDelegate> {
    
    CGSize screenSize;
    EditModeAbler *editModeAbler;
    
    
    // To support "Did you know"
    int didYouKnowCount;
    CGPoint didYouKnowMainTxtPosition;
    CGPoint startTouchPt;
    CGPoint lastTouchPt;
    BOOL bDidYouKnowSwipe;

    CCMenuItemImage *audioImage;

}

@property (nonatomic, retain) CCArray *didYouKnowTxts;
@property (nonatomic, retain) CCLabelTTF *didYouKnowTxtLabel;
@property (nonatomic, retain) CCLabelTTF *previousDidYouKnowTxtLabel;
@property (nonatomic, retain) CCMenuItemImage *audioImage;


@end

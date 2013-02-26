//
//  MainTextImagesLayer.h
//  PlantHD
//
//  Created by Kelvin Chan on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCLayer.h"
#import "Constants.h"
#import "FlowAndStateManager.h"
#import "TextAndQuizScene.h"
#import "ScrollableCCLabelTTF.h"
#import "EditModeAbler.h"
#import "TopicInfo.h"

typedef enum {
    kMainTextImagesBackgroundTag=100,
    kMainTextImagesMainTitleTag=101,
    kMainTextImagesDYKHeaderTag=102,
    kMainTextImagesDYKLeftMenuTag=103,
    kMainTextImagesDYKRightMenuTag=104,
    kMainTextImagesDYKTxtTag=105,
    kMainTextImagesDYKPrevTxtTag=106,
    kMainTextImagesBatchNodeTag=107,
    kMainTextImagesMainTextTag=108,
    kMainTextImagesVoiceOverSliderTag=109,
    kMainTextImagesImageStackTag=110,
    kMainTextImagesHomeButtonTag=111,
    kMainTextImagesPopquizButtonTag=112,
    kMainTextImagesReadmeButtonTag=113,
    kMainTextImagesMainMenuTag=114,
    kMainTextImagesAudioMenuTag=115,
    kMainTextImagesPhotoMenuTag=116,
    kMainTextImagesVideoMenuTag=117
    
} MainTextImagesLayerTags;

@interface MainTextImagesLayer : CCLayer <CCTouchOneByOneDelegate, ScrollableCCLabelTTFDelegate, EditModeAblerDelegate> {

    NSString *mainText;
    CGSize screenSize;
    EditModeAbler *editModeAbler;
    
    // Audio & Voiceover
    ALuint voiceOver;
    BOOL voiceOverOn;
    CCMenuItemImage *audioItemImage;
    NSTimeInterval voiceOverTrackTime;
    CCMenuItemImage *readmeItemImage;
        
    // To support "Did you know"
    int didYouKnowCount;
    CGPoint didYouKnowMainTxtPosition;
    CGPoint startTouchPt;
    CGPoint lastTouchPt;
    BOOL bDidYouKnowSwipe;
    
    CGPoint mainTextLabel_position;
    float maintextimage_viewport_height;
    float maintextimage_stack_x_offset;
    float maintextimage_stack_y_offset;
    CGPoint maintextimage_voiceoverslider_initial_position;
    
}

@property (nonatomic, retain)  TopicInfo *topicInfo;

// Batch Node for the scene
//@property (nonatomic, retain) CCSpriteBatchNode *imagesBatchNode;

// Main text on the left hand side
@property (nonatomic, copy) NSString *mainText;
@property (nonatomic, retain) ScrollableCCLabelTTF *mainTextLabel;
@property (nonatomic, retain) CCSprite *voiceOverSlider;
@property (nonatomic, assign) TextAndQuizScene *currentScene;

// Audio & Voiceover
@property (nonatomic, assign) BOOL voiceOverOn;
@property (nonatomic, retain) CCMenuItemImage *audioItemImage;
@property (nonatomic, retain) CCMenuItemImage *readmeItemImage;

// Supporting the stack of images on the right hand side
@property (nonatomic, retain) CCArray *imgFileNames;
@property (nonatomic, retain) CCArray *imgScalings;
@property (nonatomic, retain) CCArray *imgTitles;
@property (nonatomic, retain) CCArray *imgAttributions;

@property (nonatomic, copy) NSString *imageAtlasPlistName;
@property (nonatomic, copy) NSString *imageAtlasPngName;

// Supporting the "Did you know" at the bottom
@property (nonatomic, retain) NSMutableArray *didYouKnowTxts;
@property (nonatomic, retain) CCLabelTTF *didYouKnowTxtLabel;
@property (nonatomic, retain) CCLabelTTF *previousDidYouKnowTxtLabel;

@property (nonatomic, retain) NSArray* pacings;


// Helper methods for loading info from Plist 
-(NSDictionary*)loadTopicSpecificsForScene:(SceneTypes)sceneType;
    
-(void)readme;


@end

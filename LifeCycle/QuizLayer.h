//
//  QuizLayer.h
//  PlantHD
//
//  Created by Kelvin Chan on 10/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCLayer.h"
#import "EditModeAbler.h"
#import "Constants.h"

typedef enum {
    kQuizQuestionLabelTag=100,
    kQuizCoinTag=101,
    kQuizMenuTag=102,
    kQuizCorrectTag=103,
    kQuizWrongTag=104,
    kQuizNextTag=105,
    kQuizResultLabelTag=106,
    kQuizDareLabelTag=107,
    kQuizHomeButtonTag=108,
    kQuizAudioButtonTag=109,
    kQuizBackButtonTag=110
} QuizLayerTags;

@interface QuizLayer : CCLayer <CCTargetedTouchDelegate, EditModeAblerDelegate> {
    CGSize screenSize;
    NSDictionary *questionDict;
    NSMutableArray *ansKey;
    NSArray *choicesImgNames;
    CCMenuItemImage *audioItemImage;
    
    EditModeAbler *editModeAbler;
    
    CGPoint nextIconPosition;
    CGPoint correctIconPosition;
    CGPoint wrongIconPosition;
    CGPoint dareLabelPosition;
    CGPoint questionPosition;
    
    // score keeping 
    int currentCorrectCount;
    
    //QA state
    BOOL alreadyAnswered;
    
}

@property (nonatomic, retain) NSDictionary *topicInfo;

@property (nonatomic, retain) NSDictionary *questionDict;
@property (nonatomic, retain) NSMutableArray *ansKey;
@property (nonatomic, retain) NSArray *choicesImgNames;
    
@property (nonatomic, retain) CCMenuItemImage *audioItemImage;



// -(void)loadQuestionsForScene:(SceneTypes)sceneType;
-(void)addMenu;
-(void)prepareLayerForQuestion;
-(void)showScoreRepresentation:(NSInteger)correctCount;
-(void)showResult:(NSInteger)correctCount outOfTotal:(NSInteger)totalCount;
-(void)showResult:(NSInteger)correctCount outOfTotal:(NSInteger)totalCount withText:(NSString *)text;

@end

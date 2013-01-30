//
//  TextAndQuizScene.h
//  PlantHD
//
//  Created by Kelvin Chan on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCScene.h"
#import "Constants.h"
#import "TextAndQuizBackgroundLayer.h"


@interface TextAndQuizScene : CCScene {
    NSArray *questions;
    int numberOfEasy;
    int numberOfMedium;
    int numberOfHard;
    
    // Q/A state
    int currentQuestion;
    
    // score keeping 
    int correctCount;
    
}

@property (nonatomic, retain) NSDictionary *topicInfo;

@property (nonatomic, retain) NSArray *questions;

-(void)loadQuiz;
-(void)loadNextQuiz:(BOOL)must;
-(void)loadQuestionsForTopic:(int)topicId;
-(void)loadResult;
-(void)progressReportEasy;
-(void)progressReportMedium;
-(void)progressReportHard;

// score keeping
-(void)incrementCorrectCount;

// Sound effect
-(void) play_great_job;
-(void) play_oops;
-(void) play_kaching;
-(void) play_funny;
-(void) play_dyk_scroll_left;
-(void) play_dyk_scroll_right;


@end

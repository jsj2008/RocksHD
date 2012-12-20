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
#import "SLImageGalleryDownloader.h"
#import "SLImageDownloader.h"
#import "SLImageInfoDownloader.h"


typedef enum {
    kMatchingGameBackgroundTag=100,
    kMatchingGameInfoButtonTag=108,
    kMatchingGameInfoMenuTag=109,
    kMatchingGameAudioButtonTag=110,
    kMatchingGameAudioMenuTag=111,
    kMatchingGamePhotoFrameTag=112,
    kMatchingGameTopic1ButtonTag=113,
    kMatchingGameTopic2ButtonTag=114,
    kMatchingGameTopic3ButtonTag=115,
    kMatchingGameTopic4ButtonTag=116,
    kMatchingGameTopic5ButtonTag=117,
    kMatchingGameTopic6ButtonTag=118,
    kMatchingGameTopic7ButtonTag=119,
    kMatchingGameMainMenuTag=120,
    kMatchingGameHomeButtonTag=121,
    kMatchingGameHomeMenuTag=122,
    kMatchingGameCurriculumButtonTag=123,
    kMatchingGameCurriculumMenuTag=124,
    kMatchingGameInfoCurriculumMenuTag=124,
    kMatchingGameHeaderTag=125,
    kMatchingGamePhotoTag=126,
    kMatchingGameCorrectTag=127,
    kMatchingGameWrongTag=128,
    kMatchingGameNextTag=129,
    kMatchingGameResultLabelTag=130,
    kMatchingGameCoinTag=131,
    kMatchingGameDareLabelTag=132,
    kMatchingGameWinnerBadgeTag=133,
    
    
} MatchingGameLayerTags;

typedef enum  {
    kMatchingGameTotalQuestions = 10,
    
} MatchingGameConstants;

@interface MatchinGameBackup : CCLayer <CCTargetedTouchDelegate, EditModeAblerDelegate> {
    
    CGSize screenSize;
    EditModeAbler *editModeAbler;
    
    CGPoint nextIconPosition;
    CGPoint correctIconPosition;
    CGPoint wrongIconPosition;
    
    // score keeping 
    int currentCorrectCount;
    int totalQuestions;
    bool gameJustEnded;
    
    //QA state
    BOOL alreadyAnswered;
    int photoTopicId;
    
    // background thread
    dispatch_queue_t backgroundQueue;
    
    // Image download states
    BOOL numOfImagesKnown;
    int numOfImages;
    //    SLImageGalleryDownloader *imgGalleryDownloader;
    
    NSMutableArray *coinMap;
    NSMutableArray *slImageDownloaders;
    NSMutableArray *slImageInfoDownloaders;
    
    
    CCMenuItemImage *audioImage;
    CCSprite *photoFrame;
    CCSprite *photo;
    
    NSString *lastDisplayedPhoto;
    
}

@property (nonatomic, retain) CCMenuItemImage *audioImage;
@property (nonatomic, retain) CCSprite *photoFrame;
@property (nonatomic, retain) NSString *lastDisplayedPhoto;


-(CGSize)retrieveImageSizeFromDoc:(NSString*)imageName;
-(void)prepareLayerForQuestion;
-(void)showScoreRepresentation:(NSInteger)correctCount;
-(void)showResult:(NSInteger)correctCount outOfTotal:(NSInteger)totalCount;
-(void)showResult:(NSInteger)correctCount outOfTotal:(NSInteger)totalCount withText:(NSString *)text;

@end





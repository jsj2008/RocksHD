//
//  QuizLayer.m
//  PlantHD
//
//  Created by Kelvin Chan on 10/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QuizLayer.h"
#import "FlowAndStateManager.h"
#import "ConfigManager.h"
#import "TextAndQuizScene.h"
#import "SizeSmartCCLabelTTF.h"
#import "AppConfigManager.h"

#define kCorrect 11
#define kWrong 10
#define kNext 100

@implementation QuizLayer

@synthesize topicInfo;
@synthesize questionDict;
@synthesize ansKey;
@synthesize choicesImgNames;
@synthesize audioItemImage;


-(void)dealloc {
    [questionDict release];
    [ansKey release];
    [choicesImgNames release];
    [audioItemImage release];
    [topicInfo release];
    
    [super dealloc];
}

-(void) addQuestion:(NSString*)question withFontName:(NSString*)fontName withFontSize:(float)fontSize {
    SizeSmartCCLabelTTF *questionLabel = [[SizeSmartCCLabelTTF alloc] initWithString:question withFixedWidth:screenSize.width*3/4 alignment:UITextAlignmentLeft fontName:fontName fontSize:fontSize];
                                        
    questionLabel.color = ccc3(0, 0, 0);
    questionLabel.anchorPoint = ccp(0.0, 0.5);
    questionLabel.position = questionPosition;
    [self addChild:questionLabel z:0 tag:kQuizQuestionLabelTag];
    
    [questionLabel release];
}

-(void) choiceSelected:(id)sender {
    
    
    CCLOG(@"selected %d", [sender tag]);
    // Check the answer
    if ([[ansKey objectAtIndex:[sender tag]] isEqualToString:@"Y"]) {
        CCLOG(@"Correct!");
        
        if (!self.audioItemImage.isSelected) {
            // PLAYSOUNDEFFECT(GREAT_JOB);
            [(TextAndQuizScene*)self.parent play_great_job];
        }
        
        CCSprite *s = (CCSprite*) [self getChildByTag:kQuizCorrectTag];
        s.visible = YES;
        [s stopAllActions];
        
        CCAction *shake = [CCSequence actions: 
                           [CCMoveTo actionWithDuration:0.1 position:ccp(correctIconPosition.x, correctIconPosition.y+10)],
                           [CCMoveTo actionWithDuration:0.1 position:ccp(correctIconPosition.x, correctIconPosition.y-10)],
                           [CCMoveTo actionWithDuration:0.1 position:correctIconPosition],
                           nil];    

        
        [s runAction:shake];
        
        CCSprite *ss = (CCSprite*) [self getChildByTag:kQuizWrongTag];
        ss.visible = NO;
        
        CCSprite *sss = (CCSprite*) [self getChildByTag:kQuizNextTag];
        sss.visible = YES;
        
        TextAndQuizScene *parentScene = (TextAndQuizScene *)[self parent];
        if (alreadyAnswered == NO) {
            [parentScene incrementCorrectCount];
            
            // animate coin across the top
            // PLAYSOUNDEFFECT(KA_CHING);
            
            CCSprite *coin = [CCSprite spriteWithFile:@"coin.png"];
            coin.position = ccp(screenSize.width + 200.0, screenSize.height-coin.boundingBox.size.height*0.5);
            
            id action = [CCSequence actions:
                         [CCMoveBy actionWithDuration:0.5 position:CGPointZero],
                         [CCSpawn actions:
                          [CCEaseElasticOut actionWithAction:
                           [CCMoveTo actionWithDuration:1.5 position:ccp(3.0*coin.boundingBox.size.width/2.0 + currentCorrectCount*20, screenSize.height-coin.boundingBox.size.height/2.0)]
                          ],
                          [CCCallBlock actionWithBlock:^{ if (!self.audioItemImage.isSelected) [(TextAndQuizScene*)self.parent play_kaching]; }],
                          nil],
                         nil];
            
            [coin runAction:action];
            [self addChild:coin z:0 tag:kQuizCoinTag];
        }
        
    }
    else {
        CCLOG(@"Wrong!");
        
        if (!self.audioItemImage.isSelected) {
            // PLAYSOUNDEFFECT(OOPS);
            [(TextAndQuizScene*)self.parent play_oops];
        }
        
        CCSprite *s = (CCSprite*) [self getChildByTag:kQuizCorrectTag];
        s.visible = NO;
        
        CCSprite *ss = (CCSprite*) [self getChildByTag:kQuizWrongTag];
        ss.visible = YES;
        [ss stopAllActions];
        
        CCAction *shake = [CCSequence actions:
                           [CCMoveTo actionWithDuration:0.1 position:ccp(wrongIconPosition.x+10, wrongIconPosition.y)],
                           [CCMoveTo actionWithDuration:0.1 position:ccp(wrongIconPosition.x-10, wrongIconPosition.y)],
                           [CCMoveTo actionWithDuration:0.1 position:wrongIconPosition],
                           nil];
        
        [ss runAction:shake];

    }
    
    alreadyAnswered = YES;
}

-(void) addMultipleChoice:(NSArray *)answers withFontName:(NSString*)fontName withFontSize:(float)fontSize {
    
    [ansKey removeAllObjects];
    
    float spacing = 85.0f;
    
    int k = 0;
    for (NSString *a in answers) {
        
        NSString *trim_a = [a stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSArray *tmp = [trim_a componentsSeparatedByString:@"|"];
        
        NSString *ans = [tmp objectAtIndex:0];
        
        NSString *ansStr = [NSString stringWithFormat:@"%@", ans];
        
        [ansKey addObject:[tmp objectAtIndex:1]];
        
        // put choice label (ie. A, B, C, or D)
        NSString *imgName = [self.choicesImgNames objectAtIndex:k];
                             
        CCMenuItemImage *c = [CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"%@.png", imgName]
                                                    selectedImage:[NSString stringWithFormat:@"%@_bigger.png", imgName]
                                                    disabledImage:[NSString stringWithFormat:@"%@.png", imgName]
                                                            target:self
                                                         selector:@selector(choiceSelected:)];
        c.tag = k;
        CCMenu *m = [CCMenu menuWithItems:c, nil];
        m.anchorPoint = ccp(0.0, 1.0);
        m.position = ccp(screenSize.width/5.0f, screenSize.height*7/12 - spacing*k);
        [self addChild:m];

//        CCLabelTTF *ansLabel = [CCLabelTTF labelWithString:ansStr fontName:fontName fontSize:fontSize];
        SizeSmartCCLabelTTF *ansLabel = [[SizeSmartCCLabelTTF alloc] initWithString:ansStr withFixedWidth:screenSize.width*0.6 alignment:UITextAlignmentLeft fontName:fontName fontSize:fontSize];
        
        ansLabel.color = ccc3(0, 0, 0);
        // ansLabel.anchorPoint = ccp(0.0, 1.0);
        
        // Use CCMenuItemLabel to wrap the CCLabelTTF
        CCMenuItemLabel *ansLabel2 = [CCMenuItemLabel itemWithLabel:ansLabel target:self selector:@selector(choiceSelected:)];
        ansLabel2.color = ccc3(0, 0, 0);
        ansLabel2.anchorPoint = ccp(0.0, 1.0);
        ansLabel2.tag = k;
        
        CCMenu *m2 = [CCMenu menuWithItems:ansLabel2, nil];
        m2.anchorPoint = ccp(0.0, 1.0);
        m2.position = ccp(screenSize.width-100.0, screenSize.height*7/12 - spacing*k + 19);
        id action = [CCSpawn actions:
                     [CCMoveTo actionWithDuration:0.77 position:ccp(screenSize.width/5.0f + c.boundingBox.size.width, screenSize.height*7/12 - spacing*k + 19)],
                     [CCFadeIn actionWithDuration:0.77],
                     nil];
        
        // m2.position = ccp(screenSize.width/5.0f + c.boundingBox.size.width, screenSize.height*7/12 - spacing*k + 19);
        [m2 runAction:action];
        [self addChild:m2];
        
        // [self addChild:ansLabel];
        k++;
    }
    
}

-(void)next:(id)sender {
    CCLOG(@"Next...");
    TextAndQuizScene *parentScene = (TextAndQuizScene *)[self parent];
    [parentScene loadNextQuiz:NO];
    alreadyAnswered = NO;
}

-(void)nextMust:(id)sender {
    CCLOG(@"Next...");
    TextAndQuizScene *parentScene = (TextAndQuizScene *)[self parent];
    [parentScene loadNextQuiz:YES];
    alreadyAnswered = NO;
}

-(void)addMenu {
    
    
    
    NSString *path = [NSString stringWithFormat:@"%@/CCMenu:%d/CCMenuItemImage", NSStringFromClass([self class]), kQuizMenuTag];
    
    CGPoint home_position = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kQuizHomeButtonTag];
    
    CCMenuItemImage *home = [CCMenuItemImage itemFromNormalImage:@"home.png" 
                                                   selectedImage:@"home_bigger.png"
                                                   disabledImage:@"home.png"
                                                          target:self selector:@selector(goHome)];
    home.position = home_position;
    home.tag = kQuizHomeButtonTag;
    
    /*CCMenuItemImage *playGame = [CCMenuItemImage itemFromNormalImage:@"play2.png"
                                                       selectedImage:@"play2_bigger.png"
                                                       disabledImage:@"play.png"
                                                              target:self selector:@selector(goPlayGame)];
    playGame.position = ccp(0.0f, 0.0f);*/
    
    CGPoint audio_position = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kQuizAudioButtonTag];
    
    self.audioItemImage = [CCMenuItemImage itemFromNormalImage:@"audio_on.png" 
                                                         selectedImage:@"audio_off.png"
                                                         disabledImage:@"audio_off.png" 
                                                                target:self
                                                              selector:@selector(audio:)];
    
    self.audioItemImage.position = audio_position;
    self.audioItemImage.tag = kQuizAudioButtonTag;
    
    if ([[FlowAndStateManager sharedFlowAndStateManager] isMusicON]) 
        [self.audioItemImage unselected];
    else 
        [self.audioItemImage selected];
    
    CGPoint back_position = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kQuizBackButtonTag];
    
    CCMenuItemImage *back = [CCMenuItemImage itemFromNormalImage:@"back.png"
                                                   selectedImage:@"back_bigger.png"
                                                   disabledImage:@"back.png"
                                                          target:self 
                                                        selector:@selector(goBackToMainText)];
    
    back.position = back_position;
    back.tag = kQuizBackButtonTag;

    CCMenu *menu = [CCMenu menuWithItems:home, self.audioItemImage, back, nil];
    
    NSString *menu_path = [NSString stringWithFormat:@"%@/CCMenu", NSStringFromClass([self class])];
    CGPoint menu_position = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:menu_path andTag:kQuizMenuTag];
                              
    menu.position = menu_position;
    
    [self addChild:menu z:0 tag:kQuizMenuTag];
}

-(void)goHome {
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kHomeScene withTranstion:kCCTransitionPageTurnForward];
}

-(void) audio:(CCMenuItemImage*)i {
    if ([FlowAndStateManager sharedFlowAndStateManager].isMusicON) {
        [i selected];
        [FlowAndStateManager sharedFlowAndStateManager].isMusicON = NO;
        [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
        
    }
    else {
        [i unselected];
        [FlowAndStateManager sharedFlowAndStateManager].isMusicON = YES;
//        [[FlowAndStateManager sharedFlowAndStateManager] playBackgroundTrack:BACKGROUND_TRACK_TEXTPAGE];
        [[FlowAndStateManager sharedFlowAndStateManager] playBackgroundTrack:[topicInfo objectForKey:@"background_track_name"]];
    }
}

-(void) goBackToMainText {
    
    CCLOG(@"go Back");
    
   int topicNumber =              [AppConfigManager  getInstance].currentTopic;
    CCLOG(@"Topic no %d",topicNumber);
    
    switch (topicNumber) {
        case 1:
            [[FlowAndStateManager sharedFlowAndStateManager] runSceneSansAudioOpWithID:kTopic1Scene withTranstion:kCCTransitionPageTurnBackward];
                CCLOG(@"Go Back to scene 1");
            break;
        case 2:
            [[FlowAndStateManager sharedFlowAndStateManager] runSceneSansAudioOpWithID:kTopic2Scene withTranstion:kCCTransitionPageTurnBackward];
            break;
        case 3:
            [[FlowAndStateManager sharedFlowAndStateManager] runSceneSansAudioOpWithID:kTopic3Scene withTranstion:kCCTransitionPageTurnBackward];
            break;
        case 4:
            [[FlowAndStateManager sharedFlowAndStateManager] runSceneSansAudioOpWithID:kTopic4Scene withTranstion:kCCTransitionPageTurnBackward];
            break;
        case 5:
            [[FlowAndStateManager sharedFlowAndStateManager] runSceneSansAudioOpWithID:kTopic5Scene withTranstion:kCCTransitionPageTurnBackward];
            break;
        case 6:
            [[FlowAndStateManager sharedFlowAndStateManager] runSceneSansAudioOpWithID:kTopic6Scene withTranstion:kCCTransitionPageTurnBackward];
            break;
        case 7:
            [[FlowAndStateManager sharedFlowAndStateManager] runSceneSansAudioOpWithID:kTopic7Scene withTranstion:kCCTransitionPageTurnBackward];
            break;
        default:
            break;
    }
    
}


-(void)goPlayGame {
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kPlayScene withTranstion:kCCTransitionCrossFade];
}

-(void)prepareLayerForQuestion {
    
    NSString *fontName = @"ArialRoundedMTBold";
    
    [self addQuestion:[questionDict objectForKey:@"question"] withFontName:fontName withFontSize:36];
    [self addMultipleChoice:[questionDict objectForKey:@"answers"] withFontName:fontName withFontSize:24];
    
    // add right/wrong image
    
    // Display correct icon
    CCSprite *correct = [CCSprite spriteWithFile:@"correct.png"];
    correct.position = correctIconPosition;
    correct.visible = NO;
    correct.tag = kQuizCorrectTag;
    [self addChild:correct z:100];  // always on very top
    
    CCSprite *wrong = [CCSprite spriteWithFile:@"wrong.png"];
    wrong.position = wrongIconPosition;
    wrong.visible = NO;
    wrong.tag = kQuizWrongTag;
    [self addChild:wrong z:-1];          // always at very bottom
    
    CCMenuItemImage *next = [CCMenuItemImage itemFromNormalImage:@"next.png" 
                                                   selectedImage:@"next.png"
                                                   disabledImage:@"next.png"
                                                          target:self
                                                        selector:@selector(next:)];
    
    CCMenu *nextMenu = [CCMenu menuWithItems:next, nil];
    nextMenu.tag = kQuizNextTag;
    
    nextMenu.position = nextIconPosition;
//    nextMenu.position = QUIZ_NEXT_ICON_POSITION;
    nextMenu.visible = NO;
    
    [self addChild:nextMenu];

}

-(void)showScoreRepresentation:(NSInteger)correctCount {
    CCLOG(@"# of coins = %d", correctCount);
    for (int i = 0; i < correctCount; i++) {
        CCSprite *coin = [CCSprite spriteWithFile:@"coin.png"];
        coin.position = ccp(coin.boundingBox.size.width*1.5 + i*20, screenSize.height-coin.boundingBox.size.height*0.5);
        [self addChild:coin];
    }
    currentCorrectCount = correctCount;
}

-(void)showResult:(NSInteger)correctCount outOfTotal:(NSInteger)totalCount {
    
    NSString *result;
    if (correctCount > 10) 
        result = [NSString stringWithFormat:@"You got %d out of %d questions right.", correctCount, totalCount];
    else 
        result = [NSString stringWithFormat:@"You got %d out of %d questions right.", correctCount, totalCount];
    
    CCLabelTTF *resultLabel = [CCLabelTTF labelWithString:result fontName:@"ArialRoundedMTBold" fontSize:42];
    
    resultLabel.color = ccc3(0, 0, 0);
    resultLabel.position = ccp(screenSize.width/2, screenSize.height/2);
    
    [self addChild:resultLabel z:0 tag:kQuizResultLabelTag];
    
}

-(void)showResult:(NSInteger)correctCount outOfTotal:(NSInteger)totalCount withText:(NSString *)text {
    
    /*NSString *result = [NSString stringWithFormat:@"You got %d out of %d questions right so far", correctCount, totalCount];
    CCLabelTTF *resultLabel = [CCLabelTTF labelWithString:result fontName:@"Noteworthy" fontSize:48];
    resultLabel.color = ccc3(0, 0, 0);
    resultLabel.position = ccp(screenSize.width/2, screenSize.height/2+50);
    [self addChild:resultLabel];*/
    
    // CCLabelTTF *dareLabel = [CCLabelTTF labelWithString:text fontName:@"ArialRoundedMTBold" fontSize:42];
//    SizeSmartCCLabelTTF *dareLabel = [[SizeSmartCCLabelTTF alloc] initWithString:text withFixedWidth:screenSize.width*3/4 alignment:UITextAlignmentCenter fontName:@"ArialRoundedMTBold" fontSize:42];
    SizeSmartCCLabelTTF *dareLabel = [[SizeSmartCCLabelTTF alloc] initWithString:text withFixedWidth:screenSize.width*3/4 alignment:UITextAlignmentLeft fontName:@"ArialRoundedMTBold" fontSize:42];
    
    
    dareLabel.color = ccc3(0, 0, 0);
    dareLabel.position = dareLabelPosition;
    [self addChild:dareLabel z:0 tag:kQuizDareLabelTag];
    [dareLabel release];
    
    CCMenuItemImage *next = [CCMenuItemImage itemFromNormalImage:@"next.png" 
                                                   selectedImage:@"next.png"
                                                   disabledImage:@"next.png"
                                                          target:self
                                                        selector:@selector(nextMust:)];
    
    CCMenu *nextMenu = [CCMenu menuWithItems:next, nil];
    nextMenu.tag = kQuizNextTag;
    nextMenu.position = nextIconPosition;
//    nextMenu.position = QUIZ_NEXT_ICON_POSITION;
    nextMenu.visible = YES;
    
    [self addChild:nextMenu];
    
}

- (id)init
{
    self = [super init];
    if (self) {
        
        NSMutableArray *a = [[NSMutableArray alloc] init];
        self.ansKey = a;
        [a release];
        
        self.isTouchEnabled = YES;
        
        screenSize = [CCDirector sharedDirector].winSize;
        // NSString *fontName = @"Marker Felt";
        
        // initialize image names for ans choices
        NSArray *a2 = [NSArray arrayWithObjects:@"quiz_A", @"quiz_B", @"quiz_C", @"quiz_D", nil];
        self.choicesImgNames = a2;
        
      //  [CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
        
        NSString *path = [NSString stringWithFormat:@"%@/CCMenu", NSStringFromClass([self class])];
        nextIconPosition = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kQuizNextTag];

        path = [NSString stringWithFormat:@"%@/CCSprite", NSStringFromClass([self class])];
        correctIconPosition = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kQuizCorrectTag];
        wrongIconPosition = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kQuizWrongTag];
        
        path = [NSString stringWithFormat:@"%@/SizeSmartCCLabelTTF", NSStringFromClass([self class])];
        dareLabelPosition = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kQuizDareLabelTag];
        questionPosition = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kQuizQuestionLabelTag];
        
    }
    
    return self;
}

-(void)onEnter {
    [super onEnter];
    
    editModeAbler = [EditModeAbler node];
    [editModeAbler retain];
    editModeAbler.delegateLayer = self;
    
    [editModeAbler activate];
}

-(void)onExit {
    [editModeAbler release];
    [super onExit];
}




@end

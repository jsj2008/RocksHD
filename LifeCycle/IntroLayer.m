//
//  IntroLayer.m
//  PlantHD
//
//  Created by Kelvin Chan on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IntroLayer.h"
#import "Constants.h"
#import "ConfigManager.h"
#import "PlistManager.h"

@implementation IntroLayer

@synthesize miniGame;

-(void)dealloc {
    
    CCLOG(@"Releasing IntroLayer");
    
    if (miniGame != nil)
        [miniGame release];
        
    [super dealloc];
}

#pragma mark - Setup all the menus, buttons and arrows

-(void) addArrows {
    // Add all the arrows connecting the topics
    
    NSString *path = [NSString stringWithFormat:@"%@/CCSprite", NSStringFromClass([self class])];
    
    // Get arrow positions from User Defaults
    CGPoint arrow3Position = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kIntro3OclockArrowTag];
    CGPoint arrow4Position = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kIntro4OclockArrowTag];
    CGPoint arrow6Position = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kIntro6OclockArrowTag];
    CGPoint arrow9Position = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kIntro9OclockArrowTag];
    CGPoint arrow10Position = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kIntro10OclockArrowTag];
    CGPoint arrow12Position = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kIntro12OclockArrowTag];
    CGPoint arrow2Position = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kIntro2OclockArrowTag];
    
    // Get arrow angles from User defaults
    float arrow3Angle = [[ConfigManager sharedConfigManager] angleFromDefaultsForNodeHierPath:path andTag:kIntro3OclockArrowTag];
    float arrow4Angle = [[ConfigManager sharedConfigManager] angleFromDefaultsForNodeHierPath:path andTag:kIntro4OclockArrowTag];
    float arrow6Angle = [[ConfigManager sharedConfigManager] angleFromDefaultsForNodeHierPath:path andTag:kIntro6OclockArrowTag];
    float arrow9Angle = [[ConfigManager sharedConfigManager] angleFromDefaultsForNodeHierPath:path andTag:kIntro9OclockArrowTag];
    float arrow10Angle = [[ConfigManager sharedConfigManager] angleFromDefaultsForNodeHierPath:path andTag:kIntro10OclockArrowTag];
    float arrow12Angle = [[ConfigManager sharedConfigManager] angleFromDefaultsForNodeHierPath:path andTag:kIntro12OclockArrowTag];
    float arrow2Angle = [[ConfigManager sharedConfigManager] angleFromDefaultsForNodeHierPath:path andTag:kIntro2OclockArrowTag];

    
    CCSprite *arrow3oclock = [CCSprite spriteWithFile:@"Arrow3Oclock.png"];
    arrow3oclock.position = arrow3Position;
    arrow3oclock.rotation = arrow3Angle;
    [self addChild:arrow3oclock z:0 tag:kIntro3OclockArrowTag];
    
    CCSprite *arrow4oclock = [CCSprite spriteWithFile:@"Arrow4Oclock.png"];
    arrow4oclock.position = arrow4Position;
    arrow4oclock.rotation = arrow4Angle;
    [self addChild:arrow4oclock z:0 tag:kIntro4OclockArrowTag];
    
    CCSprite *arrow6oclock = [CCSprite spriteWithFile:@"Arrow6Oclock.png"];
    arrow6oclock.position = arrow6Position;
    arrow6oclock.rotation = arrow6Angle;
//    arrow6oclock.rotation = 22.5f;
    [self addChild:arrow6oclock z:0 tag:kIntro6OclockArrowTag];
    
    CCSprite *arrow9oclock = [CCSprite spriteWithFile:@"Arrow9Oclock.png"];
    arrow9oclock.position = arrow9Position;
    arrow9oclock.rotation = arrow9Angle;
    [self addChild:arrow9oclock z:0 tag:kIntro9OclockArrowTag];
    
    CCSprite *arrow10oclock = [CCSprite spriteWithFile:@"Arrow10Oclock.png"];
    arrow10oclock.position = arrow10Position;
    arrow10oclock.rotation = arrow10Angle;
    [self addChild:arrow10oclock z:0 tag:kIntro10OclockArrowTag];
    
    CCSprite *arrow12oclock = [CCSprite spriteWithFile:@"Arrow12Oclock.png"];
    arrow12oclock.position = arrow12Position;
    arrow12oclock.rotation = arrow12Angle;
    [self addChild:arrow12oclock z:0 tag:kIntro12OclockArrowTag];
    
    CCSprite *arrow2oclock = [CCSprite spriteWithFile:@"Arrow2Oclock.png"];
    arrow2oclock.position = arrow2Position;
    arrow2oclock.rotation = arrow2Angle;
    [self addChild:arrow2oclock z:0 tag:kIntro2OclockArrowTag];

}

-(void) addInfoAndAudioOnOffButton {
    CCMenuItemImage *info = [CCMenuItemImage itemFromNormalImage:@"info.png" 
                                                   selectedImage:@"info_bigger.png"
                                                          target:self
                                                        selector:@selector(info)];
    info.position = ccp(0,0);
    info.tag = kIntroInfoButtonTag;
    
    CCMenu *infoMenu = [CCMenu menuWithItems:info, nil];
    
    infoMenu.position = ccp(screenSize.width - info.boundingBox.size.width/2.0 - 10, 
                            screenSize.height - info.boundingBox.size.height/2.0 - 10);
    
    [self addChild:infoMenu z:10 tag:kIntroInfoMenuTag];
    
    CCMenuItemImage *curr = [CCMenuItemImage itemFromNormalImage:@"curriculum.png"
                                                   selectedImage:@"curriculum_bigger.png"
                                                          target:self 
                                                        selector:@selector(curriculum)];
    curr.position = ccp(0, 0);
    curr.tag = kIntroCurriculumButtonTag;
    
    CCMenu *currMenu = [CCMenu menuWithItems:curr, nil];
    
    currMenu.position = ccp(screenSize.width - info.boundingBox.size.width - curr.boundingBox.size.width/2.0 - 10,
                            screenSize.height - info.boundingBox.size.height/2.0 - 10);
    [self addChild:currMenu z:10 tag:kIntroCurriculumMenuTag];
    
    CCMenuItemImage *audioImage = [CCMenuItemImage itemFromNormalImage:@"audio_on.png" 
                                                         selectedImage:@"audio_off.png"
                                                         disabledImage:@"audio_off.png" 
                                                                target:self
                                                              selector:@selector(audio:)];
    
    if ([[FlowAndStateManager sharedFlowAndStateManager] isMusicON]) 
        [audioImage unselected];
    else 
        [audioImage selected];
    
    audioImage.position = ccp(0,0);
    audioImage.tag = kIntroAudioButtonTag;

    CCMenu *audioMenu = [CCMenu menuWithItems:audioImage, nil];
    
    audioMenu.position = ccp(screenSize.width - info.boundingBox.size.width - curr.boundingBox.size.width - audioImage.boundingBox.size.width/2.0 - 10, 
                             screenSize.height - info.boundingBox.size.height/2.0 - 10);
    
    [self addChild:audioMenu z:10 tag:kIntroAudioMenuTag];

}

- (CCActionInterval *) makeGentleSwirlingAction:(CGPoint)origin {
    
    ccBezierConfig bezierConfigTop;
    bezierConfigTop.controlPoint_1 = ccp(4.0, 2.0);
    bezierConfigTop.controlPoint_2 = ccp(4.0, 2.0);
    bezierConfigTop.endPosition = ccp(8, 0);
    
    ccBezierConfig bezierConfigRight;
    bezierConfigRight.controlPoint_1 = ccp(2.0, -4.0);
    bezierConfigRight.controlPoint_2 = ccp(2.0, -4.0);
    bezierConfigRight.endPosition = ccp(0, -8);
    
    ccBezierConfig bezierConfigBottom;
    bezierConfigBottom.controlPoint_1 = ccp(-4.0, -2.0);
    bezierConfigBottom.controlPoint_2 = ccp(-4.0, -2.0);
    bezierConfigBottom.endPosition = ccp(-8, 0);
    
    ccBezierConfig bezierConfigLeft;
    bezierConfigLeft.controlPoint_1 = ccp(-2.0, 4.0);
    bezierConfigLeft.controlPoint_2 = ccp(-2.0, 4.0);
    bezierConfigLeft.endPosition = ccp(0, 8);
        
    return [CCRepeatForever actionWithAction:
             [CCSequence actions:

              [CCBezierBy actionWithDuration:(0.5 + ((float) random() / RAND_MAX)) bezier:bezierConfigTop],
              [CCBezierBy actionWithDuration:(0.5 + ((float) random() / RAND_MAX)) bezier:bezierConfigRight],
              [CCBezierBy actionWithDuration:(0.5 + ((float) random() / RAND_MAX)) bezier:bezierConfigBottom],
              [CCBezierBy actionWithDuration:(0.5 + ((float) random() / RAND_MAX)) bezier:bezierConfigLeft],

              [CCMoveTo actionWithDuration:0 position:origin],
              
              nil]];
}

- (CCActionInterval *) makeMoveBackToOriginAction:(CGPoint)point {
    return [CCMoveTo actionWithDuration:0.2 position:point];
}

- (void) animateAllTopicIconsBack2Orig {
    // to be impl...
}

-(void) addTopicMenus {
    
    // Main Menu
    CCMenu *menu = [CCMenu menuWithItems:nil];
    menu.tag = kIntroMainMenuTag;
    NSString *menuHierPath = [NSString stringWithFormat:@"%@/CCMenu", NSStringFromClass([self class])];
    CGPoint pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:menuHierPath andTag:kIntroMainMenuTag];
    
//    NSLog(@"pos from user default %f, %f",pos.x, pos.y);
    
    menu.position = pos;
    [self addChild:menu z:0];
                
    // The big Play button
    CCMenuItemImage *play = [CCMenuItemImage itemFromNormalImage:@"play.png" 
                                                   selectedImage:@"play_bigger.png" 
                                                   disabledImage:@"play.png" 
                                                          target:self 
                                                        selector:@selector(play)];
    play.tag = kIntroPlayButtonTag;
    NSString *playHierPath = [NSString stringWithFormat:@"%@/CCMenu:%d/CCMenuItemImage", NSStringFromClass([self class]), kIntroPlayButtonTag];
    CGPoint playPos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:playHierPath andTag:kIntroPlayButtonTag];
    play.position = playPos;
    play.scale = 1.2;
    [menu addChild:play];
    
    // All life cycle buttons
    NSDictionary *basicInfoAboutCycles = [[PlistManager sharedPlistManager] allTopicsPlistDictionary];

    NSString *hierPath = [NSString stringWithFormat:@"%@/CCMenu:%d/CCMenuItemImage", NSStringFromClass([self class]), kIntroMainMenuTag];

    int topicCursor = 0;
    int numOfTopics = [FlowAndStateManager sharedFlowAndStateManager].numOfTopics;
    for (NSString *topic in [[basicInfoAboutCycles allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {
        CCLOG(@"ky = %@", topic);
        
        NSString *imageName = [[basicInfoAboutCycles objectForKey:topic] objectForKey:@"intro_topic_image_name"];
        NSString *biggerImageName = [[basicInfoAboutCycles objectForKey:topic] objectForKey:@"intro_topic_bigger_image_name"];
        
        CCMenuItemImage *topicItemImage = [CCMenuItemImage itemFromNormalImage:imageName
                                                                 selectedImage:biggerImageName
                                                                 disabledImage:imageName
                                                                        target:self 
                                                                      selector:@selector(topicHandler:)];
        
        topicItemImage.tag = kIntroTopic1ButtonTag + topicCursor;
        CGPoint pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:hierPath andTag:topicItemImage.tag];
        topicItemImage.position = pos;

        [topicItemImage runAction:[self makeGentleSwirlingAction:topicItemImage.position]];
        
        [menu addChild:topicItemImage];
        
        if (topicCursor == numOfTopics - 1)
            break;
        
        topicCursor++;
    }
    
}

-(void) removeTopicMenus {
    // Remove the original topic menu to make way for the game
    CCMenu *menu = (CCMenu*) [self getChildByTag:kIntroMainMenuTag];
    [menu removeFromParentAndCleanup:YES];
}

-(void) setUpMenus {
    
    [self addTopicMenus];
    
    [self addInfoAndAudioOnOffButton];
    
    //[self addArrows];
    
}


#pragma mark - Mini Game 
- (void) playMiniGame {
    
    if ([FlowAndStateManager sharedFlowAndStateManager].isMusicON)
        [[FlowAndStateManager sharedFlowAndStateManager] playBackgroundTrack:BACKGROUND_TRACK_MINIGAME];
    
    if (self.miniGame == nil) {
        self.miniGame = [MiniGame gameWithParentLayer:self];
    }
    
    [self.miniGame start];
    
    [self removeTopicMenus];
    
    [self.miniGame installHomeButton];
    
    isGameOn = YES;

}

- (void) miniGameDidFinish:(MiniGame *)miniGame {
    CCLOG(@"Finish up the game");
    
    self.miniGame = nil;   // release game
    
    [self addTopicMenus];
    
    if ([FlowAndStateManager sharedFlowAndStateManager].isMusicON)
        [[FlowAndStateManager sharedFlowAndStateManager] playBackgroundTrack:BACKGROUND_TRACK_MENUPAGE];
    
    isGameOn = NO;
}

#pragma mark - Menu Item pressed

-(void) info {
    // CCLOG(@"Info pressed");
    
    PLAYSOUNDEFFECT(INTRO_CLICK_1);
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kInfoScene withTranstion:kCCTransitionPageFlip];
//    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kTestScene withTranstion:kCCTransitionPageFlip];
    
}

-(void) curriculum {
    PLAYSOUNDEFFECT(INTRO_CLICK_1);
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kCurrScene withTranstion:kCCTransitionPageFlip];
}

-(void) play {
    //[[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kPlayScene withTranstion:kCCTransitionCrossFade];
    [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];

    // PLAYSOUNDEFFECT(INTRO_CLICK_1);
    [self playMiniGame];
    
}

-(void) playOriginal {
    PLAYSOUNDEFFECT(INTRO_CLICK_1);
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kPlayScene withTranstion:kCCTransitionCrossFade];
}

-(void) topicHandler:(CCNode*)sender {
    PLAYSOUNDEFFECT(INTRO_CLICK_1);
    switch (sender.tag) {
        case kIntroTopic1ButtonTag:
            [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
            [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kTopic1Scene withTranstion:kCCTransitionPageTurnForward];
            break;
        case kIntroTopic2ButtonTag:
            [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
            [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kTopic2Scene withTranstion:kCCTransitionPageTurnForward];
            break;
        case kIntroTopic3ButtonTag:
            [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
            [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kTopic3Scene withTranstion:kCCTransitionPageTurnForward];
            break;
        case kIntroTopic4ButtonTag:
            [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
            [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kTopic4Scene withTranstion:kCCTransitionPageTurnForward];
            break;
        case kIntroTopic5ButtonTag:
            [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
            [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kTopic5Scene withTranstion:kCCTransitionPageTurnForward];
            break;
        case kIntroTopic6ButtonTag:
            [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
            [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kTopic6Scene withTranstion:kCCTransitionPageTurnForward];
            break;
        case kIntroTopic7ButtonTag:
            [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
            [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kTopic7Scene withTranstion:kCCTransitionPageTurnForward];
            break;
        default:
            break;
    }
}


#pragma mark - Audio

-(void) audio:(CCMenuItemImage*)i {

    if ([FlowAndStateManager sharedFlowAndStateManager].isMusicON) {
        [i selected];
        [FlowAndStateManager sharedFlowAndStateManager].isMusicON = NO;
        [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
        
    }
    else {
        [i unselected];
        [FlowAndStateManager sharedFlowAndStateManager].isMusicON = YES;
        if (isGameOn)
            [[FlowAndStateManager sharedFlowAndStateManager] playBackgroundTrack:BACKGROUND_TRACK_MINIGAME];
        else 
            [[FlowAndStateManager sharedFlowAndStateManager] playBackgroundTrack:BACKGROUND_TRACK_MENUPAGE];
    }        
    
}

#pragma mark - Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        screenSize = [CCDirector sharedDirector].winSize;
        isGameOn = NO;
                
        CCSprite *backgroundImage;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            backgroundImage = [CCSprite spriteWithFile:@"cyclebackground.png"];
        }
        else {
            backgroundImage = nil;
        }
        
        [backgroundImage setPosition:ccp(screenSize.width/2, screenSize.height/2)];
        [self addChild:backgroundImage z:0 tag:kIntroBackgroundTag];
        
        [self setUpMenus];
                
        if ([FlowAndStateManager sharedFlowAndStateManager].isMusicON)
            [[FlowAndStateManager sharedFlowAndStateManager] playBackgroundTrack:BACKGROUND_TRACK_MENUPAGE];
            
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

#pragma mark - Touches

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGPoint location = [touch locationInView: [touch view]];
    CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
    CCLOG(@"Intro Layer Touched (%f, %f)", loc.x, loc.y);
    
    return (NO || [editModeAbler ccTouchBegan:touch withEvent:event]);
    
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    [editModeAbler ccTouchMoved:touch withEvent:event];
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [editModeAbler ccTouchEnded:touch withEvent:event];
}

@end

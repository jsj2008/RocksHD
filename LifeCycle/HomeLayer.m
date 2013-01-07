//
//  HomeLayer.m
//  PlantHD
//
//  Created by Kelvin Chan on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HomeLayer.h"
#import "Constants.h"
#import "ConfigManager.h"
#import "PlistManager.h"
#import "AppConfigManager.h"

@implementation HomeLayer

@synthesize audioImage;
@synthesize didYouKnowTxts;
@synthesize didYouKnowTxtLabel, previousDidYouKnowTxtLabel;



-(void) goLeftOnDidYouKnow:(id)sender {
    [didYouKnowTxtLabel stopAllActions];
    
    if (!self.audioImage.isSelected)
        [self play_dyk_scroll_left];
    
    didYouKnowCount--;
    if (didYouKnowCount < 0) 
        didYouKnowCount = [self.didYouKnowTxts count]-1;
    
    [self slideInDidYouKnow:@"right" withDuration:1.0];
}

-(void) goRightDidYouKnow:(id)sender {
    [didYouKnowTxtLabel stopAllActions];
    
    if (!self.audioImage.isSelected)
        [self play_dyk_scroll_right];
    
    didYouKnowCount++;
    if (didYouKnowCount > [self.didYouKnowTxts count]-1) 
        didYouKnowCount = 0;
    
    [self slideInDidYouKnow:@"left" withDuration:1.0];
}

-(void)dealloc {
    
    CCLOG(@"Releasing HomeLayer");
    
    
    // [audioImage release];
    if (didYouKnowTxts != nil) 
        [didYouKnowTxts release];
    
    [didYouKnowTxtLabel release];
    [previousDidYouKnowTxtLabel release];

    
    [super dealloc];
}

#pragma mark - Setup all the menus, buttons and arrows


-(void) addInfoAndAudioOnOffButton {
    CCMenuItemImage *info = [CCMenuItemImage itemFromNormalImage:@"info.png" 
                                                   selectedImage:@"info_bigger.png"
                                                          target:self
                                                        selector:@selector(info)];
    info.position = ccp(0,0);
    info.tag = kHomeInfoButtonTag;
    
    CCMenu *infoMenu = [CCMenu menuWithItems:info, nil];
    
    infoMenu.position = ccp(screenSize.width - info.boundingBox.size.width/2.0 - 10, 
                            screenSize.height - info.boundingBox.size.height/2.0 - 10);
    
    [self addChild:infoMenu z:10 tag:kHomeInfoMenuTag];
        
    audioImage = [CCMenuItemImage itemFromNormalImage:@"audio_on.png" 
                                                         selectedImage:@"audio_off.png"
                                                         disabledImage:@"audio_off.png" 
                                                                target:self
                                                              selector:@selector(audio:)];
    
    if ([[FlowAndStateManager sharedFlowAndStateManager] isMusicON]) 
        [audioImage unselected];
    else 
        [audioImage selected];
    
    audioImage.position = ccp(0,0);
    audioImage.tag = kHomeAudioButtonTag;

    CCMenu *audioMenu = [CCMenu menuWithItems:audioImage, nil];
    
    audioMenu.position = ccp(screenSize.width - info.boundingBox.size.width  - audioImage.boundingBox.size.width/2.0 - 10, 
                             screenSize.height - info.boundingBox.size.height/2.0 - 10);
    
    [self addChild:audioMenu z:10 tag:kHomeAudioMenuTag];
    
    
    
    CCMenuItemImage *otherApps = [CCMenuItemImage itemFromNormalImage:@"apps.png" 
                                                        selectedImage:@"apps_bigger.png"
                                                               target:self
                                                             selector:@selector(apps)];
    otherApps.position = ccp(50,0);
    otherApps.tag = kIntroAppButtonTag;
    
    CCMenu *otherAppsMenu = [CCMenu menuWithItems:otherApps, nil];
    otherAppsMenu.tag = kIntroAppMenuTag;
    
    NSString *path = [NSString stringWithFormat:@"%@/CCMenu", NSStringFromClass([self class])];
    
    CGPoint pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kIntroAppMenuTag];
    pos.y = pos.y -5;
    otherAppsMenu.position = pos;
    
    [self addChild:otherAppsMenu z:10 tag:kIntroAppMenuTag];
    
    /*
    CCMenuItemImage *curr = [CCMenuItemImage itemFromNormalImage:@"curriculum.png"
                                                   selectedImage:@"curriculum_bigger.png"
                                                          target:self 
                                                        selector:@selector(curriculum)];
    curr.position = ccp(0, 0);
    curr.tag = kHomeCurriculumButtonTag;
    
    CCMenu *currMenu = [CCMenu menuWithItems:curr, nil];
    
    currMenu.position = ccp(40,  screenSize.height - info.boundingBox.size.height/2.0 - 10);
    [self addChild:currMenu z:10 tag:kHomeCurriculumMenuTag];
     */


}

-(void) apps {
    PLAYSOUNDEFFECT(INTRO_CLICK_1);
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kOtherAppsScene withTranstion:kCCTransitionPageFlip];
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
    
    debugLog(@"No play button needed");
    return;
    
    
    // Main Menu
    CCMenu *menu = [CCMenu menuWithItems:nil];
    menu.tag = kHomeMainMenuTag;
    NSString *menuHierPath = [NSString stringWithFormat:@"%@/CCMenu", NSStringFromClass([self class])];
    CGPoint pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:menuHierPath andTag:kHomeMainMenuTag];
    
//    NSLog(@"pos from user default %f, %f",pos.x, pos.y);
    
    menu.position = pos;
    [self addChild:menu z:0];
                
    // The big Play button
    CCMenuItemImage *play = [CCMenuItemImage itemFromNormalImage:@"play.png" 
                                                   selectedImage:@"play_bigger.png" 
                                                   disabledImage:@"play.png" 
                                                          target:self 
                                                        selector:@selector(play)];
    play.tag = kHomePlayButtonTag;
    NSString *playHierPath = [NSString stringWithFormat:@"%@/CCMenu:%d/CCMenuItemImage", NSStringFromClass([self class]), kHomePlayButtonTag];
    CGPoint playPos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:playHierPath andTag:kHomePlayButtonTag];
    playPos.y = playPos.y + 25;
    play.position = playPos;
    play.scale = 1.2;
    [menu addChild:play];
    
    /*
    // All life cycle buttons
    NSDictionary *basicInfoAboutCycles = [[PlistManager sharedPlistManager] allTopicsPlistDictionary];

    NSString *hierPath = [NSString stringWithFormat:@"%@/CCMenu:%d/CCMenuItemImage", NSStringFromClass([self class]), kHomeMainMenuTag];

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
        
        topicItemImage.tag = kHomeTopic1ButtonTag + topicCursor;
        CGPoint pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:hierPath andTag:topicItemImage.tag];
        topicItemImage.position = pos;
        
        
        

       [topicItemImage runAction:[self makeGentleSwirlingAction:topicItemImage.position]];
        
        [menu addChild:topicItemImage];
        
        if (topicCursor == numOfTopics - 1)
            break;
        
        topicCursor++;
    }
     
     */
    
}

-(void) removeTopicMenus {
    // Remove the original topic menu to make way for the game
    CCMenu *menu = (CCMenu*) [self getChildByTag:kHomeMainMenuTag];
    [menu removeFromParentAndCleanup:YES];
}

-(void) setUpMenus {
    
    [self addTopicMenus];
    
    [self addInfoAndAudioOnOffButton];
    

    
}



#pragma mark - Menu Item pressed

-(void) info {
    // CCLOG(@"Info pressed");
    
    PLAYSOUNDEFFECT(Home_CLICK_1);
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kInfoScene withTranstion:kCCTransitionPageFlip];
//    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kTestScene withTranstion:kCCTransitionPageFlip];
    
}

-(void) curriculum {
    PLAYSOUNDEFFECT(Home_CLICK_1);
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kCurrScene withTranstion:kCCTransitionPageFlip];
}

-(void) play {
    


    PLAYSOUNDEFFECT(Home_CLICK_1);
    [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];    
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kMatchingGameScene withTranstion:kCCTransitionCrossFade];
    
    
}

-(void) playOriginal {
    PLAYSOUNDEFFECT(Home_CLICK_1);
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kPlayScene withTranstion:kCCTransitionCrossFade];
}

-(void) topicHandler:(CCNode*)sender {
    PLAYSOUNDEFFECT(Home_CLICK_1);
    
    CCLOG(@"Topic %d clicked",sender.tag);
    switch (sender.tag) {
        case kHomeTopic1ButtonTag:
            
            [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
            
            
         [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kTopic1Scene withTranstion:kCCTransitionPageTurnForward];
            break;
        case kHomeTopic2ButtonTag:
            [AppConfigManager  getInstance].currentTopic = 2;
            [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
            [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kTopic2Scene withTranstion:kCCTransitionPageTurnForward];
            break;
        case kHomeTopic3ButtonTag:
            [AppConfigManager  getInstance].currentTopic = 3;
            [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
            [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kTopicInteractiveScene withTranstion:kCCTransitionPageFlip];
            break;
        case kHomeTopic4ButtonTag:
            [AppConfigManager  getInstance].currentTopic = 4;
            [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
            [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kTopic4Scene withTranstion:kCCTransitionPageTurnForward];
            break;
        case kHomeTopic5ButtonTag:
            [AppConfigManager  getInstance].currentTopic = 5;
            [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
            [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kTopic5Scene withTranstion:kCCTransitionPageTurnForward];
            break;
        case kHomeTopic6ButtonTag:
                      [AppConfigManager  getInstance].currentTopic = 6;
            [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
            [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kTopic6Scene withTranstion:kCCTransitionPageTurnForward];
            break;
        case kHomeTopic7ButtonTag:
                        [AppConfigManager  getInstance].currentTopic = 7;
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
        [[FlowAndStateManager sharedFlowAndStateManager] playBackgroundTrack:BACKGROUND_TRACK_MENUPAGE];
    }        
    
}

#pragma mark - Lifecycle

- (id)init
{
    CCLOG(@"init");
    self = [super init];
    if (self) {
        screenSize = [CCDirector sharedDirector].winSize;
      
                
        CCSprite *backgroundImage;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            backgroundImage = [CCSprite spriteWithFile:@"home_background.png"];
        }
        else {
            backgroundImage = nil;
        }
        
        [backgroundImage setPosition:ccp(screenSize.width/2, screenSize.height/2)];
        [self addChild:backgroundImage z:0 tag:kHomeBackgroundTag];

        
        CCSprite *backgroundImageDYK;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            backgroundImageDYK = [CCSprite spriteWithFile:@"info_background_strip.png"];
        }
        else {
            backgroundImageDYK = nil;
        }
        
        //[backgroundImageDYK setPosition:ccp(screenSize.width/2, screenSize.height/2)];
        
        
        NSString *dykBgImagePosPath = [NSString stringWithFormat:@"%@/CCSprite", NSStringFromClass([self class])];
        CGPoint dykBgImagePos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:dykBgImagePosPath andTag:kHomeDYKBackgroundTag];
        
        backgroundImageDYK.position = dykBgImagePos;
        
        [self addChild:backgroundImageDYK z:0 tag:kHomeDYKBackgroundTag];

        
        CCLOG(@"Setup Menus");
        
        [self setUpMenus];
                
        
        
        if ([FlowAndStateManager sharedFlowAndStateManager].isMusicON)
            [[FlowAndStateManager sharedFlowAndStateManager] playBackgroundTrack:BACKGROUND_TRACK_MENUPAGE];
            
    }
    
NSString *path = [NSString stringWithFormat:@"%@/CCSprite", NSStringFromClass([self class])];
    /*
    
    NSString *path = [NSString stringWithFormat:@"%@/CCSprite", NSStringFromClass([self class])];
    
    // Get arrow positions from User Defaults
    CGPoint arrow3Position = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kHome3OclockArrowTag];
    CGPoint arrow6Position = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kHome4OclockArrowTag];
    CGPoint arrow4Position = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kHome6OclockArrowTag];
    
    // Get arrow angles from User defaults
    float arrow3Angle = [[ConfigManager sharedConfigManager] angleFromDefaultsForNodeHierPath:path andTag:kHome3OclockArrowTag];
    float arrow4Angle = [[ConfigManager sharedConfigManager] angleFromDefaultsForNodeHierPath:path andTag:kHome4OclockArrowTag];
    float arrow6Angle = [[ConfigManager sharedConfigManager] angleFromDefaultsForNodeHierPath:path andTag:kHome6OclockArrowTag];
    
    
    CCSprite *arrow3oclock = [CCSprite spriteWithFile:@"arrow_bottom.png"];
    arrow3oclock.position = arrow3Position;
    arrow3oclock.rotation = arrow3Angle;
    [self addChild:arrow3oclock z:0 tag:kHome3OclockArrowTag];
    
    CCSprite *arrow4oclock = [CCSprite spriteWithFile:@"arrow_left.png"];
    arrow4oclock.position = arrow4Position;
    arrow4oclock.rotation = arrow4Angle;
    [self addChild:arrow4oclock z:0 tag:kHome4OclockArrowTag];
    
    CCSprite *arrow6oclock = [CCSprite spriteWithFile:@"arrow_right.png"];
    arrow6oclock.position = arrow6Position;
    arrow6oclock.rotation = arrow6Angle;
    //    arrow6oclock.rotation = 22.5f;
    [self addChild:arrow6oclock z:0 tag:kHome6OclockArrowTag];
    
    */
    
    // Get arrow positions from User Defaults
        NSString *hierPath = [NSString stringWithFormat:@"%@/CCMenu:%d/CCMenuItemImage", NSStringFromClass([self class]), kIntroTopicButtonsMenuTag];
    CGPoint arrow90Position = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:hierPath andTag:kHomeTopic1ButtonTag];
    CGPoint arrow100Position = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:hierPath andTag:kHomeTopic1ButtonTag+2];
    CGPoint arrow120Position = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:hierPath andTag:kHomeTopic1ButtonTag+1];
   CGPoint arrow20Position = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:hierPath andTag:kHomeTopic1ButtonTag+3];



    
    
    CCMenuItemImage *reduceMenuItem = [CCMenuItemImage itemFromNormalImage:@"fossils.png"
                                                             selectedImage:@"fossils_bigger.png"
                                                             disabledImage:@"fossils.png"
                                                                    target:self 
                                                                  selector:@selector(topicHandler:)];
    
    reduceMenuItem.tag = kHomeTopic1ButtonTag;
    reduceMenuItem.position = arrow90Position;
    
    
    [reduceMenuItem runAction:[self makeGentleSwirlingAction:reduceMenuItem.position]];
    
    CCMenuItemImage *recycleMenuItem = [CCMenuItemImage itemFromNormalImage:@"rocks.png"
                                                             selectedImage:@"rocks_bigger.png"
                                                             disabledImage:@"rocks.png"
                                                                    target:self 
                                                                  selector:@selector(topicHandler:)];
    
    recycleMenuItem.tag = kHomeTopic1ButtonTag+2;
    recycleMenuItem.position = arrow100Position;

    [recycleMenuItem runAction:[self makeGentleSwirlingAction:recycleMenuItem.position]];

    CCMenuItemImage *reuseMenuItem = [CCMenuItemImage itemFromNormalImage:@"soils.png"
                                                              selectedImage:@"soils_bigger.png"
                                                              disabledImage:@"soils.ong"
                                                                     target:self 
                                                                   selector:@selector(topicHandler:)];
    
    reuseMenuItem.tag = kHomeTopic1ButtonTag +1;
    reuseMenuItem.position = arrow120Position;

    [reuseMenuItem runAction:[self makeGentleSwirlingAction:reuseMenuItem.position]];
    
    CCMenuItemImage *runoffMenuItem = [CCMenuItemImage itemFromNormalImage:@"minerals.png"
                                                            selectedImage:@"minerals_bigger.png"
                                                            disabledImage:@"minerals.png"
                                                                   target:self
                                                                 selector:@selector(topicHandler:)];
    
    runoffMenuItem.tag = kHomeTopic1ButtonTag +3;
    runoffMenuItem.position = arrow20Position;

    [runoffMenuItem runAction:[self makeGentleSwirlingAction:runoffMenuItem.position]];
    
    CCMenu *topicButtonMenu = [CCMenu menuWithItems:reduceMenuItem,recycleMenuItem, reuseMenuItem,runoffMenuItem,nil];
    
    NSString *topicButtonMenuPath = [NSString stringWithFormat:@"%@/CCMenu", NSStringFromClass([self class])];
    CGPoint topicButtonMenuPos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:topicButtonMenuPath andTag:kIntroTopicButtonsMenuTag];
    topicButtonMenu.position = topicButtonMenuPos;
    [self addChild:topicButtonMenu z:10 tag:kIntroTopicButtonsMenuTag];   // z = 10 to make sure it covers the text
    
    

    
    // Loading "Did you know"
    // TODO: why mutableCopy?
    CCArray *dYKTxts = [CCArray arrayWithCapacity:15];
    
        NSDictionary * dict = [[PlistManager sharedPlistManager] appDictionary];
    dYKTxts = [[dict objectForKey:@"infolines"] mutableCopy];
    [dYKTxts autorelease];
    self.didYouKnowTxts = dYKTxts;
    
    // Put the left/right arrow        
    CCMenuItemImage *right = [CCMenuItemImage itemFromNormalImage:@"info_right_arrow.png" 
                                                    selectedImage:@"info_right_arrow_selected.png"
                                                    disabledImage:@"info_right_arrow.png"
                                                           target:self
                                                         selector:@selector(goRightDidYouKnow:)];
    CCMenu *rightMenu = [CCMenu menuWithItems:right, nil];
    
    NSString *rMenuPath = [NSString stringWithFormat:@"%@/CCMenu", NSStringFromClass([self class])];
    CGPoint rmenu_pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:rMenuPath andTag:kHomeDYKRightMenuTag];
    rightMenu.position = rmenu_pos;
    [self addChild:rightMenu z:10 tag:kHomeDYKRightMenuTag];   // z = 10 to make sure it covers the text

    
    
    
    // Did you know?
    didYouKnowTxtLabel = [[CCLabelTTF alloc] initWithString:@"" dimensions:CGSizeMake(screenSize.width*0.75, 80) alignment:UITextAlignmentCenter fontName:@"ArialRoundedMTBold" fontSize:24];
    
    didYouKnowTxtLabel.color = ccc3(255, 255,255);
    didYouKnowTxtLabel.anchorPoint = ccp(-0.05,0);
    
    [self addChild:didYouKnowTxtLabel z:0 tag:kHomeDYKTxtTag];
    
    previousDidYouKnowTxtLabel = [[CCLabelTTF alloc] initWithString:@"" dimensions:CGSizeMake(screenSize.width*0.8, 80) alignment:UITextAlignmentCenter fontName:@"ArialRoundedMTBold" fontSize:24];
    previousDidYouKnowTxtLabel.color = ccc3(255, 255,255);
    previousDidYouKnowTxtLabel.anchorPoint = ccp(-0.05,0);
    
    [self addChild:previousDidYouKnowTxtLabel z:0 tag:kHomeDYKPrevTxtTag];
    
    NSString *dykMainTextPath = [NSString stringWithFormat:@"%@/CCLabelTTF", NSStringFromClass([self class])];
    didYouKnowMainTxtPosition = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:dykMainTextPath andTag:kHomeDYKTxtTag];
    didYouKnowMainTxtPosition.x = didYouKnowMainTxtPosition.x + 30;
    
    
    //CCLOG(@"Info text poistion %d %d",didYouKnowMainTxtPosition.x,didYouKnowMainTxtPosition.y);
    didYouKnowTxtLabel.position = didYouKnowMainTxtPosition;
    
    didYouKnowCount = 0;
    
    if ([self.didYouKnowTxts count] > 0) {
    //    [self.didYouKnowTxts shuffle];      // randomize the "Did you know?"
        
        [self slideInDidYouKnow:@"left" withDuration:0.5];
    }
    CCLOG(@"Added DYK text");
    
    return self;
}

-(void)onEnter {

    CCLOG(@"onEnter");
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
    CCLOG(@"Home Layer Touched (%f, %f)", loc.x, loc.y);
    
    return (NO || [editModeAbler ccTouchBegan:touch withEvent:event]);
    
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    [editModeAbler ccTouchMoved:touch withEvent:event];
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [editModeAbler ccTouchEnded:touch withEvent:event];

    CGPoint location = [touch locationInView: [touch view]];
    CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
    CCLOG(@"Object Moved to Layer Touched (%f, %f)", loc.x, loc.y);

}

-(void) play_dyk_scroll_left {
    // override this
    
        CCLOG(@"play sound empty");
}

-(void) play_dyk_scroll_right {
    
    CCLOG(@"play sound");
   PLAYSOUNDEFFECTWITHLOWERVOL(SCROLL_TEXT);
}

-(void)slideInDidYouKnow:(NSString *)direction withDuration:(float)time {
    
    
    CCLOG(@"slideInDidYouKnow");
    // CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    if (self.didYouKnowTxts != nil && [self.didYouKnowTxts count] > 0) {
        
        CCLOG(@"Did you know > 0");
        
        NSString *didYouKnowTxt = (NSString*)[self.didYouKnowTxts objectAtIndex:didYouKnowCount];
        
        CCLOG(@"Text to display %@",didYouKnowTxt);
               
        
        // 2nd slide the new text in.
        didYouKnowTxtLabel.string = didYouKnowTxt;
               
    }
    else
    {
                CCLOG(@"Did you know <= 0, cannot display");
    }
}


#pragma mark - Did you know
-(void) setPreviousDidYouKnowTxtLabel {
    NSString *str = [didYouKnowTxtLabel.string copy];
    previousDidYouKnowTxtLabel.string = str;
    [str release];
}

@end

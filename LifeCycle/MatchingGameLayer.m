//
//  HomeLayer.m
//  PlantHD
//
//  Created by Kelvin Chan on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MatchingGameLayer.h"
#import "Constants.h"
#import "ConfigManager.h"
#import "PlistManager.h"
#import "Gallery.h"
#import "GalleryManager.h"
#import "GalleryItem.h"

@implementation MatchingGameLayer

@synthesize audioImage;
@synthesize lastDisplayedPhoto,lastDisplayedPhotos;




-(void)dealloc {
    
    CCLOG(@"Releasing Matching Game Layer");
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IMAGE_GALLERY_DOWNLOADER_DIDFINISH_NOTIFICATIONNAME object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IMAGE_DOWNLOADER_DIDFINISH_NOTIFICATIONNAME object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IMAGE_INFO_DOWNLOADER_DIDFINISH_NOTIFICATIONNAME object:nil];
    
    dispatch_release(backgroundQueue);
    
    [lastDisplayedPhoto release];
    [lastDisplayedPhotos release];
    
    
    [super dealloc];
}

#pragma mark - Setup all the menus, buttons and arrows


-(void) addInfoAndAudioOnOffButton {
    CCMenuItemImage *info = [CCMenuItemImage itemFromNormalImage:@"mg_home.png"
                                                   selectedImage:@"mg_home_bigger.png"
                                                          target:self
                                                        selector:@selector(home)];
    info.position = ccp(0,0);
    info.tag = kMatchingGameInfoButtonTag;
    
    
    
    
    CCMenu *infoMenu = [CCMenu menuWithItems:info, nil];
    
    infoMenu.position = ccp(screenSize.width - info.boundingBox.size.width/2.0 - 10, 
                            screenSize.height - info.boundingBox.size.height/2.0 - 10);
    
    [self addChild:infoMenu z:10 tag:kMatchingGameInfoMenuTag];
    
          
    audioImage = [CCMenuItemImage itemFromNormalImage:@"mg_audio_on.png"
                                        selectedImage:@"mg_audio_off.png"
                                        disabledImage:@"mg_audio_off.png" 
                                               target:self
                                             selector:@selector(audio:)];
    
    if ([[FlowAndStateManager sharedFlowAndStateManager] isMusicON]) 
        [audioImage unselected];
    else 
        [audioImage selected];
    
    audioImage.position = ccp(0,0);
    audioImage.tag = kMatchingGameAudioButtonTag;
    
    CCMenu *audioMenu = [CCMenu menuWithItems:audioImage, nil];
    
    audioMenu.position = ccp(screenSize.width - info.boundingBox.size.width - info.boundingBox.size.width/2 - 10, 
                             screenSize.height - info.boundingBox.size.height/2.0 - 10);
    
    [self addChild:audioMenu z:10 tag:kMatchingGameAudioMenuTag];
    
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
    menu.tag = kMatchingGameMainMenuTag;
    NSString *menuHierPath = [NSString stringWithFormat:@"%@/CCMenu", NSStringFromClass([self class])];
    CGPoint pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:menuHierPath andTag:kMatchingGameMainMenuTag];
    
    //    NSLog(@"pos from user default %f, %f",pos.x, pos.y);
    
    menu.position = pos;
    [self addChild:menu z:0];
    
    
    // All life cycle buttons
    NSDictionary *basicInfoAboutCycles = [[PlistManager sharedPlistManager] matchingGameDictionary];
    
    NSString *hierPath = [NSString stringWithFormat:@"%@/CCMenu:%d/CCMenuItemImage", NSStringFromClass([self class]), kMatchingGameMainMenuTag];
    
    int topicCursor = 0;
   int numOfTopics = [FlowAndStateManager sharedFlowAndStateManager].numOfTopics;
    //int numOfTopics =0; // don't need this
    
    CCLOG(@"no. of topics %d", numOfTopics);
    
    for (NSString *topic in [[basicInfoAboutCycles allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {
        CCLOG(@"ky = %@", topic);
        
        NSString *imageName = [[basicInfoAboutCycles objectForKey:topic] objectForKey:@"intro_topic_image_name"];
        NSString *biggerImageName = [[basicInfoAboutCycles objectForKey:topic] objectForKey:@"intro_topic_bigger_image_name"];
        
        
        
        CCMenuItemImage *topicItemImage = [CCMenuItemImage itemFromNormalImage:imageName
                                                                 selectedImage:biggerImageName
                                                                 disabledImage:imageName
                                                                        target:self 
                                                                      selector:@selector(topicHandler:)];
        
        topicItemImage.tag = kMatchingGameTopic1ButtonTag + topicCursor;
        CGPoint pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:hierPath andTag:topicItemImage.tag];
        topicItemImage.position = pos;
        
        
        
        [menu addChild:topicItemImage];
        
        if (topicCursor == numOfTopics - 1)
            break;
        
        topicCursor++;
    }
    
    
    photoFrame = [CCSprite spriteWithFile:@"photo_frame.png"];
    
    photoFrame.tag = kMatchingGamePhotoFrameTag;
    NSString *playHierPath = [NSString stringWithFormat:@"%@/CCSprite", NSStringFromClass([self class])];
    CGPoint playPos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:playHierPath andTag:kMatchingGamePhotoFrameTag];
    photoFrame.position = playPos;
    [self addChild:photoFrame z:0 tag:kMatchingGamePhotoFrameTag];
    
    
    photo = [CCSprite spriteWithFile:@"test.png"];
    
    photo.tag = kMatchingGamePhotoTag;
    playPos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:playHierPath andTag:kMatchingGamePhotoTag];
    photo.position = playPos;
    [self addChild:photo z:2 tag:kMatchingGamePhotoTag];
    
    
    CCSprite *gameHeader = [CCSprite spriteWithFile:@"matching_game_header.png"];
    
    gameHeader.tag = kMatchingGameHeaderTag;
    playPos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:playHierPath andTag:kMatchingGameHeaderTag];
    gameHeader.position = playPos;
    [self addChild:gameHeader z:0 tag:kMatchingGameHeaderTag];
    
    
}

-(void) removeTopicMenus {
    // Remove the original topic menu to make way for the game
    CCMenu *menu = (CCMenu*) [self getChildByTag:kMatchingGameMainMenuTag];
    [menu removeFromParentAndCleanup:YES];
}

-(void) setUpMenus {
    
    [self addTopicMenus];
    
    [self addInfoAndAudioOnOffButton];
    
    
    
}



#pragma mark - Menu Item pressed

-(void) next :(id) sender{
    // CCLOG(@"Info pressed");
    
    PLAYSOUNDEFFECT(Home_CLICK);

    
    if (totalQuestions == kMatchingGameTotalQuestions)
    {
        
        NSLog(@"Total question is 10, display results");   
        
        CCSprite *ss = (CCSprite*) [self getChildByTag:kMatchingGameWrongTag];
        ss.visible = NO;
        
        ss = (CCSprite*) [self getChildByTag:kMatchingGameCorrectTag];
        ss.visible = NO;

        
        ss = (CCSprite*) [self getChildByTag:kMatchingGameNextTag];
        ss.visible = YES;
        
        photo.visible = FALSE;
        
        
        
        CCMenu *yesNoMenu = (CCMenu*) [self getChildByTag:kMatchingGameTriviaMenuTag];
       // [yesNoMenu setIsTouchEnabled:FALSE];
        
        
        CCMenuItemImage  *button = (CCMenuItemImage*) [yesNoMenu getChildByTag:kMatchingGameTriviaYesButton];
        [button setIsEnabled:NO];
        button = (CCMenuItemImage*)  [yesNoMenu getChildByTag:kMatchingGameTriviaNoButton];
        [button setIsEnabled:NO];
        
        /*
        ss = (CCSprite*) [self getChildByTag:kMatchingGameAnswerStripTag];
        ss.visible = NO;
        
        ss = (CCSprite*) [self getChildByTag:kMatchingGameAnswerLabelTag];
        ss.visible = NO;
        */
       

        
        [self showResult];
      
    }
    else {
        
        if (gameJustEnded) {
            
            NSLog(@"Game just end reset stage");
            gameJustEnded =FALSE;
            
          // remove all coins
            photo.visible = true;
            
            CCMenu *yesNoMenu = (CCMenu*) [self getChildByTag:kMatchingGameTriviaMenuTag];
            //[yesNoMenu setIsTouchEnabled:TRUE];

            
            
            CCMenuItemImage  *button = (CCMenuItemImage*) [yesNoMenu getChildByTag:kMatchingGameTriviaYesButton];
                    [button setIsEnabled:YES];
            button = (CCMenuItemImage*)  [yesNoMenu getChildByTag:kMatchingGameTriviaNoButton];
        [button setIsEnabled:YES];
            
            CCLabelTTF *result = (CCLabelTTF*) [self getChildByTag:kMatchingGameResultLabelTag];
            result.string = @"";
            /*
            ss = (CCSprite*) [self getChildByTag:kMatchingGameAnswerStripTag];
            ss.visible = TRUE;
            
            ss = (CCSprite*) [self getChildByTag:kMatchingGameAnswerLabelTag];
            ss.visible = TRUE;
            */
            
            CCSprite *photoShadow =  (CCSprite*) [self getChildByTag:kMatchingGamePhotoShadow];
            photoShadow.visible = TRUE;
            

            
           CCLabelTTF *resultLabel = (CCLabelTTF*) [self getChildByTag:kMatchingGameResultLabelTag];
            resultLabel.visible = TRUE;
            

            debugLog(@"Remove monkey");
            [self removeChildByTag:kMatchingGameWinnerBadgeTag cleanup:TRUE]; 
            
            for (int i =0; i< [coinMap count]; i++) {
                CCSprite *coin = [coinMap objectAtIndex:i];
                [self removeChild:coin cleanup:YES];
            }
            
        }

    CCSprite *s = (CCSprite*) [self getChildByTag:kMatchingGameCorrectTag];
    s.visible = NO;

    
    CCSprite *sx = (CCSprite*) [self getChildByTag:kMatchingGameWrongTag];
    sx.visible = NO;
    
    CCSprite *sy = (CCSprite*) [self getChildByTag:kMatchingGameNextTag];
    sy.visible = NO;

        
        CCMenu *yesNoMenu = (CCMenu*) [self getChildByTag:kMatchingGameTriviaMenuTag];
        // [yesNoMenu setIsTouchEnabled:FALSE];
        
        
        CCMenuItemImage  *button = (CCMenuItemImage*) [yesNoMenu getChildByTag:kMatchingGameTriviaYesButton];
        [button setIsEnabled:YES];
        button = (CCMenuItemImage*)  [yesNoMenu getChildByTag:kMatchingGameTriviaNoButton];
        [button setIsEnabled:YES];
        


    [self displayNextPhoto];
    }
    
    
}


-(void) home {
    // CCLOG(@"Info pressed");
    
    PLAYSOUNDEFFECT(Home_CLICK);
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kHomeScene withTranstion:kCCTransitionPageFlip];
    
    
}

-(void) curriculum {
    PLAYSOUNDEFFECT(Home_CLICK);
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kCurrScene withTranstion:kCCTransitionPageFlip];
}



-(void) topicHandler:(CCNode*)sender {
    PLAYSOUNDEFFECT(Home_CLICK_1);
    
    CCLOG(@"Topic %d clicked",sender.tag);
    
    if (sender.tag >= 135   && sender.tag <=136)
    {
        
        // check if correct or not
        
           [self checkAnswer:sender.tag];
        

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
        [[FlowAndStateManager sharedFlowAndStateManager] playBackgroundTrack:BACKGROUND_TRACK_MATCHING_GAME];
    }        
    
}

#pragma mark - Lifecycle

- (id)init
{
    CCLOG(@"init");
    self = [super init];
    if (self) {
        
         srandom(time(NULL));
        GalleryManager *gman = [GalleryManager getInstance];
        [gman syncAllGalleries];
        
        self.lastDisplayedPhoto = @"";
        lastDisplayedPhotos = [[NSMutableArray alloc] init];
        
        screenSize = [CCDirector sharedDirector].winSize;
        
        coinMap = [[NSMutableArray alloc] init];
        
        CCSprite *backgroundImage;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            backgroundImage = [CCSprite spriteWithFile:@"matching_game_background.png"];
        }
        else {
            backgroundImage = nil;
        }
        
        [backgroundImage setPosition:ccp(screenSize.width/2, screenSize.height/2)];
        [self addChild:backgroundImage z:0 tag:kMatchingGameBackgroundTag];
        
      
        NSMutableArray *photos =  [gman.itemMap objectForKey:GALLERIES_PHOTO_FOR_MATCHING_GAME_ITEM_MAP];
        if (photos.count > 0)
        {
            
            lastDisplayedPhotosArraySize = photos.count/2;
        }
        else {
            lastDisplayedPhotosArraySize =0;
        }
        
        CCLOG(@"Setup Menus");
        
        [self setUpMenus];
        
        if ([FlowAndStateManager sharedFlowAndStateManager].isMusicON)
            [[FlowAndStateManager sharedFlowAndStateManager] playBackgroundTrack:BACKGROUND_TRACK_MATCHING_GAME];
        
        
        
        slImageDownloaders = [[NSMutableArray alloc] initWithCapacity:10];
        slImageInfoDownloaders = [[NSMutableArray alloc] initWithCapacity:10];
        
        // observe the "Image Gallery Downloader DidFinish notification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(slImageGalleryDownloaderDidFinish:)
                                                     name:IMAGE_GALLERY_DOWNLOADER_DIDFINISH_NOTIFICATIONNAME 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(slImageDownloaderDidFinish:) 
                                                     name:IMAGE_DOWNLOADER_DIDFINISH_NOTIFICATIONNAME 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(slImageInfoDownloaderDidFinish:) 
                                                     name:IMAGE_INFO_DOWNLOADER_DIDFINISH_NOTIFICATIONNAME
                                                   object:nil];
        
        backgroundQueue = dispatch_queue_create("com.appilly.lifecycle.bgqueue", NULL);
        
        
        int numOfTopics = [FlowAndStateManager sharedFlowAndStateManager].numOfTopics;
        
        //numOfTopics = 2;
        
        for (int i=1; i<= numOfTopics; i++) {
            
            
            SLImageGalleryDownloader  *imgGalleryDownloader = [[SLImageGalleryDownloader alloc] init];
            NSDictionary *dict = [[PlistManager sharedPlistManager] getDictionaryForTopic:i+1];
            
            imgGalleryDownloader.galleryId = [dict objectForKey:@"gallery_id"];
            
            CCLOG(@"Intialize the downloader %d for gallery id %@",i,imgGalleryDownloader.galleryId);
            //[imgGalleryDownloader fetchImageURLs];
            
        }
    
      
        
        CCLOG(@"Get Sprite Positions");        
        NSString *path = [NSString stringWithFormat:@"%@/CCMenu", NSStringFromClass([self class])];
        
        nextIconPosition = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kMatchingGameNextTag];
        
        path = [NSString stringWithFormat:@"%@/CCSprite", NSStringFromClass([self class])];
        correctIconPosition = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kMatchingGameCorrectTag];
        wrongIconPosition = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kMatchingGameWrongTag];
        

        CCLOG(@"Add Correct Sprite");
        
        // Display correct icon
        CCSprite *correct = [CCSprite spriteWithFile:@"correct.png"];
        correct.position = correctIconPosition;
        correct.visible = NO;
        correct.tag = kMatchingGameCorrectTag;
        [self addChild:correct z:100];  // always on very top
        
        CCLOG(@"Add wrong Sprite");
        
        CCSprite *wrong = [CCSprite spriteWithFile:@"wrong.png"];
        wrong.position = wrongIconPosition;
        wrong.visible = NO;
        wrong.tag = kMatchingGameWrongTag;
       // [self addChild:wrong z:-1];          // always at very bottom
        [self addChild:wrong z:10];          // always at very bottom
        
        CCMenuItemImage *next = [CCMenuItemImage itemFromNormalImage:@"next.png" 
                                                       selectedImage:@"next.png"
                                                       disabledImage:@"next.png"
                                                              target:self
                                                            selector:@selector(next:)];
        
        CCMenu *nextMenu = [CCMenu menuWithItems:next, nil];
        nextMenu.tag = kMatchingGameNextTag;
        
        nextMenu.position = nextIconPosition;
        //    nextMenu.position = QUIZ_NEXT_ICON_POSITION;
        nextMenu.visible = NO;
        
        [self addChild:nextMenu];

     
        


        CCLabelTTF *resultLabel = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(485, 300) alignment:UITextAlignmentLeft lineBreakMode:UILineBreakModeWordWrap fontName:@"ArialMT" fontSize:42];
        
        resultLabel.color = ccc3(255, 255,255);
        resultLabel.position = ccp(screenSize.width/2 - 30, screenSize.height/2 -150);
        
        [self addChild:resultLabel z:1 tag:kMatchingGameResultLabelTag];
        
        
        
 
        
                
        path = [NSString stringWithFormat:@"%@/CCSprite", NSStringFromClass([self class])];
        CGPoint answerStripPos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kMatchingGameAnswerStripTag];
        CGPoint photoShadowPos= [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kMatchingGamePhotoShadow];
        
        
        CCLOG(@"Add Correct Sprite");
        
        // Display answer strip
        CCSprite *answerStrip = [CCSprite spriteWithFile:@"matching_game_strip.png"];
        answerStrip.position = answerStripPos;
        answerStrip.visible = YES;
        answerStrip.tag = kMatchingGameAnswerStripTag;
        [self addChild:answerStrip z:10]; 

        
        // Display photo shadow
        CCSprite *photoShadow = [CCSprite spriteWithFile:@"photo_shadow.png"];
        photoShadow.position = photoShadowPos;
        photoShadow.visible = YES;
        photoShadow.tag = kMatchingGamePhotoShadow;
        [self addChild:photoShadow z:1]; 
        
        
        path = [NSString stringWithFormat:@"%@/CCLabelTTF", NSStringFromClass([self class])];
        CGPoint triviaAnswerLabelPos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kMatchingGameAnswerLabelTag];
        CGPoint triviaQuesLabelPos= [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kMatchingGameQuestionLabelTag];


        CCLabelTTF *answerLabel = [[CCLabelTTF alloc] initWithString:@"Answer..." dimensions:CGSizeMake(screenSize.width*0.9, 80) alignment:UITextAlignmentCenter fontName:@"ArialRoundedMTBold" fontSize:24];
        
        answerLabel.color = ccc3(255, 255,255);
        answerLabel.anchorPoint = ccp(-0.05,0);
        answerLabel.position = triviaAnswerLabelPos;
        
        [self addChild:answerLabel z:10 tag:kMatchingGameAnswerLabelTag];

        
        
        CCLabelTTF *questionLabel = [[CCLabelTTF alloc] initWithString:@"Question..." dimensions:CGSizeMake(screenSize.width*0.6, 80) alignment:UITextAlignmentCenter fontName:@"ArialRoundedMTBold" fontSize:22];
        
        questionLabel.color = ccc3(0, 0,0);
        questionLabel.anchorPoint = ccp(-0.05,0);
        questionLabel.position = triviaQuesLabelPos;
        
        [self addChild:questionLabel z:10 tag:kMatchingGameQuestionLabelTag];
        
        
        
        path = [NSString stringWithFormat:@"%@/CCMenu", NSStringFromClass([self class])];
        CGPoint triviaMenu = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kMatchingGameTriviaMenuTag];
        
        
         NSString *hierPath = [NSString stringWithFormat:@"%@/CCMenu:%d/CCMenuItemImage", NSStringFromClass([self class]), kMatchingGameTriviaMenuTag];
        
        CGPoint triviaYesButton = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:hierPath andTag:kMatchingGameTriviaYesButton];
        CGPoint triviaNoButton = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:hierPath andTag:kMatchingGameTriviaNoButton];
        
        
        
        CCMenuItemImage *yesButton = [CCMenuItemImage itemFromNormalImage:@"yes_button.png" 
                                                       selectedImage:@"yes_button_bigger.png"
                                                            disabledImage:@"yes_button_disabled.png"
                                                              target:self
                                                            selector:@selector(topicHandler:)];
        yesButton.position =triviaYesButton;
        yesButton.tag = kMatchingGameTriviaYesButton;

        
        
        CCMenuItemImage *noButton = [CCMenuItemImage itemFromNormalImage:@"no_button.png" 
                                                       selectedImage:@"no_button_bigger.png"
                                                                          disabledImage:@"no_button_disabled.png"
                                                              target:self
                                                            selector:@selector(topicHandler:)];
        //noButton.position = ccp(0,0);
         noButton.position = triviaNoButton;
        noButton.tag = kMatchingGameTriviaNoButton;
        
        
          
                
        CCMenu *yesNoMenu = [CCMenu menuWithItems:yesButton,noButton, nil];
        
        yesNoMenu.position = triviaMenu;        
        [self addChild:yesNoMenu z:10 tag:kMatchingGameTriviaMenuTag];

    }
    
    
    
    
    
    return self;
}


-(void) checkAnswer :(int) answer {
    CCLOG(@"selected %d %d", answer , photoTopicId);
    
    bool choosenAnswer= true;
    if (answer == kMatchingGameTriviaNoButton)
    {
        choosenAnswer = false;
    }


    // Check the answer
    if (choosenAnswer == correctAnswer) {

        CCLOG(@"Correct!");
        
        
            CCLabelTTF *questionAnswerLabel =  (CCLabelTTF*) [self getChildByTag:kMatchingGameAnswerLabelTag];
    questionAnswerLabel.visible = TRUE;
        
        
//        CCSprite *photoShadow =  (CCSprite*) [self getChildByTag:kMatchingGamePhotoShadow];
  //          photoShadow.visible = FALSE;

        
        if (!self.audioImage.isSelected) {
            // PLAYSOUNDEFFECT(GREAT_JOB);
            [self play_great_job];
        }
        
        CCSprite *s = (CCSprite*) [self getChildByTag:kMatchingGameCorrectTag];
        s.visible = YES;
        [s stopAllActions];
        
        CCAction *shake = [CCSequence actions: 
                           [CCMoveTo actionWithDuration:0.1 position:ccp(correctIconPosition.x, correctIconPosition.y+10)],
                           [CCMoveTo actionWithDuration:0.1 position:ccp(correctIconPosition.x, correctIconPosition.y-10)],
                           [CCMoveTo actionWithDuration:0.1 position:correctIconPosition],
                           nil];    
        
        
        [s runAction:shake];
        
        CCSprite *ss = (CCSprite*) [self getChildByTag:kMatchingGameWrongTag];
        ss.visible = NO;
        
        CCSprite *sss = (CCSprite*) [self getChildByTag:kMatchingGameNextTag];
        sss.visible = YES;
        

        if (alreadyAnswered == NO) {
            
            NSLog(@"Display another coin");
            currentCorrectCount++;  
            
            // animate coin across the top
            // PLAYSOUNDEFFECT(KA_CHING);
            
            
            int secRowHeightDelta = 0;
             int relativeCoinIndex = currentCorrectCount;
            if (currentCorrectCount > 5)
            {
                secRowHeightDelta  = - 120;
                relativeCoinIndex  = currentCorrectCount - 5;
            }
            CCSprite *coin = [CCSprite spriteWithFile:@"coin.png"];
            coin.position = ccp(screenSize.width + 200.0, screenSize.height-coin.boundingBox.size.height*0.5);
            
            id action = [CCSequence actions:
                         [CCMoveBy actionWithDuration:0.5 position:CGPointZero],
                         [CCSpawn actions:
                          [CCEaseElasticOut actionWithAction:
                           [CCMoveTo actionWithDuration:1.5 position:ccp(0.8*coin.boundingBox.size.width/2.0 + relativeCoinIndex*20, secRowHeightDelta + screenSize.height-coin.boundingBox.size.height/2.0)]
                           ],
                          [CCCallBlock actionWithBlock:^{ if (!self.audioImage.isSelected) [self play_kaching]; }],
                          nil],
                         nil];
            
            [coin runAction:action];
            [self addChild:coin z:0 tag:kMatchingGameCoinTag];
            [coinMap addObject:coin];   // store referecence
            
        }
        
        
        CCMenu *yesNoMenu = (CCMenu*) [self getChildByTag:kMatchingGameTriviaMenuTag];
        // [yesNoMenu setIsTouchEnabled:FALSE];
        
        
        CCMenuItemImage  *button = (CCMenuItemImage*) [yesNoMenu getChildByTag:kMatchingGameTriviaYesButton];
        [button setIsEnabled:NO];
        button = (CCMenuItemImage*)  [yesNoMenu getChildByTag:kMatchingGameTriviaNoButton];
        [button setIsEnabled:NO];
        

        
    }
    else {
        CCLOG(@"Wrong!");
        
        if (!self.audioImage.isSelected) {
            // PLAYSOUNDEFFECT(OOPS);
            [self play_oops];
        }
        
        CCSprite *s = (CCSprite*) [self getChildByTag:kMatchingGameCorrectTag];
        s.visible = NO;
        
        CCSprite *ss = (CCSprite*) [self getChildByTag:kMatchingGameWrongTag];
        ss.visible = YES;
        [ss stopAllActions];
        
        CCAction *shake = [CCSequence actions:
                           [CCMoveTo actionWithDuration:0.1 position:ccp(wrongIconPosition.x+10, wrongIconPosition.y)],
                           [CCMoveTo actionWithDuration:0.1 position:ccp(wrongIconPosition.x-10, wrongIconPosition.y)],
                           [CCMoveTo actionWithDuration:0.1 position:wrongIconPosition],
                           nil];
        
        [ss runAction:shake];
        
        CCLOG(@"Run Action");
        
    }
    
    alreadyAnswered = YES;
}


-(void)onEnter {
    
    CCLOG(@"onEnter");
    [super onEnter];
    
    editModeAbler = [EditModeAbler node];
    [editModeAbler retain];
    editModeAbler.delegateLayer = self;
    
    [editModeAbler activate];
    
    gameJustEnded = FALSE;
    [self displayNextPhoto];
    
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

-(void)showResult{
    
    NSString *result;
    NSString *badgeImage;
    CCSprite *photoShadow =  (CCSprite*) [self getChildByTag:kMatchingGamePhotoShadow];
    photoShadow.visible = FALSE;
    

    if (currentCorrectCount == kMatchingGameTotalQuestions)
    {
        

        
        // testing only
//        currentCorrectCount = 10;
  //      totalQuestions  = 10;
        result = [NSString stringWithFormat:@"Great Job! You got %d out of %d right", currentCorrectCount, totalQuestions];
        badgeImage = @"winner_badge.png";
        
            }
    else
    {
        result = [NSString stringWithFormat:@"You got %d out %d right. Continue playing...", currentCorrectCount, totalQuestions];
        badgeImage = @"second_place.png";
    }
    
    
    
    CCSprite *badge = [CCSprite spriteWithFile:badgeImage];
    badge.position = ccp(screenSize.width + 200.0, screenSize.height-badge.boundingBox.size.height*0.5);
    
    id action = [CCSequence actions:
                 [CCMoveBy actionWithDuration:0.5 position:CGPointZero],
                 [CCSpawn actions:
                  [CCEaseElasticOut actionWithAction:
                   [CCMoveTo actionWithDuration:1.5 position:ccp((screenSize.width-badge.boundingBox.size.width)/2 + 160, (screenSize.height)/2.0 +150)]
                   ],
                  [CCCallBlock actionWithBlock:^{ if (!self.audioImage.isSelected) [self play_kaching]; }],
                  nil],
                 nil];
    
    [badge runAction:action];
    [self addChild:badge z:10 tag:kMatchingGameWinnerBadgeTag];
    

    CCLabelTTF *resultLabel =  [self getChildByTag:kMatchingGameResultLabelTag];
    

    CCLabelTTF *questionAnswerLabel =  (CCLabelTTF*) [self getChildByTag:kMatchingGameAnswerLabelTag];
        CCLabelTTF *questionLabel =  (CCLabelTTF*) [self getChildByTag:kMatchingGameQuestionLabelTag];
    questionLabel.string = @"";
    questionAnswerLabel.visible = FALSE;

    
   resultLabel.string = result;
    resultLabel.visible = true;
   
    
    gameJustEnded = TRUE;
    
    // reset
    totalQuestions =0;
    currentCorrectCount =0;
    
}



-(void) displayNextPhoto
{

    GalleryManager  *gman = [GalleryManager getInstance];
    NSMutableArray *photos =  [gman.itemMap objectForKey:GALLERIES_PHOTO_FOR_MATCHING_GAME_ITEM_MAP];

    
    int photoIndex = arc4random() % photos.count;
    
    debugLog(@"total %d , choosen %d",photos.count, photoIndex);

    GalleryItem *item = [photos objectAtIndex:photoIndex];
    
    
    alreadyAnswered = NO;
    
    debugLog(@"gallery id for topic %@",item.galleryUid);
    
    if ([item.correctAnswer isEqualToString:@"1"])
        {
            correctAnswer = TRUE;
        }
    else {
            correctAnswer = FALSE;
    }

    
    CCLabelTTF *questionLabel =  (CCLabelTTF*) [self getChildByTag:kMatchingGameQuestionLabelTag];
    CCLabelTTF *questionAnswerLabel =  (CCLabelTTF*) [self getChildByTag:kMatchingGameAnswerLabelTag];
    questionAnswerLabel.string =item.description;
    questionLabel.string = item.question;
    questionAnswerLabel.visible = FALSE;
    
    
    NSString *photoImage = item.fileName;
    
    
    // check is the one displayed already
    if ([photoImage isEqualToString:self.lastDisplayedPhoto])
    {
        CCLOG(@"Duplicate Photo , get another one" );        
        [self displayNextPhoto];
        return;

    }

    bool isPhotoInLastDisplayedPhotos = FALSE;
    for (int i=0; i<[lastDisplayedPhotos count]; i++) {
        
        NSString *fileName = [lastDisplayedPhotos objectAtIndex:i];
        if ([fileName isEqualToString:photoImage])
        {
            debugLog(@"%@ has been displayed in last %d, skip it",fileName,lastDisplayedPhotosArraySize);
            isPhotoInLastDisplayedPhotos = TRUE;
            break;
        }
        
    }

    if (isPhotoInLastDisplayedPhotos)
    {
        [self displayNextPhoto];
        return;
    }
    
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", docDir, photoImage];
    
    
    BOOL destFileExits = [[NSFileManager defaultManager]  fileExistsAtPath:filePath]; 
    
    if (!destFileExits)
    {
        CCLOG(@"Photo not found locally, skip" );        
        [self displayNextPhoto];
        return;
        
    }

    totalQuestions++; // increment
    // set it for next time
    self.lastDisplayedPhoto = photoImage;
    
    CCLOG(@"photo to display %@",photoImage);


    UIImage *image = [UIImage imageWithContentsOfFile:filePath];


    CCTexture2D *newTexture=[[[CCTexture2D alloc]initWithImage:image]autorelease];
    
    [photo setTexture:newTexture];
    
    [photo setTextureRect:CGRectMake(0,0, newTexture.contentSize.width, newTexture.contentSize.height)];
    
   [self resizeTo:photo toSize:CGSizeMake(520, 330)];
     
    // add to last photo
    [lastDisplayedPhotos addObject:photoImage];
    if ([lastDisplayedPhotos count] > lastDisplayedPhotosArraySize)
    {
        debugLog(@"Trim the first element from the array as it exceeded the last array size");
        [lastDisplayedPhotos removeObjectAtIndex:0];
    }

}




-(void)resizeTo:(CCSprite*) sprite toSize:(CGSize) theSize
{

    CCLOG(@"Resize the sprite, the displayed photo");
    CGFloat newWidth = theSize.width;
    CGFloat newHeight = theSize.height;
    
    
    float startWidth = sprite.contentSize.width;
    float startHeight = sprite.contentSize.height;
    
    CCLOG(@"%f %f content width and height",startWidth,startHeight);
    
    float newScaleX = newWidth/startWidth;
    float newScaleY = newHeight/startHeight;
    
   CCLOG(@"%f %f scale width and height",newScaleX,newScaleY);
    
    sprite.scaleX = newScaleX;
    sprite.scaleY = newScaleY;
    
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



-(NSString*) getGalleryIdForTopic:(int) topicId
{
    NSDictionary *dict = [[PlistManager sharedPlistManager] getDictionaryForTopic:topicId];
    return  [dict objectForKey:@"gallery_id"];
    
}






-(void) play_great_job {
    PLAYSOUNDEFFECTWITHLOWERVOL(GREAT_JOB);
}

-(void) play_oops {
    PLAYSOUNDEFFECTWITHLOWERVOL(OOPS);
}

-(void) play_kaching {
    PLAYSOUNDEFFECTWITHLOWERVOL(KA_CHING);
}

@end

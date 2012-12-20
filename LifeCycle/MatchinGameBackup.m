//
//  HomeLayer.m
//  PlantHD
//
//  Created by Kelvin Chan on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MatchinGameBackup.h"
#import "Constants.h"
#import "ConfigManager.h"
#import "PlistManager.h"


@implementation MatchinGameBackup

@synthesize audioImage;
@synthesize lastDisplayedPhoto;




-(void)dealloc {
    
    CCLOG(@"Releasing Matching Game Layer");
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IMAGE_GALLERY_DOWNLOADER_DIDFINISH_NOTIFICATIONNAME object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IMAGE_DOWNLOADER_DIDFINISH_NOTIFICATIONNAME object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IMAGE_INFO_DOWNLOADER_DIDFINISH_NOTIFICATIONNAME object:nil];
    
    dispatch_release(backgroundQueue);
    
    
    
    [super dealloc];
}

#pragma mark - Setup all the menus, buttons and arrows


-(void) addInfoAndAudioOnOffButton {
    CCMenuItemImage *info = [CCMenuItemImage itemFromNormalImage:@"home.png" 
                                                   selectedImage:@"home_bigger.png"
                                                          target:self
                                                        selector:@selector(home)];
    info.position = ccp(0,0);
    info.tag = kMatchingGameInfoButtonTag;
    
    
    
    
    CCMenu *infoMenu = [CCMenu menuWithItems:info, nil];
    
    infoMenu.position = ccp(screenSize.width - info.boundingBox.size.width/2.0 - 10, 
                            screenSize.height - info.boundingBox.size.height/2.0 - 10);
    
    [self addChild:infoMenu z:10 tag:kMatchingGameInfoMenuTag];
    
    
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
    audioImage.tag = kMatchingGameAudioButtonTag;
    
    CCMenu *audioMenu = [CCMenu menuWithItems:audioImage, nil];
    
    audioMenu.position = ccp(screenSize.width - info.boundingBox.size.width - info.boundingBox.size.width - audioImage.boundingBox.size.width/2.0 - 10, 
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
    [self addChild:photo z:0 tag:kMatchingGamePhotoTag];
    
    
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
        
        [self showResult];
        
    }
    else {
        
        if (gameJustEnded) {
            
            NSLog(@"Game just end reset stage");
            gameJustEnded =FALSE;
            
            // remove all coins
            photo.visible = true;
            
            CCLabelTTF *resultLabel =  [self getChildByTag:kMatchingGameResultLabelTag];
            resultLabel.visible = FALSE;
            
            
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
    
    if (sender.tag >= 113 && sender.tag <=119)
    {
        
        // check if correct or not
        
        // map tag to answer
        int answer = sender.tag - 112;
        [self checkAnswer:answer];
        
        
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
        
        self.lastDisplayedPhoto = @"";
        
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
        
        
        
        CCLOG(@"Setup Menus");
        
        [self setUpMenus];
        
        if ([FlowAndStateManager sharedFlowAndStateManager].isMusicON)
            [[FlowAndStateManager sharedFlowAndStateManager] playBackgroundTrack:BACKGROUND_TRACK_MENUPAGE];
        
        
        
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
            
            imgGalleryDownloader.galleryId = [dict objectForKey:@"flickrphotos"];
            
            CCLOG(@"Intialize the downloader %d for gallery id %@",i,imgGalleryDownloader.galleryId);
            [imgGalleryDownloader fetchImageURLs];
            
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
        
        
        
        
        
        CCLabelTTF *resultLabel = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(485, 300) alignment:UITextAlignmentLeft lineBreakMode:UILineBreakModeWordWrap fontName:@"ArialRoundedMTBold" fontSize:42];
        
        resultLabel.color = ccc3(0, 0, 0);
        resultLabel.position = ccp(screenSize.width/2 - 30, screenSize.height/2 -150);
        
        [self addChild:resultLabel z:1 tag:kMatchingGameResultLabelTag];
        
    }
    
    
    
    
    
    return self;
}


-(void) checkAnswer :(int) answer {
    CCLOG(@"selected %d %d", answer , photoTopicId);
    // Check the answer
    if (answer == photoTopicId) {
        CCLOG(@"Correct!");
        
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
    [self addChild:badge z:0 tag:kMatchingGameWinnerBadgeTag];
    
    
    CCLabelTTF *resultLabel =  [self getChildByTag:kMatchingGameResultLabelTag];
    
    
    
    resultLabel.string = result;
    resultLabel.visible = true;
    
    
    gameJustEnded = TRUE;
    
    // reset
    totalQuestions =0;
    currentCorrectCount =0;
    
}


-(void) displayNextPhoto
{
    
    int numOfTopics = [FlowAndStateManager sharedFlowAndStateManager].numOfTopics; 
    photoTopicId = arc4random() % numOfTopics + 2; // add 1 since index starts from 2
    
    alreadyAnswered = NO;
    
    NSString *galleryId = [self getGalleryIdForTopic:photoTopicId];
    NSArray *photoIdArray = [self retrievePhotoIdArrayFromDoc:galleryId];
    
    // reset the topic to -1 as the index for buttons start with 1
    photoTopicId = photoTopicId -1;
    
    
    CCLOG(@"Choosen topic id %d", photoTopicId);
    
    if (photoIdArray == nil || photoIdArray.count <=0)
    {
        CCLOG(@"No photo avaiable for that galllery");
        [self displayNextPhoto];
        return;
    }
    
    totalQuestions++; // increment
    int photoIndex = arc4random() % photoIdArray.count;
    
    
    
    NSString *photoImage = [NSString stringWithFormat:@"%@.jpg",[photoIdArray objectAtIndex:photoIndex]];
    
    if ([photoImage isEqualToString:self.lastDisplayedPhoto])
    {
        CCLOG(@"Duplicate Photo , get another one" );        
        [self displayNextPhoto];
        return;
        
    }
    
    // set it for next time
    self.lastDisplayedPhoto = photoImage;
    
    CCLOG(@"photo to display %@",photoImage);
    
    /*
     
     // try to see if there's a cache hit b4 doing "disk I/O"
     CCTexture2D *t = [[CCTextureCache sharedTextureCache] textureForKey:photoImage];
     if (t != nil) {
     
     CCLOG(@"Sprite Texture available");
     [photo setTexture:t];
     
     }
     else {
     
     CCLOG(@"Load from disk");
     NSData *imageData = [self retrieveImageDataFromDoc:photoImage];
     
     if (imageData != nil) {
     
     CCLOG(@"found image data");
     UIImage *image = [UIImage imageWithData:imageData];
     [[CCTextureCache sharedTextureCache] addCGImage:[image CGImage] forKey:photoImage];
     t = [[CCTextureCache sharedTextureCache] textureForKey:photoImage];
     [photo setTexture:t];
     
     
     
     // CGSize size = [self retrieveImageSizeFromDoc:photoImage];
     
     // CCLOG(@"found size %d %d",size.height,size.width);
     [photo setTextureRect:CGRectMake(0, 0, image.size.width, image.size.height)];        
     
     
     //[photo setTextureRect:CGRectMake(0, 0, 540,400)];        
     
     CCLOG(@"Make the texture small");
     //     [photo setTextureRect:CGRectMake(0, 0, 540,400)];        
     
     
     }
     }    
     
     */
    
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", docDir, photoImage];
    
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    
    
    CCTexture2D *newTexture=[[[CCTexture2D alloc]initWithImage:image]autorelease];
    
    [photo setTexture:newTexture];
    
    [photo setTextureRect:CGRectMake(0,0, newTexture.contentSize.width, newTexture.contentSize.height)];
    
    [self resizeTo:photo toSize:CGSizeMake(540, 400)];
    
    
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


#pragma mark - Image IO Functions

-(BOOL)saveImageFoundInDoc:(NSString*)imageName {
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString* imgFilePath = [NSString stringWithFormat:@"%@/%@", documentsPath, imageName];
    //    CCLOG(@"imgFilePath = %@", imgFilePath);
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:imgFilePath])
        return YES;
    else 
        return NO;
}

-(void)saveImageDataToDoc:(NSData*)data withImageName:(NSString*)imageName {
    
    
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", docDir, imageName];
    CCLOG(@"Save image to %@",filePath);
    [data writeToFile:filePath atomically:YES];
}

-(NSData *)retrieveImageDataFromDoc:(NSString*)imageName {
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", docDir, imageName];
    
    return [NSData dataWithContentsOfFile:filePath];
}

+(void) savePhotoIdArrayToDoc:(NSArray*)aPhotoIdArray withGalleryId:(NSString*)galleryId {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/imageInfo.plist", docDir];
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    
    if (info != nil) {
        
        [info setObject:aPhotoIdArray forKey:galleryId];
        [info writeToFile:filePath atomically:YES];
        [info release];
    }
    else {
        info = [NSDictionary dictionaryWithObject:aPhotoIdArray forKey:galleryId];
        [info writeToFile:filePath atomically:YES];
    }
    
}


-(NSString*) getGalleryIdForTopic:(int) topicId
{
    NSDictionary *dict = [[PlistManager sharedPlistManager] getDictionaryForTopic:topicId];
    return  [dict objectForKey:@"flickrphotos"];
    
}

-(NSArray*) retrievePhotoIdArrayFromDoc:(NSString*)galleryId {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/imageInfo.plist", docDir];
    
    NSDictionary *info = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    
    return [info objectForKey:galleryId];
}

-(void) deletePhotoFromOldSet:(NSSet *)lastPhotoSet withNewSet:(NSSet *)newPhotoSet {
    
    // we need to delete photos thats no longer in the gallery
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError *err;
    
    for (NSString *photo in lastPhotoSet) {
        if (![newPhotoSet containsObject:photo]) {
            NSString *filename = [NSString stringWithFormat:@"%@/%@.jpg", docDir, photo];
            if (![fileMgr removeItemAtPath:filename error:&err]) 
                CCLOG(@"Unable to delete file: %@", [err localizedDescription]);
            
        }
    }
}

-(void) saveImageSizeToDoc:(CGSize)size withImageName:(NSString*)imageName {
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/imageInfo.plist", docDir];
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    
    NSString *dim = [NSString stringWithFormat:@"%.2f,%.2f", size.width, size.height];
    
    if (info != nil) {
        [info setObject:dim forKey:imageName];
        [info writeToFile:filePath atomically:YES];
        [info release];
    }
    else {
        info = [NSDictionary dictionaryWithObject:dim forKey:imageName];
        [info writeToFile:filePath atomically:YES];
    }
    
}

-(CGSize) retrieveImageSizeFromDoc:(NSString*)imageName {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/imageInfo.plist", docDir];
    
    NSDictionary *info = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    
    NSString *s = [info objectForKey:imageName];
    
    if (s != nil) {
        NSArray *size = [s componentsSeparatedByString:@","];
        float width = [[size objectAtIndex:0] floatValue];
        float height = [[size objectAtIndex:1] floatValue];
        
        [info release];
        return CGSizeMake(width, height);
    }
    else {
        [info release];
        return CGSizeMake(640.0, 480.0);
    }
    
}

#pragma mark - SLImageGalleryDownloaderDelegate
-(void)slImageGalleryDownloaderDidFinish:(NSNotification *)notification {
    
    
    CCLOG(@"in : slImageGalleryDownloaderDidFinish (Gallery Download)");
    NSDictionary *userInfo = [notification userInfo];
    
    NSString *galleryId = [userInfo objectForKey:@"galleryId"];
    NSArray *photoIds = [userInfo objectForKey:@"photoIDs"];
    NSArray *imageURLs = [userInfo objectForKey:@"imageURLs"];
    //    self.bigImageURLs = [userInfo objectForKey:@"bigImageURLs"];
    
    NSError *error = [userInfo objectForKey:@"error"];
    
    if (error == nil) {
        
        CCLOG(@"no error");
        numOfImages = [imageURLs count];
        
        CCLOG(@"No if Images %d",numOfImages);
        
        // Retrieve photo id arrays from doc plist
        NSArray *lastPhotoIdArray = [self retrievePhotoIdArrayFromDoc:galleryId];
        NSSet *lastPhotoSet = [NSSet setWithArray:lastPhotoIdArray];
        NSSet *newPhotoSet = [NSSet setWithArray:photoIds];
        
        [self deletePhotoFromOldSet:lastPhotoSet withNewSet:newPhotoSet];
        
        // Store gallery photo id in imageInfo.plist
        [self savePhotoIdArrayToDoc:photoIds withGalleryId:galleryId];
        
        int k = 0;
        for (NSString *photoId in photoIds) {
            
            
            NSString *filename = [NSString stringWithFormat:@"%@jpg", photoId];
            
            // try to download image on the current slide
            if (![self saveImageFoundInDoc:filename]) {
                
                CCLOG(@"Image not downloaded yet %@",photoId);
                SLImageDownloader *imgDownloader = [[SLImageDownloader alloc] init];
                imgDownloader.imageURL = [[userInfo objectForKey:@"imageURLs"] objectAtIndex:k];
                imgDownloader.photoId = photoId;
                imgDownloader.huge = TRUE;
                [imgDownloader loadImage];
                [imgDownloader release];
            }
            else
            {
                CCLOG(@"Image downloaded skip it %@",photoId);
            }
            
            
            
            
            CCLOG(@"Download Photo Info %@",photoId);
            SLImageInfoDownloader *infoDL = [[SLImageInfoDownloader alloc] init];
            infoDL.photoId = photoId;
            //  [infoDL fetchInfo];
            [infoDL release];
            
            
            
            k++;
        }
        
        
    }
    else {
        // handle network error
        CCLOG(@"error in dowloading");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Please check your WiFi or cellular data network and try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
    }
    
}

#pragma mark - SLImageDownloaderDelegate

-(void) slImageDownloaderDidFinish:(NSNotification *)notification {
    
    CCLOG(@"in : slImageDownloaderDidFinish (Image Download)");
    
    NSDictionary *userInfo = [notification userInfo];
    
    NSString *sizeType = [userInfo objectForKey:@"sizeType"];
    
    if ([sizeType isEqualToString:@"huge"]) {    // Perform in background queue (thread)
        dispatch_async(backgroundQueue, ^{
            NSString *photoId = [userInfo objectForKey:@"photoId"];
            NSData *data = [userInfo objectForKey:@"data"];
            UIImage *image = [UIImage imageWithData:data];
            //            NSString *key = [userInfo objectForKey:@"imageURL"];
            
            NSString *imgFileName = [NSString stringWithFormat:@"%@.jpg", photoId];
            [self saveImageDataToDoc:data withImageName:imgFileName];
            
            //            [[CCTextureCache sharedTextureCache] addCGImage:[image CGImage] forKey:imgFileName];
            [self saveImageSizeToDoc:image.size withImageName:imgFileName];
            
        });
    }
    else {
        dispatch_async(backgroundQueue, ^{
            NSString *photoId = [userInfo objectForKey:@"photoId"];
            NSData *data = [userInfo objectForKey:@"data"];
            
            UIImage *image = [UIImage imageWithData:data];
            NSString *key = [userInfo objectForKey:@"imageURL"];
            
            NSString *imgFileName = [NSString stringWithFormat:@"%@.jpg", photoId];
            [self saveImageDataToDoc:data withImageName:imgFileName];
            
            
            [self saveImageSizeToDoc:image.size withImageName:imgFileName];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                CCLOG(@"Add the image to text cache");
                [[CCTextureCache sharedTextureCache] addCGImage:[image CGImage] forKey:imgFileName];
                
                
                
            });
            
        });
    }
}

#pragma mark - SLImageInfoDownloaderDelegate
-(void) slImageInfoDownloaderDidFinish:(NSNotification *)notification {
    
    CCLOG(@"slImageInfoDownloaderDidFinish (Image Info");
    
    NSDictionary *userInfo = [notification userInfo];
    NSString *photoId = [userInfo objectForKey:@"photoId"];
    NSDictionary *info = [userInfo objectForKey:@"info"];
    
    //   [photoInfo setObject:info forKey:photoId];
    
    CCLOG(@"Info %@",info);
    
    
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

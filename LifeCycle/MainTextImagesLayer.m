//
//  MainTextImagesLayer.m
//  LifeCycle
//
//  Created by Kelvin Chan on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainTextImagesLayer.h"
#import "PlistManager.h"
#import "ConfigManager.h"
#import "CCImageStack.h"
#import "NSMutableArrayShuffle.h"
#import "SLAudio.h"
#import "GalleryManager.h"
#import "Reachability.h"
#import "AppConfigManager.h"
#import "ModelManager.h"
#import "AppInfo.h"
#import "DidYouKnowInfo.h"
#import "TopicInfo.h"


#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@implementation MainTextImagesLayer

@synthesize topicInfo;
//@synthesize imagesBatchNode;

@synthesize currentScene;
@synthesize mainText;
@synthesize imgFileNames, imgScalings, imgTitles,imgAttributions;
@synthesize imageAtlasPlistName, imageAtlasPngName;

@synthesize pacings;

@synthesize mainTextLabel, voiceOverSlider, voiceOverOn, audioItemImage, readmeItemImage;

@synthesize didYouKnowTxts;
@synthesize didYouKnowTxtLabel, previousDidYouKnowTxtLabel;


-(void)dealloc {
    CCLOG(@"Dealloc in MainTextImagesLayer");
    
//    [imagesBatchNode release];
    [mainText release];
    
    [imgFileNames release];
    [imgScalings release];
    [imgTitles release];
    [imgAttributions release];
    
    [imageAtlasPlistName release];
    [imageAtlasPngName release];
    
    [mainTextLabel release];
    [voiceOverSlider release];
    
    [audioItemImage release];
    [readmeItemImage release];
    
    if (didYouKnowTxts != nil) 
        [didYouKnowTxts release];
    
    [didYouKnowTxtLabel release];
    [previousDidYouKnowTxtLabel release];
    
    [pacings release];
    [topicInfo release];
     
    [super dealloc];
}

-(NSArray*) getTimeSpaceInterleavedPacingsFromDictionary:(VoiceoverPacingsInfo *)voiceoverpacings {
    
    if (voiceoverpacings == nil) {
        CCLOG(@"Could not find VoiceOverPacing for this scene.");
        return nil;
    }
    
    NSArray *timePacings = voiceoverpacings.voiceoverPacingsTime.time;
    NSArray *spacePacings = voiceoverpacings.voiceoverPacingsSpace.space;
    
    NSMutableArray *timespaceInterleavedPacings = [[[NSMutableArray alloc] init] autorelease];
    
    for (int k=0; k < [timePacings count]; k++) {
        [timespaceInterleavedPacings addObject:[timePacings objectAtIndex:k]];
        [timespaceInterleavedPacings addObject:[spacePacings objectAtIndex:k]];
    }
    
    return timespaceInterleavedPacings;
    
}

-(TopicInfo*)loadTopicSpecificsForTopic:(int)topicId {
    
    AppInfo *appInfo =  [ModelManager sharedModelManger].appInfo;
    TopicInfo *ti = [appInfo.topics objectAtIndex:topicId-1];


    NSString *mainTxt = (NSString *) ti.mainText;
    // need to take of escaping the \n
    self.mainText = [mainTxt stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    /*
    NSArray *imagesInfoArray = (NSArray *) [dict objectForKey:@"images"];
    
    CCArray *images = [[CCArray alloc] initWithCapacity:[imagesInfoArray count]];
    CCArray *imageScales = [[CCArray alloc] initWithCapacity:[imagesInfoArray count]];
    
    int k=0;
    for (NSString *i in imagesInfoArray) {
        NSArray *a = [i componentsSeparatedByString:@","];
        [images insertObject:[(NSString*)[a objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] atIndex:k];
        [imageScales insertObject:[(NSString*)[a objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] atIndex:k];
        k++;
    }
    
    self.imgFileNames = images;
    self.imgScalings = imageScales;
    self.imgTitles = [CCArray arrayWithNSArray:((NSArray *) [dict objectForKey:@"titles"])];
    self.imgAttributions = [CCArray arrayWithNSArray:((NSArray *) [dict objectForKey:@"attributions"])];
    
    [images release];
    [imageScales release];
    
    
    */
    
    
    self.didYouKnowTxts = ti.didYouKnows.items;
    
    debugLog(@"Items %@",didYouKnowTxts);
    
    
    // Load Voice Over pacings
    self.pacings = [self getTimeSpaceInterleavedPacingsFromDictionary:ti.voiceoverPacings];
    
    return ti;
}


-(void)addMainTextLabelWithFontName:(NSString*)fontName withFontSize:(float)fontSize {
    if (self.mainTextLabel == nil) {
            
        CCLOG(@"Before ScrollableCCLabelTTF alloc-init");
        
        
        float heightMutiplier =2.6;
        //if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
          //  heightMutiplier = 2.6;
        //}

        CCLOG(@"Height multipler %f",heightMutiplier);
        
        ScrollableCCLabelTTF *m = [[ScrollableCCLabelTTF alloc] 
                                   initWithString:self.mainText 
                                   dimensions:CGSizeMake(screenSize.width*0.5,
                                                         screenSize.height*heightMutiplier) 
                                   alignment:UITextAlignmentLeft 
                                   fontName:fontName 
                                   fontSize:fontSize];
        CCLOG(@"End ScrollableCCLabelTTF alloc-init");
        
        m.delegate = self;
        
        self.mainTextLabel = m;
        
        [self addChild:self.mainTextLabel z:0 tag:kMainTextImagesMainTextTag];
        
        [m release];
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/ScrollableCCLabelTTF", NSStringFromClass([self class])];
    mainTextLabel_position = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kMainTextImagesMainTextTag];
    
    self.mainTextLabel.color = ccc3(0, 0, 0);
    self.mainTextLabel.anchorPoint = ccp(0.0, 1.0);
    self.mainTextLabel.position = mainTextLabel_position;
    //self.mainTextLabel.viewPortRatio = ? 
    
    maintextimage_viewport_height = [[ConfigManager sharedConfigManager] lengthInUnitOfScreenHeightFromDefaultsWithKey:@"MAINTEXTIMAGE_VIEWPORT_HEIGHT"];
    self.mainTextLabel.viewPortHeight = maintextimage_viewport_height;
}

-(void)startVoiceOverSlider {
    if (self.voiceOverSlider == nil) {
       
        self.voiceOverSlider = [CCSprite spriteWithFile:@"voiceoverslider.png"];
        self.voiceOverSlider.anchorPoint = ccp(0.0, 0.5);
        self.voiceOverSlider.scale = 1.05f;
        self.voiceOverSlider.opacity = 200;
        [self addChild:voiceOverSlider z:0 tag:kMainTextImagesVoiceOverSliderTag];
    }
    
    self.voiceOverSlider.visible = YES;
    self.voiceOverSlider.position = maintextimage_voiceoverslider_initial_position;
      
    NSMutableArray *actionsArrayForSlider = [[NSMutableArray alloc] init];
    NSMutableArray *actionsArrayForMainTextLabel = [[NSMutableArray alloc] init];
    
    float duration = 0.0;
    float dY = 0.0;
    float dYs = 0.0;
    
    for (int k = 0; k < [self.pacings count]; k+=2) {
        
        duration = [[self.pacings objectAtIndex:k] floatValue];
        dY = [[self.pacings objectAtIndex:k+1] floatValue];
        dYs += dY;
        
        // CCLOG(@"lhs = %f, rhs = %f", self.voiceOverSlider.position.y + dYs,  mainTextLabel_position.y - maintextimage_viewport_height);
                
        if (self.voiceOverSlider.position.y + dYs < mainTextLabel_position.y - maintextimage_viewport_height) {   
            // CCLOG(@"Over the lower bound");
            
            [actionsArrayForMainTextLabel addObject:[CCMoveBy actionWithDuration:(duration-0.2f) position:CGPointZero]];
            [actionsArrayForMainTextLabel addObject:[CCEaseInOut actionWithAction:[CCMoveBy actionWithDuration:0.2 position:ccp(0, -dY)] rate:1.0]];
        }
        else {

            [actionsArrayForSlider addObject:[CCMoveBy actionWithDuration:(duration-0.2f) position:CGPointZero]];
            [actionsArrayForSlider addObject:[CCEaseInOut actionWithAction:[CCMoveBy actionWithDuration:0.2 position:ccp(0, dY)] rate:1.0]];
        }
    }
    // The slider actually point right at the bottom of the main text pane
    // so we need to back up one
    // [actionsArrayForSlider removeLastObject];
    
    //CCLOG(@"actionsArrayForSlider.count = %d", [actionsArrayForSlider count]);
    //CCLOG(@"actionsArrayForMainTextLabel.count = %d", [actionsArrayForMainTextLabel count]);
    
    if ([actionsArrayForSlider count] > 0) {
        
        // first scroll text back to original position
        CCLOG(@"mainTextLabel position = %f, %f", self.mainTextLabel.position.x, self.mainTextLabel.position.y);
        id scrollBackAction = [CCMoveTo actionWithDuration:0.5f position:mainTextLabel_position];
        [self.mainTextLabel runAction:scrollBackAction];
        
        // then start sliding the indicator from top to bottom
        
        id actionCallBackMainText = [CCCallBlock actionWithBlock:^{
            if ([actionsArrayForMainTextLabel count] > 0) {
                [actionsArrayForMainTextLabel addObject:[CCMoveBy actionWithDuration:4.0 position:CGPointZero]];
                [actionsArrayForMainTextLabel addObject:[CCCallBlock actionWithBlock:^{
                    if (!self.audioItemImage.isSelected) {
                        [[FlowAndStateManager sharedFlowAndStateManager] playBackgroundTrack:topicInfo.backgroundTrackName];
                    }
                    // [self.mainTextLabel unfreezeScrolling];
                    voiceOverOn = NO;
                    self.voiceOverSlider.visible = NO;
                    voiceOverTrackTime = 0.0;
                }]];
                id action2 = [CCSequence actionsWithArray:actionsArrayForMainTextLabel];
                [self.mainTextLabel runAction:action2];
            }
        }];
        
        [actionsArrayForSlider addObject:actionCallBackMainText];
        
        id action = [CCSequence actionsWithArray:actionsArrayForSlider];
        
        [voiceOverSlider runAction:action];
    }
    
    [actionsArrayForSlider release];
    [actionsArrayForMainTextLabel release];
}

-(void)startVoiceOverSlider:(NSTimeInterval)aTime {
    if (self.voiceOverSlider == nil) {
      
        self.voiceOverSlider = [CCSprite spriteWithFile:@"voiceoverslider.png"];
        self.voiceOverSlider.anchorPoint = ccp(0.0, 0.5);
        self.voiceOverSlider.scale = 1.05f;
        self.voiceOverSlider.opacity = 200;
        [self addChild:voiceOverSlider z:0 tag:kMainTextImagesVoiceOverSliderTag];
    }
    
    self.voiceOverSlider.visible = YES;
    self.voiceOverSlider.position = maintextimage_voiceoverslider_initial_position;
    [self.mainTextLabel stopAllActions];
    id scrollBackAction = [CCMoveTo actionWithDuration:0.02f position:mainTextLabel_position];
    [self.mainTextLabel runAction:scrollBackAction];
//    self.mainTextLabel.position = mainTextLabel_position;
    
    NSMutableArray *actionsArrayForSlider = [[NSMutableArray alloc] init];
    NSMutableArray *actionsArrayForMainTextLabel = [[NSMutableArray alloc] init];
    
    float duration = 0.0;
    float totalDuration = 0.0;
    float dY = 0.0;
    float dYs = 0.0;
    
    BOOL animationStarted = NO;
    for (int k = 0; k < [self.pacings count]; k+=2) {
        
        duration = [[self.pacings objectAtIndex:k] floatValue];
        dY = [[self.pacings objectAtIndex:k+1] floatValue];
        dYs += dY;
        totalDuration += duration;
                
        if (self.voiceOverSlider.position.y + dYs < mainTextLabel_position.y - maintextimage_viewport_height) {   
            
            if (totalDuration > aTime) {
                
                if (!animationStarted) 
                    duration = totalDuration - aTime;
                
                [actionsArrayForMainTextLabel addObject:[CCMoveBy actionWithDuration:(duration-0.2f) position:CGPointZero]];
                [actionsArrayForMainTextLabel addObject:[CCEaseInOut actionWithAction:[CCMoveBy actionWithDuration:0.2 position:ccp(0, -dY)] rate:1.0]];
                
                animationStarted = YES;
            }
            else {
                [actionsArrayForMainTextLabel addObject:[CCMoveBy actionWithDuration:0.01 position:ccp(0, -dY)]];
            }
        }
        else {
            
            if (totalDuration > aTime) {
                
                if (!animationStarted)
                    duration = totalDuration - aTime;
                
                [actionsArrayForSlider addObject:[CCMoveBy actionWithDuration:(duration-0.2f) position:CGPointZero]];
                [actionsArrayForSlider addObject:[CCEaseInOut actionWithAction:[CCMoveBy actionWithDuration:0.2 position:ccp(0, dY)] rate:1.0]];
                
                animationStarted = YES;
            }
            else {
                [actionsArrayForSlider addObject:[CCMoveBy actionWithDuration:0.01 position:ccp(0, dY)]];
            }
        }
        
        
    }
    
    if ([actionsArrayForSlider count] > 0) {
        
        // first scroll text back to original position
        CCLOG(@"mainTextLabel position = %f, %f", self.mainTextLabel.position.x, self.mainTextLabel.position.y);
//        id scrollBackAction = [CCMoveTo actionWithDuration:0.5f position:mainTextLabel_position];
//        [self.mainTextLabel runAction:scrollBackAction];
        
        // then start sliding the indicator from top to bottom
        
        id actionCallBackMainText = [CCCallBlock actionWithBlock:^{
            if ([actionsArrayForMainTextLabel count] > 0) {
                [actionsArrayForMainTextLabel addObject:[CCMoveBy actionWithDuration:4.0 position:CGPointZero]];
                [actionsArrayForMainTextLabel addObject:[CCCallBlock actionWithBlock:^{
                    if (!self.audioItemImage.isSelected) {
                        [[FlowAndStateManager sharedFlowAndStateManager] playBackgroundTrack:topicInfo.backgroundTrackName];
                    }
                    // [self.mainTextLabel unfreezeScrolling];
                    voiceOverOn = NO;
                    [self.readmeItemImage unselected];
                    self.voiceOverSlider.visible = NO;
                    voiceOverTrackTime = 0.0;
                }]];
                id action2 = [CCSequence actionsWithArray:actionsArrayForMainTextLabel];
                [self.mainTextLabel runAction:action2];
            }
        }];
        
        [actionsArrayForSlider addObject:actionCallBackMainText];
        
        id action = [CCSequence actionsWithArray:actionsArrayForSlider];
        
        [voiceOverSlider runAction:action];
    }
    
    [actionsArrayForSlider release];
    [actionsArrayForMainTextLabel release];
}


-(void)addImage {    
    
    [self unschedule:_cmd];
    
    maintextimage_stack_x_offset = [[ConfigManager sharedConfigManager] absoluteValueFromDefaultsWithKey:@"MAINTEXTIMAGE_STACK_X_OFFSET"];
    maintextimage_stack_y_offset = [[ConfigManager sharedConfigManager] absoluteValueFromDefaultsWithKey:@"MAINTEXTIMAGE_STACK_Y_OFFSET"];

    CCImageStack *imageStack = [CCImageStack ccImageStack];
    imageStack.position = ccp(maintextimage_stack_x_offset + imageStack.boundingBox.size.width/2, 
                              screenSize.height - imageStack.boundingBox.size.height/2 + maintextimage_stack_y_offset);
        
    imageStack.images = self.imgFileNames;
    imageStack.imageScales = self.imgScalings;
    imageStack.imageTitles = self.imgTitles;
    imageStack.imageAttributions = self.imgAttributions;
    
//    imageStack.imageAtlasPlistName = self.imageAtlasPlistName;
//    imageStack.imageAtlasPngName = self.imageAtlasPngName;
    // imageStack.imagesBatchNode = self.imagesBatchNode;
        
    [self addChild:imageStack z:10 tag:kMainTextImagesImageStackTag];
    
//    CCSprite *s = [CCSprite spriteWithSpriteFrameName:@"ImageFrameLite.png"];
//    CCSprite *s = [CCSprite spriteWithFile:@"ImageFrameLite.png"];
//    s.position = ccp(227.500000, 466.500000);
//    [self addChild:s z:10];
    
}

-(void)addTitle:(SceneTypes)sceneType {

    NSString *imageName = topicInfo.topicImageName;
    
    NSString *biggerImageName  = topicInfo.topicBiggerImageName;
    
    debugLog(@"Adding title %@ %@",imageName,biggerImageName);
    
    
    CCMenuItemImage *topicItemImage = [CCMenuItemImage itemFromNormalImage:imageName
                                                             selectedImage:biggerImageName
                                                             disabledImage:imageName
                                                                    target:self 
                                                                  selector:@selector(goHome)];



    NSString *path = [NSString stringWithFormat:@"%@/CCMenu", NSStringFromClass([self class])];
    CGPoint title_pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kMainTextImagesMainTitleTag];
    

    
    CCMenu *topicMenu = [CCMenu menuWithItems:topicItemImage,nil];
        topicMenu.position = title_pos;
    
    [self addChild:topicMenu z:20 tag:kMainTextImagesMainTitleTag];
    
    
}



-(void)addMenu {
    
    debugLog(@"adding menu");
    
    NSString *path = [NSString stringWithFormat:@"%@/CCMenu:%d/CCMenuItemImage", NSStringFromClass([self class]), kMainTextImagesMainMenuTag];
    
    
    CCMenuItemImage *home = [CCMenuItemImage itemFromNormalImage:@"mt_home.png"
                                                   selectedImage:@"mt_home_bigger.png"
                                            disabledImage:@"mt_home.png"
                                                          target:self selector:@selector(goHome)];
    
    CGPoint home_position = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kMainTextImagesHomeButtonTag];
    home.position = home_position;
    home.tag = kMainTextImagesHomeButtonTag;
    
    CCMenuItemImage *photo = [CCMenuItemImage itemFromNormalImage:@"photo.png"
                                                       selectedImage:@"photo_bigger.png"
                                                       disabledImage:@"photo.png"
                                                              target:self selector:@selector(goPhoto)];
    CGPoint photo_position = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kMainTextImagesPhotoMenuTag];
    photo.position = photo_position;
    photo.tag = kMainTextImagesPhotoMenuTag;
    
    CCMenuItemImage *video = [CCMenuItemImage itemFromNormalImage:@"video.png"
                                                    selectedImage:@"video_bigger.png"
                                                    disabledImage:@"video.png"
                                                           target:self selector:@selector(goVideo)];
    CGPoint video_position = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kMainTextImagesVideoMenuTag];
    video.position = video_position;
    video.tag = kMainTextImagesVideoMenuTag;
    
    CCMenuItemImage *quiz = [CCMenuItemImage itemFromNormalImage:@"popquiz.png"
                                                       selectedImage:@"popquiz_bigger.png"
                                                       disabledImage:@"popquiz.png"
                                                              target:self selector:@selector(goQuiz)];
    
    CGPoint quiz_position = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kMainTextImagesPopquizButtonTag];
    quiz.position = quiz_position;
    quiz.tag = kMainTextImagesPopquizButtonTag;
    
    self.readmeItemImage = [CCMenuItemImage itemFromNormalImage:@"stopreadme.png"
                                                   selectedImage:@"readme.png"
                                                   disabledImage:@"readme.png"
                                                          target:self selector:@selector(readme)];
    
    CGPoint readme_position = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kMainTextImagesReadmeButtonTag];
    self.readmeItemImage.position = readme_position;
    self.readmeItemImage.tag = kMainTextImagesReadmeButtonTag;
    
    CCMenu *menu = [CCMenu menuWithItems:home, photo, video, quiz, self.readmeItemImage, nil];
    
    NSString *menu_path = [NSString stringWithFormat:@"%@/CCMenu", NSStringFromClass([self class])];
    CGPoint menu_pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:menu_path andTag:kMainTextImagesMainMenuTag];
    menu.position = menu_pos;

    [self addChild:menu z:0 tag:kMainTextImagesMainMenuTag];
    
    
}

-(void)addAudioControl {
    self.audioItemImage = [CCMenuItemImage itemFromNormalImage:@"main_text_audio_on.png"
                                                         selectedImage:@"main_text_audio_off.png"
                                                         disabledImage:@"main_text_audio_off.png" 
                                                                target:self
                                                              selector:@selector(audio:)];
    
    // When the screen is first entered, use if there's background music check to 
    // see if the audio control should be enabled or disabled.
    if ([[FlowAndStateManager sharedFlowAndStateManager] isMusicON]) 
        [self.audioItemImage unselected];
    else 
        [self.audioItemImage selected];
    
    self.audioItemImage.position = ccp(0,0);
    
    CCMenu *audioMenu = [CCMenu menuWithItems:self.audioItemImage, nil];
//    audioMenu.position = ccp(screenSize.width - self.audioItemImage.boundingBox.size.width/2.0 - 10.0, screenSize.height - self.audioItemImage.boundingBox.size.height/2.0 - 10.0);
    
    NSString *path = [NSString stringWithFormat:@"%@/CCMenu", NSStringFromClass([self class])];
    CGPoint pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kMainTextImagesAudioMenuTag];
    audioMenu.position = pos;
    
    [self addChild:audioMenu z:0 tag:kMainTextImagesAudioMenuTag];

}

#pragma mark - Menu item pressed.

-(void) audio:(CCMenuItemImage*)i {

    if ([FlowAndStateManager sharedFlowAndStateManager].isMusicON) {
        [i selected];
        [FlowAndStateManager sharedFlowAndStateManager].isMusicON = NO;
        if (!voiceOverOn)
            [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
        
    }
    else {
        [i unselected];
        [FlowAndStateManager sharedFlowAndStateManager].isMusicON = YES;
        if (!voiceOverOn)
            [[FlowAndStateManager sharedFlowAndStateManager] playBackgroundTrack:topicInfo.backgroundTrackName];
    }
    
}

-(void)goHome {
    [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kHomeScene withTranstion:kCCTransitionPageTurnBackward];
}

-(void) goPhoto {
    CCLOG(@"Photo menu clicked");
    voiceOverTrackTime = [CDAudioManager sharedManager].backgroundMusic.currentTime;
    [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
    if (!self.audioItemImage.isSelected) {
        [[FlowAndStateManager sharedFlowAndStateManager] playBackgroundTrack:topicInfo.backgroundTrackName];
    }
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kPhotoScene withTranstion:kCCTransitionCrossFade];
}

-(void)goVideo {
    CCLOG(@"Video menu clicked");
    
    if ([self isConnectedToNetwork] == FALSE)
    {
        CCLOG(@"error in dowloading");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Please check your WiFi or cellular data network and try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    
    voiceOverTrackTime = [CDAudioManager sharedManager].backgroundMusic.currentTime;
    [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
    if (!self.audioItemImage.isSelected) {
        [[FlowAndStateManager sharedFlowAndStateManager] playBackgroundTrack:topicInfo.backgroundTrackName];
    }
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kVideoScene withTranstion:kCCTransitionCrossFade];
}

-(void)goPlayGame {
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kPlayScene withTranstion:kCCTransitionCrossFade];
}

-(void)goQuiz {
    // CCLOG(@"Launch quiz");
    // CCLOG(@"Scene name = %@", NSStringFromClass([[self parent] class]));
    [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
    if (!self.audioItemImage.isSelected) {
        [[FlowAndStateManager sharedFlowAndStateManager] playBackgroundTrack:topicInfo.backgroundTrackName];
    }
    
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kQuizScene  withTranstion:kCCTransitionPageFlip];
    
}

-(void)readme {
    // This acts like a toggle.
    // Voice Over (Readme) trumps Audio Control Button trumps Background Music
    
    if (!voiceOverOn) {
        [[FlowAndStateManager sharedFlowAndStateManager] playBackgroundTrack:topicInfo.voiceoverTrackName loop:NO];
        [[CDAudioManager sharedManager].backgroundMusic playAt:voiceOverTrackTime];
        voiceOverOn = YES;
        // [self.mainTextLabel freezeScrolling];
//        if (voiceOverTrackTime == 0)
        [self.readmeItemImage selected];
        // Comment next line out for voiceover pace recoding:
        [self startVoiceOverSlider:voiceOverTrackTime];  
    }
    else {
        
        voiceOverTrackTime = [CDAudioManager sharedManager].backgroundMusic.currentTime;
        
        if (!self.audioItemImage.isSelected) {
            [[FlowAndStateManager sharedFlowAndStateManager] playBackgroundTrack:topicInfo.backgroundTrackName];
        }
        else
            [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
        
        [self.voiceOverSlider stopAllActions];
        [self.mainTextLabel stopAllActions];
        
        // [self.mainTextLabel unfreezeScrolling];
        voiceOverOn = NO;
        [self.readmeItemImage unselected];
        
        self.voiceOverSlider.visible = NO;
    }
    
}

-(void) readmeFirstTime {
    [self unschedule:_cmd];
    [self readme];
}

#pragma mark - ScrollableCCLabelTTFDelegate methods

-(void)scrollableCCLabelTTFBeginScroll:(ScrollableCCLabelTTF *)scrollableCCLabelTTF {
}

-(void)scrollableCCLabelTTFDidScroll:(ScrollableCCLabelTTF *)scrollableCCLabelTTF {
    // if voiceover is on, turns it off.
    // Comment next 2 lines out for voiceover pace recoding:
    if ([self voiceOverOn]) 
        [self readme];   
}

#pragma mark - Did you know
-(void) setPreviousDidYouKnowTxtLabel {
    NSString *str = [didYouKnowTxtLabel.string copy];
    previousDidYouKnowTxtLabel.string = str;
    [str release];
}

-(void)slideInDidYouKnow:(NSString *)direction withDuration:(float)time {
    
    
    CCLOG(@"slideInDidYouKnow");
    // CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    if (self.didYouKnowTxts != nil && [self.didYouKnowTxts count] > 0) {
        
        CCLOG(@"Did you know > 0");
        
        DidYouKnowInfo *ddki =  [self.didYouKnowTxts objectAtIndex:didYouKnowCount];
        NSString *didYouKnowTxt = ddki.text;
        
        CCLOG(@"Text to display %@",didYouKnowTxt);
        
        
        
        // 2nd slide the new text in.
        didYouKnowTxtLabel.string = didYouKnowTxt;
        
    }
    else
    {
        CCLOG(@"Did you know <= 0, cannot display");
    }
}

-(void)slideInDidYouKnowX:(NSString *)direction withDuration:(float)time {
    
    // CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    if (self.didYouKnowTxts != nil && [self.didYouKnowTxts count] > 0) {
        
        NSString *didYouKnowTxt = (NSString*)[self.didYouKnowTxts objectAtIndex:didYouKnowCount];
        
        // First put previousDidYouKnowTxtLabel in place and slide it off
        // previousDidYouKnowTxtLabel.position = ccp(screenSize.width/16, screenSize.height/8);
        previousDidYouKnowTxtLabel.position = ccp(didYouKnowTxtLabel.position.x, didYouKnowTxtLabel.position.y);
        CGPoint endPoint;
        if ([direction isEqualToString:@"left"])
            endPoint = ccp(-screenSize.width , didYouKnowMainTxtPosition.y);
        else 
            endPoint = ccp(screenSize.width , didYouKnowMainTxtPosition.y);
        
        id moveOutAction = [CCMoveTo actionWithDuration:time position:endPoint];
        
        
        
        [previousDidYouKnowTxtLabel runAction:moveOutAction];
        
        
        // 2nd slide the new text in.
        didYouKnowTxtLabel.string = didYouKnowTxt;
        
        CGPoint startPoint;
        if ([direction isEqualToString:@"left"]) 
            startPoint = ccp(screenSize.width  , didYouKnowMainTxtPosition.y);
        else 
            startPoint = ccp(-screenSize.width  , didYouKnowMainTxtPosition.y);
        
        didYouKnowTxtLabel.position = startPoint;
        
        id moveInAction = [CCMoveTo actionWithDuration:time position:didYouKnowMainTxtPosition];
        id callBack = [CCCallFunc actionWithTarget:self selector:@selector(setPreviousDidYouKnowTxtLabel)];
        
        id allAction = [CCSequence actions:moveInAction, callBack, nil];
        
        [didYouKnowTxtLabel runAction:allAction];
        
    }
}

-(void) goLeftOnDidYouKnow:(id)sender {
    [didYouKnowTxtLabel stopAllActions];
    
    if (!self.audioItemImage.isSelected && !voiceOverOn)
        [(TextAndQuizScene*)self.parent play_dyk_scroll_left];
    
    didYouKnowCount--;
    if (didYouKnowCount < 0) 
        didYouKnowCount = [self.didYouKnowTxts count]-1;
    
    [self slideInDidYouKnow:@"right" withDuration:1.0];
}

-(void) goRightDidYouKnow:(id)sender {
    [didYouKnowTxtLabel stopAllActions];
    
    if (!self.audioItemImage.isSelected && !voiceOverOn)
        [(TextAndQuizScene*)self.parent play_dyk_scroll_right];
    
    didYouKnowCount++;
    if (didYouKnowCount > [self.didYouKnowTxts count]-1) 
        didYouKnowCount = 0;
    
    [self slideInDidYouKnow:@"left" withDuration:1.0];
}



#pragma mark - Life cycle

- (id)init
{
    CCLOG(@"Enter: [MainTextImageLayer init]");
    self = [super init];
    if (self) {
        srandom(time(NULL));
        
        GalleryManager *gman = [GalleryManager getInstance];
        [gman syncAllGalleries];

        
        // set background to white 
        //glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
        
        voiceOverOn = NO;        
        voiceOverTrackTime = 0;
        
        self.isTouchEnabled = YES;
        bDidYouKnowSwipe = NO;
        
        screenSize = [CCDirector sharedDirector].winSize;
        
        CCLOG(@"Before loadTopicSpecificsForScene");
        self.topicInfo = [self loadTopicSpecificsForTopic:[AppConfigManager  getInstance].currentTopic];
        CCLOG(@"After loadTopicSpecificsForScene");
        
        
        

        
        
        CCSprite *bg = [CCSprite spriteWithFile:topicInfo.mainTextTitleImageName];
        
        bg.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:bg z:0 tag:kMainTextImagesBackgroundTag];
        
        [self addTitle:[FlowAndStateManager sharedFlowAndStateManager].currentScene];
        
        // [self addImage];
        
        [self addMenu];
        
        NSString *fontName = @"Noteworthy";
        CGFloat fontSize = 24; 
        CCLOG(@"Begin Add Main Text");
        [self addMainTextLabelWithFontName:fontName withFontSize:fontSize];
        CCLOG(@"After Add Main Text");
        
        [self addAudioControl];
        
        // "Did you know?"
        
        
        /*
        CCSprite *didYouKnowHeadTitle = [CCSprite spriteWithFile:@"didyouknowtext.png"];
        
        NSString *dykHeaderPath = [NSString stringWithFormat:@"%@/CCSprite", NSStringFromClass([self class])];
        CGPoint dykHeader_position = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:dykHeaderPath andTag:kMainTextImagesDYKHeaderTag];
                                   
        didYouKnowHeadTitle.position = dykHeader_position;
        didYouKnowHeadTitle.anchorPoint = ccp(0, 0);
        didYouKnowHeadTitle.rotation = -15.0f;


        [self addChild:didYouKnowHeadTitle z:1 tag:kMainTextImagesDYKHeaderTag];
         */
        

      
        // Put the left/right arrow        
        CCMenuItemImage *right = [CCMenuItemImage itemFromNormalImage:  topicInfo.didYouKnows.didYouKnowRightImage
                                                        selectedImage:  topicInfo.didYouKnows.didYouKnowRightImage
                                                        disabledImage:  topicInfo.didYouKnows.didYouKnowRightImage
                                                               target:self
                                                             selector:@selector(goRightDidYouKnow:)];
        CCMenu *rightMenu = [CCMenu menuWithItems:right, nil];
        
        NSString *rMenuPath = [NSString stringWithFormat:@"%@/CCMenu", NSStringFromClass([self class])];
        CGPoint rmenu_pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:rMenuPath andTag:kMainTextImagesDYKRightMenuTag];
        rmenu_pos.x = rmenu_pos.x + 20;
        rightMenu.position = rmenu_pos;
        [self addChild:rightMenu z:10 tag:kMainTextImagesDYKRightMenuTag];   // z = 10 to make sure it covers the text
        
        CCMenuItemImage *left = [CCMenuItemImage itemFromNormalImage:  topicInfo.didYouKnows.didYouKnowLeftImage
                                                       selectedImage:topicInfo.didYouKnows.didYouKnowLeftImage
                                                       disabledImage:topicInfo.didYouKnows.didYouKnowLeftImage
                                                              target:self
                                                            selector:@selector(goLeftOnDidYouKnow:)];
        CCMenu *leftMenu = [CCMenu menuWithItems:left, nil];
        leftMenu.anchorPoint = ccp(0, 0);
        
        NSString *lMenuPath = [NSString stringWithFormat:@"%@/CCMenu", NSStringFromClass([self class])];
        CGPoint lmenu_pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:lMenuPath andTag:kMainTextImagesDYKLeftMenuTag];
        lmenu_pos.x = lmenu_pos.x - 23;
        leftMenu.position = lmenu_pos;
        [self addChild:leftMenu z:10 tag:kMainTextImagesDYKLeftMenuTag];   // z = 10 to make sure it covers the text
        
        // Did you know?
        didYouKnowTxtLabel = [[CCLabelTTF alloc] initWithString:@"" dimensions:CGSizeMake(screenSize.width*0.8, 80) alignment:UITextAlignmentCenter fontName:@"ArialRoundedMTBold" fontSize:25];
        
        didYouKnowTxtLabel.color = ccc3(255, 255, 255);
        didYouKnowTxtLabel.anchorPoint = ccp(0, 0.5);
        

        [self addChild:didYouKnowTxtLabel z:0 tag:kMainTextImagesDYKTxtTag];
        
        previousDidYouKnowTxtLabel = [[CCLabelTTF alloc] initWithString:@"" dimensions:CGSizeMake(screenSize.width*0.8, 80) alignment:UITextAlignmentCenter fontName:@"ArialRoundedMTBold" fontSize:25];
        previousDidYouKnowTxtLabel.color = ccc3(255, 255,255);
        previousDidYouKnowTxtLabel.anchorPoint = ccp(0, 0.5);
        
        [self addChild:previousDidYouKnowTxtLabel z:0 tag:kMainTextImagesDYKPrevTxtTag];
        
        NSString *dykMainTextPath = [NSString stringWithFormat:@"%@/CCLabelTTF", NSStringFromClass([self class])];
        didYouKnowMainTxtPosition = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:dykMainTextPath andTag:kMainTextImagesDYKTxtTag];
        
        didYouKnowTxtLabel.position = ccp(100, 51);
                
        didYouKnowCount = 0;
        
        if ([self.didYouKnowTxts count] > 0) {
            [self.didYouKnowTxts shuffle];      // randomize the "Did you know?"
            
            [self slideInDidYouKnow:@"left" withDuration:0.5];
        }
        CCLOG(@"Added DYK text");
        
        NSString *vslider_path = [NSString stringWithFormat:@"%@/CCSprite", NSStringFromClass([self class])];
        maintextimage_voiceoverslider_initial_position = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:vslider_path andTag:kMainTextImagesVoiceOverSliderTag];
    
    }
    CCLOG(@"Exit: [MainTextImageLayer init]");

    return self;
}

-(void)onEnter {
//    [self addChild:imagesBatchNode z:20 tag:kMainTextImagesBatchNodeTag];
    self.currentScene = (TextAndQuizScene *)self.parent;
    
    //NSString *fontName = @"Noteworthy";
    //CGFloat fontSize = 24; 
    // [self addMainTextLabelWithFontName:fontName withFontSize:fontSize];
    
    [super onEnter];
    
    // schedule a delay of 0.5 sec before running Readme the voiceover.
    // [self schedule:@selector(readmeFirstTime) interval:0.8];
    [self schedule:@selector(addImage) interval:0.27];
    
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    
    editModeAbler = [EditModeAbler node];
    [editModeAbler retain];
    editModeAbler.delegateLayer = self;
    [editModeAbler activate];
    
    // start background music (if audio is on)
    if (!self.audioItemImage.isSelected) {
        [[FlowAndStateManager sharedFlowAndStateManager] playBackgroundTrack:topicInfo.backgroundTrackName];
    }
        
    CCLOG(@"Main Text Layer after onEnter");
}

-(void)onExit {
    [editModeAbler release];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super onExit];
}

#pragma mark - Touches

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    // UITouch *touch = [touches anyObject];
    
    CGPoint location = [touch locationInView: [touch view]];
    CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
    
    CGRect didyouknowBound = CGRectMake(12.390400, -1.482407, 1000.0, 173.0);
    
    if (CGRectContainsPoint(didyouknowBound, loc)) {
        startTouchPt = loc;
        lastTouchPt = loc;
        bDidYouKnowSwipe = YES;
        CCLOG(@"Voiceover snapshot (%f,%f)", loc.x, loc.y);
    }
    else 
        bDidYouKnowSwipe = NO;
    
    //    override
       bDidYouKnowSwipe = NO;
    
    return (NO || [editModeAbler ccTouchBegan:touch withEvent:event]);
    
    
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    // UITouch *touch = [touches anyObject];
    
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
    if (bDidYouKnowSwipe) {
        CGPoint dpt = ccp(loc.x - lastTouchPt.x, loc.y - lastTouchPt.y);
        lastTouchPt = loc;
        
        // drag the "did you know" labels accordingly
        self.didYouKnowTxtLabel.position = ccp(self.didYouKnowTxtLabel.position.x + dpt.x, self.didYouKnowTxtLabel.position.y);
    }
    
    [editModeAbler ccTouchMoved:touch withEvent:event];

}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
//    UITouch *touch = [touches anyObject];
    
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
    
    if (bDidYouKnowSwipe) {
        if (loc.x - lastTouchPt.x < 0 && abs(loc.x - startTouchPt.x) > 80.0f ) {
            [self goRightDidYouKnow:nil];
        }
        else if (loc.x - lastTouchPt.x > 0 && abs(loc.x - startTouchPt.x) > 80.0f ) {
            [self goLeftOnDidYouKnow:nil];
        }
        else {
            id slideBackAction = [CCMoveTo actionWithDuration:0.5f position:didYouKnowMainTxtPosition];
            [self.didYouKnowTxtLabel runAction:slideBackAction];
        }
    }
    bDidYouKnowSwipe = NO;
    
    [editModeAbler ccTouchEnded:touch withEvent:event];
}

-(BOOL) isConnectedToNetwork
{
   
        Reachability *reachability = [Reachability reachabilityForInternetConnection];  
        NetworkStatus networkStatus = [reachability currentReachabilityStatus]; 
            return !(networkStatus == NotReachable);

}
@end

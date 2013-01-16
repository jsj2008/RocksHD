//
//  GameManager.m
//  PlantHD
//
//  Created by Kelvin Chan on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlowAndStateManager.h"
#import "HomeScene.h"
#import "AppConfigManager.h"
#import "PlistManager.h"
#import "IntroScene.h"
#import "Topic2Scene.h"
#import "Topic1Scene.h"
#import "Topic6Scene.h"
#import "Topic4Scene.h"
#import "Topic3Scene.h"
#import "Topic5Scene.h"
#import "Topic7Scene.h"
#import "InfoScene.h"
#import "PhotoScene.h"
#import "VideoScene.h"
#import "CurrScene.h"
#import "TopicInteractiveBackgroundLayer.h"
#import "ReadTextScene.h"

#import "MatchingGameScene.h"
#import "OtherAppsScene.h"
#import "ModelManager.h"

@implementation FlowAndStateManager
static FlowAndStateManager* _sharedFlowAndStateManager = nil;

@synthesize isMusicON;
@synthesize isSoundEffectsON;
@synthesize managerSoundState;
@synthesize listOfSoundEffectFiles;
@synthesize soundEffectsState;
@synthesize currentScene;
@synthesize numOfTopics;

+(FlowAndStateManager*)sharedFlowAndStateManager {
    @synchronized([FlowAndStateManager class]) {
        if (!_sharedFlowAndStateManager) 
            [[self alloc] init];
        return _sharedFlowAndStateManager;
    }
    return nil;
}

+(id)alloc {
    @synchronized([FlowAndStateManager class]) {
        NSAssert(_sharedFlowAndStateManager == nil, @"Attempted to allocate a 2nd instance of the Flow State Manager singleton");
        _sharedFlowAndStateManager = [super alloc];
        return _sharedFlowAndStateManager;
    }
    return nil;
}

-(void)runSceneWithID:(SceneTypes)sceneID withTranstion:(CCTransitionStyles)transitionStyle {
    SceneTypes oldScene = currentScene;
    currentScene = sceneID;
    
//    id sceneToRun = nil;
    CCScene *sceneToRun = nil;
    switch (sceneID) {
        case kIntroScene: 
            sceneToRun = [IntroScene node];
            break;
          
        case kHomeScene: 
            sceneToRun = [HomeScene node];
            break;
//        case kPlayScene:
//            sceneToRun = [PlayScene node];
//            break;
        case kTopic1Scene:
            sceneToRun = [Topic1Scene node];
            break;
        case kTopic2Scene:
            sceneToRun = [Topic2Scene node];
            break;
        case kTopic3Scene:
            sceneToRun = [Topic3Scene node];
            break;
        case kTopic4Scene:
            sceneToRun = [Topic4Scene node];
            break;
        case kTopic5Scene:
            sceneToRun = [Topic5Scene node];
            break;
        case kTopic6Scene:
            sceneToRun = [Topic6Scene node];
            break;
        case kTopic7Scene:
            sceneToRun = [Topic7Scene node];
            break;
        case kInfoScene:
            sceneToRun = [InfoScene node];
            break;
        case kCurrScene: 
            sceneToRun = [CurrScene node];
            break;
        case kMatchingGameScene:
            sceneToRun = [MatchingGameScene node];
            break;
    
             case kOtherAppsScene:
             sceneToRun = [OtherAppsScene node];
            break;
        
        case kQuizScene:
        {
            sceneToRun = [TextAndQuizScene node];
            
            [(TextAndQuizScene*) sceneToRun loadQuestionsForScene:kTopic1Scene];
            [(TextAndQuizScene*) sceneToRun loadQuiz];
        }
            break;
        case kReadTextScene:
            sceneToRun = [ReadTextScene node];
            break;
            
        case kPhotoScene:
            sceneToRun = [PhotoScene node];
        {
            /*
            CCScene *current_scene = [[CCDirector sharedDirector] runningScene];
            if ([current_scene respondsToSelector:@selector(topicInfo)]) {
//                ((PhotoScene*)sceneToRun).topicInfo = [current_scene topicInfo];
                ((PhotoScene*)sceneToRun).topicInfo = [current_scene performSelector:@selector(topicInfo)];
            }
             */
            

            ((PhotoScene*)sceneToRun).topicInfo  = [self loadTopicSpecificsForScene:[AppConfigManager  getInstance].currentTopic];

            break;
                    }
        case kVideoScene:
        {
            sceneToRun = [VideoScene node];
            ((VideoScene*)sceneToRun).topicInfo  = [self loadTopicSpecificsForScene:[AppConfigManager  getInstance].currentTopic];

            break;
        }
        case kTopicInteractiveScene:
        {
            
            TopicInteractiveBackgroundLayer *l = [TopicInteractiveBackgroundLayer node];
            CCScene *c = (CCScene*) l;
            ModelManager *mm = [ModelManager sharedModelManger];
            
            l.info = mm.appInfo.topics[[AppConfigManager  getInstance].currentTopic -1];
            sceneToRun = c;
            
            break;
        }
        default:
            CCLOG(@"Unknown ID, cannot switch scenes");
            return;
            break;
    }
    if (sceneToRun == nil) {
        // Revert back, since no new scene was found
        currentScene = oldScene;
        return;
    }
    
    // Load audio for new scene based on sceneID
    [self performSelectorInBackground:@selector(loadAudioForSceneWithID:) withObject:[NSNumber numberWithInt:currentScene]];
    
    if ([[CCDirector sharedDirector] runningScene] == nil) {
        [[CCDirector sharedDirector] runWithScene:sceneToRun];        
    } else {
        /*if (sceneID == kPlayScene || sceneID == kIntroScene)
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5f scene:sceneToRun]];            
        else 
            [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:0.5f scene:sceneToRun backwards:NO]];
         */
        
        switch (transitionStyle) {
            case kCCTransitionCrossFade:
                [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.1f scene:sceneToRun]]; 
                break;
            case kCCTransitionPageTurnForward:
                [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:0.5f scene:sceneToRun backwards:NO]];
                break;
            case kCCTransitionPageTurnBackward:
                [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:0.5f scene:sceneToRun backwards:YES]];
                break;
            case kCCTransitionPageFlip:
                [[CCDirector sharedDirector] replaceScene:[CCTransitionFlipX transitionWithDuration:0.5f scene:sceneToRun]];
                break;
            default:
                break;
        }
    }    
    
    [self performSelectorInBackground:@selector(unloadAudioForSceneWithID:) withObject:[NSNumber numberWithInt:oldScene]];
}

-(void)runSceneSansAudioOpWithID:(SceneTypes)sceneID withTranstion:(CCTransitionStyles)transitionStyle {
    
    //TODO: This is a temp solution to fix the sound issue for the quiz page, the quiz page should be 
    // redesigned such that it is a separate scene, rather than a layer being manipulated on/off within the 
    // same as Main Text.
    
    SceneTypes oldScene = currentScene;
    currentScene = sceneID;
    CCLOG(@"scene id %d",sceneID);
    
    
    //    id sceneToRun = nil;
    CCScene *sceneToRun = nil;
    switch (sceneID) {
        case kIntroScene: 
            sceneToRun = [IntroScene node];
            break;
            //        case kPlayScene:
            //            sceneToRun = [PlayScene node];
            //            break;
        case kTopic1Scene:
            sceneToRun = [Topic1Scene node];
            break;
        case kTopic2Scene:
            sceneToRun = [Topic2Scene node];
            break;
        case kTopic3Scene:
            sceneToRun = [Topic3Scene node];
            break;
        case kTopic4Scene:
            sceneToRun = [Topic4Scene node];
            break;
        case kTopic5Scene:
            sceneToRun = [Topic5Scene node];
            break;
        case kTopic6Scene:
            sceneToRun = [Topic6Scene node];
            break;
        case kTopic7Scene:
            sceneToRun = [Topic7Scene node];
            break;
        case kInfoScene:
            sceneToRun = [InfoScene node];
            break;
        case kCurrScene: 
            sceneToRun = [CurrScene node];
            break;
        case kMatchingGameScene: 
            sceneToRun = [MatchingGameScene node];
            break;     
            
        case kOtherAppsScene:
            sceneToRun = [OtherAppsScene node];
            break;
    
        case kQuizScene:
            sceneToRun = [TextAndQuizScene node];
            break;
        case kReadTextScene:
            sceneToRun = [ReadTextScene node];
            break;
            
        case kPhotoScene: 
            sceneToRun = [PhotoScene node];
        {
            CCScene *current_scene = [[CCDirector sharedDirector] runningScene];
            if ([current_scene respondsToSelector:@selector(topicInfo)]) {
                //                ((PhotoScene*)sceneToRun).topicInfo = [current_scene topicInfo];
                ((PhotoScene*)sceneToRun).topicInfo = [current_scene performSelector:@selector(topicInfo)];
            }
        }
            break;
        case kVideoScene:
            sceneToRun = [VideoScene node];
        {
            CCScene *current_scene = [[CCDirector sharedDirector] runningScene];
            if ([current_scene respondsToSelector:@selector(topicInfo)]) {
                ((VideoScene*)sceneToRun).topicInfo = [current_scene performSelector:@selector(topicInfo)];
            }
        }
            break;
        default:
            CCLOG(@"Unknown ID, cannot switch scenes");
            return;
            break;
    }
    if (sceneToRun == nil) {
        // Revert back, since no new scene was found
        currentScene = oldScene;
        return;
    }
    
    // Load audio for new scene based on sceneID
//    [self performSelectorInBackground:@selector(loadAudioForSceneWithID:) withObject:[NSNumber numberWithInt:currentScene]];
    
    if ([[CCDirector sharedDirector] runningScene] == nil) {
        [[CCDirector sharedDirector] runWithScene:sceneToRun];        
    } else {
        /*if (sceneID == kPlayScene || sceneID == kIntroScene)
         [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5f scene:sceneToRun]];            
         else 
         [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:0.5f scene:sceneToRun backwards:NO]];
         */
        
        switch (transitionStyle) {
            case kCCTransitionCrossFade:
                [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.1f scene:sceneToRun]]; 
                break;
            case kCCTransitionPageTurnForward:
                [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:0.5f scene:sceneToRun backwards:NO]];
                break;
            case kCCTransitionPageTurnBackward:
                [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:0.5f scene:sceneToRun backwards:YES]];
                break;
            case kCCTransitionPageFlip:
                [[CCDirector sharedDirector] replaceScene:[CCTransitionFlipX transitionWithDuration:0.5f scene:sceneToRun]];
                break;
            default:
                break;
        }
    }    
    
//    [self performSelectorInBackground:@selector(unloadAudioForSceneWithID:) withObject:[NSNumber numberWithInt:oldScene]];
}


-(void)openSiteWithLinkType:(LinkTypes)linkTypeToOpen {
    NSURL *urlToOpen = nil;
    if (linkTypeToOpen == kLinkTypeWebSite) {
        CCLOG(@"Opening Book Site");
        urlToOpen = [NSURL URLWithString:@"http://www.informit.com/title/9780321735621"];
    }
    
    if (![[UIApplication sharedApplication] openURL:urlToOpen]) {
        CCLOG(@"%@%@",@"Failed to open url:",[urlToOpen description]);
        [self runSceneWithID:kHomeScene withTranstion:kCCTransitionCrossFade];
    }    
}



- (id)init
{
    self = [super init];
    if (self) {
        // Flow/State Manager initialization
        // CCLOG(@"Flow/State Manager Singleton init");
        currentScene = kNoSceneUninitialized;
        
        // About audio.
        isMusicON = YES;
        isSoundEffectsON = YES;
        
        hasAudioBeenInitialized = NO;
        soundEngine = nil;
        managerSoundState = kAudioManagerUninitialized;
        
        uiEditMode = NO;
        
        numOfTopics = [[[[PlistManager sharedPlistManager] appDictionary] objectForKey:@"numberOfTopics"] intValue];
        
    }
    
    return self;
}

#pragma mark - Audio
-(void)playBackgroundTrack:(NSString*)trackFileName {
    // Wait to make sure soundEngine is initialized
    if ((managerSoundState != kAudioManagerReady) && 
        (managerSoundState != kAudioManagerFailed)) {
        
        int waitCycles = 0;
        while (waitCycles < AUDIO_MAX_WAITTIME) {
            [NSThread sleepForTimeInterval:0.1f];
            if ((managerSoundState == kAudioManagerReady) || 
                (managerSoundState == kAudioManagerFailed)) {
                break;
            }
            waitCycles = waitCycles + 1;
        }
    }
    
    if (managerSoundState == kAudioManagerReady) {
        if ([soundEngine isBackgroundMusicPlaying]) {
            [soundEngine stopBackgroundMusic];
        }
        [soundEngine preloadBackgroundMusic:trackFileName];
        [soundEngine playBackgroundMusic:trackFileName loop:YES];
    }
}

-(void)playBackgroundTrack:(NSString *)trackFileName loop:(BOOL)loop {
    // Wait to make sure soundEngine is initialized
    if ((managerSoundState != kAudioManagerReady) && 
        (managerSoundState != kAudioManagerFailed)) {
        
        int waitCycles = 0;
        while (waitCycles < AUDIO_MAX_WAITTIME) {
            [NSThread sleepForTimeInterval:0.1f];
            if ((managerSoundState == kAudioManagerReady) || 
                (managerSoundState == kAudioManagerFailed)) {
                break;
            }
            waitCycles = waitCycles + 1;
        }
    }
    
    if (managerSoundState == kAudioManagerReady) {
        if ([soundEngine isBackgroundMusicPlaying]) {
            [soundEngine stopBackgroundMusic];
        }
        [soundEngine preloadBackgroundMusic:trackFileName];
        [soundEngine playBackgroundMusic:trackFileName loop:loop];
    }
}

-(void)stopBackgroundTrack {
    if (managerSoundState == kAudioManagerReady) {
        [soundEngine stopBackgroundMusic];
    }
}

-(void)muteBackgroundTrack {
    if (managerSoundState == kAudioManagerReady) {
        soundEngine.mute = YES;
    }
}

-(void)unMuteBackgroundTrack {
    if (managerSoundState == kAudioManagerReady) {
        soundEngine.mute = NO;
    }
}

-(void)stopSoundEffect:(ALuint)soundEffectID {
    if (managerSoundState == kAudioManagerReady) {
        [soundEngine stopEffect:soundEffectID];
    }
}

-(ALuint)playSoundEffect:(NSString*)soundEffectKey {
    ALuint soundID = 0;
    if (managerSoundState == kAudioManagerReady) {
        NSNumber *isSFXLoaded = [soundEffectsState objectForKey:soundEffectKey];
        if ([isSFXLoaded boolValue] == SFX_LOADED) {
            soundID = [soundEngine playEffect:[listOfSoundEffectFiles objectForKey:soundEffectKey]];
            // soundID = [soundEngine playEffect:[listOfSoundEffectFiles objectForKey:soundEffectKey] pitch:1.0f pan:0.0f gain:1.0f];
        } else {
            CCLOG(@"GameMgr: SoundEffect %@ is not loaded, cannot play.",soundEffectKey);
        }
    } else {
        CCLOG(@"GameMgr: Sound Manager is not ready, cannot play %@", soundEffectKey);
    }
    return soundID;
}


-(ALuint)playSoundEffect:(NSString*)soundEffectKey gain:(Float32)gain {
    ALuint soundID = 0;
    if (managerSoundState == kAudioManagerReady) {
        NSNumber *isSFXLoaded = [soundEffectsState objectForKey:soundEffectKey];
        if ([isSFXLoaded boolValue] == SFX_LOADED) {
            soundID = [soundEngine playEffect:[listOfSoundEffectFiles objectForKey:soundEffectKey] pitch:1.0f pan:0.0f gain:gain];
        } else {
            CCLOG(@"GameMgr: SoundEffect %@ is not loaded, cannot play.",soundEffectKey);
        }
    } else {
        CCLOG(@"GameMgr: Sound Manager is not ready, cannot play %@", soundEffectKey);
    }
    return soundID;
}

- (NSString*)formatSceneTypeToString:(SceneTypes)sceneID {
    NSString *result = nil;
    switch(sceneID) {
        case kNoSceneUninitialized:
            result = @"kNoSceneUninitialized";
            break;
        case kIntroScene:
            result = @"kIntroScene";
            break;
        case kPlayScene:
            result = @"kPlayScene";
            break;
        case kTopic1Scene:
            result = @"kTopic1Scene";
            break;
        case kTopic2Scene:
            result = @"kTopic2Scene";
            break;
        case kTopic3Scene:
            result = @"kTopic3Scene";
            break;
        case kTopic4Scene:
            result = @"kTopic4Scene";
            break;
        case kTopic5Scene:
            result = @"kTopic5Scene";
            break;
        case kTopic6Scene:
            result = @"kTopic6Scene";
            break;
        case kTopic7Scene:
            result = @"kTopic7Scene";
            break;
        case kInfoScene:
            result = @"kInfoScene";
            break;
        case kHomeScene:
            result = @"kHomeScene";
            break;    
        case kCurrScene:
            result = @"kCurrScene";
            break;
        case kPhotoScene:
            result = @"kPhotoScene";
            break;
        case kVideoScene:
            result = @"kVideoScene";
            break;
        case kTestScene:
            result = @"kTestScene";
            break;
        case kMatchingGameScene:
            result = @"kMatchingGameScene";
            break;
        case kOtherAppsScene:
            result = @"kOtherAppsScene";
            break;
        case kQuizScene:
            result = @"kQuizScene";
            break;
        case kReadTextScene:
            result = @"kReadTextScene";
            break;
    
        case kTopicInteractiveScene:
            result = @"kTopicInteractiveScene";
            break;
   
            
        default:
            [NSException raise:NSGenericException format:@"Unexpected SceneType."];
    }
    return result;
}

//-(NSDictionary *)loadBasicInfo {
//    NSString *fullFileName = @"AllTopics.plist";
//    NSString *plistPath;
//    
//    // 1: Get the Path to the plist file
//    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
//        plistPath = [[NSBundle mainBundle] pathForResource:@"AllTopics" ofType:@"plist"];
//    }
//    
//    // 2: Read in the plist file
//    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
//    
//    // 3: If the plistDictionary was null, the file was not found.
//    if (plistDictionary == nil) {
//        CCLOG(@"Error reading AllTopics.plist");
//        return nil; // No Plist Dictionary or file found
//    }
//
//    return plistDictionary;
//}

-(NSDictionary *)loadBasicInfoForSceneWithID:(NSUInteger)topicNumber {
        
//    NSDictionary *plistDictionary = [self loadBasicInfo];
    
    NSDictionary *plistDictionary = [[PlistManager sharedPlistManager] allTopicsPlistDictionary];
    
    NSString *key = [NSString stringWithFormat:@"topic%d", topicNumber];

    return [plistDictionary objectForKey:key];

}

-(NSDictionary *)getSoundEffectsListForSceneWithID:(SceneTypes)sceneID {
//    NSString *fullFileName = @"SoundEffects.plist";
//    NSString *plistPath;
//
//    // 1: Get the Path to the plist file
//    NSString *rootPath = 
//    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//                                         NSUserDomainMask, YES) 
//     objectAtIndex:0];
//    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
//        plistPath = [[NSBundle mainBundle] 
//                     pathForResource:@"SoundEffects" ofType:@"plist"];
//    }
//    
//    // 2: Read in the plist file
//    NSDictionary *plistDictionary = 
//    [NSDictionary dictionaryWithContentsOfFile:plistPath];
//    
//    // 3: If the plistDictionary was null, the file was not found.
//    if (plistDictionary == nil) {
//        CCLOG(@"Error reading SoundEffects.plist");
//        return nil; // No Plist Dictionary or file found
//    }
    
    NSDictionary *plistDictionary = [[PlistManager sharedPlistManager] soundEffectsDictionary];
    if (plistDictionary == nil) {
        CCLOG(@"Error reading SoundEffects.plist");
        return nil;
    }
    
    // 4. If the list of soundEffectFiles is empty, load it
    if ((listOfSoundEffectFiles == nil) || 
        ([listOfSoundEffectFiles count] < 1)) {
        CCLOG(@"Before");
        [self setListOfSoundEffectFiles:
         [[NSMutableDictionary alloc] init]];
        CCLOG(@"after");
        for (NSString *sceneSoundDictionary in plistDictionary) {
            [listOfSoundEffectFiles addEntriesFromDictionary:[plistDictionary objectForKey:sceneSoundDictionary]];
        }
        CCLOG(@"Number of SFX filenames:%d", 
              [listOfSoundEffectFiles count]);
    }
    
    // 5. Load the list of sound effects state, mark them as unloaded
    if ((soundEffectsState == nil) || 
        ([soundEffectsState count] < 1)) {
        [self setSoundEffectsState:[[NSMutableDictionary alloc] init]];
        for (NSString *SoundEffectKey in listOfSoundEffectFiles) {
            [soundEffectsState setObject:[NSNumber numberWithBool:SFX_NOTLOADED] forKey:SoundEffectKey];
        }
    }
    
    // 6. Return just the mini SFX list for this scene
    NSString *sceneIDName = [self formatSceneTypeToString:sceneID];
    NSDictionary *soundEffectsList = [plistDictionary objectForKey:sceneIDName];
    
    return soundEffectsList;
}

-(void)loadAudioForSceneWithID:(NSNumber*)sceneIDNumber {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    SceneTypes sceneID = (SceneTypes) [sceneIDNumber intValue];
    // 1
    if (managerSoundState == kAudioManagerInitializing) {
        int waitCycles = 0;
        while (waitCycles < AUDIO_MAX_WAITTIME) {
            [NSThread sleepForTimeInterval:0.1f];
            if ((managerSoundState == kAudioManagerReady) || 
                (managerSoundState == kAudioManagerFailed)) {
                break;
            }
            waitCycles = waitCycles + 1;
        }
    }
    
    if (managerSoundState == kAudioManagerFailed) {
        return; // Nothing to load, CocosDenshion not ready
    }
    
    NSDictionary *soundEffectsToLoad = 
    [self getSoundEffectsListForSceneWithID:sceneID];
    if (soundEffectsToLoad == nil) { // 2
        CCLOG(@"Error reading SoundEffects.plist");
        return;
    }
    // Get all of the entries and PreLoad // 3
    for( NSString *keyString in soundEffectsToLoad )
    {
        CCLOG(@"\nLoading Audio Key:%@ File:%@", 
              keyString,[soundEffectsToLoad objectForKey:keyString]);
        [soundEngine preloadEffect:
         [soundEffectsToLoad objectForKey:keyString]]; // 3
        // 4
        [soundEffectsState setObject:[NSNumber numberWithBool:SFX_LOADED] forKey:keyString];
        
    }
    [pool release];
}

-(void)unloadAudioForSceneWithID:(NSNumber*)sceneIDNumber {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    SceneTypes sceneID = (SceneTypes)[sceneIDNumber intValue];
    if (sceneID == kNoSceneUninitialized) {
        [pool release];
        return; // Nothing to unload
    }
    
    
    NSDictionary *soundEffectsToUnload = 
    [self getSoundEffectsListForSceneWithID:sceneID];
    if (soundEffectsToUnload == nil) {
        CCLOG(@"Error reading SoundEffects.plist");
        [pool release];
        return;
    }
    if (managerSoundState == kAudioManagerReady) {
        // Get all of the entries and unload
        for( NSString *keyString in soundEffectsToUnload )
        {
            [soundEffectsState setObject:[NSNumber numberWithBool:SFX_NOTLOADED] forKey:keyString];
            [soundEngine unloadEffect:keyString];
            CCLOG(@"\nUnloading Audio Key:%@ File:%@", 
                  keyString,[soundEffectsToUnload objectForKey:keyString]);
            
        }
    }
    [pool release];
}


-(void)initAudioAsync {
    // Initializes the audio engine asynchronously
    managerSoundState = kAudioManagerInitializing; 
    // Indicate that we are trying to start up the Audio Manager
    [CDSoundEngine setMixerSampleRate:CD_SAMPLE_RATE_MID];
    
    //Init audio manager asynchronously as it can take a few seconds
    //The FXPlusMusicIfNoOtherAudio mode will check if the user is
    // playing music and disable background music playback if 
    // that is the case.
    [CDAudioManager initAsynchronously:kAMM_FxPlusMusicIfNoOtherAudio];
    
    //Wait for the audio manager to initialise
    while ([CDAudioManager sharedManagerState] != kAMStateInitialised) 
    {
        [NSThread sleepForTimeInterval:0.1];
    }
    
    //At this point the CocosDenshion should be initialized
    // Grab the CDAudioManager and check the state
    CDAudioManager *audioManager = [CDAudioManager sharedManager];
    if (audioManager.soundEngine == nil || 
        audioManager.soundEngine.functioning == NO) {
        CCLOG(@"CocosDenshion failed to init, no audio will play.");
        managerSoundState = kAudioManagerFailed; 
    } else {
        [audioManager setResignBehavior:kAMRBStopPlay autoHandle:YES];
        soundEngine = [SimpleAudioEngine sharedEngine];
        managerSoundState = kAudioManagerReady;
        CCLOG(@"CocosDenshion is Ready");
    }
    
}

-(void)setupAudioEngine {
    if (hasAudioBeenInitialized == YES) {
        return;
    } else {
        hasAudioBeenInitialized = YES;
        NSOperationQueue *queue = [[NSOperationQueue new] autorelease];
        NSInvocationOperation *asyncSetupOperation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                          selector:@selector(initAudioAsync) object:nil];
        
        [queue addOperation:asyncSetupOperation];
        [asyncSetupOperation autorelease];
    }
}


-(NSDictionary*)loadTopicSpecificsForScene:(int)sceneType {
    NSDictionary *dict;
    
    switch (sceneType) {
        case kTopic1Scene:
            dict = [[PlistManager sharedPlistManager] topic1SpecificsDictionary];
            break;
        case kTopic2Scene:
            dict = [[PlistManager sharedPlistManager] topic2SpecificsDictionary];
            break;
        case kTopic3Scene:
            dict = [[PlistManager sharedPlistManager] topic3SpecificsDictionary];
            break;
        case kTopic4Scene:
            dict = [[PlistManager sharedPlistManager] topic4SpecificsDictionary];
            break;
        case kTopic5Scene:
            dict = [[PlistManager sharedPlistManager] topic5SpecificsDictionary];
            break;
        case kTopic6Scene:
            dict = [[PlistManager sharedPlistManager] topic6SpecificsDictionary];
            break;
        case kTopic7Scene:
            dict = [[PlistManager sharedPlistManager] topic7SpecificsDictionary];
            break;
        default:
            break;
    }
    
    if (dict == nil) {
        CCLOG(@"Error reading Topic?Specifics plist");
        return nil;
    }
 
    return dict;
}

@end

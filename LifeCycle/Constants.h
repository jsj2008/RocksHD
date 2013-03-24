//
//  Constants.h
//  LifeCycle
//
//  Created by Kelvin Chan on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef LifeCycle_Constants_h
#define LifeCycle_Constants_h

// "Factory setting" positions of various UI components

//#define DIDYOUKNOWPANE_POSITION (ccp(0.0121f * screenSize.width, 0.1107f * screenSize.height))

// About Main Text

// About Image Pane and Image stacks

//#define MAINTEXTIMAGE_VOICEOVERSLIDER_INITIAL_POSITION (ccp(0.4785f * screenSize.width, 0.778f * screenSize.height))

// Quiz
//#define QUIZ_NEXT_ICON_POSITION  (ccp(0.8359f * screenSize.width, 0.2552f * screenSize.height))
//#define QUIZ_CORRECT_ICON_POSITION (ccp(0.7012f * screenSize.width, 0.3984f * screenSize.height))
//#define QUIZ_WRONG_ICON_POSITION (ccp(0.7012f * screenSize.width, 0.3984f * screenSize.height))
//#define QUIZ_DARE_LABEL_POSITION (ccp(0.5f * screenSize.width, 0.5651f * screenSize.height))
//#define QUIZ_QUESTION_POSITION (ccp(0.125f * screenSize.width, 0.75f * screenSize.height))

// Info scene
//#define INFO_TEXT_POSITION (ccp(0.25f * screenSize.width, 0.8620f * screenSize.height))
// #define INFO_TEXT_VIEWPORT_HEIGHT (screenSize.height*2.0/3.0+90)
//#define INFO_TEXT_VIEWPORT_HEIGHT 550

//#define INFO_TEXT_PANE_POSITON (ccp(0.5f * screenSize.width, 0.5f * screenSize.height))

//#define INFO_MENU_POSITION (ccp(0.875f * screenSize.width, 0.9375f * screenSize.height))

typedef enum {
    kNoSceneUninitialized=0,
    kIntroScene=1,
    kTopic1Scene=2,
    kTopic2Scene=3,
    kTopic3Scene=4,
    kTopic4Scene=5,
    kTopic5Scene=6,
    kTopic6Scene=7,
    kTopic7Scene=8,
    kHomeScene=10,
    kPlayScene=100,
    kInfoScene=101,
    kPhotoScene=102,
    kVideoScene=103,
    kCurrScene=104,
    kMatchingGameScene=105,
    kOtherAppsScene=106,
    kTopicInteractiveScene=107,
    kQuizScene=108,
    kReadTextScene=109,
    kTestScene=999
} SceneTypes;

typedef enum {
    kCCTransitionNoneSpecified,
    kCCTransitionCrossFade,
    kCCTransitionPageTurnForward,
    kCCTransitionPageTurnBackward,
    kCCTransitionPageFlip
} CCTransitionStyles;

typedef enum {
    kLinkTypeWebSite
} LinkTypes;

// Audio Items 
#define AUDIO_MAX_WAITTIME 150 

typedef enum { 
    kAudioManagerUninitialized=0, 
    kAudioManagerFailed=1, 
    kAudioManagerInitializing=2, 
    kAudioManagerInitialized=100, 
    kAudioManagerLoading=200, 
    kAudioManagerReady=300 
} GameManagerSoundState; 

// Audio Constants 
#define SFX_NOTLOADED NO 
#define SFX_LOADED YES 

// Background Music and Voice Overs
#define BACKGROUND_TRACK_DUMMY @"Music - Menu page.mp3"
#define BACKGROUND_TRACK_MINIGAME @"Music - Game.mp3"
#define BACKGROUND_TRACK_GAME @"Music - Game.mp3"
#define BACKGROUND_TRACK_MENUPAGE @"Music - Menu page.mp3"
#define BACKGROUND_TRACK_MATCHING_GAME @"Music-Matching-Game.mp3"
#define BACKGROUND_TRACK_TEXTPAGE @"Music - Text page.mp3"

#define PLAYSOUNDEFFECT(...) \
[[FlowAndStateManager sharedFlowAndStateManager] playSoundEffect:@#__VA_ARGS__] 
#define PLAYSOUNDEFFECTWITHLOWERVOL(...) \
[[FlowAndStateManager sharedFlowAndStateManager] playSoundEffect:@#__VA_ARGS__ gain:0.3f] 
#define STOPSOUNDEFFECT(...) \
[[FlowAndStateManager sharedFlowAndStateManager] stopSoundEffect:__VA_ARGS__]
#define PLAYSOUNDEFFECTNEW(...) \
[[FlowAndStateManager sharedFlowAndStateManager] playSoundEffect:@#__VA_ARGS__]


// Network related notification

#define IMAGE_GALLERY_DOWNLOADER_DIDFINISH_NOTIFICATIONNAME @"ImageGalleryDownloaderDidFinishNotification"
#define IMAGE_DOWNLOADER_DIDFINISH_NOTIFICATIONNAME @"ImageDownloaderDidFinishNotification"
#define IMAGE_INFO_DOWNLOADER_DIDFINISH_NOTIFICATIONNAME @"ImageInfoDownloaderDidFinishNotification"
#define YOUTUBEVIDEO_DIDFINISH_NOTIFICATIONNAME @"YoutubeVideoDidFinishNotification"


#define WEB_SERVICE_URL @"http://webservices.infuzemobile.com/apps/watercycle"
#define APP_CONFIG_FILE_NAME @"app-config.dat"
#define debugLog( s, ... ) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#define debugLogX( s, ... ) 

#define IOS_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define IOS_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define IOS_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define IOS_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#endif

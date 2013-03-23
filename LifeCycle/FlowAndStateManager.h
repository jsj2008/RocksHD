//
//  GameManager.h
//  PlantHD
//
//  Created by Kelvin Chan on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "Constants.h"



@interface FlowAndStateManager : NSObject {
    
    int numOfStages;
    
    SceneTypes currentScene;
    
    // Added for audio
    BOOL hasAudioBeenInitialized;
    GameManagerSoundState managerSoundState;
    SimpleAudioEngine *soundEngine;
    NSMutableDictionary *listOfSoundEffectFiles;
    NSMutableDictionary *soundEffectsState;
    
    // Sprite position and anchor pt debugging.
    BOOL uiEditMode;
    NSString *currentBackgroundTrackName;
}

@property (readwrite) BOOL isMusicON;
@property (readwrite) BOOL isSoundEffectsON;
@property (readwrite) GameManagerSoundState managerSoundState;
@property (nonatomic, retain) NSMutableDictionary *listOfSoundEffectFiles;
@property (nonatomic, retain) NSMutableDictionary *soundEffectsState;
@property (readonly) SceneTypes currentScene;
@property (readonly) int numOfTopics;
@property (nonatomic, retain) NSString  *currentBackgroundTrackName;

+(FlowAndStateManager*)sharedFlowAndStateManager;
-(void)runSceneWithID:(SceneTypes)sceneID withTranstion:(CCTransitionStyles)transitionStyle;
-(void)runSceneSansAudioOpWithID:(SceneTypes)sceneID withTranstion:(CCTransitionStyles)transitionStyle;
-(void)openSiteWithLinkType:(LinkTypes)linkTypeToOpen;
-(NSDictionary *)loadBasicInfoForSceneWithID:(NSUInteger)topicNumber;

-(void)setupAudioEngine;
-(ALuint)playSoundEffect:(NSString *)soundEffectKey;
-(ALuint)playSoundEffect:(NSString*)soundEffectKey gain:(Float32)gain;
-(void)stopSoundEffect:(ALuint)soundEffectID;
-(void)playBackgroundTrack:(NSString *)trackFileName;
-(void)playBackgroundTrack:(NSString *)trackFileName loop:(BOOL)loop;
-(void)stopBackgroundTrack;
-(void)muteBackgroundTrack;
-(void)unMuteBackgroundTrack;

@end

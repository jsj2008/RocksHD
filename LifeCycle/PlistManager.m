//
//  PlistManager.m
//  LifeCycle
//
//  Created by Kelvin Chan on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlistManager.h"
#import "cocos2d.h"
#import "Constants.h"
@implementation PlistManager

@synthesize allTopicsPlistDictionary=_allTopicsPlistDictionary;

@synthesize topic1SpecificsDictionary=_topic1SpecificsDictionary;
@synthesize topic2SpecificsDictionary=_topic2SpecificsDictionary;
@synthesize topic3SpecificsDictionary=_topic3SpecificsDictionary;
@synthesize topic4SpecificsDictionary=_topic4SpecificsDictionary;
@synthesize topic5SpecificsDictionary=_topic5SpecificsDictionary;
@synthesize topic6SpecificsDictionary=_topic6SpecificsDictionary;
@synthesize topic7SpecificsDictionary=_topic7SpecificsDictionary;

@synthesize quizDictionary=_quizDictionary;

@synthesize soundEffectsDictionary=_soundEffectsDictionary;

@synthesize factorySettingsDictionary=_factorySettingsDictionary;

@synthesize appDictionary=_appDictionary;
@synthesize matchingGameDictionary=_matchingGameDictionary;

static PlistManager* _sharedPlistManager = nil;

-(void) dealloc {
    
    [_allTopicsPlistDictionary release];
    _allTopicsPlistDictionary = nil;
    
    [_topic1SpecificsDictionary release];
    _topic1SpecificsDictionary = nil;
    
    [_topic2SpecificsDictionary release];
    _topic2SpecificsDictionary = nil;
    
    [_topic3SpecificsDictionary release];
    _topic3SpecificsDictionary = nil;
    
    [_topic4SpecificsDictionary release];
    _topic4SpecificsDictionary = nil;
    
    [_topic5SpecificsDictionary release];
    _topic5SpecificsDictionary = nil;
    
    [_topic6SpecificsDictionary release];
    _topic6SpecificsDictionary = nil;
    
    [_topic7SpecificsDictionary release];
    _topic7SpecificsDictionary = nil;
    
    [_quizDictionary release];
    _quizDictionary = nil;
    
    [_factorySettingsDictionary release];
    _factorySettingsDictionary = nil;
   
    
    [_matchingGameDictionary release];
    _matchingGameDictionary = nil;
    

    [_appDictionary release];
    _appDictionary = nil;
    
    [super dealloc];
}

+(PlistManager*) sharedPlistManager {
    @synchronized([PlistManager class]) {
        if (!_sharedPlistManager) 
            [[self alloc] init];
        return _sharedPlistManager;
    }
    return nil;
}

+(id)alloc {
    @synchronized([PlistManager class]) {
        NSAssert(_sharedPlistManager == nil, @"Attempted to allocate a 2nd instance of the Config Manager singleton");
        _sharedPlistManager = [super alloc];
        return _sharedPlistManager;
    }
    return nil;
}

- (id)init
{
    self = [super init];
    if (self) {

    }
    
    return self;
}

-(NSDictionary *)loadBasicInfo {
    NSString *fullFileName = @"AllTopics.plist";
    NSString *plistPath;
    
    // 1: Get the Path to the plist file
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"AllTopics" ofType:@"plist"];
    }
    
    // 2: Read in the plist file
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    // 3: If the plistDictionary was null, the file was not found.
    if (plistDictionary == nil) {
//        CCLOG(@"Error reading AllTopics.plist");
        return nil;             // No Plist Dictionary or file found
    }
    
    return plistDictionary;
}

-(NSDictionary *)loadTopicSpecifics:(int)topicNum {
    NSString *filename = [NSString stringWithFormat:@"Topic%dSpecifics", topicNum];
    NSString *fullfilename = [NSString stringWithFormat:@"%@.plist", filename];
    
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:fullfilename];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:filename ofType:@"plist"];
    }
    
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    if (plistDictionary == nil) {
//        CCLOG(@"Error reading plist: %@.plist", filename);
        return nil;
    }

    return plistDictionary;

}

-(NSDictionary *)loadQuiz {
    NSString *fileName = @"Quiz";
    
    NSString *fullFileName = [NSString stringWithFormat:@"%@.plist", fileName];
    NSString *plistPath;
    
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    }
    
    NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    if (plistDict == nil) {
//        CCLOG(@"Error reading plist: %@.plist", fileName);
        return nil;
    }
    
    return plistDict;

}

-(NSDictionary*)loadSoundEffects {
    
    debugLog(@"Load sound effects");
    NSString *fullFileName = @"SoundEffects.plist";
    NSString *plistPath;
    
    // 1: Get the Path to the plist file
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"SoundEffects" ofType:@"plist"];
    }
    
    // 2: Read in the plist file
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    // 3: If the plistDictionary was null, the file was not found.
    if (plistDictionary == nil) {
       debugLog(@"Error reading SoundEffects.plist, not found check");
        return nil;                         // No Plist Dictionary or file found
    }

       debugLog(@"sound effects loaded successfully");    
    return plistDictionary;
}

-(NSDictionary*) loadFactorySettings {
    NSString *fullFileName = @"FactorySettings.plist";
    NSString *plistPath;
    
    // 1: Get the Path to the plist file
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"FactorySettings" ofType:@"plist"];
    }

    // 2: Read in the plist file
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    // 3: If the plistDictionary was null, the file was not found.
    if (plistDictionary == nil) {
        //        CCLOG(@"Error reading FactorySettings.plist");
        return nil;                         // No Plist Dictionary or file found
    }
    
    return plistDictionary;
}

-(NSDictionary*) loadApp {
    NSString *fullFileName = @"App.plist";
    NSString *plistPath;
    
    // 1: Get the Path to the plist file
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"App" ofType:@"plist"];
    }
    
    // 2: Read in the plist file
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    // 3: If the plistDictionary was null, the file was not found.
    if (plistDictionary == nil) {
        //        CCLOG(@"Error reading FactorySettings.plist");
        return nil;                         // No Plist Dictionary or file found
    }
    
    return plistDictionary;
}

-(NSDictionary*) loadMatchingGameDictionary {
    NSString *fullFileName = @"MatchingGame.plist";
    NSString *plistPath;
    
    // 1: Get the Path to the plist file
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"MatchingGame" ofType:@"plist"];
    }
    
    // 2: Read in the plist file
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    // 3: If the plistDictionary was null, the file was not found.
    if (plistDictionary == nil) {
           CCLOG(@"Error reading MatchingGame.plist");
        return nil;                         // No Plist Dictionary or file found
    }
    
    return plistDictionary;
}

-(NSDictionary*)allTopicsPlistDictionary {
    if (_allTopicsPlistDictionary == nil) {
        _allTopicsPlistDictionary = [self loadBasicInfo];
        [_allTopicsPlistDictionary retain];
    }
    return _allTopicsPlistDictionary;
}

-(NSDictionary*)topic1SpecificsDictionary {
    if (_topic1SpecificsDictionary == nil) {
        _topic1SpecificsDictionary = [self loadTopicSpecifics:1];
        [_topic1SpecificsDictionary retain];
    }
    return _topic1SpecificsDictionary;
}

-(NSDictionary*)topic2SpecificsDictionary {
    if (_topic2SpecificsDictionary == nil) {
        _topic2SpecificsDictionary = [self loadTopicSpecifics:2];
        [_topic2SpecificsDictionary retain];
    }
    return _topic2SpecificsDictionary;
}

-(NSDictionary*)topic3SpecificsDictionary {
    if (_topic3SpecificsDictionary == nil) {
        _topic3SpecificsDictionary = [self loadTopicSpecifics:3];
        [_topic3SpecificsDictionary retain];
    }
    return _topic3SpecificsDictionary;
}

-(NSDictionary*)topic4SpecificsDictionary {
    if (_topic4SpecificsDictionary == nil) {
        _topic4SpecificsDictionary = [self loadTopicSpecifics:4];
        [_topic4SpecificsDictionary retain];
    }
    return _topic4SpecificsDictionary;
}

-(NSDictionary*)topic5SpecificsDictionary {
    if (_topic5SpecificsDictionary == nil) {
        _topic5SpecificsDictionary = [self loadTopicSpecifics:5];
        [_topic5SpecificsDictionary retain];
    }
    return _topic5SpecificsDictionary;
}

-(NSDictionary*)topic6SpecificsDictionary {
    if (_topic6SpecificsDictionary == nil) {
        _topic6SpecificsDictionary = [self loadTopicSpecifics:6];
        [_topic6SpecificsDictionary retain];
    }
    return _topic6SpecificsDictionary;
}

-(NSDictionary*)topic7SpecificsDictionary {
    if (_topic7SpecificsDictionary == nil) {
        _topic7SpecificsDictionary = [self loadTopicSpecifics:7];
        [_topic7SpecificsDictionary retain];
    }
    return _topic7SpecificsDictionary;
}

-(NSDictionary*)quizDictionary {
    if (_quizDictionary == nil) {
        _quizDictionary = [self loadQuiz];
        [_quizDictionary retain];
    }
    return _quizDictionary;
}

-(NSDictionary*)soundEffectsDictionary {
    if (_soundEffectsDictionary == nil) {
        _soundEffectsDictionary = [self loadSoundEffects];
        [_soundEffectsDictionary retain];
    }
    return _soundEffectsDictionary;
}

-(NSDictionary*)factorySettingsDictionary {
    if (_factorySettingsDictionary == nil) {
        _factorySettingsDictionary = [self loadFactorySettings];
        [_factorySettingsDictionary retain];
    }
    return _factorySettingsDictionary;
}

-(NSDictionary*)appDictionary {
    if (_appDictionary == nil) {
        _appDictionary = [self loadApp];
        [_appDictionary retain];
    }
    return _appDictionary;
}

-(NSDictionary*)matchingGameDictionary {
    if (_matchingGameDictionary == nil) {
        _matchingGameDictionary = [self loadMatchingGameDictionary];
        [_matchingGameDictionary retain];
    }
    return _matchingGameDictionary;
}

-(NSDictionary*) getDictionaryForTopic:(int) topicId
{
    
    switch (topicId) {
        case kTopic1Scene:
            return [self topic1SpecificsDictionary];
            break;
        case kTopic2Scene:
            return [self topic2SpecificsDictionary];
            break;
        case kTopic3Scene:
            return [self topic3SpecificsDictionary];
            break;
        case kTopic4Scene:
            return [self topic4SpecificsDictionary];
            break;
        case kTopic5Scene:
            return [self topic5SpecificsDictionary];
            break;
        case kTopic6Scene:
            return [self topic6SpecificsDictionary];
            break;
        case kTopic7Scene:
            return [self topic7SpecificsDictionary];
            break;           
        default:
            break;
    }   
}

@end

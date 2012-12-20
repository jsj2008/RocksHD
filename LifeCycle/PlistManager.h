//
//  PlistManager.h
//  LifeCycle
//
//  Created by Kelvin Chan on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlistManager : NSObject

@property (nonatomic, readonly) NSDictionary *allTopicsPlistDictionary;

@property (nonatomic, readonly) NSDictionary *topic1SpecificsDictionary;
@property (nonatomic, readonly) NSDictionary *topic2SpecificsDictionary;
@property (nonatomic, readonly) NSDictionary *topic3SpecificsDictionary;
@property (nonatomic, readonly) NSDictionary *topic4SpecificsDictionary;
@property (nonatomic, readonly) NSDictionary *topic5SpecificsDictionary;
@property (nonatomic, readonly) NSDictionary *topic6SpecificsDictionary;
@property (nonatomic, readonly) NSDictionary *topic7SpecificsDictionary;

@property (nonatomic, readonly) NSDictionary *quizDictionary;

@property (nonatomic, readonly) NSDictionary *soundEffectsDictionary;

@property (nonatomic, readonly) NSDictionary *factorySettingsDictionary;

@property (nonatomic, readonly) NSDictionary *appDictionary;
@property (nonatomic, readonly) NSDictionary *matchingGameDictionary;


+(PlistManager *)sharedPlistManager;

-(NSDictionary*) getDictionaryForTopic:(int) topicId;
@end

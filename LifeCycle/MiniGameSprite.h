//
//  MiniGameSprite.h
//  PlantHD
//
//  Created by Kelvin Chan on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CCSprite.h"
#import "Constants.h"
#import "GameConstant.h"

@interface MiniGameSprite : CCSprite <CCTouchOneByOneDelegate> {
    CGPoint startTouchPt;
    CGPoint lastTouchPt;
    
    CGSize screenSize;
    int numOfTopics;
    
    CCArray *placeholders;  // MiniGameSprite is aware of "placeholders", and react to it.
    
    int wasInAPlaceHolderIndex;   // if -1, then its in no placeholder
    
    // for calculating momentum scrolling 
    NSDate *date;
    NSTimeInterval last_Dt;
    NSMutableArray *dtArray;
    NSMutableArray *dpxArray;
    NSMutableArray *dpyArray;
    
    // internal
    bool touchInProgress;
}

@property (nonatomic, retain) CCArray *placeholders;
@property (nonatomic, assign) int inPlaceHolderIndex;

+(MiniGameSprite*) miniGameSpriteWithTopic:(NSInteger)topic;

@end

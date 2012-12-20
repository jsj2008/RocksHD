//
//  MiniGame.h
//  PlantHD
//
//  Created by Kelvin Chan on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
    kMiniGameButtonTag=500,
    kMiniGameHomeMenuTag=501
} MiniGameTags;

@protocol MiniGameDelegate;

@interface MiniGame : NSObject {
    
    CCArray *miniGameSprites;
    CCArray *placeHolders;
    
    CGSize screenSize;
    int numOfTopics;
}

@property (nonatomic, assign) CCLayer *parentLayer;

+(id)gameWithParentLayer:(CCLayer*)parentLayer;
-(void)start;
-(void)installHomeButton;
-(void)removeHomeButton;
-(void)forceEndGame;

@end

@protocol MiniGameDelegate 

@optional
-(void) miniGameDidFinish:(MiniGame *)miniGame;
@end

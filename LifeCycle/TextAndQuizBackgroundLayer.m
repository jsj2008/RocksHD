//
//  TextAndQuizBackgroundLayer.m
//  PlantHD
//
//  Created by Kelvin Chan on 10/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TextAndQuizBackgroundLayer.h"
#import "Constants.h"

@implementation TextAndQuizBackgroundLayer

- (id)init
{
    self = [super init];
    if (self) {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        CCLayerColor *colorLayer = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 255)];
        [self addChild:colorLayer z:0 tag:kTextAndQuizColorTag];
            
        CCSprite *bg = [CCSprite spriteWithFile:@"quizbackground.png"];
        bg.position = ccp(screenSize.width/2, screenSize.height/2);
        bg.opacity = 195;
        [self addChild:bg z:0 tag:kTextAndQuizBackgroundTag];
                
        CCSprite *quizbox = [CCSprite spriteWithFile:@"quiz-box.png"];
        quizbox.position = ccp(screenSize.width/2, screenSize.height/2);
        quizbox.opacity = 195;
        [self addChild:quizbox z:0 tag:0];


    }
    
    return self;
}

@end

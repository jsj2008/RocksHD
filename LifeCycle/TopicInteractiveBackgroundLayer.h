//
//  TopicInteractiveBackgroundLayer.h
//  SLPOC
//
//  Created by Kelvin Chan on 8/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  The primary entry layer for a particular topic with interactive background to popup text, audio, or video.
//  It also has button access to multimedia, as well as home and audio control buttons.

#import "cocos2d.h"
//#import "SLLayer.h"
#import "TopicInfo.h"
#import "CCUIPopupView.h"

@interface TopicInteractiveBackgroundLayer : CCLayer <CCTargetedTouchDelegate, CCUIPopupViewDelegate>
{
    // Instance variable with Protect scope
    CGSize screenSize;
    CGPoint globalCenter;
    NSMutableDictionary *navigationMap;
    TopicInfo *info;
    NSMutableArray *hotspotBounds;
    int currentHotspotsFilledBackgroundIndex;
    
    // Touch
    CGPoint startTouchPoint;
    CGPoint lastTouchPoint;

}

@property (nonatomic, retain) TopicInfo *info;
@property (nonatomic, retain) NSMutableDictionary *navigationMap;

@end

@interface GlowingHotSpotSprite : CCSprite


@end

@interface BackgroundSprite : CCSprite

@end
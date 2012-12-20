//
//  CCSeasonControl.h
//  PlantHD
//
//  Created by Kelvin Chan on 10/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CCSprite.h"

@interface CCSeasonControl : CCSprite {
// <CCTargetedTouchDelegate> {
    CGSize screenSize;
    float initialAngle;
    float second_per_season;
    
    CCSprite *nob;
    float nobRadius;
    NSString *yrLabelStr;
    int year;
    
    CCLabelTTF *seasonLabel;
    
    // nob state
    float angle;
    
    // internal opt
    float timeElapsedInTheYr;
    
}

@property (nonatomic, assign) float nobRadius;
@property (nonatomic, assign) float angle;
@property (nonatomic, retain) NSString *yrLabelStr;
@property (nonatomic, assign) int year;
@property (nonatomic, retain) NSString *season;

+ (CCSeasonControl *) ccSeasonControlWithStartingAngle:(float)initialAngle;
- (void) update:(ccTime)deltaTime;


@end

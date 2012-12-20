//
//  CCSeasonControl.m
//  PlantHD
//
//  Created by Kelvin Chan on 10/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CCSeasonControl.h"
#import "GameConstant.h"

@implementation CCSeasonControl

@synthesize nobRadius, angle, yrLabelStr, year, season;

-(void)dealloc {
    [yrLabelStr release];
    [season release];
    
    [super dealloc];
}

+ (CCSeasonControl *) ccSeasonControlWithStartingAngle:(float) initialAngle {
    CCSeasonControl *ret = [CCSeasonControl spriteWithFile:@"seasoncontrol.png"];
    ret.nobRadius = ret.boundingBox.size.width/2;
    ret.yrLabelStr = @"Year 1";
    ret.angle = initialAngle;
    
    return ret;
}


-(id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)onEnter {
    screenSize = [CCDirector sharedDirector].winSize;
    // [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    
    nob = [CCSprite spriteWithFile:@"slidernob.png"];
    
    if (nobRadius == 0)
        nobRadius = self.boundingBox.size.height/4;
    
    second_per_season = t_s;
        
    initialAngle = angle;
    year = 1;
    
    float x = nobRadius*cos(angle);
    float y = nobRadius*sin(angle);
    
    nob.position = ccp(self.boundingBox.size.width/2 + x, self.boundingBox.size.height/2 + y);
    [self addChild:nob];
    
    seasonLabel = [CCLabelTTF labelWithString:yrLabelStr fontName:@"Marker Felt" fontSize:24];
    seasonLabel.color = ccc3(0, 0, 0);
    seasonLabel.position = ccp(self.boundingBox.size.width/2, self.boundingBox.size.height/2);
    [self addChild:seasonLabel];
    
    // Label the 4 seasons
    CCLabelTTF *fallLabel = [CCLabelTTF labelWithString:@"Fall" fontName:@"Marker Felt" fontSize:24];
    fallLabel.color = ccc3(0, 0, 0);
    fallLabel.position = ccp(0, self.boundingBox.size.height);
    [self addChild:fallLabel];
    
    CCLabelTTF *winterLabel = [CCLabelTTF labelWithString:@"Winter" fontName:@"Marker Felt" fontSize:24];
    winterLabel.color = ccc3(0, 0, 0);
    winterLabel.position = ccp(self.boundingBox.size.width+10, self.boundingBox.size.height);
    [self addChild:winterLabel];
    
    CCLabelTTF *springLabel = [CCLabelTTF labelWithString:@"Spring" fontName:@"Marker Felt" fontSize:24];
    springLabel.color = ccc3(0, 0, 0);
    springLabel.position = ccp(self.boundingBox.size.width+10, 0);
    [self addChild:springLabel];
    
    CCLabelTTF *summerLabel = [CCLabelTTF labelWithString:@"Summer" fontName:@"Marker Felt" fontSize:24];
    summerLabel.color = ccc3(0, 0, 0);
    summerLabel.position = ccp(-10, 0);
    [self addChild:summerLabel];
    
}

-(void)onExit {
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super onExit];
}

#pragma mark - Getters and Setters

-(void)setAngle:(float)ang {
    angle = ang;
    float x = nobRadius * cos(angle);
    float y = nobRadius * sin(angle);
    
    nob.position = ccp(self.boundingBox.size.width/2 + x, self.boundingBox.size.height/2 + y);
}
- (void) update:(ccTime)deltaTime {
    
    timeElapsedInTheYr += deltaTime;
    
    if (timeElapsedInTheYr > second_per_season*4.0f) {    // 1 year has passed.
        year++;
        self.yrLabelStr = [NSString stringWithFormat:@"Year %d", year];
        seasonLabel.string = self.yrLabelStr;
        timeElapsedInTheYr = 0.0;
    }
    
    self.angle = - timeElapsedInTheYr * M_PI / (second_per_season*2.0f) + initialAngle;

    // compute the season
    
    if (timeElapsedInTheYr > 0.0 && timeElapsedInTheYr < second_per_season) {
        season = @"Fall";
    }
    else if (timeElapsedInTheYr > second_per_season && timeElapsedInTheYr < second_per_season*2.0) {
        season = @"Winter";
    }
    else if (timeElapsedInTheYr > second_per_season*2.0 && timeElapsedInTheYr < second_per_season*3.0) {
        season = @"Spring";
    }
    else 
        season = @"Summer";
    
}


/*
#pragma mark - Touch

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
    
    return CGRectContainsPoint(self.boundingBox, loc);
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {

}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    
}
*/

@end

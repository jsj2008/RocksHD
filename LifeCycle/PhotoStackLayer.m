//
//  PhotoStackLayer.m
//  ButterflyHD
//
//  Created by Kelvin Chan on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoStackLayer.h"

@interface PhotoStackLayer() 
@property (nonatomic, retain) SLCCImageStack *stack;
@end

@implementation PhotoStackLayer

@synthesize stack = _stack;
@synthesize topicInfo = _topicInfo;

-(void) dealloc {
    [_stack release];
    [_topicInfo release];
    
    [super dealloc];
}

-(id)init {
    self = [super init];
    if (self) {
        screenSize = [CCDirector sharedDirector].winSize;
        
        isNumOfImagesKnown = NO;
        numOfImages = 0;
        
        
        
        
    }
    return self;
}



@end

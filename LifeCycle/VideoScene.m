//
//  VideoScene.m
//  ButterflyPOC
//
//  Created by Kelvin Chan on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideoScene.h"
#import "VideoLayer.h"

@implementation VideoScene

@synthesize topicInfo=_topicInfo;

-(void) dealloc {
    [_topicInfo release];
    
    [super dealloc];
}

-(id)init 
{
    self = [super init];
    if (self) {
        VideoLayer *t = [VideoLayer node];
        [self addChild:t z:0 tag:0];
    }
    
    return self;
}

-(void)setTopicInfo:(NSDictionary *)topicInfo {
    if (_topicInfo == topicInfo) 
        return;
    
    NSDictionary *oldval = _topicInfo;
    _topicInfo = [topicInfo retain];
    [oldval release];
    
    VideoLayer *t = (VideoLayer*) [self getChildByTag:0];
    t.topicInfo = _topicInfo;
}

@end

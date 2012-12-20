//
//  TestScene.m
//  LifeCycle
//
//  Created by Kelvin Chan on 1/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestScene.h"
#import "TestLayerPhotoSlidersFromFlickr.h"
#import "TestLayerWebViewVideoPlayer.h"

@implementation TestScene

- (id)init
{
    self = [super init];
    if (self) {
        TestLayer *testLayer = [TestLayer node];
        [self addChild:testLayer z:0];
        
//        TestLayerPhotoSlidersFromFlickr *t = [TestLayerPhotoSlidersFromFlickr node];
//        [self addChild:t z:0];
        
//        TestLayerWebViewVideoPlayer *t2 = [TestLayerWebViewVideoPlayer node];
//        [self addChild:t2 z:0];
    }
    
    return self;
}

@end

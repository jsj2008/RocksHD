//
//  SLCCCompositeNode.m
//  SLPOC
//
//  Created by Kelvin Chan on 11/2/12.
//
//

#import "SLCCCompositeNode.h"

@implementation SLCCCompositeNode

-(id) init {
    self = [super init];
    if (self) {
        screenSize = [CCDirector sharedDirector].winSize;
    }
    return self;
}

-(CGRect) obtainUIKitFrameForGLOrigin:(CGPoint)origin andSize:(CGSize)size {
    CGPoint o = [[CCDirector sharedDirector] convertToUI:origin];
    // offset to place origin at the top left as in UIKit convention
    o.y -= size.height;
    return CGRectMake(o.x, o.y, size.width, size.height);
}

-(CGSize)adjustedContentSize {
    CCLOG(@"SLCCCompositeNode adjustedContentSize should be overriden");
    NSAssert(NO, @"Subclass must override BUT don't call super on adjustedContentSize");
    return [self contentSize];
}

-(CGRect)adjustedBoundingBox {
    CCLOG(@"SLCCCompositeNode adjustedBoundingBox should be overriden");
    NSAssert(NO, @"Subclass must override BUT don't call super on adjustedBoundingBox");
    return [self boundingBox];
}

@end

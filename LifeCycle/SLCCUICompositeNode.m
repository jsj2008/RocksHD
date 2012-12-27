//
//  SLCCUICompositeNode.m
//  SLPOC
//
//  Created by Kelvin Chan on 11/12/12.
//
//

#import "SLCCUICompositeNode.h"
#import "CCUIViewWrapper.h"

@implementation SLCCUICompositeNode {
    CCUIViewWrapper *wrapper;
}

-(void) dealloc {
    [self removeChild:wrapper cleanup:YES];
    wrapper = nil;
    
    [super dealloc];
}

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

-(void) embedUIView:(UIView *)uiView {
    wrapper = [CCUIViewWrapper wrapperForUIView:uiView bringGLViewToFront:NO defaultViewHierStruct:YES];
    [self addChild:wrapper];

}

-(CGSize)adjustedContentSize {
    CCLOG(@"SLCCUICompositeNode adjustedContentSize should be overriden");
    NSAssert(NO, @"Subclass must override BUT don't call super on adjustedContentSize");
    return [self contentSize];
}

-(CGRect)adjustedBoundingBox {
    CCLOG(@"SLCCUICompositeNode adjustedBoundingBox should be overriden");
    NSAssert(NO, @"Subclass must override BUT don't call super on adjustedBoundingBox");
    return [self boundingBox];
}

@end

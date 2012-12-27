//
//  SLCCUIPageControl.m
//  ButterflyPOC
//
//  Created by Kelvin Chan on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLCCUIPageControl.h"

@implementation SLCCUIPageControl {
    CGSize adjustedContentSize;
    
    UIPageControl *pageControl;
}

@synthesize numberOfPages, currentPage;

-(void) dealloc {
    
    if (pageControl != nil)
        [pageControl release];
    
    [super dealloc];
}

+(id) slCCUIPageControlWithParentNode:(CCNode *)parentNode withGlFrame:(CGRect)glFrame {
    return [[[self alloc] initWithParentNode:parentNode withGlFrame:glFrame] autorelease];
}

-(id) initWithParentNode:(CCNode *)parentNode withGlFrame:(CGRect)glFrame {
    self = [super init];
    if (self) {
        [parentNode addChild:self];
        
        if (CGRectIsNull(glFrame)) {
            CGPoint o = ccp(screenSize.width*0.5, screenSize.height*0.5 + 280.0);
            CGSize s = CGSizeMake(10.0, 10.0);
            glFrame = CGRectMake(o.x, o.y, s.width, s.height);
        }
        
        CGRect fr = [self obtainUIKitFrameForGLOrigin:glFrame.origin andSize:glFrame.size];
        _frame = fr;
        
        pageControl = [[UIPageControl alloc] init];
        pageControl.numberOfPages = 1;
        pageControl.currentPage = 0;
        pageControl.defersCurrentPageDisplay = NO;
        
        if ([pageControl respondsToSelector:@selector(setCurrentPageIndicatorTintColor:)]) {
            pageControl.currentPageIndicatorTintColor = [UIColor redColor];
            pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        }
        
        pageControl.frame = fr;
        [self embedUIView:pageControl];
        
        adjustedContentSize = glFrame.size;
        position_ = glFrame.origin;
    }
    return self;
}

-(CGSize)adjustedContentSize {
    return adjustedContentSize;
}

-(CGRect)adjustedBoundingBox {
    // return this in GL Coord and convention for rectangle
    return CGRectMake(position_.x, position_.y, adjustedContentSize.width, adjustedContentSize.height);
}

#pragma mark - Getters & Setters
-(void) setPosition:(CGPoint)position {
    [super setPosition:position];
    
    // If this node's position is changed externally, readjust the UIKit frame
    // to be consistent with that.
    
    CGRect f = [self obtainUIKitFrameForGLOrigin:position andSize:self.frame.size];
    
    pageControl.frame = f;
    self.frame = f;
}

-(void) setNumberOfPages:(NSInteger)numOfPages {
    pageControl.numberOfPages = numOfPages;
}

-(void) setCurrentPage:(NSInteger)currPage {
    pageControl.currentPage = currPage;
}

-(NSInteger)numberOfPages {
    return pageControl.numberOfPages;
}

-(NSInteger)currentPage {
    return pageControl.currentPage;
}

-(BOOL) isHidden {
    return pageControl.hidden;
}

-(void) setHidden:(BOOL)bHidden {
    pageControl.hidden = bHidden;
}

@end

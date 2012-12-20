//
//  SLCCUIPageControl.m
//  ButterflyPOC
//
//  Created by Kelvin Chan on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLCCUIPageControl.h"

@implementation SLCCUIPageControl

@synthesize numberOfPages, currentPage;

-(void) dealloc {
    
    if (pageControl != nil)
        [pageControl release];
    
    [self removeChild:wrapper cleanup:YES];
    wrapper = nil;
    
    [super dealloc];
}

+(id) slCCUIPageControlWithParentNode:(CCNode *)parentNode {
    return [[[self alloc] initWithParentNode:parentNode] autorelease];
}

-(id) initWithParentNode:(CCNode *)parentNode {
    self = [super init];
    if (self) {
        [parentNode addChild:self];
        
        screenSize = [CCDirector sharedDirector].winSize;
        
        CGPoint position = [[CCDirector sharedDirector] convertToUI:ccp(screenSize.width*0.5, screenSize.height*0.5 + 280.0)];
        
        CGRect frame = CGRectMake(position.x, position.y, 10.0, 10.0);
        
        pageControl = [[UIPageControl alloc] init];
        pageControl.frame = frame;
        pageControl.numberOfPages = 1;
        pageControl.currentPage = 0;
        pageControl.defersCurrentPageDisplay = NO;
    
        wrapper = [CCUIViewWrapper wrapperForUIView:pageControl bringGLViewToFront:NO defaultViewHierStruct:YES];
        [self addChild:wrapper];
        
    }
    return self;
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

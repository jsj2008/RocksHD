//
//  SLCCUIPageControl.h
//  ButterflyPOC
//
//  Created by Kelvin Chan on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCNode.h"
#import "CCUIViewWrapper.h"

@interface SLCCUIPageControl : CCNode {
    
    CGSize screenSize;

    CCUIViewWrapper *wrapper;
    UIPageControl *pageControl;
}

@property(nonatomic) NSInteger numberOfPages;
@property(nonatomic) NSInteger currentPage;
@property(nonatomic, getter=isHidden) BOOL hidden;

+(id) slCCUIPageControlWithParentNode:(CCNode *)parentNode;
-(id) initWithParentNode:(CCNode *)parentNode;

@end

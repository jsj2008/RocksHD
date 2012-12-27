//
//  SLCCUIPageControl.h
//  ButterflyPOC
//
//  Created by Kelvin Chan on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SLCCUICompositeNode.h"

@interface SLCCUIPageControl : SLCCUICompositeNode

@property(nonatomic) NSInteger numberOfPages;
@property(nonatomic) NSInteger currentPage;
@property(nonatomic, getter=isHidden) BOOL hidden;

+(id) slCCUIPageControlWithParentNode:(CCNode *)parentNode withGlFrame:(CGRect)glFrame;
-(id) initWithParentNode:(CCNode *)parentNode withGlFrame:(CGRect)glFrame;

@property (nonatomic, assign) CGRect frame;   // Note: this is UIKit frame;

@end

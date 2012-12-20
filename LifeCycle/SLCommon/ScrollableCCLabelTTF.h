//
//  ScrollableCCLabelTTF.h
//  SLCommon
//
//  Created by Kelvin Chan on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCLabelTTF.h"
#import "cocos2d.h"

@protocol ScrollableCCLabelTTFDelegate;

@interface ScrollableCCLabelTTF : CCLabelTTF <CCTargetedTouchDelegate> {
    CGPoint startTouchPt;
    CGPoint lastTouchPt;
    
    CGSize screenSize;
    
    CGPoint fixedPosition;
    CGPoint highTresholdPosition;
    
    float viewPortRatio;
    float viewPortHeight;
    
    // for calculating momentum scrolling
    NSDate *date;
    NSTimeInterval last_Dt;
    NSMutableArray *dtArray;
    NSMutableArray *dpxArray;
    NSMutableArray *dpyArray;
    
    // internal
    BOOL bScrollable;
    
}

@property (readwrite) float viewPortRatio;
@property (readwrite) float viewPortHeight;

@property (nonatomic, assign) id<ScrollableCCLabelTTFDelegate> delegate;

-(void) freezeScrolling;
-(void) unfreezeScrolling;

@end

@protocol ScrollableCCLabelTTFDelegate <NSObject>

@optional
-(void) scrollableCCLabelTTFBeginScroll:(ScrollableCCLabelTTF*)scrollableCCLabelTTF;
-(void) scrollableCCLabelTTFDidScroll:(ScrollableCCLabelTTF*)scrollableCCLabelTTF;

@end

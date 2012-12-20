//
//  SLCCImageStack.h
//  LifeCycle
//
//  Created by Kelvin Chan on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CCNode.h"
#import "SLObjectPool.h"

@class SLCCImageStack;

@protocol SLCCImageStackDataSource <NSObject>
-(NSInteger) sLCCImageStack:(SLCCImageStack *) sLCCImageStack numberOfObjectsInSection:(NSInteger)section;
-(id) sLCCImageStack:(SLCCImageStack *) sLCCImageStack objectforIndex:(NSInteger)index;
@end

@protocol SLCCImageStackDelegate <NSObject>
@optional
-(void) slCCImageStack:(SLCCImageStack *)sender didShuffleToCurrentIndex:(int)index;
@end

@interface SLCCImageStack : CCNode <CCTargetedTouchDelegate> {
    
    // Object pool
    SLObjectPool *pool;
    
    // UI State
    int cursorTop;          // index point to the top "card" on stack/deck
    int cursorTop2;         // index pointing to 2nd "card" on stack/deck
    int cursorBottom;       // index pointing to the bottom on stack/deck
    float dAngle;
    float dX;
    int numberOfObjects;
    id spriteMoving;
    
    // Sprite Refs
    id spriteTop;           // pt to instantiated "id" on top
    id spriteTop2;          // pt to instantiated "id" on 2nd top
    id spriteBottom;        // pt to instantiated "id" at the bottom
    
    // Touches
    CGPoint startTouchPt;
    CGPoint lastTouchPt;
    CGRect touchBound;
    
}

@property (nonatomic, assign) id<SLCCImageStackDataSource> dataSource;
@property (nonatomic, assign) id<SLCCImageStackDelegate> delegate;
@property (nonatomic, retain) SLObjectPool *pool;
@property (nonatomic, readonly) int cursorTop;

+(id) slCCImageStackWithParentNode:(CCNode*)parentNode;
-(id) initWithParentNode:(CCNode*)parentNode;
-(void) show;
-(void) reset;
-(void) syncWithIndex:(int)index;
-(id) dequeueReusableObject;

@end



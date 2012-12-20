//
//  SLCCPhotoSlides.h
//  LifeCycle
//
//  Created by Kelvin Chan on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CCNode.h"
#import "SLObjectPool.h"

@protocol SLCCPhotoSlidesDataSource;
@protocol SLCCPhotoSlidesDelegate;


@interface SLCCPhotoSlides : CCNode <CCTargetedTouchDelegate, UIGestureRecognizerDelegate> {
        
    // Object pool
    SLObjectPool *pool;

    // UI State
    int cursorVisible;
//    int cursorMaybeVisibleLeft;
//    int cursorMaybeVisibleRight;
    
    int *cursorVL;              // indexing instantiated stuff to right of centrally visible one
    int *cursorVR;              // indexing instantiated stuff to left of centrally visible one
    int numberOfCursorVLR;      // symmetrical
    
    int numberOfObjects;
    
    // Sprite references
    id spriteVisible;
//    id spriteMaybeVisibleLeft;
//    id spriteMaybeVisibleRight;
    
    NSMutableArray *spriteVL;   // pt to instantiated "id" to right of centrally visible one
    NSMutableArray *spriteVR;   // pt to instantiated "id" to left of centrally visible one
    
    CGSize internal_contentSize;
    
    // Touches
    CGPoint startTouchPt;
    CGPoint lastTouchPt;
    CGRect touchBound;
    
}

@property (nonatomic, assign) id<SLCCPhotoSlidesDataSource> dataSource;
@property (nonatomic, assign) id<SLCCPhotoSlidesDelegate> delegate;
@property (nonatomic, retain) SLObjectPool *pool;
@property (nonatomic, readonly) int cursorVisible;
@property (nonatomic, assign) CGSize fixedSize;
@property (nonatomic, assign) int numOfNeighbors;
@property (nonatomic, assign) BOOL frozen;   // stop it responding to panning
@property (nonatomic, readonly) BOOL scrolling; 

+(id) slCCPhotoSlidesWithParentNode:(CCNode*)parentNode;
-(id) initWithParentNode:(CCNode*)parentNode;
-(void) show;
-(void) reset;
-(void) syncWithIndex:(int)index;
-(id) dequeueReusableObject;
@end

@protocol SLCCPhotoSlidesDataSource <NSObject>

-(NSInteger) sLCCPhotoSlides:(SLCCPhotoSlides *) sLCCPhotoSlides numberOfObjectsInSection:(NSInteger)section;
// -(NSString *) sLCCPhotoSlides:(SLCCPhotoSlides *) sLCCPhotoSlides imageNameforIndex:(NSInteger)index;
-(id) sLCCPhotoSlides:(SLCCPhotoSlides *) sLCCPhotoSlides objectforIndex:(NSInteger)index;

@end

@protocol SLCCPhotoSlidesDelegate <NSObject>

@optional
-(void) sLCCPhotoSlides:(SLCCPhotoSlides *) sLCCPhotoSlides didScrollToCurrentIndex:(int) index;

@end
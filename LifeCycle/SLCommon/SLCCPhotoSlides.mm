//
//  SLCCPhotoSlides.m
//  LifeCycle
//
//  Created by Kelvin Chan on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLCCPhotoSlides.h"
#import "CCImageReflector.h"
#import "AppConfigManager.h"

@interface SLCCPhotoSlides (Private) 
@end

@implementation SLCCPhotoSlides

@synthesize dataSource;
@synthesize delegate;
@synthesize pool;
@synthesize cursorVisible;
@synthesize fixedSize;
@synthesize numOfNeighbors=_numOfNeighbors;
@synthesize frozen = _frozen;
@synthesize scrolling;

#pragma mark - OBject Life Cycle

-(void) dealloc {
    CCLOG(@"deallocating SLCCPhotoSlide");
    
    [pool release];
    
    if (spriteVL != nil) [spriteVL release];
    
    if (spriteVR != nil) [spriteVR release];
    
    if (cursorVL != NULL) {
        delete cursorVL;
        cursorVL = NULL;
    }
    
    if (cursorVR != NULL) {
        delete cursorVR;
        cursorVR = NULL;
    }
    
    [super dealloc];
}

+(id) slCCPhotoSlidesWithParentNode:(CCNode*)parentNode {
    return [[[self alloc] initWithParentNode:parentNode] autorelease];
}

-(id) initWithParentNode:(CCNode*)parentNode {
    
    self = [super init];
    if (self) {
        [parentNode addChild:self];
        self.pool = [SLObjectPool objectsPoolWithCapacity:10];
        fixedSize = CGSizeZero;
        self.numOfNeighbors = 1;
    }
    
    return self;
}

-(void)onEnter {
    [super onEnter];    

    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:1 swallowsTouches:NO];

}

-(void)onExit {
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super onExit];
}

-(void)visit {
    if (!self.visible) {
        return;
    }
        
    float width = internal_contentSize.width;
    float height = internal_contentSize.height;
    
    glEnable(GL_SCISSOR_TEST);
    
    AppConfigManager *cfg = [AppConfigManager getInstance];
    int scale = 1;
    if ([cfg isRetinaDisplay])
    {
        scale = 2;
    }
   
    
    glScissor((self.position.x - width*0.5)*scale, (self.position.y - height*0.5)*scale, width*scale, height*scale);
    [super visit];
    glDisable(GL_SCISSOR_TEST);
}

#pragma mark - Getters & Setters
-(void)setNumOfNeighbors:(int)numOfNeighbors {
    // as soon as this is set, we will know how big to allocate 
    _numOfNeighbors = numOfNeighbors;
    
    if (_numOfNeighbors > 0) {
        cursorVL = new int[_numOfNeighbors];
        cursorVR = new int[_numOfNeighbors];

        // to be save, zeros them
        for (int i = 0; i < _numOfNeighbors; i++) {
            cursorVL[i] = 0;
            cursorVR[i] = 0;
        }
        
        spriteVL = [[NSMutableArray alloc] initWithCapacity:_numOfNeighbors];
        spriteVR = [[NSMutableArray alloc] initWithCapacity:_numOfNeighbors];
        
        for (int i = 0; i < _numOfNeighbors; i++) {
            [spriteVL addObject:[NSNull null]];
            [spriteVR addObject:[NSNull null]];
        }

    }
}

#pragma mark - Object pool 
-(id) dequeueReusableObject {
    return [pool dequeueReusableObject];
}


#pragma mark - Display Logic
-(void) show {
    
    if (self.pool == nil)
        self.pool = [SLObjectPool objectsPoolWithCapacity:10];
    
    numberOfObjects = [dataSource sLCCPhotoSlides:self numberOfObjectsInSection:0];
    CCLOG(@"number of objects = %d", numberOfObjects);
    
    if (numberOfObjects <= 0)   
        return;                 // shouldnt do anything more.
    
    // initialize cursorVisible, cursorVL[], and cursorVR[]
    cursorVisible = 0;
//    cursorMaybeVisibleLeft = -1;
//    cursorMaybeVisibleRight = 1;
    
    // run up to only there's enuf to go around
    numberOfCursorVLR = MIN( (int) ceilf(((float) numberOfObjects - 1.0)/2.0), _numOfNeighbors);
    
    for (int k = 0; k < numberOfCursorVLR; k++) 
        cursorVL[k] = -(k+1);
    
    for (int k = 0; k < numberOfCursorVLR; k++)
        cursorVR[k] = k+1;

    // get the instance for the centrally visible one.
    id imageVisible = [dataSource sLCCPhotoSlides:self objectforIndex:cursorVisible];
    [pool assignObjectToPool:imageVisible];
    [imageVisible setPosition:ccp(0.0, 0.0)];
    [self addChild:imageVisible];
    spriteVisible = imageVisible;
    
    // Set touchBound to be the same as the 1st image
    CGPoint visibleImageOrigin = [imageVisible boundingBox].origin;
    CGSize visibleImageSize = [imageVisible boundingBox].size;
    
//    CGRect box = [imageVisible boundingBox];
//    CCLOG(@"visibleImageOrigin= %f, %f", visibleImageOrigin.x, visibleImageOrigin.y);
    
    if (fixedSize.width == 0 && fixedSize.height == 0)  // no fixedSize provided, figure this out dynamically
        touchBound = CGRectMake(visibleImageOrigin.x + self.position.x, visibleImageOrigin.y + self.position.y, 
                                visibleImageSize.width, visibleImageSize.height);
    else
        touchBound = CGRectMake(-fixedSize.width*0.5 + self.position.x, -fixedSize.height*0.5 + self.position.y, 
                                fixedSize.width, fixedSize.height);
    
    // get the instance for the stuff to the right 
    for (int k = 0; k < numberOfCursorVLR; k++) {
        id imageMaybeVisible = [dataSource sLCCPhotoSlides:self objectforIndex:cursorVR[k]];
        [pool assignObjectToPool:imageMaybeVisible];
        
        if (fixedSize.width == 0)
            [imageMaybeVisible setPosition:ccp(visibleImageSize.width * (k+1), 0.0)];
        else
            [imageMaybeVisible setPosition:ccp(fixedSize.width * (k+1), 0.0)];
        
        [self addChild:imageMaybeVisible];
//        [spriteVR addObject:imageMaybeVisible];
        [spriteVR replaceObjectAtIndex:k withObject:imageMaybeVisible];
    }
    
    // nothing to do for all spriteVL
    
//    id imageMaybeVisible = [dataSource sLCCPhotoSlides:self objectforIndex:cursorMaybeVisibleRight];
//    [pool assignObjectToPool:imageMaybeVisible];
//    
//    if (fixedSize.width == 0)
//        [imageMaybeVisible setPosition:ccp(visibleImageSize.width, 0.0)];
//    else
//        [imageMaybeVisible setPosition:ccp(fixedSize.width, 0.0)];
//    
//    [self addChild:imageMaybeVisible];
    
    // set the references
//    spriteMaybeVisibleRight = imageMaybeVisible;
//    spriteMaybeVisibleLeft = nil;
    
    if (fixedSize.width == 0 && fixedSize.height == 0)
        internal_contentSize = [spriteVisible boundingBox].size;
    else
        internal_contentSize = CGSizeMake(fixedSize.width, fixedSize.height);
    
}

-(void) reset {
    self.pool = nil;   // release the pool
    [self removeAllChildrenWithCleanup:YES];
    
    // reset cursor arrays to zeros
    for (int i = 0; i < _numOfNeighbors; i++) {
        cursorVL[i] = 0;
        cursorVR[i] = 0;
    }
    
    // set everything in spriteVL(R) to NSNull
    
    for (int i = 0; i < _numOfNeighbors; i++) {
        [spriteVL replaceObjectAtIndex:i withObject:[NSNull null]];
        [spriteVR replaceObjectAtIndex:i withObject:[NSNull null]];
    }
    
    // set centrally visible sprite reference to nil
    spriteVisible = nil;
}

-(void) syncWithIndex:(int)index {
    
    // re-load object for index only if it is the current set
    if (index == cursorVisible) {
        
        // (0) Snaphot the position 
        CGPoint position = [spriteVisible position];
        // (1) Free and release object back to pool
        [pool freeObjectForReuse:spriteVisible];
        [spriteVisible removeFromParentAndCleanup:NO];
        // (2) Obtain updated object from data source delegate
        id imageVisible = [dataSource sLCCPhotoSlides:self objectforIndex:cursorVisible];
        // (3) Re-assign back to pool as active object
        [pool assignObjectToPool:imageVisible];
        // (4) Assign spriteVisible to the current object
        spriteVisible = imageVisible;
        // (5) Add sprite back to parent node
        [self addChild:imageVisible];
        // (6) set position 
        [imageVisible setPosition:position];
        
        for (int k = 0; k < numberOfCursorVLR; k++) {
            id spriteMaybeVisibleLeft = [spriteVL objectAtIndex:k];
            if (spriteMaybeVisibleLeft != [NSNull null]) {
                CGPoint position = [spriteMaybeVisibleLeft position];
                [pool freeObjectForReuse:spriteMaybeVisibleLeft];
                [spriteMaybeVisibleLeft removeFromParentAndCleanup:NO];
                id imageMaybeVisible = [dataSource sLCCPhotoSlides:self objectforIndex:cursorVL[k]];
                [pool assignObjectToPool:imageMaybeVisible];
                [spriteVL replaceObjectAtIndex:k withObject:imageMaybeVisible];
                [self addChild:imageMaybeVisible];
                [imageMaybeVisible setPosition:position];
            }
        }
        
        for (int k = 0; k < numberOfCursorVLR; k++) {
            id spriteMaybeVisibleRight = [spriteVR objectAtIndex:k];
            if (spriteMaybeVisibleRight != [NSNull null]) {
                CGPoint position = [spriteMaybeVisibleRight position];
                [pool freeObjectForReuse:spriteMaybeVisibleRight];
                [spriteMaybeVisibleRight removeFromParentAndCleanup:NO];
                id imageMaybeVisible = [dataSource sLCCPhotoSlides:self objectforIndex:cursorVR[k]];
                [pool assignObjectToPool:imageMaybeVisible];
                [spriteVR replaceObjectAtIndex:k withObject:imageMaybeVisible];
                [self addChild:imageMaybeVisible];
                [imageMaybeVisible setPosition:position];
            }
        }
        /*
        if (cursorMaybeVisibleLeft >= 0) {
            
            CGPoint position = [spriteMaybeVisibleLeft position];
            [pool freeObjectForReuse:spriteMaybeVisibleLeft];
            [spriteMaybeVisibleLeft removeFromParentAndCleanup:NO];
            id imageMaybeVisible = [dataSource sLCCPhotoSlides:self objectforIndex:cursorMaybeVisibleLeft];
            [pool assignObjectToPool:imageMaybeVisible];
            spriteMaybeVisibleLeft = imageMaybeVisible;
            [self addChild:imageMaybeVisible];
            [imageMaybeVisible setPosition:position];
        }
        
        if (cursorMaybeVisibleRight < numberOfObjects && cursorMaybeVisibleRight >= 0) {
            
            CGPoint position = [spriteMaybeVisibleRight position];
            [pool freeObjectForReuse:spriteMaybeVisibleRight];
            [spriteMaybeVisibleRight removeFromParentAndCleanup:NO];
            id imageMaybeVisible = [dataSource sLCCPhotoSlides:self objectforIndex:cursorMaybeVisibleRight];
            [pool assignObjectToPool:imageMaybeVisible];
            spriteMaybeVisibleRight = imageMaybeVisible;
            [self addChild:imageMaybeVisible];
            [imageMaybeVisible setPosition:position];
        }
         */
    }
    
}

#pragma mark - Touch Action
-(void) snapBack {
    
    float visibleImageWidth = [spriteVisible boundingBox].size.width;
    
    CCAction *visibleAction = [CCMoveTo actionWithDuration:0.5 position:ccp(0, 0)];
    [spriteVisible runAction:visibleAction];
    
    for (int k = 0; k < numberOfCursorVLR; k++) {
        id spriteMaybeVisibleRight = [spriteVR objectAtIndex:k];
        
        if (spriteMaybeVisibleRight != [NSNull null]) {
            CCAction *visibleActionRight;
            if (fixedSize.width == 0) 
                visibleActionRight = [CCMoveTo actionWithDuration:0.5 position:ccp(visibleImageWidth*(k+1), 0.0)];
            else
                visibleActionRight = [CCMoveTo actionWithDuration:0.5 position:ccp(fixedSize.width*(k+1), 0.0)];
            [spriteMaybeVisibleRight runAction:visibleActionRight];
        }
        
    
        id spriteMaybeVisibleLeft = [spriteVL objectAtIndex:k];
        
        if (spriteMaybeVisibleLeft != [NSNull null]) {
            CCAction *visibleActionLeft;
            if (fixedSize.width == 0)
                visibleActionLeft = [CCMoveTo actionWithDuration:0.5 position:ccp(-visibleImageWidth*(k+1), 0.0)];
            else
                visibleActionLeft = [CCMoveTo actionWithDuration:0.5 position:ccp(-fixedSize.width*(k+1), 0.0)];
            
            [spriteMaybeVisibleLeft runAction:visibleActionLeft];
        }
    }
    
}

-(void) snapRight {
//    NSLog(@"snapRight");
//*
    // Update the UI States, the cursors
    for (int k = 0; k < numberOfCursorVLR; k++)
        cursorVR[k]--;    // may index past 0, so should do a bound check downstream
    cursorVisible--;
    for (int k = 0; k < numberOfCursorVLR; k++)
        cursorVL[k]--;
    
//    cursorMaybeVisibleRight = cursorVisible;
//    cursorVisible = cursorMaybeVisibleLeft;
//    cursorMaybeVisibleLeft--;

    // Free, allocate, etc. 
    
    // Try to free the rightmost reference if spriteVR is "full"
    id spriteMaybeVisibleRight = [spriteVR lastObject];
    if (spriteMaybeVisibleRight != [NSNull null]) {          // Free only if not NULL
        [pool freeObjectForReuse:spriteMaybeVisibleRight];
        [spriteMaybeVisibleRight removeFromParentAndCleanup:NO];
    }
    
    // Update the references
    // 1) Right (run from n-1 to 1) 
    for (int k = numberOfCursorVLR - 1; k > 0; k--) {
        id nextObj = [spriteVR objectAtIndex:k-1];
        [spriteVR replaceObjectAtIndex:k withObject:nextObj];
    }
    // 2) VR -> V
    [spriteVR replaceObjectAtIndex:0 withObject:spriteVisible];
    // 3) V -> VL
    spriteVisible = [spriteVL objectAtIndex:0];
    // 4) Left (run from 0 to n-1) 
    for (int k = 0; k < numberOfCursorVLR - 1; k++) {
        id nextObj = [spriteVL objectAtIndex:k+1];
        [spriteVL replaceObjectAtIndex:k withObject:nextObj];
    }
    // 5) VL^N, handling the left most
    if (cursorVL[numberOfCursorVLR-1] >= 0) {
        id imageMaybeVisible = [dataSource sLCCPhotoSlides:self objectforIndex:cursorVL[numberOfCursorVLR-1]];
        
        [pool assignObjectToPool:imageMaybeVisible];
        float visibleImageWidth = [spriteVisible boundingBox].size.width;
        
        if (fixedSize.width == 0) 
            [imageMaybeVisible setPosition:ccp(-visibleImageWidth*numberOfCursorVLR, 0.0)];
        else 
            [imageMaybeVisible setPosition:ccp(-fixedSize.width*numberOfCursorVLR, 0.0)];
        
        [self addChild:imageMaybeVisible];
        [spriteVL replaceObjectAtIndex:(numberOfCursorVLR-1) withObject:imageMaybeVisible];
    
    }
    else {
        [spriteVL replaceObjectAtIndex:(numberOfCursorVLR-1) withObject:[NSNull null]];
    }
//    spriteMaybeVisibleRight = spriteVisible;
//    spriteVisible = spriteMaybeVisibleLeft;
    
    // Handle the spriteMaybeVisibleLeft
    //     Get the new image to the left
//    if (cursorMaybeVisibleLeft != -1) {
//        
//        id imageMaybeVisible = [dataSource sLCCPhotoSlides:self objectforIndex:cursorMaybeVisibleLeft];
//        
//        [pool assignObjectToPool:imageMaybeVisible];
//        float visibleImageWidth = [spriteVisible boundingBox].size.width;
//        if (fixedSize.width == 0)
//            [imageMaybeVisible setPosition:ccp(-visibleImageWidth, 0.0)];
//        else
//            [imageMaybeVisible setPosition:ccp(-fixedSize.width, 0.0)];
//        
//        [self addChild:imageMaybeVisible];
//        spriteMaybeVisibleLeft = imageMaybeVisible;
//    }
//    else {
//        spriteMaybeVisibleLeft = nil;
//    }
    
    [self snapBack];
//*/
}

-(void) snapLeft {
//    NSLog(@"snapLeft");
//*
    // update UI States, the cursors
    for (int k = 0; k < numberOfCursorVLR; k++)
        cursorVL[k]++; 
    cursorVisible++;
    for (int k = 0; k < numberOfCursorVLR; k++) 
        cursorVR[k]++;  // may index past the array of objs, so should do a bound check first 
    
//    cursorMaybeVisibleLeft = cursorVisible;
//    cursorVisible = cursorMaybeVisibleRight;
//    cursorMaybeVisibleRight++;
//    if (cursorMaybeVisibleRight == numberOfObjects)
//        cursorMaybeVisibleRight = -1;
    
    // Free, Allocate, etc.
        
    // Try to Free the leftmost reference if spriteVL is "full"
    id spriteMaybeVisibleLeft = [spriteVL lastObject];
    if (spriteMaybeVisibleLeft != [NSNull null]) {        // Free only if not NULL
        [pool freeObjectForReuse:spriteMaybeVisibleLeft];
        [spriteMaybeVisibleLeft removeFromParentAndCleanup:NO];
    }
    
    // Update the references
    // 1) Left (run from n-1, to 1)
    for (int k = numberOfCursorVLR - 1; k > 0; k--) {
        id nextObj = [spriteVL objectAtIndex:k-1];
        [spriteVL replaceObjectAtIndex:k withObject:nextObj];
    }
    // 2) VL -> V
    [spriteVL replaceObjectAtIndex:0 withObject:spriteVisible];
    // 3) V -> VR
    spriteVisible = [spriteVR objectAtIndex:0];
    // 4) Right (run from 0 to n-1)
    for (int k = 0; k < numberOfCursorVLR - 1; k++) {
        id nextObj = [spriteVR objectAtIndex:k+1];
        [spriteVR replaceObjectAtIndex:k withObject:nextObj];
    }
    
    // 5) VR^N, handling the right most
    if (cursorVR[numberOfCursorVLR-1] <= numberOfObjects-1) {
        id imageMaybeVisible = [dataSource sLCCPhotoSlides:self objectforIndex:cursorVR[numberOfCursorVLR-1]];
        
        [pool assignObjectToPool:imageMaybeVisible];
        float visibleImageWidth = [spriteVisible boundingBox].size.width;
        
        if (fixedSize.width == 0) 
            [imageMaybeVisible setPosition:ccp(visibleImageWidth*numberOfCursorVLR, 0.0)];
        else
            [imageMaybeVisible setPosition:ccp(fixedSize.width*numberOfCursorVLR, 0.0)];
        
        [self addChild:imageMaybeVisible];
        [spriteVR replaceObjectAtIndex:(numberOfCursorVLR-1) withObject:imageMaybeVisible];
                                 
    }
    else {
        [spriteVR replaceObjectAtIndex:(numberOfCursorVLR-1) withObject:[NSNull null]];
    }
    
//    spriteMaybeVisibleLeft = spriteVisible;
//    spriteVisible = spriteMaybeVisibleRight;
    
    // Handle the spriteMaybeVisibleRight
    //    Get the new image to the right
//    if (cursorMaybeVisibleRight != -1) {
//        
//        id imageMaybeVisible = [dataSource sLCCPhotoSlides:self objectforIndex:cursorMaybeVisibleRight];
//        
//        [pool assignObjectToPool:imageMaybeVisible];
//        float visibleImageWidth = [spriteVisible boundingBox].size.width;
//        
//        if (fixedSize.width == 0)
//            [imageMaybeVisible setPosition:ccp(visibleImageWidth, 0.0)];
//        else
//            [imageMaybeVisible setPosition:ccp(fixedSize.width, 0.0)];
//    
//        [self addChild:imageMaybeVisible];
//        spriteMaybeVisibleRight = imageMaybeVisible;
//    }
//    else {
//        spriteMaybeVisibleRight = nil;
//    }
    
    [self snapBack];
//*/
}

#pragma mark - Touches
-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
//    CCLOG(@"total # of obj in pool = %d", [pool numberOfObjectAllocation]);
    
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
    
    if (!_frozen && CGRectContainsPoint(touchBound, loc)) {
        startTouchPt = loc;
        lastTouchPt = loc;
        
        return YES;
    }
    
    return NO;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
    
    if (CGRectContainsPoint(touchBound, loc)) {
        
        CGPoint dpt = ccp(loc.x - lastTouchPt.x, loc.y - lastTouchPt.y);
        lastTouchPt = ccp(loc.x, loc.y);
        
        [spriteVisible setPosition:ccp([spriteVisible position].x + dpt.x, [spriteVisible position].y)];
        
        for (int k = 0; k < numberOfCursorVLR; k++) {
            id spriteMaybeVisibleLeft = [spriteVL objectAtIndex:k];
            if (spriteMaybeVisibleLeft != [NSNull null]) {
                if (spriteMaybeVisibleLeft != nil)
                    [spriteMaybeVisibleLeft setPosition:ccp([spriteMaybeVisibleLeft position].x + dpt.x, [spriteMaybeVisibleLeft position].y)];
            }
            
            id spriteMaybeVisibleRight = [spriteVR objectAtIndex:k];
            if (spriteMaybeVisibleRight != [NSNull null]) {
                if (spriteMaybeVisibleRight != nil) 
                    [spriteMaybeVisibleRight setPosition:ccp([spriteMaybeVisibleRight position].x + dpt.x, [spriteMaybeVisibleRight position].y)];
            }
        }
        
        scrolling = YES;
    }
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
            
    if (abs(loc.x - startTouchPt.x) < touchBound.size.width*0.333) {  // animate back to origin        
        [self snapBack];
    }
    else if (loc.x - startTouchPt.x > touchBound.size.width*0.333) { 
//        CCLOG(@"slide to the right unless this is the first image");
        
        if (cursorVisible == 0) 
            [self snapBack];
        else {
            [self snapRight];
            if (delegate != nil && [delegate respondsToSelector:@selector(sLCCPhotoSlides:didScrollToCurrentIndex:)]) {
                [delegate sLCCPhotoSlides:self didScrollToCurrentIndex:self.cursorVisible];
            }
        }
    }
    else if (loc.x - startTouchPt.x < -touchBound.size.width*0.333) {
//        CCLOG(@"slide to the left unless this is the last image");
        
        if (cursorVisible == numberOfObjects - 1) 
            [self snapBack];
        else {
            [self snapLeft];
            if (delegate != nil && [delegate respondsToSelector:@selector(sLCCPhotoSlides:didScrollToCurrentIndex:)]) {
                [delegate sLCCPhotoSlides:self didScrollToCurrentIndex:self.cursorVisible];
            }
        }
    }
    
    scrolling = NO;
    
}

#pragma mark - Swipe gesture handler

-(void)handlePan:(UIPanGestureRecognizer *)gesture {
    
//    CCLOG(@"total # of obj in pool = %d", [pool numberOfObjectAllocation]);
    
    static float last_x = 0.0;
    
    CGPoint translation = [gesture translationInView:[[CCDirector sharedDirector] openGLView]];
    float dx = translation.x - last_x;
    last_x = translation.x;
    
    // CCLOG(@"Translation = %f, %f", translation.x, translation.y);
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        
        scrolling = NO;
        
        if (abs(translation.x) < touchBound.size.width*0.333) {
            [self snapBack];
        }
        else if (translation.x > touchBound.size.width*0.333) {
            if (cursorVisible == 0)
                [self snapBack];
            else  {
                [self snapRight];
                if (delegate != nil && [delegate respondsToSelector:@selector(sLCCPhotoSlides:didScrollToCurrentIndex:)]) {
                    [delegate sLCCPhotoSlides:self didScrollToCurrentIndex:self.cursorVisible];
                }
            }
        }
        else if (translation.x < -touchBound.size.width*0.333) {
            if (cursorVisible == numberOfObjects - 1)
                [self snapBack];
            else {
                [self snapLeft];
                if (delegate != nil && [delegate respondsToSelector:@selector(sLCCPhotoSlides:didScrollToCurrentIndex:)]) {
                    [delegate sLCCPhotoSlides:self didScrollToCurrentIndex:self.cursorVisible];
                }
            }
        }
        
        last_x = 0.0;  
    }
    else {
        
        // just move the whole slide along
        scrolling = YES;
        
        CGPoint currentPosition = [spriteVisible position];
        [spriteVisible setPosition:ccp(currentPosition.x + dx, currentPosition.y)];
        
        for (int k = 0; k < numberOfCursorVLR; k++) {
            id spriteMaybeVisibleLeft = [spriteVL objectAtIndex:k];
            if (spriteMaybeVisibleLeft != [NSNull null]) {
                if (spriteMaybeVisibleLeft != nil) {
                    CGPoint currentPosition = [spriteMaybeVisibleLeft position];
                    [spriteMaybeVisibleLeft setPosition:ccp(currentPosition.x + dx, currentPosition.y)];
                }
            }
            id spriteMaybeVisibleRight = [spriteVR objectAtIndex:k];
            if (spriteMaybeVisibleRight != [NSNull null]) {
                if (spriteMaybeVisibleRight != nil) {
                    CGPoint currentPosition = [spriteMaybeVisibleRight position];
                    [spriteMaybeVisibleRight setPosition:ccp(currentPosition.x + dx, currentPosition.y)];
                }
            }
            
        }
    }
//    [gesture setTranslation:CGPointZero inView:[[CCDirector sharedDirector] openGLView]];

}

#pragma mark - UIGestureRecognizerDelegate methods
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

@end

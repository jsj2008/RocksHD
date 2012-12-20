//
//  SLCCImageStack.m
//  LifeCycle
//
//  Created by Kelvin Chan on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLCCImageStack.h"

@interface SLCCImageStack (Private)
@end

@implementation SLCCImageStack

@synthesize dataSource;
@synthesize delegate;
@synthesize pool;
@synthesize cursorTop;

#pragma mark - Object Life Cycle

-(void) dealloc {
    CCLOG(@"deallocating SLCCImageStack");
    [pool release];
    
    [super dealloc];
}

+(id) slCCImageStackWithParentNode:(CCNode *)parentNode {
    return [[[self alloc] initWithParentNode:parentNode] autorelease];
}
             
-(id) initWithParentNode:(CCNode*)parentNode {
    
    self = [super init];
    if (self) {
        [parentNode addChild:self];
        self.pool = [SLObjectPool objectsPoolWithCapacity:10];
    }
    
    return self;
}

-(void)onEnter {
    [super onEnter];
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(void)onExit {
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super onExit];
}

#pragma mark - Object pool 
-(id) dequeueReusableObject {
    return [pool dequeueReusableObject];
}

#pragma mark - Sprite Creating and Texture replacement Logic
//-(CCSprite *) makeNewSpriteWithImageNamed:(NSString *)imageName {
//    CCSprite *s = nil;
//    @try {
//        s = [CCSprite spriteWithSpriteFrameName:imageName];
//    }
//    @catch (NSException *NSInternalInconsistencyException) {
//        s = [CCSprite spriteWithFile:imageName];
//    }
//    @finally {
//        ;
//    }
//    return s;
//}
//
//-(void) replaceSpriteTextureForSprite:(CCSprite *) sprite withImageNamed:(NSString *)imageName {
//    CCSpriteFrame *spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:imageName];
//    if (spriteFrame != nil)
//        [sprite setDisplayFrame:spriteFrame];
//    else {
//        UIImage *image = [UIImage imageNamed:imageName];
//        [[CCTextureCache sharedTextureCache] addImage:imageName];
//        
//        [sprite setTexture:[[CCTextureCache sharedTextureCache] textureForKey:imageName]];
//        [sprite setTextureRect:CGRectMake(0, 0, image.size.width, image.size.height)];
//    }
//}

#pragma mark - Display Logic
-(void) show {
    
    if (self.pool == nil)
        self.pool = [SLObjectPool objectsPoolWithCapacity:10];
    
    numberOfObjects = [dataSource sLCCImageStack:self numberOfObjectsInSection:0];
    CCLOG(@"number of objects = %d", numberOfObjects);
    
    if (numberOfObjects <= 0)
        return;                     // shouldnt do anything more.
    
    // initialize cursorTop, cursorTop2, cursorBottom
    cursorTop = 0;
    cursorTop2 = 1;
    cursorBottom = numberOfObjects - 1;
    
    dAngle = 8.0f / numberOfObjects;
    dX = 40.0f / numberOfObjects;
    
    // Top frame and image

    id imageTop = [dataSource sLCCImageStack:self objectforIndex:cursorTop];
    [pool assignObjectToPool:imageTop];
    [imageTop setPosition:ccp(0.0, 0.0)];
    [self addChild:imageTop z:numberOfObjects-1];
    
    // 2nd Top frame and image
    id imageTop2 = [dataSource sLCCImageStack:self objectforIndex:cursorTop2];
    [pool assignObjectToPool:imageTop2];
    [imageTop2 setPosition:ccp(dX, 0.0)];
    [imageTop2 setRotation:dAngle];
    [self addChild:imageTop2 z:numberOfObjects-2];
    
    // Bottom frame and image
    id imageBottom = [dataSource sLCCImageStack:self objectforIndex:cursorBottom];
    [pool assignObjectToPool:imageBottom];
    [imageBottom setPosition:ccp(2.0*dX, 0.0)];
    [imageBottom setRotation:2.0*dAngle];
    [self addChild:imageBottom z:0];
    
    // Set touchable bound 
    CGSize imageTopSize = [imageTop boundingBox].size;
    
    touchBound = CGRectMake(self.position.x - imageTopSize.width * 0.5, 
                            self.position.y - imageTopSize.height * 0.5,
                            imageTopSize.width + 100.0f, imageTopSize.height);
    
    CCLOG(@"touchBound = (%f, %f) with (%f, %f)", touchBound.origin.x, touchBound.origin.y, touchBound.size.width, touchBound.size.height);

    // set references
    spriteTop = imageTop;
    spriteTop2 = imageTop2;
    spriteBottom = imageBottom;
    spriteMoving = nil;
}

-(void) reset {
    self.pool = nil;    // release the pool
    [self removeAllChildrenWithCleanup:YES];
    
    // reset cursors to zero (this may not be absolutely safe, since 0 == top card's index
    cursorTop = 0;
    cursorTop2 = 0;
    cursorBottom = 0;
    
    // set all "id" references to nil
    spriteTop = nil;
    spriteTop2 = nil;
    spriteBottom = nil;
    spriteMoving = nil;
}

-(void) syncWithIndex:(int)index {
    if (index == cursorTop) {
        
        CGPoint position = [spriteTop position];    // (0) snapshot current position
        [pool freeObjectForReuse:spriteTop];        // (1) free and release obj back to pool
        [spriteTop removeFromParentAndCleanup:NO];  
        id imageTop = [dataSource sLCCImageStack:self objectforIndex:cursorTop];    // (2) Obtain updated object from data source delegate
        
        [pool assignObjectToPool:imageTop];         // (3) add obj back to pool
        spriteTop = imageTop;                       // (4) assign spriteTop to current obj
        [self addChild:imageTop z:numberOfObjects-1];   // (5) add sprite back to parent node
        
        [imageTop setPosition:position];            // (6) set position
        
        // Repeat this for top2
        position = [spriteTop2 position];
        [pool freeObjectForReuse:spriteTop2];
        [spriteTop2 removeFromParentAndCleanup:NO];
        id imageTop2 = [dataSource sLCCImageStack:self objectforIndex:cursorTop2];
        [pool assignObjectToPool:imageTop2];
        spriteTop2 = imageTop2;
        [self addChild:imageTop2 z:numberOfObjects-2];
        [imageTop2 setPosition:position];
        
        // Repeat this for bottom
        position = [spriteBottom position];
        [pool freeObjectForReuse:spriteBottom];
        [spriteBottom removeFromParentAndCleanup:NO];
        id imageBottom = [dataSource sLCCImageStack:self objectforIndex:cursorBottom];
        [pool assignObjectToPool:imageBottom];
        spriteBottom = imageBottom;
        [self addChild:imageBottom z:0];
        [imageBottom setPosition:position];
        
    }
}

#pragma mark - Touch Action
-(void) snapBack {
    
    // animate each image to their respective position
    
    CCFiniteTimeAction *spriteTopTranslateAction = [CCMoveTo actionWithDuration:0.5 position:ccp(0.0, 0.0)];
    CCFiniteTimeAction *spriteTopRotateAction = [CCRotateTo actionWithDuration:0.5 angle:0.0];
    CCAction *spriteTopAction = [CCSpawn actions:spriteTopTranslateAction, spriteTopRotateAction, nil];
    [self reorderChild:spriteTop z:numberOfObjects-1];
    
    [spriteTop runAction:spriteTopAction];
    
    CCFiniteTimeAction *spriteTop2TranslateAction = [CCMoveTo actionWithDuration:0.5 position:ccp(dX, 0.0)];
    CCFiniteTimeAction *spriteTop2RotateAction = [CCRotateTo actionWithDuration:0.5 angle:dAngle];
    CCAction *spriteTop2Action = [CCSpawn actions:spriteTop2TranslateAction, spriteTop2RotateAction, nil];
    [self reorderChild:spriteTop2 z:numberOfObjects-2];
    
    [spriteTop2 runAction:spriteTop2Action];
    
    CCFiniteTimeAction *spriteBottomTranslateAction = [CCMoveTo actionWithDuration:0.5 position:ccp(2.0*dX, 0.0)];
    CCFiniteTimeAction *spriteBottomRotateAction = [CCRotateTo actionWithDuration:0.5 angle:2.0*dAngle];
    CCAction *spriteBottomAction = [CCSpawn actions:spriteBottomTranslateAction, spriteBottomRotateAction, nil];
    [self reorderChild:spriteBottom z:0];

    [spriteBottom runAction:spriteBottomAction];

}

-(void) snapTopToBottom {
    
    // Animate the images to their destination positions
    
    // 0) free the back image from pool and remove from parent
    [pool freeObjectForReuse:spriteBottom];
    [spriteBottom removeFromParentAndCleanup:NO];
    
    // 1) Move top image to back of deck
    [spriteTop runAction:[CCSpawn actions:[CCMoveTo actionWithDuration:0.5 position:ccp(2.0*dX, 0.0)],
                          [CCRotateTo actionWithDuration:0.5 angle:2.0*dAngle],nil]];
    [self reorderChild:spriteTop z:0];
    
    // 2) Move the 2nd to top image to the top
    [spriteTop2 runAction:[CCSpawn actions:[CCMoveTo actionWithDuration:0.5 position:ccp(0.0, 0.0)],
                           [CCRotateTo actionWithDuration:0.5 angle:0.0], nil]];
    [self reorderChild:spriteTop2 z:numberOfObjects-1];
    
    // 3) Allocate from pool the new 2nd top image, and move to 2nd position
    id imageTop2 = [dataSource sLCCImageStack:self objectforIndex:(cursorTop2+1) % numberOfObjects];
    [pool assignObjectToPool:imageTop2];
    [self addChild:imageTop2];
    
    [imageTop2 runAction:[CCSpawn actions:[CCMoveTo actionWithDuration:0.5 position:ccp(dX, 0.0)],
                          [CCRotateTo actionWithDuration:0.5 angle:dAngle], nil]];
    
    [self reorderChild:imageTop2 z:numberOfObjects-2];
    
    
    // 4) Update the UI States, & the cursors
    cursorBottom = cursorTop;
    cursorTop = cursorTop2;
    cursorTop2++;
    cursorTop2 = cursorTop2 % numberOfObjects;
    
    
    // 5) "rotate" the references
    spriteBottom = spriteTop;
    spriteTop = spriteTop2;
    spriteTop2 = imageTop2;
    
}

-(void) snapBottomToTop {
    // Update the UI States & the cursors
    cursorTop2 = cursorTop;
    cursorTop = cursorBottom;
    cursorBottom--;
    if (cursorBottom < 0)
        cursorBottom = (numberOfObjects - 1);
    
    // free and allocate
    [pool freeObjectForReuse:spriteTop2];
    [spriteTop2 removeFromParentAndCleanup:NO];
    
    // "rotate" the references
    spriteTop2 = spriteTop;
    spriteTop = spriteBottom;
    
    // Handle the spriteBottom
    id imageBottom = [dataSource sLCCImageStack:self objectforIndex:cursorBottom];
    [pool assignObjectToPool:imageBottom];
    [imageBottom setPosition:ccp(2.0*dX, 0.0)];
    [imageBottom setRotation:2.0*dAngle];
    [self addChild:imageBottom];
    [self reorderChild:imageBottom z:0];
    spriteBottom = imageBottom;
    
    [self snapBack];
                      
}


#pragma mark - Touches
-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CCLOG(@"total # of obj in pools = %d", [pool numberOfObjectAllocation]);
    
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
    
     // Need to differentiate between moving the top image vs. bottom image
    CGPoint imageTopOrigin = [spriteTop boundingBox].origin;
    CGSize imageTopSize = [spriteTop boundingBox].size;
    CGRect imageTopBound = CGRectMake(self.position.x - imageTopSize.width * 0.5 - imageTopOrigin.x,
                                       self.position.y - imageTopSize.height * 0.5 - imageTopOrigin.y,
                                       imageTopSize.width, imageTopSize.height);
    if (CGRectContainsPoint(touchBound, loc)) {
//        CCLOG(@"ccTouchBegan: %f, %f", loc.x, loc.y);
        startTouchPt = loc;
        lastTouchPt = loc;
        
        if (CGRectContainsPoint(imageTopBound, loc)) {
            spriteMoving = spriteTop;
        }
        else {
            spriteMoving = spriteBottom;
        }
        
        return YES;
    }

    return NO;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
    
    CGPoint dpt = ccp(loc.x - lastTouchPt.x, loc.y - lastTouchPt.y);
    lastTouchPt = ccp(loc.x, loc.y);
    
    if (spriteMoving == spriteTop) {
        // move the image on top
        [spriteTop setPosition:ccp([spriteTop position].x + dpt.x, [spriteTop position].y)];
    }
    else {
        [spriteBottom setPosition:ccp([spriteBottom position].x + dpt.x, [spriteBottom position].y)];
    }

}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];

    // Need to differentiate between moving the top image vs. bottom image
    if (spriteMoving == spriteTop) {             // top
        if (loc.x - lastTouchPt.x < 0 && abs(loc.x - startTouchPt.x) > 25.0f) {
            [self snapTopToBottom];
        }
        else {
            [self snapBack];
        }
    } 
    else {                                                      // bottom
        if (loc.x - lastTouchPt.x > 0 && abs(loc.x - startTouchPt.x) > 25.0f ) {
            [self snapBottomToTop];
        }
        else {
            [self snapBack];
        }
    }
    
    spriteMoving = nil;
}
@end

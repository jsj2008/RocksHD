//
//  MiniGameSprite.m
//  PlantHD
//
//  Created by Kelvin Chan on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MiniGameSprite.h"
#import "MiniGamePlaceholder.h"
#import "FlowAndStateManager.h"

@interface MiniGameSprite (Private)
-(void) checkCorrectness;
@end

@implementation MiniGameSprite

@synthesize placeholders;
@synthesize inPlaceHolderIndex;

-(void)dealloc {
    [placeholders release];
    
    if (dtArray != nil)
        [dtArray release];
    if (dpxArray != nil)
        [dpxArray release];
    if (dpyArray != nil) 
        [dpyArray release];
    
    [super dealloc];
}

+(MiniGameSprite*) miniGameSpriteWithTopic:(NSInteger)topic {
    NSDictionary *info = [[FlowAndStateManager sharedFlowAndStateManager] loadBasicInfoForSceneWithID:topic];
    return [[[MiniGameSprite alloc] initWithFile:[info objectForKey:@"intro_topic_image_name"]] autorelease];
}

-(id)init {
    self = [super init];
    if (self) {
        screenSize = [CCDirector sharedDirector].winSize;        
        inPlaceHolderIndex = -1;
        wasInAPlaceHolderIndex = -1;
        touchInProgress = NO;
        numOfTopics = [FlowAndStateManager sharedFlowAndStateManager].numOfTopics;
    }
    return self;
}

-(void)onEnter {
    [super onEnter];
    
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    
    dtArray = [[NSMutableArray alloc] initWithCapacity:10];
    dpxArray = [[NSMutableArray alloc] initWithCapacity:10];
    dpyArray = [[NSMutableArray alloc] initWithCapacity:10];
}

-(void)onExit {
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super onExit];
}

#pragma mark - Game
-(void) checkCorrectness {
    // check the answer if all placeholders are occupied.
    int numberPlaced=0;
    
    for (MiniGamePlaceholder *pl in placeholders) {
        // CCLOG(@"Placeholder %d is %d", k, pl.isOccupied);
        if (pl.isOccupied) 
            numberPlaced++;
    }
    // CCLOG(@"\n");
    if (numberPlaced == numOfTopics) {
        // CCLOG(@"Check correctness");
        
        // Raise a notification 
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"123" forKey:@"abc"];
        
        NSNotification *checkCorrectnessNotification = [NSNotification notificationWithName:CHECKCORRECTNESSNOTIFICATIONNAME object:nil userInfo:userInfo];
        
        NSArray *modes = [NSArray arrayWithObject:NSDefaultRunLoopMode];
        
        [[NSNotificationQueue defaultQueue] enqueueNotification:checkCorrectnessNotification postingStyle:NSPostWhenIdle coalesceMask:NSNotificationCoalescingOnName forModes:modes];
        
    }   
}

#pragma mark - Touch
-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (!touchInProgress) {
    
        CGPoint location = [touch locationInView:[touch view]];
        CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
        
        if (CGRectContainsPoint(self.boundingBox, loc)) {
            startTouchPt = loc;
            lastTouchPt = loc;
            
            date = [[NSDate date] retain];
            last_Dt = (-[date timeIntervalSinceNow]);
            
            if ([self numberOfRunningActions] > 0)
                [self stopAllActions];
            
            touchInProgress = YES;
            return YES;
        }
    }
    return NO;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
    
    CGPoint dpt = ccp(loc.x - lastTouchPt.x, loc.y - lastTouchPt.y);
    lastTouchPt = ccp(loc.x, loc.y);
    
    CGPoint newPosition = ccp(self.position.x + dpt.x, self.position.y + dpt.y);
    self.position = newPosition;
        
    // check if a placeholder is in the vicinity
    BOOL onAPlaceHolder = NO;
    for (CCSprite *s in placeholders) {
        if (CGRectContainsPoint(s.boundingBox, self.position)) {
            //if ([self numberOfRunningActions] == 0) {
                id action = [CCScaleTo actionWithDuration:0.1f scale:1.0f];
                [self runAction:action];
            //}
            onAPlaceHolder = YES;
            break;
        }
    }
    
    if (!onAPlaceHolder) {
        id action = [CCScaleTo actionWithDuration:0.1f scale:0.65f];
        [self runAction:action];
        
        NSTimeInterval Dt = (-[date timeIntervalSinceNow]);
        // CCLOG(@"dt = %f, dp = (%f,%f)", Dt-last_Dt, dpt.x, dpt.y);
        
        if ([dtArray count] == 10) {
            [dtArray removeObjectAtIndex:0];
        }
        if ([dpxArray count] == 10) {
            [dpxArray removeObjectAtIndex:0];
        }
        if ([dpyArray count] == 10) {
            [dpyArray removeObjectAtIndex:0];
        }
        
        [dtArray addObject:[NSNumber numberWithFloat:(Dt-last_Dt)]];
        [dpxArray addObject:[NSNumber numberWithFloat:dpt.x]];
        [dpyArray addObject:[NSNumber numberWithFloat:dpt.y]];

        last_Dt = Dt;
        
    }
    
}

-(void) checkUpdatePlaceHolderOccupied {
    wasInAPlaceHolderIndex = self.inPlaceHolderIndex;
    if (wasInAPlaceHolderIndex != -1) 
        ((MiniGamePlaceholder*)[placeholders objectAtIndex:wasInAPlaceHolderIndex]).isOccupied = NO;
    
    int k=0;
    self.inPlaceHolderIndex = -1;
    for (MiniGamePlaceholder *pl in placeholders) {
        if (CGRectContainsPoint(pl.boundingBox, self.position)) {
            id action = [CCSpawn actions:
                         [CCMoveTo actionWithDuration:0.2f position:pl.position],
                         [CCScaleTo actionWithDuration:0.1f scale:1.0f],
                         nil];
            [self runAction:action];
            
            pl.isOccupied = YES;
            self.inPlaceHolderIndex = k;
            break;
        }
        k++;
    }
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
    
    // unoccupy the previously occupied placeholder, if any...
//    wasInAPlaceHolderIndex = self.inPlaceHolderIndex;
//    if (wasInAPlaceHolderIndex != -1) 
//        ((MiniGamePlaceholder*)[placeholders objectAtIndex:wasInAPlaceHolderIndex]).isOccupied = NO;
//    
//    int k=0;
//    self.inPlaceHolderIndex = -1;
//    for (MiniGamePlaceholder *pl in placeholders) {
//        if (CGRectContainsPoint(pl.boundingBox, self.position)) {
//            id action = [CCMoveTo actionWithDuration:0.2f position:pl.position];
//            [self runAction:action];
//            
//            pl.isOccupied = YES;
//            self.inPlaceHolderIndex = k;
//            break;
//        }
//        k++;
//    }
    [self checkUpdatePlaceHolderOccupied];
    
    if (self.inPlaceHolderIndex == -1) {   // if didnt fall into any placeholder
        // Perform momentum scrolling
        CGPoint dpt = ccp(loc.x - lastTouchPt.x, loc.y - lastTouchPt.y);
        NSTimeInterval Dt = (-[date timeIntervalSinceNow]);
        // CCLOG(@"dt = %f, dp = (%f,%f)", Dt-last_Dt, dpt.x, dpt.y);

        if ([dtArray count] == 10) {
            [dtArray removeObjectAtIndex:0];
        }
        if ([dpxArray count] == 10) {
            [dpxArray removeObjectAtIndex:0];
        }
        if ([dpyArray count] == 10) {
            [dpyArray removeObjectAtIndex:0];
        }
        
        [dtArray addObject:[NSNumber numberWithFloat:(Dt-last_Dt)]];
        [dpxArray addObject:[NSNumber numberWithFloat:dpt.x]];
        [dpyArray addObject:[NSNumber numberWithFloat:dpt.y]];
        
        /*for (int k=0; k < [dtArray count]; k++) {
            CCLOG(@"dt=%f, dp=(%f,%f)", [[dtArray objectAtIndex:k] floatValue], 
                  [[dpxArray objectAtIndex:k] floatValue],
                  [[dpyArray objectAtIndex:k] floatValue]);
        }*/
        
        // calculate avg velocity with the last ten sample
        float v_x = 0.0;
        float v_y = 0.0;
        int N = [dtArray count];
        for (int k=0; k < N; k++) {
            v_x += ([[dpxArray objectAtIndex:k] floatValue] / [[dtArray objectAtIndex:k] floatValue]);
            v_y += ([[dpyArray objectAtIndex:k] floatValue] / [[dtArray objectAtIndex:k] floatValue]);
        }
        // avg and rescale v_x, v_y
        v_x /= (N*screenSize.width);
        v_y /= (N*screenSize.height);
        //CCLOG(@"avg v_x = %f", v_x);
        //CCLOG(@"avg v_y = %f", v_y);
        
        float vsq = (v_x*v_x) + (v_y*v_y);
        
        float a = 0.01;
        
        float dP = vsq / (2.0f*a);
        float angle = atanf(v_y / v_x);
        
        float dx = fabsf(dP*cosf(angle));
        float dy = fabsf(dP*sinf(angle));
        
        if (v_x < 0) 
            dx = (-dx);
        if (v_y < 0) 
            dy = (-dy);
        
        if (self.position.x + dx > screenSize.width - self.boundingBox.size.width/2.0) 
            dx = screenSize.width - self.boundingBox.size.width/2.0 - self.position.x;
        else if (self.position.x + dx < self.boundingBox.size.width / 2.0) 
            dx = self.boundingBox.size.width/2.0 - self.position.x;
        
        if (self.position.y + dy > screenSize.height - self.boundingBox.size.height/2.0)
            dy = screenSize.height - self.boundingBox.size.height/2.0 - self.position.y;
        else if (self.position.y + dy < self.boundingBox.size.height / 2.0)
            dy = self.boundingBox.size.height / 2.0 - self.position.y;
        
//        CCLOG(@"dx = %.f, dy = %.f", dx, dy);
        
        if (isnan(dx) || isnan(dy)) {
            dx = 0.0;
            dy = 0.0;
        }
        
        if (dx > 200.0)
            dx = 200.0;
        
        if (dy > 200.0)
            dy = 200.0;
            
        
        id action = [CCSequence actions:
                     [CCEaseOut actionWithAction:[CCMoveBy actionWithDuration:1.0f position:ccp(dx, dy)] rate:4.0],
                     [CCCallBlock actionWithBlock:^{ 
            [self checkUpdatePlaceHolderOccupied]; 
            [self checkCorrectness];
        }],
                     nil];
        
        [self runAction:action];

    }
    [dtArray removeAllObjects];
    [dpxArray removeAllObjects];
    [dpyArray removeAllObjects];
    
    [date release];
    
    [self checkCorrectness];
    
    // check the answer if all placeholders are occupied.
//    int numberPlaced=0;
//
//    for (MiniGamePlaceholder *pl in placeholders) {
//        // CCLOG(@"Placeholder %d is %d", k, pl.isOccupied);
//        if (pl.isOccupied) 
//            numberPlaced++;
//    }
//    // CCLOG(@"\n");
//    if (numberPlaced == numOfTopics) {
//        // CCLOG(@"Check correctness");
//        
//        // Raise a notification 
//        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"123" forKey:@"abc"];
//        
//        NSNotification *checkCorrectnessNotification = [NSNotification notificationWithName:CHECKCORRECTNESSNOTIFICATIONNAME object:nil userInfo:userInfo];
//        
//        NSArray *modes = [NSArray arrayWithObject:NSDefaultRunLoopMode];
//        
//        [[NSNotificationQueue defaultQueue] enqueueNotification:checkCorrectnessNotification postingStyle:NSPostWhenIdle coalesceMask:NSNotificationCoalescingOnName forModes:modes];
//        
//    }
    touchInProgress = NO;
}


@end

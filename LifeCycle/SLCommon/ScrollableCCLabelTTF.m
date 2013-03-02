//
//  ScrollableCCLabelTTF.m
//  SLCommon
//
//  Created by Kelvin Chan on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.


#import "ScrollableCCLabelTTF.h"
#import "AppConfigManager.h"

@implementation ScrollableCCLabelTTF

@synthesize delegate;
@synthesize viewPortRatio;
@synthesize viewPortHeight;

-(void)dealloc {
    
    CCLOG(@"Deallocating ScrollableCCLabelTTF");
    
    if (dtArray != nil)
        [dtArray release];
    if (dpxArray != nil)
        [dpxArray release];
    if (dpyArray != nil)
        [dpyArray release];
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

-(void)onEnter {
    [super onEnter];
    
    screenSize = [CCDirector sharedDirector].winSize;
    
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    fixedPosition = self.position;
    
    if (self.viewPortRatio != 0)
        self.viewPortHeight = self.viewPortRatio * self.boundingBox.size.height;
    else if (self.viewPortRatio == 0 && self.viewPortHeight == 0) {
        self.viewPortRatio = 1.0;
        self.viewPortHeight = self.boundingBox.size.height;
    }
    else { // use the non-zero self.viewPortHeight
        self.viewPortRatio = self.boundingBox.size.height / self.viewPortHeight;
    }
    
    CGSize maximumLabelSize = CGSizeMake(self.boundingBox.size.width, 9999);
    CGSize expectedLabelSize = [self.string sizeWithFont:[UIFont fontWithName:_fontName size:_fontSize]
                                       constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
    float textHeight = expectedLabelSize.height;
    
    float truncatedTextHeight = (textHeight - self.viewPortHeight > 0) ? textHeight - self.viewPortHeight : 0.0;
    
    highTresholdPosition = ccp(self.position.x, self.position.y + truncatedTextHeight);
    
    dtArray = [[NSMutableArray alloc] initWithCapacity:5];
    dpxArray = [[NSMutableArray alloc] initWithCapacity:5];
    dpyArray = [[NSMutableArray alloc] initWithCapacity:5];
    
    bScrollable = YES;
    
    //CCLOG(@"position = %f, %f", self.position.x, self.position.y);
    //CCLOG(@"anchor = %f, %f", self.anchorPoint.x, self.anchorPoint.y);
    //CCLOG(@"bound origin = %f, %f", self.boundingBox.origin.x, self.boundingBox.origin.y);
    //CCLOG(@"bound size = %f, %f", self.boundingBox.size.width, self.boundingBox.size.height);
    
}

-(void)onExit {
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    [super onExit];
}


-(void)visit {
    
    if (!self.visible) {
        return;
    }
    
    glEnable(GL_SCISSOR_TEST);

    AppConfigManager *cfg = [AppConfigManager getInstance];
    int scale = 1;
    if ([cfg isRetinaDisplay])
    {
        scale = 2;
    }
    
    glScissor(fixedPosition.x * scale, (fixedPosition.y - self.viewPortHeight)* scale,
              self.boundingBox.size.width* scale, self.viewPortHeight* scale);
    
    
    // CCLOG(@"y=%f", fixedPosition.y - self.viewPortHeight);
    
    [super visit];
    glDisable(GL_SCISSOR_TEST);
}


#pragma mark - Touches

-(void) freezeScrolling {
    bScrollable = NO;
}

-(void) unfreezeScrolling {
    bScrollable = YES;
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    
    if (!bScrollable)
        return NO;
    
    if (delegate != nil && [delegate respondsToSelector:@selector(scrollableCCLabelTTFBeginScroll:)])
        [delegate scrollableCCLabelTTFBeginScroll:self];
    
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
    
    //    CGRect bound = CGRectMake( self.boundingBox.origin.x, 125, self.boundingBox.size.width, self.boundingBox.size.height);
    CGRect bound = CGRectMake(self.boundingBox.origin.x, fixedPosition.y - self.viewPortHeight,
                              self.boundingBox.size.width, self.boundingBox.size.height);
    
    if (CGRectContainsPoint(bound, loc)) {
        
        if ([self numberOfRunningActions] > 0)
            [self stopAllActions];
        
        startTouchPt = loc;
        lastTouchPt = loc;
        
        date = [[NSDate date] retain];
        last_Dt = (-[date timeIntervalSinceNow]);
        
        return YES;
    }
    
    return NO;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
    // CCLOG(@"ScrollableCCLabelTTF: %f, %f", loc.x, loc.y);
    
    CGPoint dpt = ccp(loc.x - lastTouchPt.x, loc.y - lastTouchPt.y);
    lastTouchPt = ccp(loc.x, loc.y);
    
    self.position = ccp(self.position.x, self.position.y + dpt.y);
    
    // For momentum scrolling:
    
    NSTimeInterval Dt = (-[date timeIntervalSinceNow]);
    
    if ([dtArray count] == 5) {
        [dtArray removeObjectAtIndex:0];
    }
    if ([dpxArray count] == 5) {
        [dpxArray removeObjectAtIndex:0];
    }
    if ([dpyArray count] == 5) {
        [dpyArray removeObjectAtIndex:0];
    }
    
    [dtArray addObject:[NSNumber numberWithFloat:(Dt-last_Dt)]];
    [dpxArray addObject:[NSNumber numberWithFloat:dpt.x]];
    [dpyArray addObject:[NSNumber numberWithFloat:dpt.y]];
    
    last_Dt = Dt;
    
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
    
    // Inform delegate
    if (loc.y != startTouchPt.y)
        if (delegate != nil && [delegate respondsToSelector:@selector(scrollableCCLabelTTFDidScroll:)])
            [delegate scrollableCCLabelTTFDidScroll:self];
    
    
    // CCLOG(@"ScrollableCCLabelTTF: %f, %f", loc.x, loc.y);
    if ([self numberOfRunningActions] > 0)
        [self stopAllActions];
    
    if (self.position.y < fixedPosition.y)
        [self runAction:[CCMoveTo actionWithDuration:0.75 position:fixedPosition]];
    else if (self.position.y > highTresholdPosition.y)
        [self runAction:[CCMoveTo actionWithDuration:0.75 position:highTresholdPosition]];
    else {
        // do momentum scroll
        
        CGPoint dpt = ccp(loc.x - lastTouchPt.x, loc.y - lastTouchPt.y);
        NSTimeInterval Dt = (-[date timeIntervalSinceNow]);
        
        if ([dtArray count] == 5) {
            [dtArray removeObjectAtIndex:0];
        }
        if ([dpxArray count] == 5) {
            [dpxArray removeObjectAtIndex:0];
        }
        if ([dpyArray count] == 5) {
            [dpyArray removeObjectAtIndex:0];
        }
        
        [dtArray addObject:[NSNumber numberWithFloat:(Dt-last_Dt)]];
        [dpxArray addObject:[NSNumber numberWithFloat:dpt.x]];
        [dpyArray addObject:[NSNumber numberWithFloat:dpt.y]];
        
        float v;
        float v_y = 0.0;
        int N = [dtArray count];
        for (int k=0; k < N; k++) {
            v = [[dpyArray objectAtIndex:k] floatValue] / [[dtArray objectAtIndex:k] floatValue];
            if (v > 2000.0)         // put a cap on the velocity.
                v = 2000.0;
            else if (v < -2000.0)
                v = -2000.0;
            v_y += v;
        }
        v_y /= (N*screenSize.height);    // avg and rescale v_x, v_y
        
        float a = 0.015;
        float dY = (v_y*v_y) / (2.0f * a);
        if (v_y < 0)
            dY = (-dY);
        
        //for (int k=0; k < [dtArray count]; k++) {
        //    CCLOG(@"dt=%f, dp=(%f,%f)", [[dtArray objectAtIndex:k] floatValue],
        //          [[dpxArray objectAtIndex:k] floatValue],
        //          [[dpyArray objectAtIndex:k] floatValue]);
        //}
        
        // CCLOG(@"dY = %f", dY);
        id action = [CCSequence actions:
                     [CCEaseOut actionWithAction:[CCMoveBy actionWithDuration:0.5f position:ccp(0, dY)] rate:4.0],
                     [CCCallBlock actionWithBlock:^{
            if (self.position.y < fixedPosition.y) {
                [self runAction:[CCMoveTo actionWithDuration:0.75 position:fixedPosition]];
            }
            else if (self.position.y > highTresholdPosition.y) {
                [self runAction:[CCMoveTo actionWithDuration:0.75 position:highTresholdPosition]];
            }
        }],
                     nil];
        
        [self runAction:action];
        
    }
    
    [dtArray removeAllObjects];
    [dpxArray removeAllObjects];
    [dpyArray removeAllObjects];
    
    [date release];
    
}

@end

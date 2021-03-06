//
//  VideoLayerExtra.m
//  ButterflyPOC
//
//  Created by Kelvin Chan on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideoLayerExtra.h"
#import "ConfigManager.h"

@implementation VideoLayer (editModeAbler)

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    return [editModeAbler ccTouchBegan:touch withEvent:event];
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    [editModeAbler ccTouchMoved:touch withEvent:event];
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [editModeAbler ccTouchEnded:touch withEvent:event];
}

#pragma mark - EditModeAblerDelegate

-(void)editModeAblerTouchedNode:(CCNode *)node nodePath:(NSString *)nodePath lastPosition:(CGPoint)position {
//    [[ConfigManager sharedConfigManager] writeToDefaultsForNode:node NodeHierPath:nodePath forPosition:position];
}

-(void) editModeAblerTouchedNodeReset {
    [[ConfigManager sharedConfigManager] resetToFactorySettings];
}

-(void)editModeAblerTouchedNodeSaveNodeBuffer:(NSArray *)saveNodeBuffer pathBuffer:(NSArray *)savePathBuffer pointBuffer:(NSArray *)saveCGPointBuffer {
    
    int saveCount = [saveNodeBuffer count];
    
    for (int k = 0; k < saveCount; k++) {
        CCNode *node = [saveNodeBuffer objectAtIndex:k];
        NSString *path = [savePathBuffer objectAtIndex:k];
        CGPoint pt = [[saveCGPointBuffer objectAtIndex:k] CGPointValue];
        
        [[ConfigManager sharedConfigManager] writeToDefaultsForNode:node NodeHierPath:path forPosition:pt];
    }
    
}

@end

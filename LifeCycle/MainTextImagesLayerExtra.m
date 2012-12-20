//
//  MainTextImagesLayerExtra.m
//  LifeCycle
//
//  Created by Kelvin Chan on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainTextImagesLayerExtra.h"
#import "ConfigManager.h"

@implementation MainTextImagesLayer (editModeAbler)

#pragma mark - EditModeAblerDelegate

-(void)editModeAblerTouchedNode:(CCNode *)node nodePath:(NSString *)nodePath lastPosition:(CGPoint)position {
//    CCLOG(@"%@:%d touched with last position (%.4f, %.4f)", nodePath, node.tag, position.x, position.y);
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
        
         debugLog(@"Write Path %@ : %f, %f",path,pt.x,pt.y);
        
        [[ConfigManager sharedConfigManager] writeToDefaultsForNode:node NodeHierPath:path forPosition:pt];
    }
    
}

@end

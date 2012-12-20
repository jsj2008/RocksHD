//
//  VideoLayerExtra.h
//  ButterflyPOC
//
//  Created by Kelvin Chan on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideoLayer.h"

@interface VideoLayer (editModeAbler)

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event;

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event;

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event;

-(void)editModeAblerTouchedNode:(CCNode *)node nodePath:(NSString *)nodePath lastPosition:(CGPoint)position;
-(void)editModeAblerTouchedNodeReset;
-(void)editModeAblerTouchedNodeSaveNodeBuffer:(NSArray *)saveNodeBuffer pathBuffer:(NSArray *)savePathBuffer pointBuffer:(NSArray *)saveCGPointBuffer;

@end

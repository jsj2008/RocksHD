//
//  CurrLayerExtra.h
//  ButterflyPOC
//
//  Created by Kelvin Chan on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CurrLayer.h"

@interface CurrLayer (editModeAbler)

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event;

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event;

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event;

-(void)editModeAblerTouchedNode:(CCNode *)node nodePath:(NSString *)nodePath lastPosition:(CGPoint)position;
-(void)editModeAblerTouchedNodeReset;
-(void)editModeAblerTouchedNodeSave;
-(void)editModeAblerTouchedNodeSaveNodeBuffer:(NSArray *)saveNodeBuffer pathBuffer:(NSArray *)savePathBuffer pointBuffer:(NSArray *)saveCGPointBuffer;

@end

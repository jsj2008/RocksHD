//
//  TestLayerExtra.h
//  LifeCycle
//
//  Created by Kelvin Chan on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestLayer.h"

@interface TestLayer (editModeAbler)

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event;

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event;

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event;

-(void)editModeAblerTouchedNode:(CCNode *)node nodePath:(NSString *)nodePath lastPosition:(CGPoint)position;
-(void)editModeAblerTouchedNodeReset;

@end

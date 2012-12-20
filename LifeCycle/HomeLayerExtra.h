//
//  IntroLayerExtra.h
//  LifeCycle
//
//  Created by Kelvin Chan on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HomeLayer.h"

@interface HomeLayer (editModeAbler)

-(void)editModeAblerTouchedNode:(CCNode *)node nodePath:(NSString *)nodePath lastPosition:(CGPoint)position;
-(void)editModeAblerTouchedNodeReset;
-(void)editModeAblerTouchedNodeSaveNodeBuffer:(NSArray *)saveNodeBuffer pathBuffer:(NSArray *)savePathBuffer pointBuffer:(NSArray *)saveCGPointBuffer;

@end

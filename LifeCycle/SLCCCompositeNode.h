//
//  SLCCCompositeNode.h
//  SLPOC
//
//  Created by Kelvin Chan on 11/2/12.
//
//

#import "cocos2d.h"

@interface SLCCCompositeNode : CCNode {
    CGSize screenSize;
}

-(CGRect) obtainUIKitFrameForGLOrigin:(CGPoint)origin andSize:(CGSize)size;

-(CGSize)adjustedContentSize;
-(CGRect)adjustedBoundingBox;

@end

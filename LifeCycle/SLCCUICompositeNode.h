//
//  SLCCUICompositeNode.h
//  SLPOC
//
//  Created by Kelvin Chan on 11/12/12.
//
//

#import "cocos2d.h"

@interface SLCCUICompositeNode : CCNode {
    CGSize screenSize;
}

-(CGRect) obtainUIKitFrameForGLOrigin:(CGPoint)origin andSize:(CGSize)size;
-(void) embedUIView:(UIView *)uiView;
-(CGSize)adjustedContentSize;
-(CGRect)adjustedBoundingBox;

@end

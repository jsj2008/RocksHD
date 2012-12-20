//
//  CCUIWebView.m
//  LifeCycle
//
//  Created by Kelvin Chan on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLUIWebView.h"

@implementation SLUIWebView

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {	
	NSSet *touches = [event allTouches];
    NSLog(@"sluiwebview hitest:");
    return [super hitTest:point withEvent:event];
//    return self;
    
//	BOOL forwardToSuper = YES;
//	for (UITouch *touch in touches) {
//		if ([touch tapCount] >= 2) {
//			// prevent this 
//			forwardToSuper = NO;
//		}		
//	}
//	if (forwardToSuper){
//		//return self.superview;
//		return [super hitTest:point withEvent:event];
//	}
//	else {
//		// Return the superview as the hit and prevent
//		// UIWebView receiving double or more taps
//		return self.superview;
//	}
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    NSLog(@"touchesBegan: %f, %f", location.x, location.y);
    
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    NSLog(@"touchesMoved: %f, %f", location.x, location.y);
    
    
    [super touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    NSLog(@"touchesEnded: %f, %f", location.x, location.y);
    
    [super touchesEnded:touches withEvent:event];
}

@end

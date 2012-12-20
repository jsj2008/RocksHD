//
//  CCUIActivityIndicatorView.h
//  ButterflyHD
//
//  Created by Kelvin Chan on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCNode.h"
#import "CCUIViewWrapper.h"

@interface CCUIActivityIndicatorView : CCNode {
    CGSize screenSize;
    
    CCUIViewWrapper *wrapper;
    UIActivityIndicatorView *activityIndicatorView;
}

+(id) ccUIActivityIndicatorViewWithParentNode:(CCNode *)parentNode;
-(id) initWithParentNode:(CCNode *)parentNode;

- (void)startAnimating;
- (void)stopAnimating;

@end

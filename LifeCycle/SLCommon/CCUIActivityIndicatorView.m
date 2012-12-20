//
//  CCUIActivityIndicatorView.m
//  ButterflyHD
//
//  Created by Kelvin Chan on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCUIActivityIndicatorView.h"

@implementation CCUIActivityIndicatorView

-(void) dealloc {

    if (activityIndicatorView != nil) 
        [activityIndicatorView release];
    
    [self removeChild:wrapper cleanup:YES];
    wrapper = nil;
        
    [super dealloc];
}

+(id) ccUIActivityIndicatorViewWithParentNode:(CCNode *)parentNode {
    return [[[self alloc] initWithParentNode:parentNode] autorelease];
}

-(id)initWithParentNode:(CCNode *)parentNode {
    self = [super init];
    if (self) {
        [parentNode addChild:self];
        
        screenSize = [CCDirector sharedDirector].winSize;
        
        CGPoint position = [[CCDirector sharedDirector] convertToUI:ccp(screenSize.width * 0.5, screenSize.height * 0.5)];
        
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        activityIndicatorView.center = position;
        activityIndicatorView.hidesWhenStopped = YES;
        
        wrapper = [CCUIViewWrapper wrapperForUIView:activityIndicatorView bringGLViewToFront:NO defaultViewHierStruct:YES];
        
        [self addChild:wrapper];
    }
    return self;
}

- (void)startAnimating {
    [activityIndicatorView startAnimating];
}

- (void)stopAnimating {
    [activityIndicatorView stopAnimating];
}

@end

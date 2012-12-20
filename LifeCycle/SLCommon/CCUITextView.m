//
//  CCUITextField.m
//  ButterflyHD
//
//  Created by Kelvin Chan on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCUITextView.h"

@implementation CCUITextView

@synthesize text=_text;

-(void) dealloc {
    
    if (textView != nil)
        [textView release];
    
    [self removeChild:wrapper cleanup:YES];
    wrapper = nil;
    
    [_text release];
    
    [super dealloc];
}

+(id)ccUITextViewWithParentNode:(CCNode *)parentNode {
    return [[[self alloc] initWithParentNode:parentNode] autorelease];
}

-(id)initWithParentNode:(CCNode *)parentNode {
    self = [super init];
    if (self) {
        [parentNode addChild:self];
        
        screenSize = [CCDirector sharedDirector].winSize;
        
        CGPoint position = [[CCDirector sharedDirector] convertToUI:ccp(screenSize.width*0.25, screenSize.height*0.875)];
        
        CGRect frame = CGRectMake(position.x, position.y, screenSize.width/2, 600);
        
        textView = [[UITextView alloc] init];
        textView.frame = frame;
        textView.layer.cornerRadius = 10;
        textView.font = [UIFont systemFontOfSize:15];
        textView.editable = NO;
        textView.text = @"hello world!";
        
        wrapper = [CCUIViewWrapper wrapperForUIView:textView bringGLViewToFront:NO defaultViewHierStruct:YES];
        [self addChild:wrapper];
        
    }
    return self;
}

#pragma mark - Getters & Setters
-(void) setText:(NSString *)aText {
    textView.text = aText;
}

-(NSString*) text {
    return textView.text;
}

@end

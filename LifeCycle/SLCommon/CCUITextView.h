//
//  CCUITextField.h
//  ButterflyHD
//
//  Created by Kelvin Chan on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCUIViewWrapper.h"

@interface CCUITextView : CCNode {
    CGSize screenSize;
    
    CCUIViewWrapper *wrapper;
    UITextView *textView;
}

+(id) ccUITextViewWithParentNode:(CCNode *)parentNode;
-(id) initWithParentNode:(CCNode *)parentNode;

@property (nonatomic, copy) NSString *text;

@end

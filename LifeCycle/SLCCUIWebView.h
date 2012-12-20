//
//  SLCCUIWebView.h
//  ButterflyHD
//
//  Created by Kelvin Chan on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCUIViewWrapper.h"

@interface SLCCUIWebView : CCNode {
    CGSize screenSize;
    
    CCUIViewWrapper *wrapper;
    UIWebView *webView;
}

+(id) slCCUIWebViewWithParentNode:(CCNode *)parentNode;
-(id) initWithParentNode:(CCNode *)parentNode;

@property (nonatomic, copy) NSString *urlStr;

@end

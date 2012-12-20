//
//  SLWebViewVideoPlayer.h
//  LifeCycle
//
//  Created by Kelvin Chan on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCUIViewWrapper.h"
#import "SLUIWebView.h"

@protocol SLWebViewVideoPlayerDelegate;

@interface SLWebViewVideoPlayer : CCNode <UIGestureRecognizerDelegate, UIWebViewDelegate> {
    
    CGSize screenSize;
    
    CCUIViewWrapper *wrapper;
    UIWebView *webView;
    
    float defaultWidth, defaultHeight;
    
}

@property (nonatomic, assign) id<SLWebViewVideoPlayerDelegate> delegate;

+(id) slWebViewVideoPlayerWithParentNode:(CCNode *)parentNode withVideoURL:(NSString*)url withDelegate:(id<SLWebViewVideoPlayerDelegate>)delegate;
-(id) initWithParentNode:(CCNode*)parentNode withVideoURL:(NSString*)url withDelegate:(id<SLWebViewVideoPlayerDelegate>)delegate;
-(void)reloadWithVideoURL:(NSString*)url;
-(void)reloadAsInternetOffline;

@end


@protocol SLWebViewVideoPlayerDelegate <NSObject>

@optional
-(void)sLWebViewVideoPlayerDidFinishLoad:(SLWebViewVideoPlayer *)wvPlayer;
-(void)sLWebViewVideoPlayer:(SLWebViewVideoPlayer *)webView didFailLoadWithError:(NSError *)error;

@end
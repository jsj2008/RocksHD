//
//  SLCCUIWebView.m
//  ButterflyHD
//
//  Created by Kelvin Chan on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SLCCUIWebView.h"

@interface SLCCUIWebView () <UIWebViewDelegate>

@end

@implementation SLCCUIWebView

@synthesize urlStr = _urlStr;

-(void) dealloc {
    if (webView != nil) 
        [webView release];
    
    [self removeChild:wrapper cleanup:YES];
    wrapper = nil;
    
    [_urlStr release];
    
    [super dealloc];
}

+(id)slCCUIWebViewWithParentNode:(CCNode *)parentNode {
    return [[[self alloc] initWithParentNode:parentNode] autorelease];
}

-(id)initWithParentNode:(CCNode *)parentNode {
    self = [super init];
    
    if (self) {
        [parentNode addChild:self];
        
        screenSize = [CCDirector sharedDirector].winSize;
        
        CGPoint position = [[CCDirector sharedDirector] convertToUI:ccp(screenSize.width*0.12, screenSize.height*0.875)];
        
        CGRect frame = CGRectMake(position.x, position.y, screenSize.width*0.77, 600);

        webView = [[UIWebView alloc] init];
        webView.delegate = self;
        webView.frame = frame;
        webView.layer.cornerRadius = 10;
        [webView setClipsToBounds:YES];
        
        [[webView layer] setBorderColor:
         [[UIColor colorWithRed:41.0/255.0 green:219.0/255.0 blue:57.0/255.0 alpha:1] CGColor]];
        [[webView layer] setBorderWidth:2.75];
        
        // add uiscrollviewindicator
        UIActivityIndicatorView *av = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        av.center = CGPointMake(webView.frame.size.width*0.5, webView.frame.size.height*0.5);
        av.transform = CGAffineTransformMakeScale(2.0, 2.0);
        [av startAnimating];
        av.tag = 10101;
        [webView addSubview:av];
                
        wrapper = [CCUIViewWrapper wrapperForUIView:webView bringGLViewToFront:NO defaultViewHierStruct:YES];
        
        [self addChild:wrapper];
    }
    
    return self;
}

#pragma mark - Getters & Setters
-(void) setUrlStr:(NSString *)urlStr {
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    
    if ([webView respondsToSelector:@selector(scrollView)]) {
        [webView.scrollView flashScrollIndicators];
    }
}

#pragma mark - UIWebViewDelegate
-(void) webViewDidFinishLoad:(UIWebView *)aWebView {
    UIActivityIndicatorView *av = (UIActivityIndicatorView *)[webView viewWithTag:10101];
    [av stopAnimating];
}


@end

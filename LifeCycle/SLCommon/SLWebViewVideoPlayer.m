//
//  SLWebViewVideoPlayer.m
//  LifeCycle
//
//  Created by Kelvin Chan on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLWebViewVideoPlayer.h"

@implementation SLWebViewVideoPlayer

@synthesize delegate;

-(void)dealloc {
    CCLOG(@"deallocating SLWebViewVideoPlayer");
    
    [webView release];
    
    [self removeChild:wrapper cleanup:YES];
    wrapper = nil;
    
    [super dealloc];
}

+(id) slWebViewVideoPlayerWithParentNode:(CCNode *)parentNode withVideoURL:(NSString*)url withDelegate:(id<SLWebViewVideoPlayerDelegate>)delegate {
    return [[[self alloc] initWithParentNode:parentNode withVideoURL:url withDelegate:delegate] autorelease];
}

-(id) initWithParentNode:(CCNode *)parentNode withVideoURL:(NSString *)url withDelegate:(id<SLWebViewVideoPlayerDelegate>)aDelegate {
    self = [super init];
    if (self) {
        [parentNode addChild:self];
        
        defaultWidth = 640.0;
        defaultHeight = 360.0;
        
        self.delegate = aDelegate;
        
        screenSize = [CCDirector sharedDirector].winSize;
        CGPoint position = [[CCDirector sharedDirector] convertToUI:ccp(screenSize.width*0.5 - defaultWidth*0.5, screenSize.height*0.5 + defaultHeight*0.5)];
        CGRect frame = CGRectMake(position.x, position.y, defaultWidth, defaultHeight);
        
        webView = [[UIWebView alloc] initWithFrame:frame];
        webView.delegate = self;

        // www.youtube.com/embed/VIDEO_ID
        NSString *embedHTML = @"\
        <html>\
        <head>\
        <style type=\"text/css\">\
        iframe {position:absolute; top:0%%; margin-top:0px;}\
        body {background-color:#000; margin:0;}\
        </style>\
        </head>\
        <body>\
        <iframe width=\"100%%\" height=\"%.0fpx\" src=\"%@?rel=0\" frameborder=\"0\" allowfullscreen></iframe>\
        </body>\
        </html>";
        
                
        NSString *html = [NSString stringWithFormat:embedHTML, frame.size.height, url];
        [webView loadHTMLString:html baseURL:nil];

        
        
                if ([webView respondsToSelector:@selector(scrollView)])   // this is not available until iOS 5.0
                        webView.scrollView.scrollEnabled = NO;
        
        wrapper = [CCUIViewWrapper wrapperForUIView:webView bringGLViewToFront:NO defaultViewHierStruct:YES];
        [self addChild:wrapper];
        
        CCLOG(@"allocating SLWebViewVideoPlayer");
        
    }
    return self;
}

-(void)reloadWithVideoURL:(NSString*)url {
    NSString *embedHTML = @"\
    <html>\
    <head>\
    <style type=\"text/css\">\
    iframe {position:absolute; top:0%%; margin-top:0px;}\
    body {background-color:#000; margin:0;}\
    </style>\
    </head>\
    <body>\
    <iframe width=\"100%%\" height=\"%.0fpx\" src=\"%@?rel=0\" frameborder=\"0\" allowfullscreen></iframe>\
    </body>\
    </html>";
    
    CGRect frame = webView.frame;
    NSString *html = [NSString stringWithFormat:embedHTML, frame.size.height, url];
    webView.alpha = 0.0;

    [webView loadHTMLString:html baseURL:nil];

    [UIView animateWithDuration:0.3 
                     animations:^{
                         webView.alpha=1.0;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

-(void)loadHTMLString:(NSString*)html baseURL:(NSURL *)baseURL {
    [webView loadHTMLString:html baseURL:baseURL];
}

-(void) reloadAsInternetOffline {
    NSString *html = @"\
    <html>\
    <head>\
    <style type=\"text/css\">\
    body {background-color:#000; margin:0;}\
    h2 {color:red}\
    </style>\
    </head>\
    <body>\
    <h2>The Internet connection appears to be offline.</h2>\
    </body>\
    </html>";
    
    [self loadHTMLString:html baseURL:nil];

}

-(void)testR:(UISwipeGestureRecognizer *)gesture {
    CCLOG(@"testR hit!");
}

-(void)testL:(UISwipeGestureRecognizer *)gesture {
    CCLOG(@"testL hit!");
}

-(void)handlePan:(UIPanGestureRecognizer *)gesture {
    CCLOG(@"Panned!");
    CGPoint translation = [gesture translationInView:[[CCDirector sharedDirector] openGLView]];
    CCLOG(@"Translation = %f, %f", translation.x, translation.y);
}


#pragma mark - UIGestureRecognizerDelegate methods
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}


#pragma mark - Position & stuff
-(void)setPosition:(CGPoint)position {
    
    // self offset
    CGPoint p = ccp(position.x - self.contentSize.width*0.5, position.y + self.contentSize.height*0.5);
    
    // parent offset
    CGPoint pp = ccp(p.x + self.parent.position.x, p.y + self.parent.position.y);

    CGPoint pos = [[CCDirector sharedDirector] convertToUI:pp];
    CGRect frame = CGRectMake(pos.x, pos.y, defaultWidth, defaultHeight);
    webView.frame = frame;
    
//    wrapper.position = position;
    
}

-(CGPoint)position {
    
    // convert to GL coord
    CGPoint origin = webView.frame.origin;
    CGPoint o = [[CCDirector sharedDirector] convertToGL:origin];
    
    // parent offset
    CGPoint oo = ccp(o.x - self.parent.position.x, o.y - self.parent.position.y);
    
    // self offset
    CGPoint newOrigin  = ccp(oo.x + self.contentSize.width*0.5, oo.y - self.contentSize.height*0.5);

    return newOrigin;
}

-(CGSize)contentSize {
    return webView.frame.size;
}

- (void)setParent:(CCNode *)parent {
    [super setParent:parent];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self.parent action:@selector(handlePan:)];
    pan.delegate = self;
    [webView addGestureRecognizer:pan];
    [pan release];
    
    CGSize size = webView.frame.size;
    CGPoint origin = webView.frame.origin;
    
    // convert to GL coord
    CGPoint o = [[CCDirector sharedDirector] convertToGL:origin];
    
    // parent offset
    CGPoint p = ccp(o.x + parent.position.x, o.y + parent.position.y);
    
    // convert back to UI coord
    CGPoint pp = [[CCDirector sharedDirector] convertToUI:p];
    
    CGRect newFrame = CGRectMake(pp.x,
                                 pp.y,
                                 size.width, 
                                 size.height);
    
    webView.frame = newFrame;
        
}

-(CGRect)boundingBox {
    CGSize size = webView.frame.size;
    
    CGPoint origin = webView.frame.origin;
    
    CGPoint o = [[CCDirector sharedDirector] convertToGL:origin];
    
    // boundingbox origin is on the lower left hand corner
    CGPoint oo = ccp(o.x, o.y - self.contentSize.height);
    
    // boundingbox origin is also relative to the parent
    CGPoint newOrigin = ccp(oo.x - self.parent.position.x,
                            oo.y - self.parent.position.y);
    
    return CGRectMake(newOrigin.x, newOrigin.y, size.width, size.height);
}

#pragma mark - UIWebViewDelegate methods
-(void)webViewDidFinishLoad:(UIWebView *)wView {
//    NSString *html = [wView stringByEvaluatingJavaScriptFromString:@"window.frames[0].document.body.innerHTML"];
//    CCLOG(@"html = %@", html);
    if (delegate != nil && [delegate respondsToSelector:@selector(sLWebViewVideoPlayerDidFinishLoad:)]) {
        [delegate sLWebViewVideoPlayerDidFinishLoad:self];
    }
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    if (delegate != nil && [delegate respondsToSelector:@selector(sLWebViewVideoPlayer:didFailLoadWithError:)]) {
        [delegate sLWebViewVideoPlayer:self didFailLoadWithError:error];
    }
}

@end

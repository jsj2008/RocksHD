//
//  SLVideoPlayerImpl.m
//  LifeCycle
//
//  Created by Kelvin Chan on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLVideoPlayerImpl.h"
#import "MediaPlayer/MediaPlayer.h"
#import "cocos2d.h"

@implementation SLVideoPlayerImpl

@synthesize isPlaying = _playing;
@synthesize center, size;

- (id) init
{
    if ( (self = [super init]) )
    {
        _theMovie = nil;
    }
    return self;
}

- (void)setDelegate: (id<SLVideoPlayerDelegate>) aDelegate
{
	_delegate = aDelegate;
}

#pragma mark - Movie setup

-(void) setupViewAndPlay {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    EAGLView *eaglView = [CCDirector sharedDirector].openGLView;
    
    if ([_theMovie respondsToSelector:@selector(view)]) {
        [eaglView addSubview:[_theMovie view]];
        
        _theMovie.view.hidden = NO;
        if (size.width == 0 || size.height == 0) 
            _theMovie.view.frame = CGRectMake(0, 0, keyWindow.frame.size.height*0.5, keyWindow.frame.size.width*0.5);
        else 
            _theMovie.view.frame = CGRectMake(0, 0, size.width, size.height);
        
        if (center.x == 0 || center.y == 0) 
            _theMovie.view.center = ccp(512.0, 384.0);
        else 
            _theMovie.view.center = ccp(center.x, center.y);
            
        _theMovie.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // Movie playback is asynchronous, so this method returns immediately.
        [_theMovie play];
        
    }
}

-(void)playMovieAtURL:(NSURL *)theURL {
    _playing = YES;
    [_delegate moviePlaybackStarts];
    MPMoviePlayerController* theMovie = [[MPMoviePlayerController alloc] initWithContentURL:theURL];
    if (!theMovie) 
        _playing = NO;
    
    _theMovie = theMovie;
    if ([theMovie respondsToSelector:@selector(setControlStyle:)]) {
//        theMovie.controlStyle = MPMovieControlStyleNone;
        theMovie.controlStyle = MPMovieControlStyleEmbedded;
//        theMovie.fullscreen = YES;
    }
    
    // Register for the playback notification.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:theMovie];
    
    if ([theMovie respondsToSelector:@selector(prepareToPlay)]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(preparedToPlayerCallback:)
                                                     name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                   object:theMovie];
        [theMovie prepareToPlay];
    }
        
}

-(void) cancelPlaying {
    
    if (_theMovie) 
        [_theMovie stop];
    
    if (_theMovie) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMoviePlayerPlaybackDidFinishNotification
                                                      object:_theMovie];
        
        // Release the movie instance created in playMovieAtURL:
        if ([_theMovie respondsToSelector:@selector(view)]) {
            [[_theMovie view] removeFromSuperview];
        }
        [_theMovie release];
        _theMovie = nil;
        
        [_delegate moviePlaybackFinished];
    }
}

#pragma mark - Movie Notifications
-(void)movieFinishedCallback:(NSNotification*)aNotification {
    MPMoviePlayerController *theMovie = [aNotification object];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:theMovie];
    
    // Release the movie instance created in playMovieAtURL:
    if ([theMovie respondsToSelector:@selector(view)]) {
        [theMovie.view removeFromSuperview];
    }
    [theMovie release];
    
    _theMovie = nil;
    _playing = NO;
    
    [_delegate moviePlaybackFinished];
    
}

-(void)preparedToPlayerCallback:(NSNotification*)aNotification
{
    MPMoviePlayerController* theMovie = [aNotification object];
    
    if (theMovie.isPreparedToPlay) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                      object:theMovie];
        [self setupViewAndPlay];
    }
}






@end

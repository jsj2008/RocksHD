//
//  SLVideoPlayerImpl.h
//  LifeCycle
//
//  Created by Kelvin Chan on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLVideoPlayer.h"

@class MPMoviePlayerController;

@interface SLVideoPlayerImpl : NSObject {
    
    MPMoviePlayerController *_theMovie;
    
    BOOL _playing;
    BOOL noSkip;
    
    //weak ref
    id<SLVideoPlayerDelegate> _delegate;
}

@property (readonly) BOOL isPlaying;
@property (nonatomic, assign) CGPoint center;
@property (nonatomic, assign) CGSize size;

- (void)playMovieAtURL:(NSURL*)theURL;
- (void)movieFinishedCallback:(NSNotification*)aNotification;

// - (void)setNoSkip:(BOOL)value;
// - (void)userCancelPlaying;
- (void)cancelPlaying;

- (void)setDelegate:(id<SLVideoPlayerDelegate>) aDelegate;


@end

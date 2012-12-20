//
//  SLVideoPlayer.h
//  LifeCycle
//
//  Created by Kelvin Chan on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SLVideoPlayerDelegate;

@interface SLVideoPlayer : NSObject

+(void) setCenter:(CGPoint)center;
+(void) setSize:(CGSize)size;
+(void) setDelegate:(id<SLVideoPlayerDelegate>) aDelegate;
+(void) playMovieWithFile: (NSString *) file;
+(void) cancelPlaying;
+(BOOL) isPlaying;


@end


@protocol SLVideoPlayerDelegate <NSObject>

- (void) moviePlaybackStarts;
- (void) moviePlaybackFinished;

@end
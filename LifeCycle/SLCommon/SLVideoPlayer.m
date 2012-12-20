//
//  SLVideoPlayer.m
//  LifeCycle
//
//  Created by Kelvin Chan on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLVideoPlayer.h"
#import "SLVideoPlayerImpl.h"

@interface SLVideoPlayer (Private)

+ (void) playMovieWithResourceFile:(NSString *)file;
+ (void) playMovieWithName:(NSString *)name Type:(NSString *)type;

@end

@implementation SLVideoPlayer

static SLVideoPlayerImpl *_impl = nil;

+(void) initialize {
    if (self == [SLVideoPlayer class]) {
        @synchronized(self) {
            _impl = [[SLVideoPlayerImpl alloc] init];
        }
    }
}

+(void)setCenter:(CGPoint)center {
    _impl.center = center;
}

+(void)setSize:(CGSize)size {
    _impl.size = size;
}

+(void)setDelegate:(id<SLVideoPlayerDelegate>)delegate {
    // If the current thread is the main thread,than
	// this message will be processed immediately.
    [_impl performSelectorOnMainThread:@selector(setDelegate:)
                            withObject:delegate
                         waitUntilDone:[NSThread isMainThread]];
}

+(void) playMovieWithFile: (NSString *) file {
    NSString *cachesDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *cachedVideoPath = [cachesDirectoryPath stringByAppendingPathComponent:file];
    
    // Try to play from Caches.
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachedVideoPath]) {
        NSURL *url = [NSURL fileURLWithPath:cachedVideoPath];
        // If the current thread is the main thread, then 
        // this message will be processed immediately.
        [_impl performSelectorOnMainThread:@selector(playMovieAtURL:) 
                                withObject:url
                             waitUntilDone:[NSThread isMainThread]];
        return;
    }
    
    // else play from our bundle 
    [self playMovieWithResourceFile:file];
}

+ (void) playMovieWithResourceFile: (NSString *) file {
    
    const char *source = [ file cStringUsingEncoding: [NSString defaultCStringEncoding] ];
    size_t length = strlen( source );
    
    char *str = malloc( sizeof( char) * (length + 1)  );
    memcpy( str, source, sizeof (char) * (length + 1) );
    
    char *type = strstr( str, "."); 
    *type = 0;
    type++; //< now we have extension in type, and name in str cStrings
    
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSString *sName, *sType;
	
	sName = [ NSString stringWithUTF8String: str ];
    sType = [ NSString stringWithUTF8String: type];
    [self playMovieWithName: sName Type: sType];
    
	// free str, but do not free type - it is a part of str
    free( str );
    
    [pool release];
}


//----- playMovieWithName:Type: -----
+ (void) playMovieWithName: (NSString *) name Type: (NSString *) type
{
	NSURL *movieURL;
	NSBundle *bundle = [NSBundle mainBundle];
	if (bundle) {
		NSString *moviePath = [bundle pathForResource:name ofType:type];
		
		if (moviePath) {
			movieURL = [NSURL fileURLWithPath:moviePath];
			
			// If the current thread is the main thread,than
			// this message will be processed immediately.
			[_impl performSelectorOnMainThread: @selector(playMovieAtURL:) 
                                    withObject: movieURL
                                 waitUntilDone: [NSThread isMainThread]  ];
		}
	}    
}

+ (void) cancelPlaying {
    // If the current thread is the main thread,than
	// this message will be processed immediately.
    [_impl performSelectorOnMainThread:@selector(cancelPlaying) 
                            withObject:nil 
                         waitUntilDone:[NSThread isMainThread]];
}

+(BOOL) isPlaying {
    return [_impl isPlaying];
}


@end

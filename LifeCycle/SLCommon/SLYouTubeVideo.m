//
//  SLYouTubeVideo.m
//  LifeCycle
//
//  Created by Kelvin Chan on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLYouTubeVideo.h"
#import "Constants.h"
#import "CJSONDeserializer.h"

@implementation SLYouTubeVideo

@synthesize videoID, delegate;
@synthesize conn;

-(void)dealloc {
    [videoID release];
    
    [conn cancel];
    
    [conn unscheduleFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    self.conn = nil;
    
    [super dealloc];
}

-(id) initWithVideoID:(NSString*)vID {
    self = [super init];
    if (self) {
        self.videoID = vID;
    }
    return self;
}


-(void)checkValidity {
    
    debugLog(@"Check validity %@",videoID);
    if (self.videoID != nil) {
        NSString *urlstr = [NSString stringWithFormat:@"http://gdata.youtube.com/feeds/api/videos/%@?v=2&alt=jsonc", self.videoID];
        // ?v=2&alt=json
        NSURL *url = [NSURL URLWithString:urlstr];
        NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
        
        self.conn = connection;
        
        [connection release];
        [req release];
        
        isValid = NO;
    }
}

-(void)cancel {
    [self.conn cancel];
    self.conn = nil;
}

#pragma mark - networking 
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
	if ([response statusCode] == 200) {
		webData = [[NSMutableData alloc] init];
        isValid = YES;
	}
	else {
        isValid = NO;
	}
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [webData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSMutableDictionary *userInfo;
    if (isValid) {
        userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"isValid"];
        [userInfo setObject:self.videoID forKey:@"videoID"];
        
        NSError *theError = nil;
        NSDictionary *results = (NSDictionary*) [[CJSONDeserializer deserializer] deserialize:webData error:&theError];
        
        NSString *embedPermission = [[[results objectForKey:@"data"] objectForKey:@"accessControl"] objectForKey:@"embed"];
        
        [userInfo setObject:embedPermission forKey:@"embed"];
//        NSLog(@"embed = %@", embedPermission);
        
    }
    else {
        userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"isValid"];     
        [userInfo setObject:self.videoID forKey:@"videoID"];
    }
    
    // raise a YoutubeVideoDidFinishNotification 
    NSNotification *n = [NSNotification notificationWithName:YOUTUBEVIDEO_DIDFINISH_NOTIFICATIONNAME object:nil userInfo:userInfo];
    NSArray *modes = [NSArray arrayWithObject:NSDefaultRunLoopMode];
    [[NSNotificationQueue defaultQueue] enqueueNotification:n postingStyle:NSPostWhenIdle coalesceMask: NSNotificationNoCoalescing forModes:modes];
    
    // Alternatively, call on the delegate (this seemed to suffer from a bug if the delegate is already released)
    if (delegate != nil && [delegate respondsToSelector:@selector(slYouTubeVideo:isValid:withError:)]) {
                
        if (isValid)
            [delegate slYouTubeVideo:self isValid:YES withError:nil];
        else 
            [delegate slYouTubeVideo:self isValid:NO withError:nil];
        
    }
    
    [webData release]; webData = nil;
     
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    // raise a YoutubeVideoDidFinishNotification 
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:error forKey:@"error"];
    [userInfo setObject:self.videoID forKey:@"videoID"];

    NSNotification *n = [NSNotification notificationWithName:YOUTUBEVIDEO_DIDFINISH_NOTIFICATIONNAME object:nil userInfo:userInfo];
    NSArray *modes = [NSArray arrayWithObject:NSDefaultRunLoopMode];
    [[NSNotificationQueue defaultQueue] enqueueNotification:n postingStyle:NSPostWhenIdle coalesceMask: NSNotificationNoCoalescing forModes:modes];

    // Alternatively, call on the delegate (this seemed to suffer from a bug if the delegate is already released)
    if (delegate != nil && [delegate respondsToSelector:@selector(slYouTubeVideo:isValid:withError:)]) {
        [delegate slYouTubeVideo:self isValid:NO withError:error];
    }
}

@end

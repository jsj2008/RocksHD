//
//  SLImageDownloader.m
//  LifeCycle
//
//  Created by Kelvin Chan on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLImageDownloader.h"
#import "Constants.h"

@implementation SLImageDownloader

@synthesize photoId;
@synthesize imageURL;
@synthesize delegate;
@synthesize conn;
@synthesize huge;

-(void) dealloc {
    
    NSLog(@"SLImageDownloader dealloc");
    
    [photoId release];
    
    [imageURL release];
    
    [conn cancel];
    
    [conn unscheduleFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    self.conn = nil;
    
    [super dealloc];
}

-(void)loadImage {
    if (self.imageURL != nil) {
        
        debugLog(@"load image send request %@",imageURL);
        
        NSURL *url = [NSURL URLWithString:self.imageURL];
        NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
        
        self.conn = connection;
        
        [connection release];
        [req release];
    }
}

-(void)cancel {
    [self.conn cancel];
    self.conn = nil;
}

#pragma mark - networking 
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    
    debugLog(@"didRecieveResponse");
	if ([response statusCode] == 200) {
        
          NSLog(@"Got Http 200 OK");    
        
		webData = [[NSMutableData alloc] init];
        NSDictionary *headerFields = [response allHeaderFields];
        if (headerFields) {
            // NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:headerFields forURL:[response URL]];
        }
	}
	else {
		// self.connection = nil;   // release the connection.
        
          NSLog(@"Error : Did not get HTTP 200 OK");    
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSLog(@"Recieved Data");
    [webData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    NSLog(@"connectionDidFinishLoading");    
    
    
    if (self.photoId != nil)
        [userInfo setObject:self.photoId forKey:@"photoId"];
    if (self.imageURL != nil)
        [userInfo setObject:self.imageURL forKey:@"imageURL"];
    if (webData != nil)
        [userInfo setObject:webData forKey:@"data"];
    if (huge)
        [userInfo setObject:@"huge" forKey:@"sizeType"];
    
    // raise a ImageDownloaderDidFinishNotification
    NSNotification *n = [NSNotification notificationWithName:IMAGE_DOWNLOADER_DIDFINISH_NOTIFICATIONNAME object:nil userInfo:userInfo];
    NSArray *modes = [NSArray arrayWithObject:NSDefaultRunLoopMode];
    [[NSNotificationQueue defaultQueue] enqueueNotification:n postingStyle:NSPostWhenIdle coalesceMask: NSNotificationNoCoalescing forModes:modes];
    
    if (delegate != nil && [delegate respondsToSelector:@selector(slImageDownloaderDidFinish:withNSData:)]) {
        [delegate slImageDownloaderDidFinish:self withNSData:webData];
    }
    [webData release]; webData = nil;
}

@end

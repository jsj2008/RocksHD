//
//  SLImageInfoDownloader.m
//  LifeCycle
//
//  Created by Kelvin Chan on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLImageInfoDownloader.h"
#import "CJSONDeserializer.h"
#import "APIKeyConstant.h"
#import "Constants.h"

@implementation SLImageInfoDownloader

@synthesize photoId;
@synthesize info;
@synthesize delegate;

-(void)dealloc {
    [photoId release];
    [info release];
    
    [super dealloc];
}

-(void)fetchInfo {
    if (photoId != nil) {
        NSString *urlStr = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=%@&photo_id=%@&format=json&nojsoncallback=1", FlickrAPIKey, self.photoId];
        
        NSURL *url = [NSURL URLWithString:urlStr];
        
        NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
        
        [conn release];
        [req release];
    }
}

#pragma mark - networking 
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
	if ([response statusCode] == 200) {
		webData = [[NSMutableData alloc] init];
        NSDictionary *headerFields = [response allHeaderFields];
        if (headerFields) {
            // NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:headerFields forURL:[response URL]];
        }
	}
	else {
		// self.connection = nil;   // release the connection.
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [webData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    NSString *strTmp = [[NSString alloc] initWithData:webData encoding:NSUTF8StringEncoding];
//    NSLog(@"str = %@", strTmp);
    
    NSError *theError = nil;
    NSDictionary *results = (NSDictionary*) [[CJSONDeserializer deserializer] deserialize:webData error:&theError];
    [webData release]; webData = nil;
    
    self.info =  [results objectForKey:@"photo"];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:self.info forKey:@"info"];
    [userInfo setObject:self.photoId forKey:@"photoId"];
    
    // raise a ImageInfoDownloaderDidFinishNotification
    NSNotification *n = [NSNotification notificationWithName:IMAGE_INFO_DOWNLOADER_DIDFINISH_NOTIFICATIONNAME object:nil userInfo:userInfo];
    NSArray *modes = [NSArray arrayWithObject:NSDefaultRunLoopMode];
    [[NSNotificationQueue defaultQueue] enqueueNotification:n postingStyle:NSPostWhenIdle coalesceMask: NSNotificationNoCoalescing forModes:modes];
    
    if (delegate != nil && [delegate respondsToSelector:@selector(slImageInfoDownloaderDidFinish:)]) {
        [delegate slImageInfoDownloaderDidFinish:self];
    }
}

@end

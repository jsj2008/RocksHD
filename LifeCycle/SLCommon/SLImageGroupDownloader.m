//
//  SLImageGroupDownloader.m
//  LifeCycle
//
//  Created by Kelvin Chan on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLImageGroupDownloader.h"
#import "CJSONDeserializer.h"
#import "APIKeyConstant.h"

//NSString *const FlickrAPIKey = @"9dcfd176af2103cf2e1cb810cd102527";

@implementation SLImageGroupDownloader

@synthesize groupId;
@synthesize photoIds;
@synthesize imageURLs;
@synthesize delegate;
@synthesize conn;

-(void)dealloc {
    [groupId release];
    [photoIds release];
    [imageURLs release];
    
    [conn cancel];
    [conn release];

    [super dealloc];
}

-(void)fetchImageURLs {
    if (groupId != nil) {
        
        NSString *urlStr = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.groups.pools.getPhotos&api_key=%@&group_id=%@&format=json&nojsoncallback=1", FlickrAPIKey, self.groupId];
        
        NSURL *url = [NSURL URLWithString:urlStr];
        
        NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
        
        self.conn = connection;
        
        [connection release];
        [req release];
    }
}

-(void) cancel {
    [self.conn cancel];
    self.conn = nil;
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
    NSString *strTmp = [[NSString alloc] initWithData:webData encoding:NSUTF8StringEncoding];
    NSLog(@"str = %@", strTmp);
    
    NSError *theError = nil;
    NSDictionary *results = (NSDictionary*) [[CJSONDeserializer deserializer] deserialize:webData error:&theError];
    [webData release]; webData = nil;
    
    NSArray *photos = [[results objectForKey:@"photos"] objectForKey:@"photo"];
    
    for (NSDictionary *photo in photos) {
        
        NSString *photoURLString = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_z.jpg", [photo objectForKey:@"farm"], [photo objectForKey:@"server"], [photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
        
        NSLog(@"photoURLStr = %@", photoURLString);
        
        [self.imageURLs addObject:photoURLString];
        [self.photoIds addObject:[photo objectForKey:@"id"]];
        
    }
    
    if (delegate != nil && [delegate respondsToSelector:@selector(slImageGroupDownloaderDidFinish:)]) {
        [delegate slImageGroupDownloaderDidFinish:self];
    }
}

#pragma mark - Life Cycle

-(id)init {
    
    self = [super init];
    if (self) {
        //        imageDataArray = [[NSMutableArray alloc] init];
        imageURLs = [[NSMutableArray alloc] init];
        photoIds = [[NSMutableArray alloc] init];
    }
    return self;
}


@end

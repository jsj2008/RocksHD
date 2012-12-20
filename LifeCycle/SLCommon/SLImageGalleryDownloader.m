//
//  SLImageGalleryDownloader.m
//  LifeCycle
//
//  Created by Kelvin Chan on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLImageGalleryDownloader.h"
#import "CJSONDeserializer.h"
#import "APIKeyConstant.h"
#import "Constants.h"
#import "cocos2d.h"

@implementation SLImageGalleryDownloader

@synthesize galleryId;
// @synthesize imageDataArray;
@synthesize photoIds;
@synthesize imageURLs;
@synthesize bigImageURLs=_bigImageURLs;
@synthesize delegate;
@synthesize conn;
@synthesize blarge=_blarge;


-(void)dealloc {
    [galleryId release];
    //    [imageDataArray release];
    [photoIds release];
    [imageURLs release];
    [_bigImageURLs release];
    
    [conn cancel];
    [conn release];
    
    [super dealloc];
}

#pragma mark - lazy getter
-(NSMutableArray*) bigImageURLs {
    if (_bigImageURLs == nil)
        _bigImageURLs = [[NSMutableArray alloc] init];
    return _bigImageURLs;
}

#pragma mark -

-(void)fetchImageURLs {
    if (galleryId != nil) {
        //        NSString *urlStr = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&user_id=74024715@N05&tags=%@&per_page=25&format=json&nojsoncallback=1", FlickrAPIKey, self.galleryId];
        
        NSString *urlStr = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.galleries.getPhotos&api_key=%@&gallery_id=%@&format=json&nojsoncallback=1", FlickrAPIKey, self.galleryId];
        
         CCLOG(@"URL %@",urlStr);
        
        NSURL *url = [NSURL URLWithString:urlStr];
        
        NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
        
        CCLOG(@"connect made");
        
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
    
        CCLOG(@"didReceiveResponse");
	if ([response statusCode] == 200) {
        CCLOG(@"get http 200");
        
		webData = [[NSMutableData alloc] init];
        NSDictionary *headerFields = [response allHeaderFields];
        if (headerFields) {
            // NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:headerFields forURL:[response URL]];
        }
	}
	else {
		// self.connection = nil;   // release the connection.
                CCLOG(@"get other than 200");
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

    CCLOG(@"didReceiveData");
    [webData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //    NSString *strTmp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //    NSLog(@"str = %@", strTmp);
    
        CCLOG(@"gconnectionDidFinishLoading");
    
    NSError *theError = nil;
    NSDictionary *results = (NSDictionary*) [[CJSONDeserializer deserializer] deserialize:webData error:&theError];
    [webData release]; webData = nil;
    
    NSArray *photos = [[results objectForKey:@"photos"] objectForKey:@"photo"];

    
    CCLOG(@"Photo count %d",photos.count);
    for (NSDictionary *photo in photos) {
        //        NSString *title = [photo objectForKey:@"title"];
        //        NSLog(@"title = %@", title);
        
        //        NSString *photoURLString = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_m.jpg", [photo objectForKey:@"farm"], [photo objectForKey:@"server"], [photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
        
        NSString *photoURLString = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_z.jpg", [photo objectForKey:@"farm"], [photo objectForKey:@"server"], [photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
        
        NSString *bigPhotoURLString = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_b.jpg", [photo objectForKey:@"farm"], [photo objectForKey:@"server"], [photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
        
//        NSLog(@"photoURLStr = %@", photoURLString);
        
        [self.imageURLs addObject:photoURLString];
        [self.photoIds addObject:[photo objectForKey:@"id"]];
        [self.bigImageURLs addObject:bigPhotoURLString];
        


    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:self.photoIds forKey:@"photoIDs"];
    [userInfo setObject:self.imageURLs forKey:@"imageURLs"];
    [userInfo setObject:self.bigImageURLs forKey:@"bigImageURLs"];
    [userInfo setObject:self.galleryId forKey:@"galleryId"];
    
    // raise a ImageGalleryDownloaderDidFinishNotification
    NSNotification *n = [NSNotification notificationWithName:IMAGE_GALLERY_DOWNLOADER_DIDFINISH_NOTIFICATIONNAME object:nil userInfo:userInfo];
    NSArray *modes = [NSArray arrayWithObject:NSDefaultRunLoopMode];
    [[NSNotificationQueue defaultQueue] enqueueNotification:n postingStyle:NSPostWhenIdle coalesceMask: NSNotificationNoCoalescing forModes:modes];

    // Alternatively, call on the delegate (this seemed to suffer from a bug if the delegate is already released)
    if (delegate != nil && [delegate respondsToSelector:@selector(slImageGalleryDownloaderDidFinish:)]) {
        [delegate slImageGalleryDownloaderDidFinish:self];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:error forKey:@"error"];
    [userInfo setObject:self.galleryId forKey:@"galleryId"];
    
    // raise a ImageGalleryDownloaderDidFinishNotification
    NSNotification *n = [NSNotification notificationWithName:IMAGE_GALLERY_DOWNLOADER_DIDFINISH_NOTIFICATIONNAME object:nil userInfo:userInfo];
    NSArray *modes = [NSArray arrayWithObject:NSDefaultRunLoopMode];
    [[NSNotificationQueue defaultQueue] enqueueNotification:n postingStyle:NSPostWhenIdle coalesceMask: NSNotificationNoCoalescing forModes:modes];    
    
    // deal with delegate here
//    if (delegate != nil) {
//        
//    }
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


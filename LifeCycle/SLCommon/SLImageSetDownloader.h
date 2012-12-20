//
//  SLSetImageDownloader.h
//  LifeCycle
//
//  Created by Kelvin Chan on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SLImageSetDownloaderDelegate;

@interface SLImageSetDownloader : NSObject {
    NSMutableData *webData;
    NSURLConnection *conn;
}

@property (nonatomic, retain) NSString *setId;
@property (nonatomic, retain) NSMutableArray *photoIds;
@property (nonatomic, retain) NSMutableArray *imageURLs;
@property (nonatomic, assign) id<SLImageSetDownloaderDelegate> delegate;
@property (nonatomic, retain) NSURLConnection *conn;

-(void)fetchImageURLs;
-(void)cancel;

@end

@protocol SLImageSetDownloaderDelegate <NSObject>

-(void)slImageSetDownloaderDidFinish:(SLImageSetDownloader*) downloader;

@end

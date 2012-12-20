//
//  SLImageGalleryDownloader.h
//  LifeCycle
//
//  Created by Kelvin Chan on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SLImageGalleryDownloaderDelegate;

@interface SLImageGalleryDownloader : NSObject {
    NSMutableData *webData;
    NSURLConnection *conn;
}

@property (nonatomic, retain) NSString *galleryId;
// @property (nonatomic, retain) NSMutableArray *imageDataArray;
@property (nonatomic, retain) NSMutableArray *photoIds;
@property (nonatomic, retain) NSMutableArray *imageURLs;
@property (nonatomic, retain) NSMutableArray *bigImageURLs;
@property (nonatomic, assign) id<SLImageGalleryDownloaderDelegate> delegate;
@property (nonatomic, retain) NSURLConnection *conn;
@property (nonatomic, assign) BOOL blarge;

-(void)fetchImageURLs;
-(void)cancel;

@end

@protocol SLImageGalleryDownloaderDelegate <NSObject>

-(void)slImageGalleryDownloaderDidFinish:(SLImageGalleryDownloader*) downloader;

@end


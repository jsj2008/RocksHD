//
//  SLImageDownloader.h
//  LifeCycle
//
//  Created by Kelvin Chan on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SLImageDownloaderDelegate;

@interface SLImageDownloader : NSObject {
    NSMutableData *webData;
    NSURLConnection *conn;
}

@property (nonatomic, retain) NSString *photoId;
@property (nonatomic, retain) NSString *imageURL;
@property (nonatomic, assign) id<SLImageDownloaderDelegate> delegate;
@property (nonatomic, retain) NSURLConnection *conn;
@property (nonatomic, assign) BOOL huge;

-(void)loadImage;

@end

@protocol SLImageDownloaderDelegate <NSObject>

-(void)slImageDownloaderDidFinish:(SLImageDownloader*) downloader withNSData:(NSData *)data;
                                                                        
@end

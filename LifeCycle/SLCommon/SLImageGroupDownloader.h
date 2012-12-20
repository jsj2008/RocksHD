//
//  SLImageGroupDownloader.h
//  LifeCycle
//
//  Created by Kelvin Chan on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SLImageGroupDownloaderDelegate;

@interface SLImageGroupDownloader : NSObject {
    NSMutableData *webData;
    NSURLConnection *conn;
}

@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSMutableArray *photoIds;
@property (nonatomic, retain) NSMutableArray *imageURLs;
@property (nonatomic, assign) id<SLImageGroupDownloaderDelegate> delegate;
@property (nonatomic, retain) NSURLConnection *conn;

-(void)fetchImageURLs;
-(void)cancel;

@end

@protocol SLImageGroupDownloaderDelegate <NSObject>

-(void)slImageGroupDownloaderDidFinish:(SLImageGroupDownloader*)downloader;

@end

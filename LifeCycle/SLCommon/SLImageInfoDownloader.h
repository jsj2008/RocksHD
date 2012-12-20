//
//  SLImageInfoDownloader.h
//  LifeCycle
//
//  Created by Kelvin Chan on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SLImageInfoDownloaderDelegate;

@interface SLImageInfoDownloader : NSObject {
    NSMutableData *webData;
}

@property (nonatomic, retain) NSString *photoId;
@property (nonatomic, retain) NSDictionary *info;
@property (nonatomic, assign) id<SLImageInfoDownloaderDelegate> delegate;

-(void)fetchInfo;

@end

@protocol SLImageInfoDownloaderDelegate <NSObject>

-(void)slImageInfoDownloaderDidFinish:(SLImageInfoDownloader*) downloader;

@end

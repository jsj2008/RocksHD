//
//  SLYouTubeVideo.h
//  LifeCycle
//
//  Created by Kelvin Chan on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SLYouTubeVideoDelegate;

@interface SLYouTubeVideo : NSObject {
    NSMutableData *webData;
    NSURLConnection *conn;
    BOOL isValid;
}

@property (nonatomic, retain) NSString *videoID;
@property (nonatomic, assign) id<SLYouTubeVideoDelegate> delegate;
@property (nonatomic, retain) NSURLConnection *conn;

-(id) initWithVideoID:(NSString*)vID;
-(void)checkValidity;

@end

@protocol SLYouTubeVideoDelegate <NSObject>

-(void)slYouTubeVideo:(SLYouTubeVideo*)slYouTubeVideo isValid:(BOOL)valid withError:(NSError *)error;
//-(void)slYouTubeVideo:(SLYouTubeVideo*)slYouTubeVideo didFailWithError:(NSError *)error;

@end
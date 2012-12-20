//
//  YoutubeVideoInfo.h
//  SLPOC
//
//  Created by Kelvin Chan on 10/15/12.
//
//

#import "SLInfo.h"

@interface YoutubeVideoInfo : SLInfo

@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSString *videoId;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *attribution;

@end

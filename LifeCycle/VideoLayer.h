//
//  VideoLayer.h
//  ButterflyPOC
//
//  Created by Kelvin Chan on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CCLayer.h"
#import "EditModeAbler.h"
#import "SLCCPhotoSlides.h"
#import "SLWebViewVideoPlayer.h"
#import "SLYouTubeVideo.h"

typedef enum {
    kVideoHomeButtonTag=101,
    kVideoTestButtonTag=102,
    kVideoMenuTag=103,
    kVideoSliderTag=104,
    kVideoFakeWindowTag=105,
    kVideoAttributionTag=106,
    kVideoMainTitleMenuTag=107,
    kVideoMainTitleTag=108,
    kVideoPlsWaitTag=109,
    kVideoBackButtonTag=110,
    kVideoBackMenuTag=111
} VideoLayerTags;

//@interface VideoLayer : CCLayer <SLCCPhotoSlidesDataSource, SLCCPhotoSlidesDelegate, SLYouTubeVideoDelegate, SLWebViewVideoPlayerDelegate> {
@interface VideoLayer : CCLayer <SLCCPhotoSlidesDataSource, SLCCPhotoSlidesDelegate, SLWebViewVideoPlayerDelegate, UIAlertViewDelegate> {
    
    CGSize screenSize;
    
    SLCCPhotoSlides *slides;
    
    CGRect infoLabelBound;
    EditModeAbler *editModeAbler;
    
    NSMutableArray *potentialVideoIDs;
    NSMutableDictionary *potentialVideoAttributions;
    NSMutableArray *videoIDs;
    NSMutableArray *videoAttributions;
    NSMutableDictionary *videoID2IndexMap;
    
    NSMutableArray *slYouTubeVideos;

}

@property (nonatomic, retain) NSDictionary *topicInfo;

@end

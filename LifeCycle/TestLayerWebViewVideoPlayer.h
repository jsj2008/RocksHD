//
//  TestLayerWebViewVideoPlayer.h
//  LifeCycle
//
//  Created by Kelvin Chan on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CCLayer.h"
#import "EditModeAbler.h"
#import "SLCCPhotoSlides.h"
#import "SLWebViewVideoPlayer.h"
#import "SLYouTubeVideo.h"

typedef enum {
    kTestingWebViewVideoPlayerHomeButtonTag=101,
    kTestingWebViewVideoPlayerTestButtonTag=102,
    kTestingWebViewVideoPlayerMenuTag=103,
    kTestingWebViewVideoPlayerSliderTag=104,
    kTestingWebViewVideoPlayerFakeWindowTag=105,
    kTestingWebViewVideoPlayerAttributionTag=106
} TestLayerWebViewVideoPlayerTaggs;

@interface TestLayerWebViewVideoPlayer : CCLayer <SLCCPhotoSlidesDataSource, SLCCPhotoSlidesDelegate, SLYouTubeVideoDelegate, SLWebViewVideoPlayerDelegate> {
    CGSize screenSize;
    
    SLCCPhotoSlides *slides;
    
    CGRect infoLabelBound;
    EditModeAbler *editModeAbler;
    
    NSMutableArray *potentialVideoIDs;
    NSMutableDictionary *potentialVideoAttributions;
    NSMutableArray *videoIDs;
    NSMutableArray *videoAttributions;
    NSMutableDictionary *videoID2IndexMap;
    
}

@end

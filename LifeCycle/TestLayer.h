//
//  TestLayer.h
//  LifeCycle
//
//  Created by Kelvin Chan on 1/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CCLayer.h"
#import "FlowAndStateManager.h"
#import "EditModeAbler.h"
#import "SLImageSetDownloader.h"
#import "SLImageDownloader.h"
#import "SLVideoPlayer.h"
#import "SLCCPhotoSlides.h"
#import "SLCCImageStack.h"
#import "Box2D.h"

typedef enum {
    kTestingPaneTag=100,
    kTestingTextTag=101,
    kTestingHomeButtonTag=102,
    kTestingTestButtonTag=103,
    kTestingMenuTag=104,
    kTestingPhotoSliderTag=105,
    kTestingImageStackTag=106,
    kTestingPhotoSliderFromFlickrTag=107,
    kTestingFakeWindowTag=108
} TestLayerTags;

@interface TestLayer : CCLayer <CCTargetedTouchDelegate, EditModeAblerDelegate, SLImageSetDownloaderDelegate, SLImageDownloaderDelegate, UIAlertViewDelegate, SLVideoPlayerDelegate, SLCCPhotoSlidesDataSource, SLCCImageStackDataSource> {
    
    CGSize screenSize;
    CGRect infoLabelBound;
    EditModeAbler *editModeAbler;
    
    // Box2D physics engine
    b2World *world;
    
    SLCCPhotoSlides *slides;
    
    SLImageSetDownloader *imgSetDowloader;
    NSMutableArray *slImageDownloaders;    // used to ref the set of individual image downloaders
}

@end

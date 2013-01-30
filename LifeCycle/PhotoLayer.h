//
//  PhotoLayer.h
//  ButterflyPOC
//
//  Created by Kelvin Chan on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CCLayer.h"
#import "EditModeAbler.h"
#import "SLImageGalleryDownloader.h"
#import "SLImageDownloader.h"
#import "SLImageInfoDownloader.h"
#import "SLCCPhotoSlides.h"
#import "SLCCUIPageControl.h"
#import "CCUIActivityIndicatorView.h"
#import "TopicInfo.h"

typedef enum {
    kPhotoHomeButtonTag=101,
    kPhotoBackButtonTag=102,
    kPhotoMenuTag=103,
    kPhotoSliderTag=104,
    kPhotoAttributionTag=105,
    kPhotoTitleTag=106,
    kPhotoPageControlTag=107,
    kPhotoMainTitleMenuTag=108,
    kPhotoMainTitleTag=109,
    kPhotoErrLabelTag=110,
    kPhotoBackMenuTag=112,
    kPhotoSliderReflectionTag=113,
    kPhotoBigImageTag=114
} PhotoLayerTags;

@interface PhotoLayer : CCLayer <SLCCPhotoSlidesDataSource, SLCCPhotoSlidesDelegate> {

    CGSize screenSize;
    EditModeAbler *editModeAbler;
    
    SLCCPhotoSlides *slides;
    CCUIActivityIndicatorView *plsWaitIndicator;
    
    NSMutableArray *urlArray;
    NSMutableDictionary *url2IndexMap;
    
    NSMutableArray *photoIdArray; 
    NSMutableDictionary *photoId2IndexMap;
    NSMutableDictionary *photoInfo;
    
    // Image download states
    BOOL numOfImagesKnown;
    int numOfImages;
    
    SLImageGalleryDownloader *imgGalleryDownloader;
    
    NSMutableArray *slImageDownloaders;
    NSMutableArray *slImageInfoDownloaders;
    
    // background thread
    dispatch_queue_t backgroundQueue;
    
    // Multi-touches
    float sq_start_distance;  // square of the starting distance between 2 fingers
    BOOL panned_completed;
    BOOL zoomed;
    
    UISwipeGestureRecognizer *swipeGestureRecognizer;
    UIPinchGestureRecognizer *pinchGestureRecognizer;
    
    NSString *galleryId;
    BOOL         firstDescriptioNotShow ;
}

@property (nonatomic, retain) TopicInfo *topicInfo;
@property (nonatomic, retain) NSString *galleryId;

@end

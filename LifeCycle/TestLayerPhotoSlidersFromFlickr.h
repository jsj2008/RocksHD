//
//  TestPhotoSlidersFromFlickr.h
//  LifeCycle
//
//  Created by Kelvin Chan on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CCLayer.h"
#import "EditModeAbler.h"
#import "SLImageSetDownloader.h"
#import "SLImageDownloader.h"
#import "SLImageGroupDownloader.h"
#import "SLImageGalleryDownloader.h"
#import "SLImageInfoDownloader.h"
#import "SLCCPhotoSlides.h"

typedef enum {
    kTestingPhotoSlidersFlickrHomeButtonTag=101,
    kTestingPhotoSlidersFlickrTestButtonTag=102,
    kTestingPhotoSlidersFlickrMenuTag=103,
    kTestingPhotoSlidersFlickrSliderTag=104,
    kTestingPhotoSlidersFlickrAttributionTag=105
} TestLayerPhotoSlidersFromFlickrTags;

@interface TestLayerPhotoSlidersFromFlickr : CCLayer <SLImageSetDownloaderDelegate, SLImageGroupDownloaderDelegate, SLImageGalleryDownloaderDelegate,SLImageDownloaderDelegate,SLCCPhotoSlidesDataSource, SLCCPhotoSlidesDelegate, SLImageInfoDownloaderDelegate> {
    
    CGSize screenSize;
    EditModeAbler *editModeAbler;
    
    SLCCPhotoSlides *slides;
    
    NSMutableArray *urlArray;
    NSMutableDictionary *url2IndexMap;
    
    NSMutableArray *photoIdArray; 
    NSMutableDictionary *photoId2IndexMap;
    NSMutableDictionary *photoInfo;
    
    // Image download states
    BOOL numOfImagesKnown;
    int numOfImages;
    
    SLImageSetDownloader *imgSetDownloader;
    SLImageGroupDownloader *imgGrpDownloader;
    SLImageGalleryDownloader *imgGalleryDownloader;
    
    NSMutableArray *slImageDownloaders;
}

@end

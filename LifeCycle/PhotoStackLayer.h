//
//  PhotoStackLayer.h
//  ButterflyHD
//
//  Created by Kelvin Chan on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CCLayer.h"
#import "SLCCImageStack.h"

#import "EditModeAbler.h"
#import "SLImageGalleryDownloader.h"
#import "SLImageDownloader.h"
#import "SLImageInfoDownloader.h"

typedef enum {
    kPhotoStackBackButtonTag=101
} PhotoStackLayerTags;

@interface PhotoStackLayer : CCLayer <SLCCImageStackDataSource, SLCCImageStackDelegate> {
    CGSize screenSize;
    
    EditModeAbler *editModeAbler;
    
    BOOL isNumOfImagesKnown;
    int numOfImages;
}

@property (nonatomic, retain) NSDictionary *topicInfo;
    
@end

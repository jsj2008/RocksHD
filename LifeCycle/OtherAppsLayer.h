//
//  OtherAppsLayer.h
//  ButterflyHD
//
//  Created by Kelvin Chan on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CCLayer.h"
#import "SLCCUIWebView.h"

typedef enum {
    kOtherAppsHomeButtonTag=101,
    kOtherAppsMenuTag=102
} OtherAppsLayerTags;

@interface OtherAppsLayer : CCLayer {
    CGSize screenSize;
    
    SLCCUIWebView *slccWebView;
}

@end

//
//  InfoLayer.h
//  PlantHD
//
//  Created by Kelvin Chan on 11/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CCLayer.h"
#import "FlowAndStateManager.h"
#import "EditModeAbler.h"


typedef enum {
    kInfoPaneTag=100,
    kInfoTextTag=101,
    kInfoHomeButtonTag=102,
    kInfoEmailButtonTag=103,
    kInfoMenuTag=104
} InfoLayerTags;


@interface InfoLayer : CCLayer <CCTouchOneByOneDelegate, EditModeAblerDelegate> {
    
    CGSize screenSize;
    CGRect infoLabelBound;
    EditModeAbler *editModeAbler;
}

@end

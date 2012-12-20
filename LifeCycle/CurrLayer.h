//
//  CurrLayer.h
//  ButterflyPOC
//
//  Created by Kelvin Chan on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CCLayer.h"
#import "FlowAndStateManager.h"
#import "EditModeAbler.h"
#import "CCUITextView.h"


typedef enum {
    kCurrPaneTag=100,
    kCurrTextTag=101,
    kCurrHomeButtonTag=102,
    kCurrEmailButtonTag=103,
    kCurrMenuTag=104
} CurrLayerTags;

@interface CurrLayer : CCLayer <CCTargetedTouchDelegate, EditModeAblerDelegate> {
    CGSize screenSize;
    CGRect currLabelBound;
    EditModeAbler *editModeAbler;
    
    CCUITextView *currTextView;
}

@end

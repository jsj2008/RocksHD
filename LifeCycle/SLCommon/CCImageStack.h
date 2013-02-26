//
//  CCImageStack.h
//  SLCommon
//
//  Created by Kelvin Chan on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CCSprite.h"

@interface CCImageStack : CCSprite <CCTouchOneByOneDelegate> {
    CGSize screenSize;
    
    CCArray *images;            // array of image file name strings
    CCArray *imageScales;       // array of image scale (format in strings)
    CCArray *imageTitles;
    CCArray *imageAttributions;
    
    // CCSpriteBatchNode *imagesBatchNode;
    
    CCArray *imageFrameSprites; // array referencing the sprite object frames
    CCArray *imageSprites;      // array referencing the sprite objects themselves
    int numberOfRecyclableImageSprites;
    
    int imageIndexOnTop;        // to keep track of which image is current on top of the card stack/deck
    int imageIndexAtBack;
    
    CGPoint startTouchPt;
    CGPoint lastTouchPt;
    
    float dAngle;               // incremental angular rotation used.
    float dX;                   // incremntal horizontal displacement
    
    // internal 
    float imgHeightAdjustment;
    float w;
    float h2;
    float h;
    int N;
    float textLeftMargin;
    float titleLabelHeight;
    float attributionLabelHeight;
    float originalIframeOrientation;
    
    CCLabelTTF *titleLabel;
    CCLabelTTF *attributionLabel;

}

@property (nonatomic, retain) CCArray *images;
@property (nonatomic, retain) CCArray *imageScales;
@property (nonatomic, retain) CCArray *imageTitles;
@property (nonatomic, retain) CCArray *imageAttributions;
//@property (nonatomic, retain) CCArray *imageSprites;
//@property (nonatomic, retain) CCArray *imageFrameSprites;

@property (nonatomic, copy) NSString *imageAtlasPlistName;
@property (nonatomic, copy) NSString *imageAtlasPngName;
//@property (nonatomic, retain) CCSpriteBatchNode *imagesBatchNode;


+(CCImageStack *) ccImageStack;

@end

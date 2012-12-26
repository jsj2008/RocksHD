//
//  SLCCMenu.h
//  SLPOC
//
//  Created by Kelvin Chan on 9/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

typedef enum {
    SLCCMenuTopLeft,
    SLCCMenuTopRight,
    SLCCMenuBottomLeft,
    SLCCMenuBottomRight
} SLCCMenuLocation;

typedef enum {
    SLCCMenuTypePullOrTabOutHorizontal,
    SLCCMenuTypePullOrTabOutVertical,
    SLCCMenuTypeSwipeOut
} SLCCMenuType;

@interface SLCCMenu : CCNode

+(id)slCCMenuWithParentNode:(CCNode *)parentNode atLocation:(SLCCMenuLocation)location withType:(SLCCMenuType) type;

-(id)initWithParentNode:(CCNode *)parentNode atLocation:(SLCCMenuLocation)location withType:(SLCCMenuType) type;

-(void) menuWithItems: (CCMenuItem*) item, ... NS_REQUIRES_NIL_TERMINATION;

@property (nonatomic, assign) SLCCMenuLocation menuLocation;
@property (nonatomic, assign) SLCCMenuType type;
@property (nonatomic, assign) CCMenu *menu;

@property (nonatomic, assign) float menuItemPadding;

@end

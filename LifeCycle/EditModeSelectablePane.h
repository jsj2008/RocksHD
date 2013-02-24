//
//  EditModeCCRenderTexture.h
//  PlantHD
//
//  Created by Kelvin Chan on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CCRenderTexture.h"

@protocol EditModeSelectablePaneDelegate;

@interface EditModeSelectablePane : CCRenderTexture <CCTouchOneByOneDelegate> {
    CGSize size;

}

@property (nonatomic, assign) BOOL selected;
@property (nonatomic, retain) NSString *note;
@property (nonatomic, assign) id<EditModeSelectablePaneDelegate> delegate;
@property (nonatomic, assign) CCNode *partnerNode;
@property (nonatomic, retain) NSString *partnerNodeFullPath;


@end

@protocol EditModeSelectablePaneDelegate

-(void)editModeSelectablePaneSelected:(EditModeSelectablePane*)pane;

@end

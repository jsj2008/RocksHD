//
//  EditModeAbler.h
//  PlantHD
//
//  Created by Kelvin Chan on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <objc/runtime.h>
#import "cocos2d.h"
#import "CCNode.h"
#import "EditModeSelectablePane.h"

typedef enum {
    kEditModeAblerEditLabelTag=1000,
    kEditModeAblerCoordinatesLabelTag=1001,
    kEditModeAblerEditExitButtonTag=1002,
    kEditModeAblerEditResetButtonTag=1003,
    kEditModeAblerEditButtonTag=1004,
    kEditModeAblerEditSaveButtonTag=1005
} EditModeAblerTags;

@protocol EditModeAblerDelegate;

@interface EditModeAbler : CCSprite <CCTargetedTouchDelegate, EditModeSelectablePaneDelegate> {
    BOOL uiEditMode;
    CCLayer *delegateLayer;
    
    // internal     
    CGSize _screenSize;
    
    BOOL _patternStarted;
    BOOL _selectModeOn;
    
    CCNode *_selectedNode;
    
//    CCLabelTTF *_editLabel;
    
    // About the edit mode menu
    CCSprite *_editExitButton;
    CCSprite *_editSaveButton;
    CCSprite *_editResetButton;
    
    CCLabelTTF *_coordinatesLabel;
    
    // For tracking touches
    CGPoint _startTouchPt;
    CGPoint _lastTouchPt;
    CCNode *_objectTouched;   // while in ui debug mode, tracking the touched object
    CCNode *_parentObjectTouched;   // while in ui debug mode, tracking the parent of the object being touched.
    
    // save
    NSMutableArray *saveNodeBuffer;
    NSMutableArray *saveCGPointBuffer;
    NSMutableArray *savePathBuffer;
    
}

@property (nonatomic, retain) NSMutableArray *_paneArray;
@property (nonatomic, assign) CCLayer *delegateLayer;
@property (nonatomic, retain) NSString *objectTouchedPath;

-(void)activate;

@end

@protocol EditModeAblerDelegate

@optional
-(void)editModeAblerTouchedNode:(CCNode *)node nodePath:(NSString*)nodePath lastPosition:(CGPoint)position;
-(void)editModeAblerTouchedNodeReset;
-(void)editModeAblerTouchedNodeSaveNodeBuffer:(NSArray *)saveNodeBuffer pathBuffer:(NSArray *)savePathBuffer pointBuffer:(NSArray *)saveCGPointBuffer;
@end

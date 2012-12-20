//
//  EditModeAbler.m
//  PlantHD
//
//  Created by Kelvin Chan on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EditModeAbler.h"

@interface EditModeAbler (Private) 
-(void)cleanEditModeCCRenderTexture;
-(void)setAllChildOpacity:(GLubyte)opacity;
-(void)disableAllNodeOfClass:(Class)klass rootNode:(CCNode*)rootNode;
-(void)enableAllNodeOfClass:(Class)klass rootNode:(CCNode*)rootNode;
-(void)setSwallowTouches:(BOOL)swallowsTouches withTarget:(id<CCTargetedTouchDelegate>)target;
-(void)setToSwallowTouchesAllNodeOfClass:(Class) klass rootNode:(CCNode*)rootNode;
-(void)setToDontSwallowTouchesAllNodeOfClass:(Class) klass rootNode:(CCNode*)rootNode;
@end

@interface CCTouchDispatcher (SL)
-(CCTouchHandler*) findHandler:(id)delegate;
@end

@implementation EditModeAbler

@synthesize _paneArray;
@synthesize delegateLayer;
@synthesize objectTouchedPath;

-(void)dealloc {
    
    CCLOG(@"releasing editmodeabler");
    
    [_paneArray release];
    [objectTouchedPath release];
     
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self.delegateLayer];

    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        uiEditMode = NO;
        _screenSize = [CCDirector sharedDirector].winSize;
        _patternStarted = NO;
        _selectModeOn = NO;

    }
    
    return self;
}

-(void)activate {
        
    // check to see if delegateLayer has already been added to cctouchdispatcher and remove it
    if ([[CCTouchDispatcher sharedDispatcher] findHandler:self.delegateLayer] != nil) {
        [[CCTouchDispatcher sharedDispatcher] removeDelegate:self.delegateLayer];
    }
    
    // register so it doesnt swallow touches
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self.delegateLayer priority:0 swallowsTouches:NO];
    
    _selectedNode = nil;
    
    /* testing dynamic adding of method back to delegateLayer
    Method touchBeginMethod = class_getInstanceMethod([self class], @selector(ccTouchBegan:withEvent:));
    
    class_addMethod([self.delegateLayer class], @selector(ccTouchBegan:withEvent:), class_getMethodImplementation([self class], @selector(ccTouchBegan:withEvent:)), method_getTypeEncoding(touchBeginMethod));
 
    // */

}

-(void)deactivate {
    
}

#pragma mark - EditModeSelectablePaneDelegate
-(void)editModeSelectablePaneSelected:(EditModeSelectablePane *)pane {
    
    if (pane != nil) {
        // CCLOG(@"%@ selected!", NSStringFromClass([pane.partnerNode class]));
        
        _selectedNode = pane.partnerNode;
        
        self.objectTouchedPath = pane.partnerNodeFullPath;
    }
    // [self setAllChildOpacity:255];
    
    _selectModeOn = NO;
    [self cleanEditModeCCRenderTexture];
    
}

#pragma mark - Edit mode gesture recognizer

-(void) editExit:(id)sender {
    CCLOG(@"Edit exit button hit!");
    // Exiting edit mode
    [self cleanEditModeCCRenderTexture];
    
//    [_editLabel runAction:[CCFadeOut actionWithDuration:1.0]];
    
    [_editExitButton runAction:[CCFadeOut actionWithDuration:0.5]];
    [_editResetButton runAction:[CCFadeOut actionWithDuration:0.5]];
    [_editSaveButton runAction:[CCFadeOut actionWithDuration:0.5]];
    
    [_coordinatesLabel runAction:[CCFadeOut actionWithDuration:0.5]];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self.delegateLayer];
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self.delegateLayer priority:0 swallowsTouches:NO];
    uiEditMode = NO;
    
    // Reable all menu buttons
    [self enableAllNodeOfClass:[CCMenuItemImage class] rootNode:self.delegateLayer];
    [self setToSwallowTouchesAllNodeOfClass:[CCMenu class] rootNode:self.delegateLayer];
}

-(void) editReset:(id)sender {
    CCLOG(@"Edit reset button hit!");
    
    if ([delegateLayer respondsToSelector:@selector(editModeAblerTouchedNodeReset)]) {
        [(id<EditModeAblerDelegate>)delegateLayer editModeAblerTouchedNodeReset];
    }
    
    // animate the reset button a bit
    float original_scale = _editResetButton.scale;
    [_editResetButton runAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.2 scale:original_scale*1.2],
                                 [CCScaleTo actionWithDuration:0.2 scale:original_scale*1.0], nil]];
}

-(void) editSave:(id)sender {
    
    if ([delegateLayer respondsToSelector:@selector(editModeAblerTouchedNodeSaveNodeBuffer:pathBuffer:pointBuffer:)]) {
        [(id<EditModeAblerDelegate>)delegateLayer editModeAblerTouchedNodeSaveNodeBuffer:saveNodeBuffer pathBuffer:savePathBuffer pointBuffer:saveCGPointBuffer];
    }
    
    [saveNodeBuffer release]; saveNodeBuffer = nil;
    [savePathBuffer release]; savePathBuffer = nil;
    [saveCGPointBuffer release]; saveCGPointBuffer = nil;
    
    // animate the save button a bit
    float original_scale = _editSaveButton.scale;
    [_editSaveButton runAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.2 scale:original_scale*1.2],
                                 [CCScaleTo actionWithDuration:0.2 scale:original_scale*1.0], nil]];
}

-(void) editModeSwipedRecognized:(CGPoint)locationInGL {
//    if (_editLabel == nil) {
//        _editLabel = [CCLabelTTF labelWithString:@"In edit Mode, touch to exit." fontName:@"AmericanTypewriter-Bold" fontSize:18];
//        _editLabel.color = ccc3(255, 0, 0);
//        _editLabel.anchorPoint = ccp(0, 0.5);
//        [self.delegateLayer addChild:_editLabel z:1000 tag:kEditModeAblerEditLabelTag];
//    }
    
    // Allocate stuff for menu if havent done so
    if (_editExitButton == nil || _editResetButton == nil || _editSaveButton == nil) {
        
        _editExitButton = [CCSprite spriteWithFile:@"edit_exit.png"];
//        _editExitButton.position = ccp(0.9053*_screenSize.width, 0.0417*_screenSize.height);
        _editExitButton.position = ccp(_editExitButton.contentSize.width*0.5, _screenSize.height - _editExitButton.contentSize.height*0.5);
        _editExitButton.tag = kEditModeAblerEditExitButtonTag;
        
        _editSaveButton = [CCSprite spriteWithFile:@"edit_save.png"];
        _editSaveButton.position = ccp(_editExitButton.contentSize.width + _editSaveButton.contentSize.width*0.5,
                                       _screenSize.height - _editSaveButton.contentSize.height * 0.5 + 4);
        _editSaveButton.tag = kEditModeAblerEditSaveButtonTag;
        _editSaveButton.scale = 0.9;
        
//        _editResetButton = [CCSprite spriteWithFile:@"edit_reset.png"];
////        _editResetButton.position = ccp(0.9609*_screenSize.width, 0.0469*_screenSize.height);
//        _editResetButton.position = ccp(_editExitButton.contentSize.width + _editSaveButton.contentSize.width + _editResetButton.contentSize.width*0.5,
//                                        _screenSize.height - _editResetButton.contentSize.height * 0.5 + 2);
//        _editResetButton.tag = kEditModeAblerEditResetButtonTag;
//        _editResetButton.scale = 1.2f;
    
        
        [self.delegateLayer addChild:_editExitButton z:1000];
        [self.delegateLayer addChild:_editSaveButton z:1000];
//        [self.delegateLayer addChild:_editResetButton z:1000];

    }
    
    if (!uiEditMode) {
        // turning Edit ON
        
//        _editLabel.position = ccp(0, _screenSize.height*0.5);
//        [_editLabel runAction:[CCFadeIn actionWithDuration:0.5]];
        
        [_editExitButton runAction:[CCFadeIn actionWithDuration:0.5]];
        [_editResetButton runAction:[CCFadeIn actionWithDuration:0.5]];
        [_editSaveButton runAction:[CCFadeIn actionWithDuration:0.5]];
        
        // Register touch, and swallow all event
        [[CCTouchDispatcher sharedDispatcher] removeDelegate:self.delegateLayer];
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self.delegateLayer priority:0 swallowsTouches:YES];
        uiEditMode = YES;
        
        // Disable all menu items
        [self disableAllNodeOfClass:[CCMenuItemImage class] rootNode:self.delegateLayer];
        [self setToDontSwallowTouchesAllNodeOfClass:[CCMenu class] rootNode:self.delegateLayer];
    }
    
}

-(void) editModeSwipeGestureBegan:(CGPoint)locationInGL {
    // swiping start anywhere in the top left side corner 
    CGRect bound = CGRectMake(0, _screenSize.height*3.0/4.0, _screenSize.width/3.0, _screenSize.height/4.0);
    if (CGRectContainsPoint(bound, locationInGL)) {
        _patternStarted = YES;
    }
}

-(void) editModeSwipeGestureEnded:(CGPoint)locationInGL {
    if (_patternStarted) {        
        CGRect bound = CGRectMake(0.0, 0.0, _screenSize.width/3.0, _screenSize.height/4.0);
        if (CGRectContainsPoint(bound, locationInGL)) {
            [self editModeSwipedRecognized:locationInGL];
        }
    }
    
    // reset the gesture recognizer.
    _patternStarted = NO;
    
}


#pragma mark - Detecting for gesture

-(CCFiniteTimeAction*) CCWait:(float)duration {
    return [CCMoveBy actionWithDuration:duration position:CGPointZero];
}

-(void)setAllChildOpacity:(GLubyte)opacity {
    for (CCNode *n in [self.delegateLayer children]) {
        if( [n conformsToProtocol:@protocol( CCRGBAProtocol)] )
        {
            [(id<CCRGBAProtocol>)n setOpacity:opacity];
        }
        
    }
}


-(void)displayPaneArray {
    for (EditModeSelectablePane *n in _paneArray) {
        n.visible = NO;
        [self.delegateLayer addChild:n];
        // CCLOG(@"node touched = %@", NSStringFromClass([n.partnerNode class]));
    }
    //[self schedule:@selector(displayPaneArrayInLoop) interval:0.5];
    [[CCScheduler sharedScheduler] scheduleSelector:@selector(displayPaneArrayInLoop) forTarget:self interval:0.5 paused:NO];

}

-(void)displayPaneArrayInLoop {
    
    // overlay a translucent plane over each node and cycle thru them.
    [self unschedule:_cmd];
    
    static int k=0;
    int N = [_paneArray count];
    
    if (N > 0) {  // else nothing to do 
        _selectModeOn = YES;
        
        if (k >= N)
            k = 0;
        
        EditModeSelectablePane *node = (EditModeSelectablePane*)[_paneArray objectAtIndex:k];
        node.visible = YES;
        
        int lastk = (k-1) < 0 ? (N-1) : (k-1);
        if (lastk != k) {    
            EditModeSelectablePane *lastNode = (EditModeSelectablePane*) [_paneArray objectAtIndex:lastk];
            lastNode.visible = NO;
        }
        
        k++;
    }
    
    // [self schedule:@selector(displayPaneArrayInLoop) interval:1.5];
    [[CCScheduler sharedScheduler] scheduleSelector:@selector(displayPaneArrayInLoop) forTarget:self interval:1.5 paused:NO];

}

-(void)enableAllNodeOfClass:(Class) klass rootNode:(CCNode*)rootNode {
    CCArray *children = [rootNode children];
    
    for (CCNode *node in children) {
        if ([node isKindOfClass:klass]) {
            [(CCMenuItemImage *)node setIsEnabled:YES];
        }
        else
            [self enableAllNodeOfClass:klass rootNode:node];
    }
    
}

-(void)disableAllNodeOfClass:(Class) klass rootNode:(CCNode*)rootNode {
    CCArray *children = [rootNode children];
    
    for (CCNode *node in children) {
        if ([node isKindOfClass:klass]) {
            [(CCMenuItemImage *)node setIsEnabled:NO];
        }
        else
            [self disableAllNodeOfClass:klass rootNode:node];
    }
    
}

-(void)setToSwallowTouchesAllNodeOfClass:(Class) klass rootNode:(CCNode*)rootNode {
    CCArray *children = [rootNode children];
    
    for (CCNode *node in children) {
        if ([node isKindOfClass:klass]) {
            id<CCTargetedTouchDelegate> n = (id<CCTargetedTouchDelegate>)node;
            [self setSwallowTouches:YES withTarget:n];
        }
        else 
            [self setToSwallowTouchesAllNodeOfClass:klass rootNode:node];
    }
}

-(void)setToDontSwallowTouchesAllNodeOfClass:(Class) klass rootNode:(CCNode*)rootNode {
    CCArray *children = [rootNode children];
    
    for (CCNode *node in children) {
        if ([node isKindOfClass:klass]) {
            id<CCTargetedTouchDelegate> n = (id<CCTargetedTouchDelegate>)node;
            [self setSwallowTouches:NO withTarget:n];
        }
        else 
            [self setToDontSwallowTouchesAllNodeOfClass:klass rootNode:node];
    }
}

-(void) setSwallowTouches:(BOOL)swallowsTouches withTarget:(id<CCTargetedTouchDelegate>)target {
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:target];
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:target priority:kCCMenuTouchPriority swallowsTouches:swallowsTouches];
}


-(NSMutableArray*)findLeafNodesTouched:(CCNode *)rootNode locationInGL:(CGPoint)locationInGL rootBound:(CGRect)rootbound rootPath:(NSString*)rootPath {
    
    // Array to store the EditModeCCRenderTexture
    NSMutableArray *paneArray = [[[NSMutableArray alloc] init] autorelease];   
    
    CCArray *children = [rootNode children];
    for (int k = [children count]-1; k >= 0; k--) {
        CCNode *child = [children objectAtIndex:k];
        
        if (![child isKindOfClass:[EditModeSelectablePane class]] && child.tag != 1000) {
            CGRect globalBound = CGRectMake(rootbound.origin.x + child.boundingBox.origin.x, 
                                            rootbound.origin.y + child.boundingBox.origin.y, 
                                            child.boundingBox.size.width, 
                                            child.boundingBox.size.height);
            
            CGRect adjGlobalBound;
            if ([child isMemberOfClass:[CCMenu class]]) { 
                // the bounding box is too big for nothing, 1024x768, adjust it
                adjGlobalBound = CGRectMake(rootbound.origin.x + child.boundingBox.origin.x-300*0.5, 
                                            rootbound.origin.y + child.boundingBox.origin.y-300*0.5, 
                                            300,
                                            300);
            }
            else {
                adjGlobalBound = globalBound;
            }
            
            if (CGRectContainsPoint(adjGlobalBound, locationInGL)) {
                
                EditModeSelectablePane *pane = [EditModeSelectablePane renderTextureWithWidth:adjGlobalBound.size.width height:adjGlobalBound.size.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
                pane.note = NSStringFromClass([child class]);
                pane.position = ccp(CGRectGetMidX(adjGlobalBound), CGRectGetMidY(adjGlobalBound));
                [pane clear:0.5 g:0.5 b:0.5 a:0.7];
                
                pane.delegate = self;
                pane.partnerNode = child;
//                pane.partnerNodeFullPath = [NSString stringWithFormat:@"%@/%@:%d", rootPath, NSStringFromClass([child class]), child.tag];
                pane.partnerNodeFullPath = [NSString stringWithFormat:@"%@/%@", rootPath, NSStringFromClass([child class])];
                
                [paneArray addObject:pane];
                
            }
            
            // don't drill further for certain node.
            if ([child isKindOfClass:[CCMenuItemImage class]] || 
                [child isKindOfClass:[CCMenuItem class]] ||
                [child isKindOfClass:[CCMenuItemLabel class]] ) {
            }
            else {
                NSString *path = [NSString stringWithFormat:@"%@/%@:%d", rootPath, NSStringFromClass([child class]), child.tag];
                [paneArray addObjectsFromArray:
                 [self findLeafNodesTouched:child locationInGL:locationInGL rootBound:globalBound rootPath:path]];
            }
            
        }
    }    
    return paneArray;
}

-(void)cleanEditModeCCRenderTexture {
    [self.delegateLayer stopAllActions];
    
    for (EditModeSelectablePane *n in _paneArray) {
        [n stopAllActions];
        [n removeFromParentAndCleanup:YES];
    }
    
    [self unschedule:@selector(displayPaneArrayInLoop)];
    _selectModeOn = NO;
    
}


#pragma mark - Touches

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView: [touch view]];
    CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
    
    [self editModeSwipeGestureBegan:loc];
    
    if (uiEditMode) {                  // track which object is being touched
        _objectTouched = nil;
        _parentObjectTouched = nil;
        
        // Recursive search for the leaf node thats touched and store the answer:
        // _objectTouched, _parentObjectTouched
        // _startTouchPt, _lastTouchPt
        
        // check to see if the Reset button is touched
        if (CGRectContainsPoint(_editResetButton.boundingBox, loc)) {
            _objectTouched = _editResetButton;
            _parentObjectTouched = _editResetButton.parent;
            return YES;
        }
        
        if (CGRectContainsPoint(_editSaveButton.boundingBox, loc)) {
            _objectTouched = _editSaveButton;
            _parentObjectTouched = _editSaveButton.parent;
            return YES;
        }
        
        if (!_selectModeOn) {
            if (_selectedNode == nil) {
                // If no node is selected via the selection phase
                self._paneArray = [self findLeafNodesTouched:self.delegateLayer locationInGL:loc rootBound:self.delegateLayer.boundingBox rootPath:NSStringFromClass([self.delegateLayer class])];
                if (self._paneArray != nil && ([self._paneArray count] == 0 )) {
                    // don't bother going into the selection phase
                }
                else 
                    [self displayPaneArray];
                
                if (self._paneArray != nil && [self._paneArray count] > 0) {
                    CCNode *chosenNode = ((EditModeSelectablePane*)[self._paneArray objectAtIndex:0]).partnerNode;
                    _objectTouched = chosenNode;
                    _parentObjectTouched = chosenNode.parent;
                    self.objectTouchedPath = ((EditModeSelectablePane*)[self._paneArray objectAtIndex:0]).partnerNodeFullPath;
                    
                    // CCLOG(@"parent origin (%f, %f)", _parentObjectTouched.boundingBox.origin.x, _parentObjectTouched.boundingBox.origin.y);
                    
                    _startTouchPt = ccp(loc.x - _parentObjectTouched.boundingBox.origin.x,
                                        loc.y - _parentObjectTouched.boundingBox.origin.y);
                    _lastTouchPt = ccp(loc.x - _parentObjectTouched.boundingBox.origin.x,
                                       loc.y - _parentObjectTouched.boundingBox.origin.y);
                    
                    [_objectTouched stopAllActions];
                }
                else {
                    // do nothing.
                }
            }
            else {
                // a node was selected via the selection phase
                _objectTouched = _selectedNode;
                _parentObjectTouched = _selectedNode.parent;
                _startTouchPt = ccp(loc.x - _parentObjectTouched.boundingBox.origin.x,
                                    loc.y - _parentObjectTouched.boundingBox.origin.y);
                _lastTouchPt = ccp(loc.x - _parentObjectTouched.boundingBox.origin.x,
                                   loc.y - _parentObjectTouched.boundingBox.origin.y);
                
                // Note: _objectTouchedPath is set in editModeSelectablePaneSelected:
                
                _selectedNode = nil;  // we are done with this now.
            }
        }
        else if (self._paneArray != nil && [self._paneArray count] > 0){
            // selection phase is on but must have tapped outside any selection pane.
            // so clean up and get out of selection phase
            _objectTouched = nil;
            _parentObjectTouched  = nil;
            [self cleanEditModeCCRenderTexture]; 
        }
        
        // check to see if the Edit label is touched.
//        if (CGRectContainsPoint(_editLabel.boundingBox, loc)) {
//            _objectTouched = _editLabel;
//            _parentObjectTouched = _editLabel.parent;
//        }
        
        // check to see if the Exit button is touched
        if (CGRectContainsPoint(_editExitButton.boundingBox, loc)) {
            _objectTouched = _editExitButton;
            _parentObjectTouched = _editExitButton.parent;
        }
        
    }
    
    return YES;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
//    if (_objectTouched == _editLabel)   //ignore this
//        return;
    
    if (_objectTouched == _editExitButton || _objectTouched == _editResetButton || _objectTouched == _editSaveButton)      //ignore this
        return;
    
    if (uiEditMode && !_selectModeOn && _objectTouched != nil) {
        [self cleanEditModeCCRenderTexture];
        
        CGPoint location = [touch locationInView:[touch view]];
        CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
        
        loc = ccp(loc.x - _parentObjectTouched.boundingBox.origin.x, loc.y - _parentObjectTouched.boundingBox.origin.y);
        
        CGPoint dpt = ccp(loc.x - _lastTouchPt.x, loc.y - _lastTouchPt.y);
        _lastTouchPt = ccp(loc.x, loc.y);
        
        CGPoint newPosition = ccp(_objectTouched.position.x + dpt.x, _objectTouched.position.y + dpt.y);
        _objectTouched.position = newPosition;
    }
    
    // If we are in selection phase...detect which pane is visible, when moved beyond certain treshold
    if (_selectModeOn) {
        CGPoint location = [touch locationInView:[touch view]];
        CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
        
        float ds = fabsf((loc.x - _startTouchPt.x) * (loc.x - _startTouchPt.x) + (loc.y - _startTouchPt.y) * (loc.y - _startTouchPt.y));
        
        if (ds > 100) {
            for (EditModeSelectablePane *n in _paneArray) {
                if (n.visible == YES) {
                    // CCLOG(@"Stopped at %@", NSStringFromClass([n.partnerNode class]));
                    
                    [self editModeSelectablePaneSelected:n];
                    
                    _objectTouched = _selectedNode;
                    _parentObjectTouched = _selectedNode.parent;
                    self.objectTouchedPath = n.partnerNodeFullPath;
                    
                    _startTouchPt = ccp(loc.x - _parentObjectTouched.boundingBox.origin.x,
                                        loc.y - _parentObjectTouched.boundingBox.origin.y);
                    _lastTouchPt = ccp(loc.x - _parentObjectTouched.boundingBox.origin.x,
                                       loc.y - _parentObjectTouched.boundingBox.origin.y);
                    
                    _selectedNode = nil;  // we are done with this now.
                    
                    break;
                    
                }
            }
        }
    }
}


-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
    
    [self editModeSwipeGestureEnded:loc];
    
    if (uiEditMode && _objectTouched != nil) {
        
        // check if this is the nob, which means we should turn debug OFF
//        if (_editLabel == _objectTouched)
        if (_editExitButton == _objectTouched) {
            [self editExit:nil];
        }
        else if (_objectTouched == _editResetButton) {
            [self editReset:nil];
        }
        else if (_objectTouched == _editSaveButton) {
            [self editSave:nil];
        }
        else {
            // print the coord of the object position at the top lefthand corner
            NSString *coordString = [NSString stringWithFormat:@"%@:%d (%.4f,%.4f)", self.objectTouchedPath, _objectTouched.tag, _objectTouched.position.x/_screenSize.width, _objectTouched.position.y/_screenSize.height];
            if (_coordinatesLabel == nil) {
                _coordinatesLabel = [CCLabelTTF labelWithString:coordString fontName:@"AmericanTypewriter-Bold" fontSize:16.0];
//                _coordinatesLabel.position = ccp(_coordinatesLabel.boundingBox.size.width/2.0f, _screenSize.height - _coordinatesLabel.boundingBox.size.height/2.0f);
                
                _coordinatesLabel.position = ccp(_screenSize.width * 0.5f, _screenSize.height - _coordinatesLabel.boundingBox.size.height/2.0f);
                _coordinatesLabel.color = ccc3(255, 0, 0);
                [self.delegateLayer addChild:_coordinatesLabel z:1000 tag:kEditModeAblerCoordinatesLabelTag];
            }
            _coordinatesLabel.string = coordString;
            [_coordinatesLabel runAction:[CCFadeIn actionWithDuration:0.5]];
            
            // call back to delegate 
            if ([delegateLayer respondsToSelector:@selector(editModeAblerTouchedNode:nodePath:lastPosition:)]) {
                 [(id<EditModeAblerDelegate>)delegateLayer editModeAblerTouchedNode:_objectTouched nodePath:self.objectTouchedPath lastPosition:_objectTouched.position];
            }
            
            // save to buffer
            if (saveNodeBuffer == nil && saveCGPointBuffer == nil && savePathBuffer == nil) {
                saveNodeBuffer = [[NSMutableArray alloc] initWithCapacity:10];
                saveCGPointBuffer = [[NSMutableArray alloc] initWithCapacity:10];
                savePathBuffer = [[NSMutableArray alloc] initWithCapacity:10];
            }
            
            [savePathBuffer addObject:self.objectTouchedPath];
            [saveNodeBuffer addObject:_objectTouched];
            [saveCGPointBuffer addObject:[NSValue valueWithCGPoint:_objectTouched.position]];

        }
        _objectTouched = nil;
        _parentObjectTouched = nil;
    }
    
}

@end

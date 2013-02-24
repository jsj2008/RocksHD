//
//  OtherAppsLayer.m
//  ButterflyHD
//
//  Created by Kelvin Chan on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OtherAppsLayer.h"
#import "EditModeAbler.h"
#import "ConfigManager.h"
#import "FlowAndStateManager.h"

@interface OtherAppsLayer () <CCTouchOneByOneDelegate, EditModeAblerDelegate>
@property (nonatomic, retain) EditModeAbler *editor;
@end

@implementation OtherAppsLayer

@synthesize editor = _editor;

-(void)dealloc {
    [_editor release];
    [super dealloc];
}

-(void) addMenu {
    CCMenuItemImage *home = [CCMenuItemImage itemFromNormalImage:@"home.png" 
                                                   selectedImage:@"home_bigger.png"
                                                   disabledImage:@"home.png"
                                                          target:self selector:@selector(goHome)];
    
    home.position = ccp(0.0f, 0.0f);
    home.tag = kOtherAppsHomeButtonTag;
    
    CCMenu *menu = [CCMenu menuWithItems:home, nil];
    NSString *path = [NSString stringWithFormat:@"%@/CCMenu", NSStringFromClass([self class])];

    CGPoint pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kOtherAppsMenuTag]; 

    menu.position = pos;
    
    [menu alignItemsHorizontallyWithPadding:20.0f];
    
    [self addChild:menu z:0 tag:kOtherAppsMenuTag];
    
}

-(void)addWebView {
    [self unschedule:_cmd];
    
    slccWebView = [SLCCUIWebView slCCUIWebViewWithParentNode:self];
    slccWebView.urlStr = @"http://www.sproutlabs.net/appmarketing.html";
}

-(void) goHome {
    [slccWebView removeFromParentAndCleanup:YES];
    
    PLAYSOUNDEFFECT(APPS_CLICK_1);
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kHomeScene withTranstion:kCCTransitionPageFlip];
}

- (id)init
{
    self = [super init];
    if (self) {
        screenSize = [CCDirector sharedDirector].winSize;
        [self addMenu];
        //        [self addCurriculum];
        [self schedule:@selector(addWebView) interval:0.4];
        
    }
    
    return self;
}

-(void)onEnter {
    [super onEnter];
    
    self.editor = [EditModeAbler node];
    self.editor.delegateLayer = self;
    [self.editor activate];
}

#pragma mark - Touches
-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    return [self.editor ccTouchBegan:touch withEvent:event];
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    [self.editor ccTouchMoved:touch withEvent:event];
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [self.editor ccTouchEnded:touch withEvent:event];
}

#pragma mark - EditModeAblerDelegate
-(void)editModeAblerTouchedNode:(CCNode *)node nodePath:(NSString *)nodePath lastPosition:(CGPoint)position {
    //    [[ConfigManager sharedConfigManager] writeToDefaultsForNode:node NodeHierPath:nodePath forPosition:position];    
}

-(void) editModeAblerTouchedNodeReset {
    [[ConfigManager sharedConfigManager] resetToFactorySettings];
}

-(void)editModeAblerTouchedNodeSaveNodeBuffer:(NSArray *)saveNodeBuffer pathBuffer:(NSArray *)savePathBuffer pointBuffer:(NSArray *)saveCGPointBuffer {
    
    int saveCount = [saveNodeBuffer count];
    
    for (int k = 0; k < saveCount; k++) {
        CCNode *node = [saveNodeBuffer objectAtIndex:k];
        NSString *path = [savePathBuffer objectAtIndex:k];
        CGPoint pt = [[saveCGPointBuffer objectAtIndex:k] CGPointValue];
        
        [[ConfigManager sharedConfigManager] writeToDefaultsForNode:node NodeHierPath:path forPosition:pt];
    }
    
}


@end

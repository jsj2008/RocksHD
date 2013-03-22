//
//  TopicInteractiveBackgroundLayer.m
//  SLPOC
//
//  Created by Kelvin Chan on 8/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TopicInteractiveBackgroundLayer.h"
#import "FlowAndStateManager.h"
#import "ModelManager.h"
#import "CCAnimationCatalog.h"
#import "CCUIPopupView.h"
#import "SLCCMenu.h"
#import "SLCCUIPageControl.h"
#import "SLCCTextTickerTape.h"
#import "HotspotsOnBackgroundInfo.h"
#import "HotspotInfo.h"
#import "GalleryItemInfo.h"
#import "NavigationItemInfo.h"
#import "TextAndQuizScene.h"
#import "MainTextImagesLayer.h"

typedef enum TopicInteractiveBackgroundLayerTags : NSInteger {
    kBackgroundSpriteTag = 1011,
    kEditorTag = 1012,
    kUIPageControlTag = 1013,
    kPageArrowMenuItem = 1014,
    kPageArrowMenu = 1015,
    kBackgroundTextTag = 1016,
    kBackgroundTextBgTag = 1017,
    kGlowingSpriteTag = 10000
} TopicInteractiveBackgroundLayerTags;


@implementation TopicInteractiveBackgroundLayer
    

@synthesize navigationMap,info;

-(void) dealloc {
    
    if (hotspotBounds != nil)
        [hotspotBounds release];
    
    [super dealloc];
}

-(id) init {
    if (self = [super init]) {
        currentHotspotsFilledBackgroundIndex = 0;
        globalCenter = CGPointMake(512, 383);
        CCLOG(@"init");
    }
    return self;
}

-(void) initializeHotspotsBoundWithInfo:(HotspotsOnBackgroundInfo *)bgInfo {
    if (hotspotBounds == nil)
        hotspotBounds = [[NSMutableArray alloc] init];
    
    [hotspotBounds removeAllObjects];
    
    for (HotspotInfo *hotspotInfo in bgInfo.hotspots) {
        [hotspotBounds addObject:[NSValue valueWithCGRect:hotspotInfo.bound]];
    }
    
    CCLOG(@"number of hotspots = %d", bgInfo.hotspots.count);
}

-(void) initializeBackgroundWithInfo:(HotspotsOnBackgroundInfo *)bgInfo {
    CCLOG(@"Background with hotpots has uid = %d", bgInfo.uid.intValue);

    debugLog(@"Bg sprite %@",bgInfo.backgroundImage);
    
    BackgroundSprite *bgSprite = [BackgroundSprite spriteWithFile:bgInfo.backgroundImage];
    bgSprite.tag = kBackgroundSpriteTag;
    bgSprite.position = globalCenter;
    
    bgSprite.scale = 0.75;
    bgSprite.opacity = 0.0;
    id action = [CCAnimationCatalog scaleUpToOneFadein];
    [bgSprite runAction:action];
    
    [self addChild:bgSprite z:0];

}

-(void) initializeBackgroundTextWithInfo:(HotspotsOnBackgroundInfo *)bgInfo {
    CCLOG(@"Background Text: %@", bgInfo.backgroundText);
    
    CCSprite *bgSprite = (CCSprite *)[self getChildByTag:kBackgroundTextBgTag];
    if (bgSprite == nil) {
        bgSprite = [CCSprite spriteWithFile:bgInfo.textBackgroundImage];
        bgSprite.tag = kBackgroundTextBgTag;
     //   [self assignPositionFromXMLForNode:bgSprite];
//        bgSprite.position = CGPointMake(512, 384);
                bgSprite.position = CGPointMake(512,0);
        [self addChild:bgSprite z:10];
    }
    
    CCLabelTTF *textLabel = (CCLabelTTF *)[self getChildByTag:kBackgroundTextTag];
    if (textLabel == nil) {
        textLabel = [CCLabelTTF labelWithString:bgInfo.backgroundText fontName:@"Arial" fontSize:25.0];
        // hotspot popup background text
        textLabel.tag = kBackgroundTextTag;
//        [self assignPositionFromXMLForNode:textLabel];
                textLabel.position = CGPointMake(512,30);
        [self addChild:textLabel z:1000];
    }
    
    textLabel.string = bgInfo.backgroundText;
    
    debugLog(@"Bg Text %@",textLabel.string);
    
    // add attribution

    NSString *attribution = [NSString stringWithFormat:@"Photo By %@",bgInfo.attribution];
    CCLabelTTF *textAttributionLabel = (CCLabelTTF *)[self getChildByTag:kBackgroundTextTag + 100];
    if (textAttributionLabel == nil) {
        textAttributionLabel = [CCLabelTTF labelWithString:attribution fontName:@"Arial" fontSize:13.0];
        // hotspot popup background text
        textAttributionLabel.tag = kBackgroundTextTag + 100;
        //        [self assignPositionFromXMLForNode:textLabel];
        textAttributionLabel.position = CGPointMake(915,7);
        [self addChild:textAttributionLabel z:1000];
    }
    else
    {
        textAttributionLabel.string = attribution;
    }
    

    

}

-(void) setupPlainBackground {
    
    debugLog(@"setupPlainBackground %@",self.info.backgroundImage);
    BackgroundSprite *bgSprite = [BackgroundSprite spriteWithFile:self.info.backgroundImage];
    bgSprite.tag = kBackgroundSpriteTag;
    bgSprite.position = globalCenter;

    [self addChild:bgSprite z:0];

}

-(void)onEnter {
    [super onEnter];
    
    
    debugLog(@"Onenter");
    
    
    NSArray *hotspotsOnBackgrounds = self.info.hotspotsOnBackgrounds;
    
    if ([FlowAndStateManager sharedFlowAndStateManager].isMusicON)
    {
        [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
        [FlowAndStateManager sharedFlowAndStateManager].isMusicON = NO;
        debugLog(@"Stop Bg Track");
        
        // start based on current hotspot
        HotspotsOnBackgroundInfo *hotspotsBgInfo = hotspotsOnBackgrounds[currentHotspotsFilledBackgroundIndex];
        
        [FlowAndStateManager sharedFlowAndStateManager].isMusicON = YES;
        [[FlowAndStateManager sharedFlowAndStateManager] playBackgroundTrack:hotspotsBgInfo.backgroundTrackName];
        

    }

    
    
    
    if (hotspotsOnBackgrounds != nil && hotspotsOnBackgrounds.count > 0) {
    
        HotspotsOnBackgroundInfo *hotspotsBgInfo = hotspotsOnBackgrounds[currentHotspotsFilledBackgroundIndex];
        
        [self initializeHotspotsBoundWithInfo:hotspotsBgInfo];
        [self initializeBackgroundWithInfo:hotspotsBgInfo];
        [self initializeBackgroundTextWithInfo:hotspotsBgInfo];
    }
    else
    {
        // no hotspot background, just set up the plain topic background
        [self setupPlainBackground];
    }
    
    
    [self setupTopLeftMenu];
    [self setupTopRightMenu];
    [self setupBottomLeftMenu];
    
    [self animateGlowingHotSpotsForNumberOfTimes:1000];
    
    [self setupUIPageControl];
    
    [self setupPageArrow];
    
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
    
}

-(void)onExit {
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
        
    [super onExit];
}

#pragma mark - Menu Setup
-(void) setupTopLeftMenu {
    
    
    CCMenuItemImage *app = [CCMenuItemImage itemWithNormalImage:@"app-button.png"
                                                   selectedImage:@"app-button.png"
                                                   disabledImage:@"app-button.png"
                                                          target:self selector:@selector(handleApp)];
    
    CCMenuItemImage *vol = [CCMenuItemImage itemWithNormalImage:@"vol-button-on.png"
                                                    selectedImage:@"vol-button-off.png"
                                                    disabledImage:@"vol-button-off.png"
                                                           target:self
                                                       selector:(@selector(handleVol:))];
    
    if ([[FlowAndStateManager sharedFlowAndStateManager] isMusicON])
    {
        debugLog(@"music is on and should be working");
        [vol unselected];
    }
    else
        [vol selected];

    CCMenuItemImage *home = [CCMenuItemImage itemWithNormalImage:@"home-button.png"
                                                    selectedImage:@"home-button.png"
                                                    disabledImage:@"home-button.png"
                                                           target:self selector:@selector(handleHome)];

    SLCCMenu *menu = [SLCCMenu slCCMenuWithParentNode:self atLocation:SLCCMenuTopLeft withType:SLCCMenuTypePullOrTabOutHorizontal];
    [self reorderChild:menu z:1000];
    [menu menuWithItems: vol, home, nil];
}
    

-(void) setupTopRightMenu {
    
    CCMenuItemImage *text = [CCMenuItemImage itemWithNormalImage:@"text-button.png" 
                                                   selectedImage:@"text-button.png"
                                                   disabledImage:@"text-button.png"
                                                          target:self selector:@selector(handleText)];
        
    CCMenuItemImage *photo = [CCMenuItemImage itemWithNormalImage:@"photo-button.png"
                                                    selectedImage:@"photo-button.png"
                                                    disabledImage:@"photo-button.png"
                                                           target:self selector:@selector(handlePhoto)];
    
    CCMenuItemImage *video = [CCMenuItemImage itemWithNormalImage:@"video-button.png"
                                                    selectedImage:@"video-button.png"
                                                    disabledImage:@"video-button.png"
                                                           target:self selector:@selector(handleVideo)];
    
    CCMenuItemImage *quiz = [CCMenuItemImage itemWithNormalImage:@"quiz-button.png"
                                                   selectedImage:@"quiz-button.png"
                                                   disabledImage:@"quiz-button.png"
                                                          target:self selector:@selector(handleQuiz)];
    
    CCMenuItemImage *share = [CCMenuItemImage itemWithNormalImage:@"share-button.png"
                                                  selectedImage:@"share-button.png"
                                                  disabledImage:@"share-button.png"
                                                         target:self selector:@selector(handleShare)];
    
    SLCCMenu *menu = [SLCCMenu slCCMenuWithParentNode:self atLocation:SLCCMenuTopRight withType:SLCCMenuTypePullOrTabOutHorizontal];
    
    [self reorderChild:menu z:1000];
    
    //[menu menuWithItems:text, photo, video, quiz, share, nil];
    [menu menuWithItems:text, photo, video, quiz, nil];

}

-(void) setupBottomLeftMenu {
    
    debugLog(@"adding nothing to buttom menu");
    return;
    CCMenuItemImage *info = [CCMenuItemImage itemWithNormalImage:@"info-button.png" 
                                                   selectedImage:@"info-button.png"
                                                   disabledImage:@"info-button.png"
                                                          target:self selector:@selector(handleInfo)];
    
    SLCCMenu *menu = [SLCCMenu slCCMenuWithParentNode:self atLocation:SLCCMenuBottomLeft withType:SLCCMenuTypePullOrTabOutHorizontal];
    
    [self reorderChild:menu z:1000];

    [menu menuWithItems:info, nil];
}

#pragma mark - Other Setups & Updates

-(void) setupUIPageControl {
    
    CGRect glFrame = CGRectMake(0.0, 0.0, 120.0, 15.0);  // the origin is a dummy, the position is the thing thats gonna be set a few lines later.
    
    SLCCUIPageControl *pageCtrl = [SLCCUIPageControl slCCUIPageControlWithParentNode:self withGlFrame:glFrame];
    pageCtrl.tag = kUIPageControlTag;
    //[self assignPositionFromXMLForNode:pageCtrl];
    pageCtrl.position = CGPointMake(471, 80);

    pageCtrl.numberOfPages = self.info.hotspotsOnBackgrounds.count;
    pageCtrl.currentPage = 0;
}

-(void) setupPageArrow {

    CCMenuItemImage *pageArrow = [CCMenuItemImage itemWithNormalImage:@"pageArrow.png"
                                                   selectedImage:@"pageArrow.png"
                                                   disabledImage:@"pageArrow.png"
                                                               target:self selector:@selector(handlePageArrow:)];
    pageArrow.tag = kPageArrowMenuItem;
    //[self assignPositionFromXMLForNode:pageArrow];
    pageArrow.position = CGPointMake(475, 50);
    
    CCMenu *menu = [CCMenu menuWithItems:pageArrow, nil];
    menu.tag = kPageArrowMenu;
    
    [pageArrow runAction:[CCAnimationCatalog fadeInOutForDuration:0.5 withTimes:4]];
    
    [self addChild:menu z:1000];
    
}

-(void)updatePageArrow {
    CCMenu *menu = (CCMenu *) [self getChildByTag:kPageArrowMenu];
    if (menu != nil) {
        CCMenuItemImage *pageArrow = (CCMenuItemImage*) [menu getChildByTag:kPageArrowMenuItem];
        [pageArrow runAction:[CCAnimationCatalog fadeInOutForDuration:0.5 withTimes:4]];
    }
}

-(void) updateUIPageControl {
    SLCCUIPageControl *pageCtrl = (SLCCUIPageControl *) [self getChildByTag:kUIPageControlTag];
    pageCtrl.currentPage = currentHotspotsFilledBackgroundIndex;
}

#pragma mark - Hotspot
-(void) animateGlowingHotSpotsForNumberOfTimes:(int) times {
    
    // Flash a glow on the hotspot region a couple of times
    
    int k = 0;
    for (NSValue *rectObj in hotspotBounds) {
        GlowingHotSpotSprite *s = [GlowingHotSpotSprite spriteWithFile:@"glow.png"];
        s.opacity = 0;
        s.position = ccp(CGRectGetMidX(rectObj.CGRectValue), CGRectGetMidY(rectObj.CGRectValue));
        s.tag = kGlowingSpriteTag + k;
        [self addChild:s z:10];
        
        if (times < 5) {
            [s runAction:[CCSequence actions:
                          [CCRepeat actionWithAction:[CCSequence actions:
                                                      [CCFadeTo actionWithDuration:0.3 opacity:155],
                                                      [CCFadeTo actionWithDuration:0.3 opacity:0],
                                                      nil] times:times],
                          [CCCallBlock actionWithBlock:^{
                [s removeFromParentAndCleanup:YES];
            }],
                          nil]];
        } else {
            [s runAction:[CCRepeatForever actionWithAction: [CCSequence actions:
                                                             [CCFadeTo actionWithDuration:1.5 opacity:155],
                                                             [CCFadeTo actionWithDuration:1.5 opacity:0],
                                                             [CCDelayTime actionWithDuration:0.75],
                                                             nil] ]];
        }
        k++;
    }

}

-(void)stopAnimateGlowingHotSpots {
    for (int k = 0; k < hotspotBounds.count; k++) {
        CCSprite *s = (CCSprite *)[self getChildByTag:kGlowingSpriteTag + k];
        [s stopAllActions];
        [s removeFromParentAndCleanup:YES];
    }
}

#pragma mark - Popup

-(void) popCurrPopupViewWithFrame:(CGRect)frame animateToLargeFrame:(CGRect)largerFrame withText:(NSString*)text withImage:(UIImage*)uiImage withTag:(int)tag {
    
    HotspotsOnBackgroundInfo *bgInfo = self.info.hotspotsOnBackgrounds[currentHotspotsFilledBackgroundIndex];
    
    CCUIPopupView *popupView = (CCUIPopupView *)[self getChildByTag:tag];

    if (popupView == nil || ![text isEqualToString:popupView.text]) {
        [self removeCurrPopupViewWithTag:tag];
        popupView = [CCUIPopupView ccUIPopupViewWithParentNode:self
                                                      withType:CCUIPopupViewTypeDefault
                                                     withGlFrame:frame
                                          animateToLargerGlFrame:largerFrame
                                                  withKeyImage:uiImage
                                                      withText:text];
        popupView.delegate = self;
        popupView.tag = tag;
        
        NSString *f = bgInfo.backgroundImage;
        NSString *basefilename = [[f lastPathComponent] stringByDeletingPathExtension];
        
        UIImage *bg;
        float scale;
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00) {
            bg = [UIImage imageNamed:[NSString stringWithFormat:@"%@-ipadhd.png", basefilename]];
            scale = 2.0;
        } else {
            bg = [UIImage imageNamed:[NSString stringWithFormat:@"%@-ipad.png", basefilename]];
            scale = 1.0;
        }

        popupView.flippable = YES;
        [popupView setBackgroundImageForFlipping:bg withFlipAngle:120.0 withScale:scale];
        [popupView flipOpen];
    }
}

-(void) removeCurrPopupViewWithTag:(int) tag {
    CCUIPopupView *popupView = (CCUIPopupView *)[self getChildByTag:tag];
    [popupView flipCloseAndRemoveFromParentAndCleanup];
}

#pragma mark - Action handlers
-(void) handleText {
    
//    CCLOG(@"handle Text is commented: needs fix");
    NSString *destLayer = self.navigationMap[@"Main Text"];
    
    
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kReadTextScene withTranstion:kCCTransitionPageFlip];

}

-(void) handlePhoto {
    CCLOG(@"Handle Photo");
    
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kPhotoScene withTranstion:kCCTransitionPageFlip];

}

-(void) handleVideo {
    CCLOG(@"Handle Video");
    
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kVideoScene withTranstion:kCCTransitionPageFlip];

}

-(void) handleQuiz {
    CCLOG(@"Handle Quiz");
    
    [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
    
    /*
    if (!self.audioItemImage.isSelected) {
        
        [[FlowAndStateManager sharedFlowAndStateManager] playBackgroundTrack:BACKGROUND_TRACK_TEXTPAGE];
    }
     */
    
    

    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kQuizScene withTranstion:kCCTransitionPageFlip];

    

}

-(void) handleShare {
    CCLOG(@"Handle Sharing");
}

-(void) handleApp {
    NSString *destLayer = self.navigationMap[@"Cross Marketing Page"];
}

-(void) handleVol:(CCMenuItemImage*)i {
    
    
    
    if ([FlowAndStateManager sharedFlowAndStateManager].isMusicON) {
        
        [i selected];
        
        [FlowAndStateManager sharedFlowAndStateManager].isMusicON = NO;
        
        [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
        
    }
    
    else {
        
        [i unselected];
        
        [FlowAndStateManager sharedFlowAndStateManager].isMusicON = YES;
        
            [[FlowAndStateManager sharedFlowAndStateManager] playBackgroundTrack:BACKGROUND_TRACK_MENUPAGE];
        
    }


    CCLOG(@"Handle sound volume");
}

-(void) handleHome {

    NSString *destLayer = self.navigationMap[@"Home"];
    
    
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kHomeScene withTranstion:kCCTransitionPageFlip];
    
    
}

-(void) handleInfo {
    
    NSString *destLayer = self.navigationMap[@"Info"];
}


#pragma mark - Touches
-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
    
    startTouchPoint = loc;
    lastTouchPoint = loc;
    
    return YES;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
    
    float distance = sqrt((lastTouchPoint.x - startTouchPoint.x)*(lastTouchPoint.x - startTouchPoint.x) + (lastTouchPoint.y - startTouchPoint.y)*(lastTouchPoint.y - startTouchPoint.y));
    
    if (distance > 10.0) {
        CCSprite *bgSprite = (CCSprite *)[self getChildByTag:kBackgroundSpriteTag];
        CGPoint dPoint = ccp(loc.x - lastTouchPoint.x, loc.y - lastTouchPoint.y);
        bgSprite.position = ccp(bgSprite.position.x + dPoint.x, bgSprite.position.y);
    }
    
    lastTouchPoint = loc;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
    lastTouchPoint = loc;
    CGPoint dPoint = ccp(lastTouchPoint.x - startTouchPoint.x, lastTouchPoint.y - startTouchPoint.y);
    
    float distance = sqrt((lastTouchPoint.x - startTouchPoint.x)*(lastTouchPoint.x - startTouchPoint.x) + (lastTouchPoint.y - startTouchPoint.y)*(lastTouchPoint.y - startTouchPoint.y));
    
    // Try to see if this is a pan, and also make sure there's no CCUIPopupView present
    CCSprite *bgSprite = (CCSprite *)[self getChildByTag:kBackgroundSpriteTag];
    if (distance > 20.0) {
        // This is recognized as a pan on the background
        // THREE actions can be taken
        
        float treshold = 1024*0.1;   // stay put or show next
        
        // 1) Move back to origin
        if (distance < treshold) {
            id action = [CCAnimationCatalog bounceMoveToAction:globalCenter withDuration:0.75];
            [bgSprite runAction:action];
        }
        else if (distance > treshold && dPoint.x > 0.0) {   // panning to the right direction
            // Remove all popup views
            [self removeAllCCUIPopupViews];
            [self renderPreviousBackground];
        }
        else if (distance > treshold && dPoint.x < 0.0) {  // panning to the left direction
            [self removeAllCCUIPopupViews];
            [self renderNextBackground];
        }
        
        return;
    }
    
    // a tap, then check for hotspot, and launch the popup
    NSArray *hotspotsOnBackgrounds = self.info.hotspotsOnBackgrounds;
    
    if (hotspotsOnBackgrounds != nil && hotspotsOnBackgrounds.count > 0) {
        HotspotsOnBackgroundInfo *bgInfo = self.info.hotspotsOnBackgrounds[currentHotspotsFilledBackgroundIndex];
        
        BOOL atLeastOneHotSpotHit = NO;
        
        int tag = 1001;
        for (HotspotInfo *hotSpot in bgInfo.hotspots) {
            CGRect bound = hotSpot.bound;
            NSString *type = hotSpot.type;
            
            if (CGRectContainsPoint(bound, loc)) {
                
                    [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
                CGRect frame = hotSpot.frame;
                CGRect largerFrame = hotSpot.largerFrame;
                CCLOG(@"title = %@", hotSpot.title);
                NSString *text = hotSpot.text;
                NSString *keyImageName = hotSpot.keyImage;
                
                UIImage *keyImage = [UIImage imageNamed:keyImageName];
                
                if ([type isEqualToString:@"defaultContent"]) {
                    [self popCurrPopupViewWithFrame:frame animateToLargeFrame:largerFrame withText:text withImage:keyImage withTag:tag];
                }
                else if ([type isEqualToString:@"largeContent"]) {
                    CCUIPopupView *popupView = (CCUIPopupView *)[self getChildByTag:tag];
                    if (popupView == nil || ![text isEqualToString:popupView.text]) {
                        [popupView removeFromParentAndCleanup:YES];
                        popupView = [CCUIPopupView ccUIPopupViewWithParentNode:self withType:CCUIPopupViewTypeLarge
                                                                   withGlFrame:frame animateToLargerGlFrame:largerFrame
                                                                  withKeyImage:keyImage withText:text];
                        popupView.delegate = self;
                        popupView.tag = tag;
                        
                        NSString *bgColorStr = hotSpot.backgroundColor;
                        popupView.backgroundColor = [hotSpot colorFromStringValue:bgColorStr];
                        
                        NSString *textColorStr = hotSpot.textColor;
                        popupView.textColor = [hotSpot colorFromStringValue:textColorStr];
                        
                        popupView.keyImageTitle = hotSpot.keyImageTitle;
                        
                        // Set up photo array as an array of uiimage
                        NSMutableArray *photoArray = [[NSMutableArray alloc] init];
                        NSMutableArray *videoURLArray = [[NSMutableArray alloc] init];
                        NSMutableArray *videoThumbNailArray = [[NSMutableArray alloc] init];
                        
                        debugLog(@"creating photo and video array");
                        debugLog(@"gallery %@",hotSpot.gallery.items);
                        
                        for (GalleryItemInfo *item in hotSpot.gallery.items) {
                            debugLog(@"Found one item");
                            if ([item.type isEqualToString:@"photo"]) {
                                                                debugLog(@"found photo %@",item.url);
                                [photoArray addObject:[UIImage imageNamed:item.url]];

                            }
                            else if ([item.type isEqualToString:@"video"]) {
                                                                debugLog(@"found video %@",item.url);
                                
                                [videoThumbNailArray addObject:item.thumbnail];
                                [videoURLArray addObject:item.url];

                            }
                        }
                        
                        popupView.photoThumbnailArray = photoArray;
                        popupView.videoThumbnailArray = videoThumbNailArray;
                        popupView.videoUrlArray = videoURLArray;
                        
                        [photoArray release];
                        [videoURLArray release];
                        [videoThumbNailArray release];
                        
                        CGRect boundingBox = popupView.boundingBox;
                        CCLOG(@"popupView boundingbox = %f, %f, %f, %f", boundingBox.origin.x, boundingBox.origin.y , boundingBox.size.width, boundingBox.size.height);
                        
                    }
                    else
                        ;
                }
                atLeastOneHotSpotHit = YES;
            }
            else {
                if ([type isEqualToString:@"defaultContent"]) {
                    [self removeCurrPopupViewWithTag:tag];
                }
                else if ([type isEqualToString:@"largeContent"]) {
                    CCUIPopupView *popupView = (CCUIPopupView *)[self getChildByTag:tag];
                    [popupView removeFromParentAndCleanup:YES];
                }
                else
                    ;
            }
            
            tag++;
        }
    }
//    }
//    if (!atLeastOneHotSpotHit)
//        [self animateHotSpotsForNumberOfTimes:2];
}

-(void) renderPreviousBackground {
    // Fade and remove this background sprite
    CCSprite *bgSprite = (CCSprite *)[self getChildByTag:kBackgroundSpriteTag];

    if (currentHotspotsFilledBackgroundIndex == 0) {  // this is the 1st, no previous one exists
        id action = [CCAnimationCatalog bounceMoveToAction:globalCenter withDuration:0.75];
        [bgSprite runAction:action];
    }
    else {
        id action = [CCAnimationCatalog moveToFadeOut:ccp(screenSize.width*1.3, screenSize.height*0.5) withDuration:0.5 withCompletion:^{
            
            [bgSprite removeFromParentAndCleanup:YES];
            
            [self stopAnimateGlowingHotSpots];
            
            // Bring in the next bacground sprite
            currentHotspotsFilledBackgroundIndex--;
            HotspotsOnBackgroundInfo *bgInfo = self.info.hotspotsOnBackgrounds[currentHotspotsFilledBackgroundIndex];
            
            if ([FlowAndStateManager sharedFlowAndStateManager].isMusicON)
            {
                [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
                [FlowAndStateManager sharedFlowAndStateManager].isMusicON = NO;
                debugLog(@"Stop Bg Track");
                
                // start based on current hotspot
                
                
                [FlowAndStateManager sharedFlowAndStateManager].isMusicON = YES;
                [[FlowAndStateManager sharedFlowAndStateManager] playBackgroundTrack:bgInfo.backgroundTrackName];
                
                
            }
            
            [self initializeHotspotsBoundWithInfo:bgInfo];
            [self initializeBackgroundWithInfo:bgInfo];
            [self initializeBackgroundTextWithInfo:bgInfo];
            
            [self animateGlowingHotSpotsForNumberOfTimes:1000];
            
            [self updateUIPageControl];
            [self updatePageArrow];
            
        }];
        [bgSprite runAction:action];
    }
}

-(void) renderNextBackground {
    
    CCSprite *bgSprite = (CCSprite *)[self getChildByTag:kBackgroundSpriteTag];
    
    if (currentHotspotsFilledBackgroundIndex+1 == self.info.hotspotsOnBackgrounds.count) {
        // this is the last, no next one available
        id action = [CCAnimationCatalog bounceMoveToAction:globalCenter withDuration:0.75];
        [bgSprite runAction:action];
    }
    else {
        // Fade and remove this background sprite
        id action = [CCAnimationCatalog moveToFadeOut:ccp(-screenSize.width*0.2, screenSize.height*0.5) withDuration:0.5 withCompletion:^{
            
            [bgSprite removeFromParentAndCleanup:YES];
            
            [self stopAnimateGlowingHotSpots];
            
            // Bring in the next bacground sprite
            currentHotspotsFilledBackgroundIndex++;
            HotspotsOnBackgroundInfo *bgInfo = self.info.hotspotsOnBackgrounds[currentHotspotsFilledBackgroundIndex];
            
            if ([FlowAndStateManager sharedFlowAndStateManager].isMusicON)
            {
                [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
                [FlowAndStateManager sharedFlowAndStateManager].isMusicON = NO;
                debugLog(@"Stop Bg Track");
                
                // start based on current hotspot
               
                
                [FlowAndStateManager sharedFlowAndStateManager].isMusicON = YES;
                [[FlowAndStateManager sharedFlowAndStateManager] playBackgroundTrack:bgInfo.backgroundTrackName];
                
                
            }

            [self initializeHotspotsBoundWithInfo:bgInfo];
            [self initializeBackgroundWithInfo:bgInfo];
            [self initializeBackgroundTextWithInfo:bgInfo];
            
            [self animateGlowingHotSpotsForNumberOfTimes:1000];
            
            [self updateUIPageControl];
            [self updatePageArrow];
        }];
        
        [bgSprite runAction:action];
    }

}

-(void) handlePageArrow:(id) sender {
    if ([self numberOfCCUIPopupViews] > 0)  // dont move if there's popup
        return;
    
    [self renderNextBackground];
}

#pragma mark - CCUIPopupViewDelegate
-(void) ccUIPopupViewPhotoLinkTapped:(CCUIPopupView *)sender {
    CCLOG(@"photo button tapped");
    sender.alpha = 0.0;
//    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithName:@"PhotoLayer" withTranstion:kCCTransitionFade withIntermediateTransition:NO withContextInfo:nil];
}

-(void) ccUIPopupViewVideoLinkTapped:(CCUIPopupView *)sender {
    CCLOG(@"video button tapped");
    sender.alpha = 0.0;
  //  [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithName:@"VideoLayer" withTranstion:kCCTransitionFade withIntermediateTransition:NO withContextInfo:nil];
}

#pragma mark - Helpers
-(int)numberOfCCUIPopupViews {
    int num = 0;
    
    CCArray *children = [self children];
    for (id node in children) {
        if ([node isMemberOfClass:[CCUIPopupView class]]) {
            num++;
        }
    }
    return num;
}

-(void) removeAllCCUIPopupViews {
    for (id node in [self children]) {
        if ([node isMemberOfClass:[CCUIPopupView class]]) {
            CCUIPopupView *p = (CCUIPopupView *) node;
            [p removeFromParentAndCleanup:YES];
        }
    }
}

-(void) setupNavigationMetadata {
    
    // Read navigation from AppInfo
    for (NavigationItemInfo *navItem in [ModelManager sharedModelManger].appInfo.navigation.navigationItems) {
        [self.navigationMap setObject:navItem.destination forKey:navItem.uid];
    }
    CCLOG(@"navigations = %@", self.navigationMap);
}

@end



@implementation GlowingHotSpotSprite

@end

@implementation BackgroundSprite

@end
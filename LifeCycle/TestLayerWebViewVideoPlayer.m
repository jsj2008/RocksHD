//
//  TestLayerWebViewVideoPlayer.m
//  LifeCycle
//
//  Created by Kelvin Chan on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestLayerWebViewVideoPlayer.h"
#import "FlowAndStateManager.h"

@implementation TestLayerWebViewVideoPlayer 

-(void)dealloc {
    if (potentialVideoIDs != nil)
        [potentialVideoIDs release];
    
    if (potentialVideoAttributions != nil)
        [potentialVideoAttributions release];
    
    if (videoIDs != nil)
        [videoIDs release];
    
    if (videoAttributions != nil) 
        [videoAttributions release];
    
    if (videoID2IndexMap != nil)
        [videoID2IndexMap release];
    
    [super dealloc];
}


-(void)addMenu {
    CCMenuItemImage *home = [CCMenuItemImage itemFromNormalImage:@"home.png" 
                                                   selectedImage:@"home_bigger.png"
                                                   disabledImage:@"home.png"
                                                          target:self selector:@selector(goHome)];
    home.position = ccp(0.0f, 0.0f);
    home.tag = kTestingWebViewVideoPlayerHomeButtonTag;
    
//    SEL testSelector = @selector(testSLWebViewVideoPlayer);
    SEL testSelector = @selector(testSLWebViewVideoPlayerSlides);
    
    CCMenuItemImage *lab = [CCMenuItemImage itemFromNormalImage:@"test.png"
                                                  selectedImage:@"test_bigger.png"
                                                  disabledImage:@"test.png"
                                                         target:self
                                                       selector:testSelector];
    
    lab.tag = kTestingWebViewVideoPlayerTestButtonTag;
    
    CCMenu *menu = [CCMenu menuWithItems:home, lab, nil];
    
    menu.position = ccp(0.875f * screenSize.width, 0.9375f * screenSize.height);
    [menu alignItemsHorizontallyWithPadding:20.0f];
    
    [self addChild:menu z:0 tag:kTestingWebViewVideoPlayerMenuTag];
    
}

-(void)goHome {
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kHomeScene withTranstion:kCCTransitionPageFlip];
}

- (id)init
{
    self = [super init];
    if (self) {
        screenSize = [CCDirector sharedDirector].winSize;
        [self addMenu];
    }
    
    return self;
}

-(void)onEnter {
    [super onEnter];
    
    editModeAbler = [EditModeAbler node];
    [editModeAbler retain];
    editModeAbler.delegateLayer = self;
    
    [editModeAbler activate];
    
    // bn9H8hbAAWQ
    potentialVideoIDs = [NSMutableArray arrayWithObjects:@"GeLzhSaJ7vw", @"HnbMYzdjuBs", @"C9LHjV48e9s", @"dontexist", @"ge3EM8AERV0", nil];
//    potentialVideoIDs = [NSMutableArray arrayWithObjects:@"GeLzhSaJ7vw", @"HnbMYzdjuBs", nil];
//    potentialVideoIDs = [NSMutableArray arrayWithObjects:@"HnbMYzdjuBs", nil];

    [potentialVideoIDs retain];
    
    potentialVideoAttributions = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"BBC Life 2009 - Plants HD", @"GeLzhSaJ7vw", @"flower red rose blooming", @"HnbMYzdjuBs", @"Redwoods: The Tallest Trees", @"C9LHjV48e9s", @"Don't exit", @"dontexist", @"Flower Pollination", @"ge3EM8AERV0", nil];
//    potentialVideoAttributions = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"BBC Life 2009 - Plants HD", @"GeLzhSaJ7vw", @"flower red rose blooming", @"HnbMYzdjuBs", nil];
//    potentialVideoAttributions = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"flower red rose blooming", @"HnbMYzdjuBs", nil];

    [potentialVideoAttributions retain];
    
    videoIDs = [[NSMutableArray alloc] initWithCapacity:5];
    videoAttributions = [[NSMutableArray alloc] initWithCapacity:5];
    videoID2IndexMap = [[NSMutableDictionary alloc] initWithCapacity:5];
}

-(void)onExit {
    [editModeAbler release];
    [super onExit];
}

#pragma mark - Touches

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    return [editModeAbler ccTouchBegan:touch withEvent:event];
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    [editModeAbler ccTouchMoved:touch withEvent:event];
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [editModeAbler ccTouchEnded:touch withEvent:event];
}

#pragma mark - Test SLWebViewVideoPlayer
-(void) testSLWebViewVideoPlayer {
//    CGPoint position = [[CCDirector sharedDirector] convertToGL:ccp(10, 768)];
//    CGRect frame = CGRectMake(position.x, position.y, 640.0, 360.0);
    SLWebViewVideoPlayer *v = [SLWebViewVideoPlayer slWebViewVideoPlayerWithParentNode:self withVideoURL:@"http://www.youtube.com/embed/bn9H8hbAAWQ" withDelegate:self];
    v.position = ccp(screenSize.width*0.5, screenSize.height*0.5);
    
    // Decorate with movie reel
    CCSprite *reel = [CCSprite spriteWithFile:@"film_reel.png"];
    reel.position = ccp(screenSize.width*0.5, screenSize.height*0.5);
//    reel.opacity = 128;
    reel.scale = 1.5;
    [self addChild:reel z:0];
    
}

#pragma mark - Test Web Video slides

-(void)testSLWebViewVideoPlayerSlides {
    
    // 1) check to see if each of the Video IDs in potentialVideoIDs is valid or not
    
    for (NSString *videoID in potentialVideoIDs) {
        SLYouTubeVideo *video = [[SLYouTubeVideo alloc] initWithVideoID:videoID];
        video.delegate = self;
        [video checkValidity];  // async op
    }
    
    // Decorate with movie reel
    CCSprite *reel = [CCSprite spriteWithFile:@"film_reel.png"];
    reel.position = ccp(screenSize.width*0.5, screenSize.height*0.5);
    reel.opacity = 128;
    reel.scaleX = 2.0;
    reel.scaleY = 1.8;
    [self addChild:reel z:0];                 
}

#pragma mark - Supporting methods for SLCCPhotoSlidesDataSource

-(SLWebViewVideoPlayer*) makeNewVideoPlayerWithVideoID:(NSString*)videoID {
    
    NSString *src = [NSString stringWithFormat:@"http://www.youtube.com/embed/%@", videoID];
    
    SLWebViewVideoPlayer *v = [[[SLWebViewVideoPlayer alloc] initWithParentNode:nil withVideoURL:src withDelegate:self] autorelease];
    
    return v;
}

-(void) replaceVideoPlayer:(SLWebViewVideoPlayer*)videoPlayer withVideoID:(NSString *)videoID {
    NSString *src = [NSString stringWithFormat:@"http://www.youtube.com/embed/%@", videoID];
    [videoPlayer reloadWithVideoURL:src];
}


#pragma mark - SLCCPhotoSlidesDataSource
-(NSInteger)sLCCPhotoSlides:(SLCCPhotoSlides *)sLCCPhotoSlides numberOfObjectsInSection:(NSInteger)section {
    return [videoIDs count];
}


-(id) sLCCPhotoSlides:(SLCCPhotoSlides *)sLCCPhotoSlides objectforIndex:(NSInteger)index {
    NSString *videoID = [videoIDs objectAtIndex:index];
    
    SLWebViewVideoPlayer *videoPlayer = nil;
    
    if (videoID != nil) {
        videoPlayer = (SLWebViewVideoPlayer*) [sLCCPhotoSlides dequeueReusableObject];
        if (videoPlayer == nil) 
            videoPlayer = [self makeNewVideoPlayerWithVideoID:videoID];
        else 
            [self replaceVideoPlayer:videoPlayer withVideoID:videoID];
    }
    
    return videoPlayer;
}

#pragma mark - SLCCPhotoSlidesDelegate
-(void) sLCCPhotoSlides:(SLCCPhotoSlides *)sLCCPhotoSlides didScrollToCurrentIndex:(int)index {
    CCLabelTTF *attribLabel= (CCLabelTTF*)[self getChildByTag:kTestingWebViewVideoPlayerAttributionTag];
    NSString *attribution = [videoAttributions objectAtIndex:index];
    if (attribution != nil) {
        attribLabel.string = attribution;
    }
    else {
        attribLabel.string = @"";
    }
        
}

#pragma mark - SLYouTubeVideoDelegate
-(void)slYouTubeVideo:(SLYouTubeVideo *)slYouTubeVideo isValid:(BOOL)valid withError:(NSError *)error {
    
    static int countOverPotential = 0;
    static int count = 0;
    if (error != nil) {      // got some sort of connection related err, so we still show the placeholders + attributions
        [videoIDs addObject:slYouTubeVideo.videoID];
        [videoAttributions addObject:[potentialVideoAttributions objectForKey:slYouTubeVideo.videoID]];
        [videoID2IndexMap setObject:[NSNumber numberWithInt:count] forKey:slYouTubeVideo.videoID];
        count++;
    }
    else if (valid && error == nil) {     // valid and no network connection error
        [videoIDs addObject:slYouTubeVideo.videoID];
        [videoAttributions addObject:[potentialVideoAttributions objectForKey:slYouTubeVideo.videoID]];
        [videoID2IndexMap setObject:[NSNumber numberWithInt:count] forKey:slYouTubeVideo.videoID];
        count++;
    }
    else 
        ;  // skip video if proven invalid.
    
    countOverPotential++;
    
    if (countOverPotential == [potentialVideoIDs count]) {  // if done checking all potential youtube video
        // Start display the video slider
        
        slides = [SLCCPhotoSlides slCCPhotoSlidesWithParentNode:self];
        slides.tag = kTestingWebViewVideoPlayerSliderTag;
        slides.dataSource = self;
        slides.delegate = self;
        slides.position = ccp(screenSize.width * 0.5f, screenSize.height * 0.5f);
        [slides show];
        
        // Display the attribute for the current video
        NSString *attribution = [videoAttributions objectAtIndex:slides.cursorVisible];
        CCLabelTTF *attribLabel = [CCLabelTTF labelWithString:attribution fontName:@"Marker Felt" fontSize:24.0];
        attribLabel.position = ccp(screenSize.width*0.5f, screenSize.height*0.1f);
        attribLabel.tag = kTestingWebViewVideoPlayerAttributionTag;
        [self addChild:attribLabel];
        
        //    CCRenderTexture *fakeWindow = [CCRenderTexture renderTextureWithWidth:640.0 height:360.0 pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        //    fakeWindow.position = ccp(screenSize.width*0.5f, screenSize.height*0.5f);
        //    [fakeWindow clear:0.5 g:0.5 b:0.5 a:0.7];
        //    fakeWindow.tag = kTestingWebViewVideoPlayerFakeWindowTag;
        //    [self addChild:fakeWindow];
        
        countOverPotential = 0;
        count = 0;
    }
    
    [slYouTubeVideo release];

}

//-(void)slYouTubeVideo:(SLYouTubeVideo *)slYouTubeVideo didFailWithError:(NSError *)error {
//    NSString *desc = [error localizedDescription];
//    NSInteger code = [error code];
//    NSString *domain = [error domain];
//    CCLOG(@"Failed with code = %d, domain=%@, desc=%@", code, domain, desc);
//    
//    
//    [slYouTubeVideo release];
//}

#pragma mark - SLWebViewVideoPlayerDelegates 

-(void)sLWebViewVideoPlayerDidFinishLoad:(SLWebViewVideoPlayer *)wvPlayer {
    
}

-(void)sLWebViewVideoPlayer:(SLWebViewVideoPlayer *)webView didFailLoadWithError:(NSError *)error {
    NSString *desc = [error localizedDescription];
    NSInteger code = [error code];
    NSString *domain = [error domain];
    CCLOG(@"Failed with code = %d, domain=%@, desc=%@", code, domain, desc);
    
    [webView reloadAsInternetOffline];
     
}

@end

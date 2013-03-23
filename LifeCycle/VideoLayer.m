//
//  VideoLayer.m
//  ButterflyPOC
//
//  Created by Kelvin Chan on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideoLayer.h"
#import "FlowAndStateManager.h"
#import "ConfigManager.h"
#import "GalleryInfo.h"
#import "GalleryManager.h"
#import "GalleryItemInfo.h"


@interface VideoLayer() <UIAlertViewDelegate>
@property (nonatomic, retain) NSMutableDictionary *validity; // key is video ID, val is nsnumber 0(false) and 1(true)
@end


@implementation VideoLayer
@synthesize validity = _validity;

@synthesize topicInfo;

#pragma mark - Getters & Setters
-(NSMutableDictionary *)validity {
    if (_validity == nil)
        _validity = [[NSMutableDictionary alloc] initWithCapacity:5];
    return _validity;
}
-(void)dealloc {
    
    CCLOG(@"videolayer dealloc");
    
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
    
    if (slYouTubeVideos != nil) 
        [slYouTubeVideos release];
    
    [topicInfo release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YOUTUBEVIDEO_DIDFINISH_NOTIFICATIONNAME object:nil];
    
    [super dealloc];
}

-(void)addMenu {
    
    NSString *path = [NSString stringWithFormat:@"%@/CCMenu:%d/CCMenuItemImage", NSStringFromClass([self class]), kVideoMenuTag];
    
    CCMenuItemImage *home = [CCMenuItemImage itemFromNormalImage:@"home.png" 
                                                   selectedImage:@"home_bigger.png"
                                                   disabledImage:@"home.png"
                                                          target:self selector:@selector(goHome)];
    
    CGPoint home_pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kVideoHomeButtonTag];
    home.position = home_pos;
    home.tag = kVideoHomeButtonTag;
        
    CCMenu *menu = [CCMenu menuWithItems:home, nil];
    
    NSString *menu_path = [NSString stringWithFormat:@"%@/CCMenu", NSStringFromClass([self class])];

    CGPoint menu_pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:menu_path andTag:kVideoMenuTag];

    menu.position = menu_pos;
    
    [menu alignItemsHorizontallyWithPadding:20.0f];
    
    [self addChild:menu z:0 tag:kVideoMenuTag];
    
}

-(void)addBack {
    
    NSString *path = [NSString stringWithFormat:@"%@/CCMenu:%d/CCMenuItemImage", NSStringFromClass([self class]), kVideoBackButtonTag];
    CGPoint back_pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kVideoBackButtonTag];
    
//    NSString *imageName = [self.topicInfo objectForKey:@"main_text_title_image_name"];
    
    //    CCSprite *imageTitleSprite = [CCSprite spriteWithSpriteFrameName:imageName];
    CCMenuItemImage *imageBackSprite = [CCMenuItemImage itemFromNormalImage:@"back.png"
                                                               selectedImage:@"back_bigger.png"
                                                               disabledImage:@"back.png"
                                                                      target:self selector:@selector(goBackToMainText)];
    //    imageTitleSprite.anchorPoint = ccp(0.5, 0.5);
    imageBackSprite.position = back_pos;
    imageBackSprite.tag = kVideoBackButtonTag;
   // imageBackSprite.scale = 0.75f;
    
    NSString *menu_path = [NSString stringWithFormat:@"%@/CCMenu", NSStringFromClass([self class])];
    CGPoint menu_pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:menu_path andTag:kVideoBackMenuTag];
    
    CCMenu *menu = [CCMenu menuWithItems:imageBackSprite, nil];
    menu.position = menu_pos;
    menu.tag = kVideoBackMenuTag;
    //    [self.imagesBatchNode addChild:imageTitleSprite z:20 tag:kMainTextImagesMainTitleTag];
    //    [self addChild:imageTitleSprite z:20 tag:kPhotoMainTitleTag];
    
    [self addChild:menu z:0];
}


-(void)addTitle{
    
    NSString *imageNameTemplate = topicInfo.backgroundImage;
    
    NSString *imageName  = [NSString stringWithFormat:@"%@.png",imageNameTemplate];
    NSString *biggerImageName  = [NSString stringWithFormat:@"%@_bigger.png",imageNameTemplate];
    
    debugLog(@"Adding title %@ %@",imageName,biggerImageName);
    
    CCMenuItemImage *topicItemImage = [CCMenuItemImage itemFromNormalImage:imageName
                                                             selectedImage:biggerImageName
                                                             disabledImage:imageName
                                                                    target:self
                                                                  selector:@selector(goBackToMainText)];
    
    
    
    NSString *path = [NSString stringWithFormat:@"%@/CCSprite", NSStringFromClass([self class])];
    CGPoint title_pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kVideoMainTitleTag];
    
    
    
    CCMenu *topicMenu = [CCMenu menuWithItems:topicItemImage,nil];
    topicMenu.position = title_pos;
    
    [self addChild:topicMenu z:0 tag:kVideoMainTitleTag];
    
    
}

-(void) addTitle_org {
    NSString *path = [NSString stringWithFormat:@"%@/CCSprite", NSStringFromClass([self class])];
    CGPoint title_pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kVideoMainTitleTag];
    
    NSString *imageName = [self.topicInfo objectForKey:@"main_text_title_image_name"];
        imageName = [imageName stringByAppendingString:@".png"];
    CCSprite *titleSprite = [CCSprite spriteWithFile:imageName];
    float scale = 135.0 / titleSprite.contentSize.width;
    titleSprite.scale = scale;
    
    titleSprite.position = title_pos;
    titleSprite.tag = kVideoMainTitleTag;
    
    [self addChild:titleSprite z:0];
}


-(void) goBackToMainText {
    
    [slides reset];

    
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kTopicInteractiveScene withTranstion:kCCTransitionPageTurnBackward];
    return;
    
    int topicNumber = [[self.topicInfo objectForKey:@"topic_number"] intValue];
    
    switch (topicNumber) {
        case 1:
            [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kTopic1Scene withTranstion:kCCTransitionPageTurnBackward];
            break;
        case 2:
            [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kTopic2Scene withTranstion:kCCTransitionPageTurnBackward];
            break;
        case 3:
            [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kTopic3Scene withTranstion:kCCTransitionPageTurnBackward];
            break;
        case 4:
            [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kTopic4Scene withTranstion:kCCTransitionPageTurnBackward];
            break;
        case 5:
            [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kTopic5Scene withTranstion:kCCTransitionPageTurnBackward];
            break;
        case 6:
            [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kTopic6Scene withTranstion:kCCTransitionPageTurnBackward];
            break;
        case 7:
            [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kTopic7Scene withTranstion:kCCTransitionPageTurnBackward];
            break;
        default:
            break;
    }
    
}


-(void)goHome {
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kHomeScene withTranstion:kCCTransitionPageFlip];
}

- (id)init
{
    self = [super init];
    if (self) {
        screenSize = [CCDirector sharedDirector].winSize;
//        [self addMenu];
        
        slYouTubeVideos = [[NSMutableArray alloc] initWithCapacity:10];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(slYouTubeVideoDidFinish:) 
                                                     name:YOUTUBEVIDEO_DIDFINISH_NOTIFICATIONNAME 
                                                   object:nil];
        
        // add please wait notice
        CCSprite *plsWait = [CCSprite spriteWithFile:@"PhotoSlidesPleaseWait.png"];
        plsWait.position = ccp(screenSize.width*0.5f, screenSize.height*0.5f);
        plsWait.scale = 0.5;
        plsWait.tag = kVideoPlsWaitTag;
        [self addChild:plsWait];
    }
    
    return self;
}

-(void)onEnter {
    [super onEnter];
    
        [[FlowAndStateManager sharedFlowAndStateManager] stopBackgroundTrack];
    editModeAbler = [EditModeAbler node];
    [editModeAbler retain];
    editModeAbler.delegateLayer = self;
    
    [editModeAbler activate];
    
    [self addBack];
    [self addTitle];
    
//    potentialVideoIDs = [NSMutableArray arrayWithObjects:@"bn9H8hbAAWQ", @"HnbMYzdjuBs", @"C9LHjV48e9s", @"dontexist", @"ge3EM8AERV0", nil];
//    potentialVideoAttributions = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"BBC Life 2009 - Plants HD", @"bn9H8hbAAWQ", @"flower red rose blooming", @"HnbMYzdjuBs", @"Redwoods: The Tallest Trees", @"C9LHjV48e9s", @"Don't exit", @"dontexist", @"Flower Pollination", @"ge3EM8AERV0", nil];
        
        // 
        
    GalleryManager *gman = [GalleryManager getInstance];
    
    NSString *galleryId =   topicInfo.gallery.uid;
    
    NSString *galleryName = [NSString stringWithFormat:@"%@-%@",galleryId,GALLERY_ITEM_TYPE_VIDEO];
    
    debugLog(@"Get video gallery name %@ from cache",galleryName);
                             
    GalleryInfo *videoGallery =     [gman getGalleryFromCache:galleryName];

      potentialVideoIDs = [[NSMutableArray alloc] init];
     potentialVideoAttributions = [[NSMutableDictionary alloc] initWithCapacity:[potentialVideoIDs count]];
    
    for (int i=0; i<[videoGallery.items count]; i++) {
        
        GalleryItemInfo *item = [videoGallery.items objectAtIndex:i];
        
        
        // parse the video id
       // http://www.youtube.com/watch?v=PVfoMaUk7K8
        int qloc = [item.url rangeOfString:@"?"].location;
        
        NSString *params = [item.url substringFromIndex:qloc + 1];
        
        debugLog(@"params %@",params);
        NSArray *tokens = [params componentsSeparatedByString: @"&"];
        
        debugLog(@"& tokens found %d",tokens.count);
        
        for (int j=0; j< [tokens count]; j++) {
            
            
            NSString *token = [tokens objectAtIndex:j];
            NSArray *kvpair = [token componentsSeparatedByString: @"="];
            
            debugLog(@"= kvpair found %d",kvpair.count);
            
            debugLog(@"token key %@",[kvpair objectAtIndex:0]);
            if ([[kvpair objectAtIndex:0] isEqualToString:@"v"]) {
                
                NSString *vid = [kvpair objectAtIndex:1];
                CCLOG(@"Found vid %@",vid);
                
                
                [potentialVideoIDs addObject:vid];    
                
                debugLog(@"about to set attribution");
                  [potentialVideoAttributions setObject:item.attribution forKey:vid];
               debugLog(@"set attribution");
                
            }
        }

    }
    
        //potentialVideoIDs = [self.topicInfo objectForKey:@"youtubevideos"];
        [potentialVideoIDs retain];
        

        
        
        videoIDs = [[NSMutableArray alloc] initWithCapacity:5];
        videoAttributions = [[NSMutableArray alloc] initWithCapacity:5];
        videoID2IndexMap = [[NSMutableDictionary alloc] initWithCapacity:5];

    
    debugLog(@"schedule launchVideoPlayerSlides");
    [self schedule:@selector(launchVideoPlayerSlides) interval:0.5];
}

-(void)onExit {
    [editModeAbler release];
    [super onExit];
}

#pragma mark - Test Web Video slides

-(void)launchVideoPlayerSlides {
    
    debugLog(@"launchVideoPlayerSlides" );
    [self unschedule:_cmd];
    
    // 1) check to see if each of the Video IDs in potentialVideoIDs is valid or not
    
    debugLog(@"potential vids %d",potentialVideoIDs.count);
    
    for (NSString *videoID in potentialVideoIDs) {
        SLYouTubeVideo *video = [[SLYouTubeVideo alloc] initWithVideoID:videoID];
//        video.delegate = self;
        
        debugLog(@"Adding video to Youtube Player %@",videoID);
        
        [slYouTubeVideos addObject:video];
        
        [video checkValidity];  // async op
        [video release];
    }
    
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
    
    debugLog(@"count of vid for ssshow %d",[videoIDs count]);
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
    
        debugLog(@"SLCCPhotoSlides didScrollToCurrentIndex");
    
    CCLabelTTF *attribLabel= (CCLabelTTF*)[self getChildByTag:kVideoAttributionTag];
    NSString *attribution = [videoAttributions objectAtIndex:index];
    if (attribution != nil) {
        attribLabel.scale = 0.0f;
//        attribLabel.string = attribution;
        attribLabel.string = [NSString stringWithFormat:@"Video by %@", attribution];
                              
        [attribLabel runAction:[CCScaleTo actionWithDuration:0.4 scale:1.0]];
    }
    else {
        attribLabel.string = @"";
    }
    
}

//pragma mark - SLYouTubeVideoDelegate
-(void)slYouTubeVideoDidFinish:(NSNotification *)notification {

static int countOverPotential = 0;
static int count = 0; // count of "valid" video, if it's unverifiable due to wifi issue, it is assumed valid still.

NSDictionary *userInfo = [notification userInfo];

BOOL valid = [[userInfo objectForKey:@"isValid"] boolValue];
NSError *error = [userInfo objectForKey:@"error"];
NSString *videoId = [userInfo objectForKey:@"videoID"];

if (error != nil) { // got some sort of connection related err, so we still show the placeholders + attributions
    [self.validity setObject:[NSNumber numberWithInt:1] forKey:videoId];
    count++;
}
else if (valid && error == nil) {
    NSString *embed = [userInfo objectForKey:@"embed"];
    if ([embed isEqualToString:@"allowed"]) {
        [self.validity setObject:[NSNumber numberWithInt:1] forKey:videoId];
        count++;
    }
}
else { // this is invalid
    [self.validity setObject:[NSNumber numberWithInt:0] forKey:videoId];
}

countOverPotential++;

if (countOverPotential == [potentialVideoIDs count]) {
    
    // construct valid videoIDs, videoAttributions, videoID2IndexMap
    int k = 0;
    for (NSString *v in potentialVideoIDs) {
        int valid = [[self.validity objectForKey:v] intValue];
        if (valid == 1) {
            [videoIDs addObject:v];
            [videoAttributions addObject:[potentialVideoAttributions objectForKey:v]];
            [videoID2IndexMap setObject:[NSNumber numberWithInt:k] forKey:v];
            k++;
        }
    }
    
    if (count > 0) {
        // Start display the video slider
        
        slides = [SLCCPhotoSlides slCCPhotoSlidesWithParentNode:self];
        slides.tag = kVideoSliderTag;
        slides.dataSource = self;
        slides.delegate = self;
        slides.numOfNeighbors = 2;
        slides.position = ccp(screenSize.width * 0.5f, screenSize.height * 0.5f);
        [slides show];
        
        // Display the attribute for the current video
        NSString *attribution = [NSString stringWithFormat:@"Video by %@", [videoAttributions objectAtIndex:slides.cursorVisible]];
        CCLabelTTF *attribLabel = [CCLabelTTF labelWithString:attribution fontName:@"Arial" fontSize:24.0];
        attribLabel.position = ccp(screenSize.width*0.5f, screenSize.height*0.1f);
        attribLabel.tag = kVideoAttributionTag;
        [self addChild:attribLabel];
        
        // CCRenderTexture *fakeWindow = [CCRenderTexture renderTextureWithWidth:640.0 height:360.0 pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        // fakeWindow.position = ccp(screenSize.width*0.5f, screenSize.height*0.5f);
        // [fakeWindow clear:0.5 g:0.5 b:0.5 a:0.7];
        // fakeWindow.tag = kTestingWebViewVideoPlayerFakeWindowTag;
        // [self addChild:fakeWindow];
    }
    else {
        // handle if there's no single youtube video
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Video Available" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    countOverPotential = 0;
    count = 0;
    
    // Remove the "please wait thing"
    CCSprite *plsWait = (CCSprite *)[self getChildByTag:kVideoPlsWaitTag];
    [plsWait removeFromParentAndCleanup:YES];
}
}

#pragma mark - SLYouTubeVideoDelegate
-(void)slYouTubeVideoDidFinishOriginal:(NSNotification *)notification {
    
    debugLog(@"notification recieved slYouTubeVideoDidFinish");
    
    static int countOverPotential = 0;
    static int count = 0;
    
    NSDictionary *userInfo = [notification userInfo];

    BOOL valid = [[userInfo objectForKey:@"isValid"] boolValue];
    NSError *error = [userInfo objectForKey:@"error"];
    NSString *videoId = [userInfo objectForKey:@"videoID"];
    
    if (error != nil) {       // got some sort of connection related err, so we still show the placeholders + attributions
        [videoIDs addObject:videoId];
        [videoAttributions addObject:[potentialVideoAttributions objectForKey:videoId]];
        [videoID2IndexMap setObject:[NSNumber numberWithInt:count] forKey:videoId];
        count++;
    }
    else if (valid && error == nil) {
        NSString *embed = [userInfo objectForKey:@"embed"];
        if ([embed isEqualToString:@"allowed"]) {
            [videoIDs addObject:videoId];
            [videoAttributions addObject:[potentialVideoAttributions objectForKey:videoId]];
            [videoID2IndexMap setObject:[NSNumber numberWithInt:count] forKey:videoId];
            count++;
        }
    }
    else 
        ;

    
    countOverPotential++;
    
    if (countOverPotential == [potentialVideoIDs count]) {
        
        if (count > 0) {
            // Start display the video slider
            
            slides = [SLCCPhotoSlides slCCPhotoSlidesWithParentNode:self];
            slides.tag = kVideoSliderTag;
            slides.dataSource = self;
            slides.delegate = self;
            slides.position = ccp(screenSize.width * 0.5f, screenSize.height * 0.5f);
            [slides show];
            
            // Display the attribute for the current video
            NSString *attribution = [NSString stringWithFormat:@"Video by %@",  [videoAttributions objectAtIndex:slides.cursorVisible]];
            CCLabelTTF *attribLabel = [CCLabelTTF labelWithString:attribution fontName:@"ArialMT" fontSize:14.0];
            attribLabel.position = ccp(screenSize.width*0.5f, screenSize.height*0.1f);
            attribLabel.tag = kVideoAttributionTag;
            [self addChild:attribLabel];
            
            //    CCRenderTexture *fakeWindow = [CCRenderTexture renderTextureWithWidth:640.0 height:360.0 pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
            //    fakeWindow.position = ccp(screenSize.width*0.5f, screenSize.height*0.5f);
            //    [fakeWindow clear:0.5 g:0.5 b:0.5 a:0.7];
            //    fakeWindow.tag = kTestingWebViewVideoPlayerFakeWindowTag;
            //    [self addChild:fakeWindow];
        }
        else {
            // handle if there's no single youtube video
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Video Available" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
            
        countOverPotential = 0;
        count = 0;
        
        // Remove the "please wait thing"
        CCSprite *plsWait = (CCSprite *)[self getChildByTag:kVideoPlsWaitTag];
        [plsWait removeFromParentAndCleanup:YES];
    }
}

//-(void)slYouTubeVideo:(SLYouTubeVideo *)slYouTubeVideo isValid:(BOOL)valid withError:(NSError *)error {
//    
//    static int countOverPotential = 0;
//    static int count = 0;
//    if (error != nil) {      // got some sort of connection related err, so we still show the placeholders + attributions
//        [videoIDs addObject:slYouTubeVideo.videoID];
//        [videoAttributions addObject:[potentialVideoAttributions objectForKey:slYouTubeVideo.videoID]];
//        [videoID2IndexMap setObject:[NSNumber numberWithInt:count] forKey:slYouTubeVideo.videoID];
//        count++;
//    }
//    else if (valid && error == nil) {     // valid and no network connection error
//        [videoIDs addObject:slYouTubeVideo.videoID];
//        [videoAttributions addObject:[potentialVideoAttributions objectForKey:slYouTubeVideo.videoID]];
//        [videoID2IndexMap setObject:[NSNumber numberWithInt:count] forKey:slYouTubeVideo.videoID];
//        count++;
//    }
//    else 
//        ;  // skip video if proven invalid.
//    
//    countOverPotential++;
//    
//    if (countOverPotential == [potentialVideoIDs count]) {  // if done checking all potential youtube video
//        // Start display the video slider
//        
//        slides = [SLCCPhotoSlides slCCPhotoSlidesWithParentNode:self];
//        slides.tag = kVideoSliderTag;
//        slides.dataSource = self;
//        slides.delegate = self;
//        slides.position = ccp(screenSize.width * 0.5f, screenSize.height * 0.5f);
//        [slides show];
//        
//        // Display the attribute for the current video
//        NSString *attribution = [videoAttributions objectAtIndex:slides.cursorVisible];
//        CCLabelTTF *attribLabel = [CCLabelTTF labelWithString:attribution fontName:@"Marker Felt" fontSize:24.0];
//        attribLabel.position = ccp(screenSize.width*0.5f, screenSize.height*0.1f);
//        attribLabel.tag = kVideoAttributionTag;
//        [self addChild:attribLabel];
//        
//        //    CCRenderTexture *fakeWindow = [CCRenderTexture renderTextureWithWidth:640.0 height:360.0 pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
//        //    fakeWindow.position = ccp(screenSize.width*0.5f, screenSize.height*0.5f);
//        //    [fakeWindow clear:0.5 g:0.5 b:0.5 a:0.7];
//        //    fakeWindow.tag = kTestingWebViewVideoPlayerFakeWindowTag;
//        //    [self addChild:fakeWindow];
//        
//        countOverPotential = 0;
//        count = 0;
//    }
//    
//    [slYouTubeVideo release];
//    
//}

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
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Please check your WiFi or cellular data network and try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    
//    [webView reloadAsInternetOffline];
    
}


@end

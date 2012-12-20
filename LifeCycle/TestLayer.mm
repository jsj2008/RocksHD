//
//  TestLayer.m
//  LifeCycle
//
//  Created by Kelvin Chan on 1/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestLayer.h"
#import "ConfigManager.h"
#import "ScrollableCCLabelTTF.h"
#import "SLObjectPool.h"
#import "SLCCPolaroidPhoto.h"
#import "SLWebViewVideoPlayer.h"

#define PTM_RATIO 32

@interface TestLayer (Private)
-(void) loadImage;
@end

@implementation TestLayer

-(void)dealloc {    
    
    CCLOG(@"Deallocating TestLayer");
    
    if (world) {
        delete world;
        world = NULL;
    }
    
    if (imgSetDowloader != nil) {
        [imgSetDowloader cancel];
        [imgSetDowloader release];
    }
    
    if (slImageDownloaders != nil) 
        [slImageDownloaders release];
    
    [super dealloc];
}

-(void) addInfo {
    
    CCSprite *infoPane = [CCSprite spriteWithFile:@"InfoTextPane.png"];
    infoPane.position = ccp(0.2f * screenSize.width, 0.5f * screenSize.height);
    // [self addChild:infoPane z:0 tag:kTestingPaneTag];
    
    NSString *text = @"Sprout Labs - Learning reimagined!";
    
    ScrollableCCLabelTTF *infoLabel = [[ScrollableCCLabelTTF alloc] 
                                       initWithString:text dimensions:CGSizeMake(screenSize.width*0.5, screenSize.height*2.0) 
                                       alignment:kCCTextAlignmentLeft
                                       fontName:@"AmericanTypewriter" 
                                       fontSize:20];
    
    infoLabel.color = ccc3(1.0, 1.0, 1.0);
    infoLabel.anchorPoint = ccp(0.0, 1.0);
    infoLabel.position = ccp(0.05f * screenSize.width, 0.8620f * screenSize.height);
//    infoLabel.position = ccp(0.25f * screenSize.width, 0.8620f * screenSize.height);
    infoLabel.viewPortHeight = 550.0;
    
    // [self addChild:infoLabel z:1 tag:kTestingTextTag];
    
    infoLabelBound = infoLabel.boundingBox;
    
    [infoLabel release];
    
}

-(void)addMenu {
    CCMenuItemImage *home = [CCMenuItemImage itemFromNormalImage:@"home.png" 
                                                   selectedImage:@"home_bigger.png"
                                                   disabledImage:@"home.png"
                                                          target:self selector:@selector(goHome)];
    home.position = ccp(0.0f, 0.0f);
    home.tag = kTestingHomeButtonTag;
    
//    SEL testSelector = @selector(testSLObjectPool1);
//    SEL testSelector = @selector(testSLObjectPool2);
//    SEL testSelector = @selector(testSLVideoPlayer);
//    SEL testSelector = @selector(testSLCCPhotoSlides);
    SEL testSelector = @selector(testSLCCImageStack);
//    SEL testSelector = @selector(testSLCCPolaroidPhoto);
//    SEL testSelector = @selector(testSLWebViewVideoPlayer);
    
    CCMenuItemImage *lab = [CCMenuItemImage itemFromNormalImage:@"test.png"
                                                    selectedImage:@"test_bigger.png"
                                                    disabledImage:@"test.png"
                                                           target:self
                                                         selector:testSelector];

    lab.tag = kTestingTestButtonTag;
    
    CCMenu *menu = [CCMenu menuWithItems:home, lab, nil];
    
    menu.position = ccp(0.875f * screenSize.width, 0.9375f * screenSize.height);
    [menu alignItemsHorizontallyWithPadding:20.0f];
    
    [self addChild:menu z:0 tag:kTestingMenuTag];

}

-(void)goHome {
    if ([SLVideoPlayer isPlaying]) 
        [SLVideoPlayer cancelPlaying];
    
    PLAYSOUNDEFFECT(TEST_CLICK_1);
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kHomeScene withTranstion:kCCTransitionPageFlip];
}


- (id)init
{
    self = [super init];
    if (self) {
        screenSize = [CCDirector sharedDirector].winSize;
        [self addMenu];
        [self addInfo];
        
        // Init video player
        [SLVideoPlayer setDelegate:self];
        
        // Initialize box2d
        b2Vec2 gravity;
        gravity.Set(0.0f, -10.0f);
        bool doSleep = true;
        
//        world = new b2World(gravity, doSleep);
        world->SetContinuousPhysics(true);
        
        slImageDownloaders = [[NSMutableArray alloc] initWithCapacity:10];
        
    }
    
    return self;
}

-(void)onEnter {
    [super onEnter];
    
    editModeAbler = [[EditModeAbler node] retain];
    editModeAbler.delegateLayer = self;    
    [editModeAbler activate];
    
    // testing flickr api
    [self schedule:@selector(loadFlickrImage) interval:0.5];
    
}

-(void)onExit {
    [editModeAbler release];
    [super onExit];
}

#pragma mark - Convenience methods
// convenience method to convert a CGPoint to a b2Vec2
-(b2Vec2) toMeters:(CGPoint)point
{
	return b2Vec2(point.x / PTM_RATIO, point.y / PTM_RATIO);
}

// convenience method to convert a b2Vec2 to a CGPoint
-(CGPoint) toPixels:(b2Vec2)vec
{
	return ccpMult(CGPointMake(vec.x, vec.y), PTM_RATIO);
}

#pragma mark - Test SLWebViewVideoPlayer
-(void) testSLWebViewVideoPlayer {

    SLWebViewVideoPlayer *v = [SLWebViewVideoPlayer slWebViewVideoPlayerWithParentNode:self withVideoURL:@"http://www.youtube.com/embed/bn9H8hbAAWQ" withDelegate:nil];
    
    v.position = ccp(10, 500);
    
//    SLWebViewVideoPlayer *v =[SLWebViewVideoPlayer slWebViewVideoPlayerWithParentNode:self withVideoURL:@"http://www.youtube.com/watch?v=sZjhDZbB2hg" withDelegate:nil];
}

#pragma mark - Test SLCCPolaroidPhoto
-(void) testSLCCPolaroidPhoto {
    SLCCPolaroidPhoto *polaroid = [SLCCPolaroidPhoto slCCPolaroidPhotoWithImageName:@"Egg-1.png" withTitle:@"Apple Egg enclosed by a fruit" withAttribution:@"Picture taken by Mark Probst"];
    polaroid.position = ccp(screenSize.width * 0.5f, screenSize.height * 0.5f);
    [self addChild:polaroid];
    
    [polaroid runAction:[CCSequence actions:
                         [CCMoveBy actionWithDuration:1.0 position:ccp(100.0, 150.0)],
                         [CCCallBlock actionWithBlock:^{
        [polaroid replaceWithImageName:@"Egg-2.png" withTitle:@"Colorful Erythrina Madagascariensis Egg" withAttribution:@"Picture taken by Ton Rulkens"];
    }],
                         nil]];
}

#pragma mark - Test SLCCImageStack
-(void) testSLCCImageStack {
    SLCCImageStack *imageStack = [SLCCImageStack slCCImageStackWithParentNode:self];
    imageStack.tag = kTestingImageStackTag;
    imageStack.dataSource = self;
    imageStack.position = ccp(screenSize.width * 0.5f, screenSize.height * 0.5);
    [imageStack show];
}

#pragma mark - Test SLCCPhotoSlides
-(void) testSLCCPhotoSlides {
        
    if (slides == nil) {
        slides = [SLCCPhotoSlides slCCPhotoSlidesWithParentNode:self];
        slides.tag = kTestingPhotoSliderTag;
        slides.dataSource = self;
        slides.position = ccp(screenSize.width*0.5f, screenSize.height*0.5f);
        [slides show];
        
        CCRenderTexture *fakeWindow = [CCRenderTexture renderTextureWithWidth:370 height:278 pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        fakeWindow.position = ccp(screenSize.width*0.5f, screenSize.height*0.5f);
        [fakeWindow clear:0.5 g:0.5 b:0.5 a:0.7];
        fakeWindow.tag = kTestingFakeWindowTag;
        [self addChild:fakeWindow];
    }
    else {
        
        [slides reset];
        [slides removeFromParentAndCleanup:YES];
        slides = nil;
        
        id whatever = [self getChildByTag:kTestingFakeWindowTag];
        [whatever removeFromParentAndCleanup:YES];
    }
}

#pragma mark - Test SLObjectPool
-(void)testSLObjectPool1 {
    SLObjectPool *objPool = [SLObjectPool objectsPoolWithCapacity:10];
    NSString *s = [objPool dequeueReusableObject];
    if (s == nil) {
        s = [[[NSMutableString alloc] initWithString:@"ok1"] autorelease];
    }
    [objPool assignObjectToPool:s];
        
    NSMutableString *s2 = [objPool dequeueReusableObject];
    if (s2 == nil) {
        s2 = [[[NSMutableString alloc] initWithString:@"ok2"] autorelease];
    }
    [objPool assignObjectToPool:s2];
    
    NSMutableString *s3 = [objPool dequeueReusableObject];
    if (s3 == nil) {
        s3 = [[[NSMutableString alloc] initWithString:@"ok3"] autorelease];
    }
    [objPool assignObjectToPool:s3];
    
    // should have (ok1, ok2, ok3) all in use
    [objPool printPoolState];
    
    // try to free the "ok2" object, and modify it for other purpose
    [objPool freeObjectForReuse:s2];
    
    // try dequeue, and verify this is s2
    NSMutableString *y = [objPool dequeueReusableObject];
    if (y == nil) 
        y = [[[NSMutableString alloc] initWithString:@""] autorelease];
    [objPool assignObjectToPool:y];
    
    CCLOG(@"confirm: y = %@", y);
    [objPool printPoolState];
    
    [y appendString:@"!!!"];
    [objPool printPoolState];
    
}

-(void)testSLObjectPool2 {
    SLObjectPool *pool = [SLObjectPool objectsPoolWithCapacity:10];
    NSMutableString *s3;
    NSMutableString *s6;
    
    for (int k=0; k < 8; k++) {
        NSMutableString *s = [pool dequeueReusableObject];
        if (s == nil) {
            s = [[[NSMutableString alloc] initWithFormat:@"ok%d", k] autorelease];
        }
        [pool assignObjectToPool:s];
        
        if (k == 3)
            s3 = s;
        
        if (k == 6)
            s6 = s;
    }
    [pool printPoolState];
    
    // free 2 objects (3) and (6)
    [pool freeObjectForReuse:s3];
    [pool freeObjectForReuse:s6];
    
    [pool printPoolState];
    
    // dequeue and use one
    NSMutableString *y = [pool dequeueReusableObject];
    CCLOG(@"Unmodified y = %@", y);
    
    // modified y
    [y appendString:@" modified"];
    CCLOG(@"Modified y = %@", y);

    [pool printPoolState];
}

#pragma mark - Test SLVideoPlayer
-(void)testSLVideoPlayer {
    if ([SLVideoPlayer isPlaying]) 
        [SLVideoPlayer cancelPlaying];
    else {
        [SLVideoPlayer setCenter:ccp(screenSize.width*0.5, screenSize.height*0.5)];
        [SLVideoPlayer setSize:CGSizeMake(screenSize.width*0.85, screenSize.height*0.85)];
        [SLVideoPlayer playMovieWithFile:@"Trailer.m4v"];
    }
}

-(void) moviePlaybackStarts {
    [[CCDirector sharedDirector] stopAnimation];
}

-(void) moviePlaybackFinished {
    [[CCDirector sharedDirector] startAnimation];
}


#pragma mark - SLImageSetDownloader
//-(CGPoint*)getPositionFromUserDefaultsForKey:(NSString*)key {
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSString *coords = (NSString*) [defaults objectForKey:key];
//    
//    if (coords == nil)
//        return nil;
//    
//    NSArray *a = [coords componentsSeparatedByString:@","];
//    NSString *xStr = [a objectAtIndex:0];
//    NSString *yStr = [a objectAtIndex:1];
//    
//    float x = [xStr floatValue];
//    float y = [yStr floatValue];
//    
//    CGPoint pt = CGPointMake(x, y);
//    
//    CGPoint *returnPt = &pt;
//    
//    return returnPt;
//}

-(void)loadFlickrImage {
    
    [self unschedule:_cmd];
    
    imgSetDowloader = [[SLImageSetDownloader alloc] init];
    imgSetDowloader.setId = @"72157628892081951";
    imgSetDowloader.delegate = self;
    
    [imgSetDowloader fetchImageURLs];
        
    for (int k=0; k < 3; k++) {
        CCSprite *imageSprite = [CCSprite spriteWithFile:@"PleaseWait.png"];
        imageSprite.tag = 10000 + k;
        
        CGPoint position = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:@"TestLayer/CCSprite" andTag:imageSprite.tag];
        imageSprite.position = position;
        
        imageSprite.scale = 2.0f;
        
        [self addChild:imageSprite];
    }
    
}

#pragma mark - SLImageSetDownloaderDelegate
-(void)slImageSetDownloaderDidFinish:(SLImageSetDownloader *)downloader {
    
    if ([downloader.imageURLs count] > 0) {
        
        for (NSString *imgURL in downloader.imageURLs) {
            SLImageDownloader *imgDownloader = [[SLImageDownloader alloc] init];
            imgDownloader.imageURL = imgURL;
            imgDownloader.delegate = self;
            
            [slImageDownloaders addObject:imgDownloader];
            
            [imgDownloader loadImage];
            [imgDownloader release];
        }
    }

}

#pragma mark - SLImageDownloaderDelegate
-(void)slImageDownloaderDidFinish:(SLImageDownloader *)downloader withNSData:(NSData *)data {
    
    static int k = 0;
    
    UIImage *image = [UIImage imageWithData:data];
        
    NSString *key = downloader.imageURL;
    
    CCSprite *imageSprite = (CCSprite*) [self getChildByTag:(10000+k)];
    
    [[CCTextureCache sharedTextureCache] addCGImage:[image CGImage] forKey:key];
    [imageSprite setTexture:[[CCTextureCache sharedTextureCache] textureForKey:key]];
    
    CCSprite *newSprite = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] textureForKey:key]];
    newSprite.position = imageSprite.position;
    
    [imageSprite removeFromParentAndCleanup:YES];

    newSprite.tag = 10000+k;
    [self addChild:newSprite];
    
    //    CCSprite *imageSprite = [CCSprite spriteWithCGImage:[image CGImage] key:key];
    //    imageSprite.position = ccp(screenSize.width*0.85, screenSize.height*0.5 + 100.0*k);
    //    [self addChild:imageSprite];
    
    k++;
    if (k > 2) 
        k = 0;
    
//    [downloader release];
}

#pragma mark - Supporting methods for SLCCPhotoSlidesDataSource

-(CCSprite *) makeNewSpriteWithImageNamed:(NSString *)imageName {
    CCSprite *s = nil;
    @try {
        CCSpriteFrame *f = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:imageName];
        if (f != nil)
            s = [CCSprite spriteWithSpriteFrame:f];
        else 
            s = [CCSprite spriteWithFile:imageName];
    }
    @catch (NSException *NSInternalInconsistencyException) {
        s = [CCSprite spriteWithFile:imageName];
    }
    @finally {
        ;
    }
    
    return s;
}

-(void) replaceSpriteTextureForSprite:(CCSprite *) sprite withImageNamed:(NSString *)imageName {
    CCSpriteFrame *spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:imageName];
    if (spriteFrame != nil)
        [sprite setDisplayFrame:spriteFrame];
    else {
        UIImage *image = [UIImage imageNamed:imageName];
        [[CCTextureCache sharedTextureCache] addImage:imageName];
        
        [sprite setTexture:[[CCTextureCache sharedTextureCache] textureForKey:imageName]];
        [sprite setTextureRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    }
}

#pragma mark - SLCCPhotoSlidesDataSource
-(NSInteger)sLCCPhotoSlides:(SLCCPhotoSlides *)sLCCPhotoSlides numberOfObjectsInSection:(NSInteger)section {
    
    static int buttonHitCount = 0;
    
    buttonHitCount = 1 - buttonHitCount;
    
    if (buttonHitCount == 1)
        return 8;
    else 
        return 4;
    
    
}

-(id) sLCCPhotoSlides:(SLCCPhotoSlides *)sLCCPhotoSlides objectforIndex:(NSInteger)index {
    
    NSString *imageName = nil;
    
    switch (index) {
        case 0:
            imageName = @"Egg-1.png";
            break;
        case 1:
            imageName = @"Egg-2.png";
            break;
        case 2:
            imageName = @"Egg-3.png";
            break;
        case 3:
            imageName = @"Egg-4.png";
            break;
        case 4:
            imageName = @"Egg-5.png";
            break;
        case 5:
            imageName = @"Egg-6.png";
            break;
        case 6:
            imageName = @"Egg-7.png";
            break;
        default:
            break;
    }
    
    CCSprite *imageVisible = nil;
    
    if (imageName != nil) {
        imageVisible = (CCSprite*)[sLCCPhotoSlides dequeueReusableObject];
        if (imageVisible == nil)
            imageVisible = [self makeNewSpriteWithImageNamed:imageName];
        else 
            [self replaceSpriteTextureForSprite:imageVisible withImageNamed:imageName];

    }
    
    return imageVisible;
}



#pragma mark - SLCCImageStackDataSource
-(NSInteger)sLCCImageStack:(SLCCImageStack *)sLCCImageStack numberOfObjectsInSection:(NSInteger)section {
    return 7;
}

-(id) sLCCImageStack:(SLCCImageStack *)sLCCImageStack objectforIndex:(NSInteger)index {
    NSString *imageName = nil;
    NSString *title = nil;
    NSString *attr = nil;

    switch (index) {
        case 0:
            imageName = @"Egg-1.png";
            title = @"Apple Egg enclosed by a fruit";
            attr = @"Picture taken by Mark Probst";
            break;
        case 1:
            imageName = @"Egg-2.png";
            title = @"Colorful Erythrina Madagascariensis Egg";
            attr = @"Picture taken by Ton Rulkens";
            break;
        case 2:
            imageName = @"Egg-3.png";
            title = @"Flax Egg";
            attr = @"Picture taken by HealthAliciousNess";
            break;
        case 3:
            imageName = @"Egg-4.png";
            title = @"Open seedpod showing Egg";
            attr = @"Picture taken by Peter Kaminski";
            break;
        case 4:
            imageName = @"Egg-5.png";
            title = @"Edible pomegranate Egg";
            attr = @"Picture taken by Lindsey Turner";
            break;
        case 5:
            imageName = @"Egg-6.png";
            title = @"The largest seedpod is from the palm tree";
            attr = @"Picture taken by mountainamoeba";
            break;
        case 6:
            imageName = @"Egg-7.png";
            title = @"Very small Egg";
            attr = @"Picture taken by photofarmer";
            break;
        default:
            break;
    }
    
    SLCCPolaroidPhoto *photoSprite = nil;
    
    if (imageName != nil && title != nil && attr != nil) {
        photoSprite = (SLCCPolaroidPhoto *)[sLCCImageStack dequeueReusableObject];
        if (photoSprite == nil)
            photoSprite = [SLCCPolaroidPhoto slCCPolaroidPhotoWithImageName:imageName withTitle:title withAttribution:attr];
        else 
            [photoSprite replaceWithImageName:imageName withTitle:title withAttribution:attr];
    }
    
    return photoSprite;
}

@end

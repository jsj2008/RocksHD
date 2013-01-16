//
//  PhotoLayer.m
//  ButterflyPOC
//
//  Created by Kelvin Chan on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoLayer.h"
#import "FlowAndStateManager.h"
#import "ConfigManager.h"
#import "CCImageReflector.h"
#import "Gallery.h"
#import "GalleryItem.h"
#import "GalleryManager.h"

@interface PhotoLayer (Private)
//-(void) loadImage;
-(void)replaceSpriteTextureForSprite:(CCSprite *)sprite withTextureCacheKey:(NSString*) key;
-(void)replaceReflectedSpriteTextureForSprite:(CCSprite *)sprite withTextureCacheKey:(NSString*) key;

-(NSData *)retrieveImageDataFromDoc:(NSString*)imageName;
-(BOOL)saveImageFoundInDoc:(NSString*)imageName;
-(void)saveImageSizeToDoc:(CGSize)size withImageName:(NSString*)imageName;
-(CGSize)retrieveImageSizeFromDoc:(NSString*)imageName;

-(void) zoomOutCurrentImage;
-(void) replaceBigCurrentImage;
@end

@interface PhotoLayer ()
@property (nonatomic, retain) NSMutableArray *urlArray;
@property (nonatomic, retain) NSMutableDictionary *bigUrl2IndexMap; 
@property (nonatomic, retain) NSMutableArray *bigImageURLs;
@end


@implementation PhotoLayer

@synthesize topicInfo;
@synthesize bigUrl2IndexMap = _bigUrl2IndexMap;
@synthesize bigImageURLs = _bigImageURLs;
@synthesize urlArray = urlArray_;
@synthesize galleryId;

-(void)dealloc {
    CCLOG(@"Deallocating PhotoLayer");
    
    [urlArray_ release];
    
    if (url2IndexMap != nil)
        [url2IndexMap release];
    
    [_bigUrl2IndexMap release];
    [_bigImageURLs release];
    
    if (photoIdArray != nil)
        [photoIdArray release];
    
    if (photoInfo != nil)
        [photoInfo release];
    
    if (photoId2IndexMap != nil)
        [photoId2IndexMap release];
    
    //    if (imgSetDownloader != nil) {
    //        [imgSetDownloader cancel];
    //        [imgSetDownloader release];
    //    }
    //    
    //    if (imgGrpDownloader != nil) {
    //        [imgGrpDownloader cancel];
    //        [imgGrpDownloader release];
    //    }
    
    if (imgGalleryDownloader != nil) {
        [imgGalleryDownloader cancel];
        [imgGalleryDownloader release];
    }
    
    if (slImageDownloaders != nil) {
        [slImageDownloaders release];
    }
    
    if (slImageInfoDownloaders != nil) {
        [slImageInfoDownloaders release];
    }
    
    [topicInfo release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IMAGE_GALLERY_DOWNLOADER_DIDFINISH_NOTIFICATIONNAME object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IMAGE_DOWNLOADER_DIDFINISH_NOTIFICATIONNAME object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IMAGE_INFO_DOWNLOADER_DIDFINISH_NOTIFICATIONNAME object:nil];
    
    dispatch_release(backgroundQueue);
    
    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:pinchGestureRecognizer];
    
    // comment to test git
    
    [super dealloc];
}

#pragma mark - lazy getters

-(NSMutableArray*) urlArray {
    if (urlArray_ == nil) {
        urlArray_ = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return urlArray_;
}

-(NSMutableDictionary*) bigUrl2IndexMap {
    if (_bigUrl2IndexMap == nil)
        _bigUrl2IndexMap = [[NSMutableDictionary alloc] initWithCapacity:10];
    return _bigUrl2IndexMap;
}

#pragma mark - 

-(void)addMenu {
    
    NSString *path = [NSString stringWithFormat:@"%@/CCMenu:%d/CCMenuItemImage", NSStringFromClass([self class]), kPhotoMenuTag];
    
    CCMenuItemImage *home = [CCMenuItemImage itemFromNormalImage:@"home.png" 
                                                   selectedImage:@"home_bigger.png"
                                                   disabledImage:@"home.png"
                                                          target:self selector:@selector(goHome)];
    
    CGPoint home_pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kPhotoHomeButtonTag];
    
    home.position = home_pos;
    home.tag = kPhotoHomeButtonTag;
    
    CCMenu *menu = [CCMenu menuWithItems:home, nil];
    
    NSString *menu_path = [NSString stringWithFormat:@"%@/CCMenu", NSStringFromClass([self class])];
    
    CGPoint menu_pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:menu_path andTag:kPhotoMenuTag];
    
    //    menu.position = ccp(0.875f * screenSize.width, 0.9375f * screenSize.height);
    menu.position = menu_pos;
    
    [menu alignItemsHorizontally];
    
    [self addChild:menu z:0 tag:kPhotoMenuTag];
    
}

-(void)addBack {
    
    NSString *path = [NSString stringWithFormat:@"%@/CCMenu:%d/CCMenuItemImage", NSStringFromClass([self class]), kPhotoBackButtonTag];
    CGPoint back_pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kPhotoBackButtonTag];
    
    //    NSString *imageName = [self.topicInfo objectForKey:@"main_text_title_image_name"];
    
    //    CCSprite *imageTitleSprite = [CCSprite spriteWithSpriteFrameName:imageName];
    CCMenuItemImage *imageBackSprite = [CCMenuItemImage itemFromNormalImage:@"back.png"
                                                              selectedImage:@"back_bigger.png"
                                                              disabledImage:@"back.png"
                                                                     target:self selector:@selector(goBackToMainText)];
    //    imageTitleSprite.anchorPoint = ccp(0.5, 0.5);
    imageBackSprite.position = back_pos;
    imageBackSprite.tag = kPhotoBackButtonTag;
    imageBackSprite.scale = 0.75f;
    
    NSString *menu_path = [NSString stringWithFormat:@"%@/CCMenu", NSStringFromClass([self class])];
    CGPoint menu_pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:menu_path andTag:kPhotoBackMenuTag];
    
    CCMenu *menu = [CCMenu menuWithItems:imageBackSprite, nil];
    menu.position = menu_pos;
    menu.tag = kPhotoBackMenuTag;
    //    [self.imagesBatchNode addChild:imageTitleSprite z:20 tag:kMainTextImagesMainTitleTag];
    //    [self addChild:imageTitleSprite z:20 tag:kPhotoMainTitleTag];
    
    [self addChild:menu z:0];
}

-(void)addTitle{
    
    NSString *imageNameTemplate = [self.topicInfo objectForKey:@"main_text_title_image_name"];
    
    NSString *imageName  = [NSString stringWithFormat:@"%@.png",imageNameTemplate];
    NSString *biggerImageName  = [NSString stringWithFormat:@"%@_bigger.png",imageNameTemplate];
    
    debugLog(@"Adding title %@ %@",imageName,biggerImageName);
    
    CCMenuItemImage *topicItemImage = [CCMenuItemImage itemFromNormalImage:imageName
                                                             selectedImage:biggerImageName
                                                             disabledImage:imageName
                                                                    target:self
                                                                  selector:@selector(goBackToMainText)];
    
    
    
    NSString *path = [NSString stringWithFormat:@"%@/CCSprite", NSStringFromClass([self class])];
    CGPoint title_pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kPhotoMainTitleTag];
    
    
    
    CCMenu *topicMenu = [CCMenu menuWithItems:topicItemImage,nil];
    topicMenu.position = title_pos;
    
    [self addChild:topicMenu z:0 tag:kPhotoMainTitleTag];
    
    
}

-(void) addTitle_org {
    NSString *path = [NSString stringWithFormat:@"%@/CCSprite", NSStringFromClass([self class])];
    CGPoint title_pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kPhotoMainTitleTag];
    
    NSString *imageName = [self.topicInfo objectForKey:@"main_text_title_image_name"];
    imageName = [imageName stringByAppendingString:@".png"];
    CCSprite *titleSprite = [CCSprite spriteWithFile:imageName];
    float scale = 135.0 / titleSprite.contentSize.width;
    titleSprite.scale = scale;
    
    titleSprite.position = title_pos;
    titleSprite.tag = kPhotoMainTitleTag;
    
    [self addChild:titleSprite z:0];
}

-(void)addWaitIndicator {
    //plsWaitIndicator = [CCUIActivityIndicatorView ccUIActivityIndicatorViewWithParentNode:self];
    //    [plsWaitIndicator startAnimating];
}

-(void) goBackToMainText {
    
    if (zoomed) {
        [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:swipeGestureRecognizer];
    }
    
    [slides reset];
    //    [slide_reflections reset];
    
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
        
        numOfImagesKnown = NO;
        numOfImages = 0;
        
        slImageDownloaders = [[NSMutableArray alloc] initWithCapacity:10];
        slImageInfoDownloaders = [[NSMutableArray alloc] initWithCapacity:10];
        
        // observe the "Image Gallery Downloader DidFinish notification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(slImageGalleryDownloaderDidFinish:)
                                                     name:IMAGE_GALLERY_DOWNLOADER_DIDFINISH_NOTIFICATIONNAME 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(slImageDownloaderDidFinish:) 
                                                     name:IMAGE_DOWNLOADER_DIDFINISH_NOTIFICATIONNAME 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(slImageInfoDownloaderDidFinish:) 
                                                     name:IMAGE_INFO_DOWNLOADER_DIDFINISH_NOTIFICATIONNAME
                                                   object:nil];
        
        backgroundQueue = dispatch_queue_create("com.appilly.lifecycle.bgqueue", NULL);
        
        self.isTouchEnabled = YES;
        
        
    }
    
    return self;
}

-(void)onEnter {
    [super onEnter];
    
    [self setupPhotosForDisplay];
    [self schedule:@selector(launchPhotoSlidesFromFlickr) interval:0.5];
    
    editModeAbler = [EditModeAbler node];
    [editModeAbler retain];
    editModeAbler.delegateLayer = self;
    
    [editModeAbler activate];
    
    [self addBack];
    [self addTitle];
    [self addWaitIndicator];
    
    //    [[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority:0];
    
    pinchGestureRecognizer = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchPhoto:)] autorelease];
    
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:pinchGestureRecognizer];
    
}

-(void)onExit {
    [editModeAbler release];
    //    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super onExit];
}

#pragma mark - Launch method
-(void) launchPhotoSlidesFromFlickr {
    
    //    if (self.topicInfo != nil) {
    //        NSString *background_track_name = [self.topicInfo objectForKey:@"background_track_name"];
    //        CCLOG(@"bg music for photo is %@", background_track_name);
    //    }
    
    
    
    NSString *path = [NSString stringWithFormat:@"%@/CCLabelTTF", NSStringFromClass([self class])];
    
    CGPoint attrib_pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kPhotoAttributionTag];
    
    GalleryManager *gm = [GalleryManager getInstance];
   
    
    

    CCLabelTTF *attribution = [CCLabelTTF labelWithString: @" " fontName:@"ArialMT" fontSize:14.0];
    attribution.position = attrib_pos;
    attribution.tag = kPhotoAttributionTag;
    [self addChild:attribution];
    
    CGPoint title_pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kPhotoTitleTag];
    
    //CCLabelTTF *title = [CCLabelTTF labelWithString:@" " fontName:@"Marker Felt" fontSize:24.0];
CCLabelTTF *title = [[CCLabelTTF alloc] initWithString:@"" dimensions:CGSizeMake(screenSize.width*0.7, 80) alignment:UITextAlignmentCenter fontName:@"ArialMT" fontSize:18];

    
    
    title.position = title_pos;
    title.tag = kPhotoTitleTag;
    [self addChild:title];

    [self unschedule:_cmd];
    
    // Main slide photos
    slides = [SLCCPhotoSlides slCCPhotoSlidesWithParentNode:self];
    slides.tag = kPhotoSliderTag;
    slides.dataSource = self;
    slides.delegate = self;
    slides.position = ccp(screenSize.width*0.5f, screenSize.height*0.5f);
    slides.fixedSize = CGSizeMake(640.0, 480.0);
    
    [slides show];
    
    CGRect glFrame = CGRectMake(0.0, 0.0, 120.0, 15.0);  // the origin is a dummy, the position is the thing thats gonna be set a few lines later.
    
    
    SLCCUIPageControl *pageCtrl = [SLCCUIPageControl slCCUIPageControlWithParentNode:self withGlFrame:glFrame];
    pageCtrl.tag = kPhotoPageControlTag;
    pageCtrl.numberOfPages = numOfImages;
    
    // Reflections of photo
    //    slide_reflections = [SLCCPhotoSlides slCCPhotoSlidesWithParentNode:self];
    //    slide_reflections.tag = kPhotoSliderReflectionTag;
    //    slide_reflections.dataSource = self;
    //    slide_reflections.delegate = self;
    //        
    //    slide_reflections.position = ccp(screenSize.width*0.5f, screenSize.height*0.5 - 240.0 - 20.0);
    //    slide_reflections.fixedSize = CGSizeMake(640.0, 40.0);
    //    [slide_reflections show];
    
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


-(CCSprite *) makeNewReflectedSpriteWithImageNamed:(NSString *)imageName {
    
    CCImageReflector *reflector = [[[CCImageReflector alloc] init] autorelease];
    
    CCSprite *s = [self makeNewSpriteWithImageNamed:imageName];
    
    if (s != nil)
        return [reflector drawSpriteReflection:s withHeight:40.0];
    else 
        return nil;
    
}

-(CCSprite *) makeNewSpriteWithSavedImageNamed:(NSString *)imageName {
    CCSprite *s = nil;
    
    debugLog(@"Make new Sprite %@",imageName);
    // try to see if there's a cache hit b4 doing "disk I/O"
    CCTexture2D *t = [[CCTextureCache sharedTextureCache] textureForKey:imageName];
    if (t != nil) {
        
            debugLog(@"texture is in cache");
        s = [CCSprite spriteWithTexture:t];
        //[plsWaitIndicator stopAnimating];
    }
    else {
        
                    debugLog(@"texture not in cache");
        NSData *imageData = [self retrieveImageDataFromDoc:imageName];
                    debugLog(@"got image data");
        
        if (imageData != nil) {
            
                        debugLog(@"data is not null");
            UIImage *image = [UIImage imageWithData:imageData];
            
              debugLog(@"add to CGImage");
            [[CCTextureCache sharedTextureCache] addCGImage:[image CGImage] forKey:imageName];
                                    debugLog(@"create the sprint from CGImage");
            s = [CCSprite spriteWithCGImage:image.CGImage key:imageName];
            
            // whats the dim?
            //            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            //            NSString *dims = [defaults objectForKey:imageName];            
            
            //            if (dims != nil) {
            //                NSArray *size = [dims componentsSeparatedByString:@","];
            //                [s setTextureRect:CGRectMake(0, 0, [[size objectAtIndex:0] floatValue], [[size objectAtIndex:1] floatValue])];
            //            }
            
           // CGSize size = [self retrieveImageSizeFromDoc:imageName];
            //[s setTextureRect:CGRectMake(0, 0, size.width, size.height)];
            
            
           [self resizeTo:s toSize:CGSizeMake(640, 480)];
           // [plsWaitIndicator stopAnimating];
            
        }
        else {
            s = [self makeNewSpriteWithImageNamed:@"PhotoSlidesPleaseWait.png"];
            //[plsWaitIndicator startAnimating];
        }
    }
    
    return s;
}



-(CCSprite *) makeNewReflectedSpriteWithSavedImageNamed:(NSString *)imageName {
    
    CCImageReflector *reflector = [[[CCImageReflector alloc] init] autorelease];
    
    CCSprite *s = [self makeNewSpriteWithSavedImageNamed:imageName];
    
    if (s != nil)
        return [reflector drawSpriteReflection:s withHeight:40];
    else 
        return nil;
    
}

-(void) replaceSpriteTextureForSprite:(CCSprite *) sprite withSavedImageNamed:(NSString *)imageName {
    
    // try to see if there's a cache hit b4 doing disk i/o
    CCTexture2D *t = [[CCTextureCache sharedTextureCache] textureForKey:imageName];
    if (t != nil) {
        [sprite setTexture:t];
        //[plsWaitIndicator stopAnimating];
        
        // whats the dim?
        //        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //        NSString *dims = [defaults objectForKey:imageName];
        //        
        //        if (dims != nil) {
        //            NSArray *size = [dims componentsSeparatedByString:@","];
        //            [sprite setTextureRect:CGRectMake(0, 0, [[size objectAtIndex:0] floatValue], [[size objectAtIndex:1] floatValue])];
        //        }
        
        CGSize size = [self retrieveImageSizeFromDoc:imageName];
        [sprite setTextureRect:CGRectMake(0, 0, size.width, size.height)];
    }
    else {
        NSData *imageData = [self retrieveImageDataFromDoc:imageName];
        
        if (imageData != nil) {
            UIImage *image = [UIImage imageWithData:imageData];
            [[CCTextureCache sharedTextureCache] addCGImage:[image CGImage] forKey:imageName];
            [sprite setTexture:[[CCTextureCache sharedTextureCache] textureForKey:imageName]];
            [sprite setTextureRect:CGRectMake(0, 0, image.size.width, image.size.height)];
            
            //[plsWaitIndicator stopAnimating];
        }
        else {
            [self replaceSpriteTextureForSprite:sprite withTextureCacheKey:@"PhotoSlidesPleaseWait.png"];
            
            //[plsWaitIndicator startAnimating];
        }
    }
}

-(void) replaceReflectedSpriteTextureForSprite:(CCSprite *)sprite withSavedImageNamed:(NSString *)imageName {
    
    CCImageReflector *reflector = [[CCImageReflector alloc] init];
    
    // try to see if there's a cache hit b4 doing disk i/o
    CCTexture2D *t = [[CCTextureCache sharedTextureCache] textureForKey:imageName];
    if (t != nil) {
        CGSize size = [self retrieveImageSizeFromDoc:imageName];
        CCSprite *s = [CCSprite spriteWithTexture:t rect:CGRectMake(0, 0, size.width, size.height)];
        CCSprite *rS = [reflector drawSpriteReflection:s withHeight:40];
        [sprite setTexture:[rS texture]];
        [sprite setTextureRect:CGRectMake(0, 0, size.width, 40.0)];
        
    }
    else {
        NSData *imageData = [self retrieveImageDataFromDoc:imageName];
        
        if (imageData != nil) {
            UIImage *image = [UIImage imageWithData:imageData];
            [[CCTextureCache sharedTextureCache] addCGImage:[image CGImage] forKey:imageName];
            
            CCSprite *s = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] textureForKey:imageName]];
            CCSprite *rS = [reflector drawSpriteReflection:s withHeight:40];
            
            [sprite setTexture:[rS texture]];
            [sprite setTextureRect:CGRectMake(0, 0, image.size.width, 40)];
        }
        else
            [self replaceReflectedSpriteTextureForSprite:sprite withTextureCacheKey:@"PhotoSlidesPleaseWait.png"];
        
        
    }
    
    
    [reflector release];
}

-(void) replaceSpriteTextureForSprite:(CCSprite *)sprite withTextureCacheKey:(NSString *)key {
    CCTexture2D *t = [[CCTextureCache sharedTextureCache] textureForKey:key];
    
    if (t != nil) {
        [sprite setTexture:t];
        if ([key isEqualToString:@"PhotoSlidesPleaseWait.png"]) {
            [sprite setTextureRect:CGRectMake(0, 0, 640.0, 360)];
        }
    }
}

-(void) replaceReflectedSpriteTextureForSprite:(CCSprite *)sprite withTextureCacheKey:(NSString *)key {
    CCImageReflector *reflector = [[CCImageReflector alloc] init];
    
    CCTexture2D *t = [[CCTextureCache sharedTextureCache] textureForKey:key];
    if (t != nil) {
        CCSprite *cs = [CCSprite spriteWithTexture:t];
        CCSprite *rS = [reflector drawSpriteReflection:cs withHeight:40];
        [sprite setTexture:[rS texture]];
    }
    
    [reflector release];
}

-(CCLabelTTF *) makeNewLabelWithText:(NSString*) text {
    CCLabelTTF *l = [CCLabelTTF labelWithString:text fontName:@"Marker Felt" fontSize:24];
    l.color = ccc3(1.0, 1.0, 1.0);
    return l;
}

-(void) replaceLabel:(CCLabelTTF *)label withText:(NSString *)text {
    label.string = text;
}

#pragma mark - SLCCPhotoSlidesDataSource
-(NSInteger)sLCCPhotoSlides:(SLCCPhotoSlides *)sLCCPhotoSlides numberOfObjectsInSection:(NSInteger)section {
    
        // adjust the page control to reflect the known number of images
        
        debugLog(@"Num of Images in Slider .... %d",numOfImages);
        
        SLCCUIPageControl *pageCtrl = (SLCCUIPageControl *) [self getChildByTag:kPhotoPageControlTag];
        pageCtrl.numberOfPages = numOfImages;
        
        return numOfImages;
   
    
}

-(id) sLCCPhotoSlides:(SLCCPhotoSlides *)sLCCPhotoSlides objectforIndex:(NSInteger)index {
    
    
    
    
    CCLOG(@"objectforIndex %d",index);
    
    
       NSString *photoId = [photoIdArray objectAtIndex:index]; // CCLOG(@"photoId = %@", photoId);
 
    if (index == 0 && !firstDescriptioNotShow)
    {
    
        firstDescriptioNotShow = true;
        [self onScroll:0];

    }

    
    if (sLCCPhotoSlides == slides) {
        
        CCLOG(@"show photo for index %d",index);
        
    
        
        
        
        CCLOG(@"imageKey = %@", photoId);
        
        CCSprite *imageVisible = nil;        
        
        if (photoId != nil) {
            

            NSString *filename = [NSString stringWithFormat:@"%@.jpg", photoId];
            
              CCLOG(@"Image key found %@",filename);
            
            imageVisible = (CCSprite*)[sLCCPhotoSlides dequeueReusableObject];
            if (imageVisible == nil) {
                
                debugLog(@"Image not visible");
                imageVisible = [self makeNewSpriteWithSavedImageNamed:filename];
            }
            else {
                debugLog(@"Image visible, replace");
                [self replaceSpriteTextureForSprite:imageVisible withSavedImageNamed:filename];
            }
            
            
            
            
            
            
            
            
            
            
            
            
            /*
             // try to download image on the current slide
             if (![self saveImageFoundInDoc:filename]) {
             SLImageDownloader *imgDownloader = [[SLImageDownloader alloc] init];
             imgDownloader.imageURL = [self.urlArray objectAtIndex:index];
             imgDownloader.photoId = photoId;
             [imgDownloader loadImage];
             [imgDownloader release];
             }
             */
        }
        else {
            
            CCLOG(@"Image key noe found, show wait image");
            imageVisible = (CCSprite*)[sLCCPhotoSlides dequeueReusableObject];
            if (imageVisible == nil) 
                imageVisible = [self makeNewSpriteWithImageNamed:@"PhotoSlidesPleaseWait.png"];
            else 
                [self replaceSpriteTextureForSprite:imageVisible withTextureCacheKey:@"PhotoSlidesPleaseWait.png"];
            
            //[plsWaitIndicator startAnimating];
        }
        
        //    CCLOG(@"ImageVisible.size = %f, %f", imageVisible.contentSize.width, imageVisible.contentSize.height);
        
        
      
        
        return imageVisible;
    }
    else {
        
        // For reflection
        NSString *imageKey = [self.urlArray objectAtIndex:index];
        NSString *photoId = [photoIdArray objectAtIndex:index];
        
        CCSprite *reflectedImageVisible = nil;
        
        if (imageKey != nil) {
            reflectedImageVisible = (CCSprite*) [sLCCPhotoSlides dequeueReusableObject];
            if (reflectedImageVisible == nil) {
                reflectedImageVisible = [self makeNewReflectedSpriteWithSavedImageNamed:[NSString stringWithFormat:@"%@.jpg", photoId]];
            }
            else {
                [self replaceReflectedSpriteTextureForSprite:reflectedImageVisible withSavedImageNamed:[NSString stringWithFormat:@"%@.jpg", photoId]];
            }
        }
        else {
            reflectedImageVisible = (CCSprite *)[sLCCPhotoSlides dequeueReusableObject];
            if (reflectedImageVisible == nil) 
                reflectedImageVisible = [self makeNewReflectedSpriteWithImageNamed:@"PhotoSlidesPleaseWait.png"];
            else 
                [self replaceReflectedSpriteTextureForSprite:reflectedImageVisible withTextureCacheKey:@"PhotoSlidesPleaseWait.png"];
            
        }
        
        return reflectedImageVisible;
        
    }
    
    
    
}

#pragma mark - SLCCPhotoSlidesDelegate
-(void) sLCCPhotoSlides:(SLCCPhotoSlides *)sLCCPhotoSlides didScrollToCurrentIndex:(int)index {
    
    CCLOG(@"did sroll to %d",index);
    [self onScroll:index];
}


-(void) onScroll :(int) index
{
    
        //    CCLOG(@"slider current index = %d", index);
        NSString *photoId = [photoIdArray objectAtIndex:index];
        
        
        
        GalleryManager *gm = [GalleryManager getInstance];
        Gallery *gallery = [gm getGalleryFromCache:galleryId];
        GalleryItem *item = [gallery.itemMap objectForKey:photoId];
        
        NSString *title = item.description;
        NSString *username = item.attribution;
        
        CCLOG(@"title = %@", title);
        CCLOG(@"username = %@", username);
        
        
        
        CCLabelTTF *attribution = (CCLabelTTF*)[self getChildByTag:kPhotoAttributionTag];
        attribution.string = [NSString stringWithFormat:@"Photo by %@", username];
        attribution.scale = 0.0;
        [attribution runAction:[CCScaleTo actionWithDuration:0.4 scale:1.0]];
        
        CCLabelTTF *titleLabel = (CCLabelTTF*)[self getChildByTag:kPhotoTitleTag];
        titleLabel.string = title;
        titleLabel.scale = 0.0;
        [titleLabel runAction:[CCScaleTo actionWithDuration:0.4 scale:1.0]];
        
        // adjust the page control 
        SLCCUIPageControl *pageCtrl = (SLCCUIPageControl *) [self getChildByTag:kPhotoPageControlTag];
        pageCtrl.currentPage = index;

}

#pragma mark - Image File I/O helpers

-(BOOL)saveImageFoundInDoc:(NSString*)imageName {
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString* imgFilePath = [NSString stringWithFormat:@"%@/%@", documentsPath, imageName];
    //    CCLOG(@"imgFilePath = %@", imgFilePath);
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:imgFilePath])
        return YES;
    else 
        return NO;
}

-(void)saveImageDataToDoc:(NSData*)data withImageName:(NSString*)imageName {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", docDir, imageName];
    [data writeToFile:filePath atomically:YES];
}

-(NSData *)retrieveImageDataFromDoc:(NSString*)imageName {
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", docDir, imageName];
    
    debugLog(@"File image %@",filePath);
    return [NSData dataWithContentsOfFile:filePath];
}

-(void) savePhotoIdArrayToDoc:(NSArray*)aPhotoIdArray withGalleryId:(NSString*)galleryId {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/imageInfo.plist", docDir];
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    
    if (info != nil) {
        
        [info setObject:aPhotoIdArray forKey:galleryId];
        [info writeToFile:filePath atomically:YES];
        [info release];
    }
    else {
        info = [NSDictionary dictionaryWithObject:aPhotoIdArray forKey:galleryId];
        [info writeToFile:filePath atomically:YES];
    }
    
}

-(NSArray*) retrievePhotoIdArrayFromDoc:(NSString*)galleryId {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/imageInfo.plist", docDir];
    
    NSDictionary *info = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    
    return [info objectForKey:galleryId];
}

-(void) deletePhotoFromOldSet:(NSSet *)lastPhotoSet withNewSet:(NSSet *)newPhotoSet {
    
    // we need to delete photos thats no longer in the gallery
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError *err;
    
    for (NSString *photo in lastPhotoSet) {
        if (![newPhotoSet containsObject:photo]) {
            NSString *filename = [NSString stringWithFormat:@"%@/%@.jpg", docDir, photo];
            if (![fileMgr removeItemAtPath:filename error:&err]) 
                CCLOG(@"Unable to delete file: %@", [err localizedDescription]);
            
        }
    }
}

-(void) saveImageSizeToDoc:(CGSize)size withImageName:(NSString*)imageName {
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/imageInfo.plist", docDir];
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    
    NSString *dim = [NSString stringWithFormat:@"%.2f,%.2f", size.width, size.height];
    
    if (info != nil) {
        [info setObject:dim forKey:imageName];
        [info writeToFile:filePath atomically:YES];
        [info release];
    }
    else {
        info = [NSDictionary dictionaryWithObject:dim forKey:imageName];
        [info writeToFile:filePath atomically:YES];
    }
    
}

-(CGSize) retrieveImageSizeFromDoc:(NSString*)imageName {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/imageInfo.plist", docDir];
    
    NSDictionary *info = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    
    NSString *s = [info objectForKey:imageName];
    
    if (s != nil) {
        NSArray *size = [s componentsSeparatedByString:@","];
        float width = [[size objectAtIndex:0] floatValue];
        float height = [[size objectAtIndex:1] floatValue];
        
        [info release];
        return CGSizeMake(width, height);
    }
    else {
        [info release];
        return CGSizeMake(640.0, 480.0);
    }
    
}

#pragma mark - SLImageGalleryDownloaderDelegate
-(void)slImageGalleryDownloaderDidFinish:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    
    NSString *galleryId = [userInfo objectForKey:@"galleryId"];
    NSArray *photoIds = [userInfo objectForKey:@"photoIDs"];
    NSArray *imageURLs = [userInfo objectForKey:@"imageURLs"];
    self.bigImageURLs = [userInfo objectForKey:@"bigImageURLs"];
    
    NSError *error = [userInfo objectForKey:@"error"];
    
    if (error == nil) {
        
        numOfImages = [imageURLs count];
        
        // Retrieve photo id arrays from doc plist
        NSArray *lastPhotoIdArray = [self retrievePhotoIdArrayFromDoc:galleryId];
        NSSet *lastPhotoSet = [NSSet setWithArray:lastPhotoIdArray];
        NSSet *newPhotoSet = [NSSet setWithArray:photoIds];
        
        [self deletePhotoFromOldSet:lastPhotoSet withNewSet:newPhotoSet];
        
        // Store gallery photo id in imageInfo.plist
        [self savePhotoIdArrayToDoc:photoIds withGalleryId:galleryId];
        
        if (numOfImages > 0) {
            
            if (url2IndexMap == nil)
                url2IndexMap = [[NSMutableDictionary alloc] initWithCapacity:10];
            
            int count = 0;
            for (NSString *imgURL in imageURLs) {
                
                [self.urlArray addObject:imgURL];
                [url2IndexMap setObject:[NSNumber numberWithInt:count] forKey:imgURL];
                
                count++;
            }
            
            if (photoIdArray == nil)
                photoIdArray = [[NSMutableArray alloc] initWithCapacity:10];
            if (photoInfo == nil)
                photoInfo = [[NSMutableDictionary alloc] initWithCapacity:10];
            if (photoId2IndexMap == nil)
                photoId2IndexMap = [[NSMutableDictionary alloc] initWithCapacity:10];
            
            int k = 0;
            for (NSString *photoId in photoIds) {
                [photoIdArray addObject:photoId];
                
                //                SLImageInfoDownloader *infoDL = [[SLImageInfoDownloader alloc] init];
                //                infoDL.photoId = photoId;
                //                //            infoDL.delegate = self;
                //                [infoDL fetchInfo];
                //                [infoDL release];
                
                [photoId2IndexMap setObject:[NSNumber numberWithInt:k] forKey:photoId];
                
                k++;
            }
            
        }
        
        numOfImagesKnown = YES;
        
        // If we know the number of images, reset the slide and re-display it 
        // If we know the number of images, reset the slide and re-display it 
        if (numOfImages > 0) {
            [slides reset];
            [slides show];
        }
        else {
            // handle zero image
            [slides reset];
            
            // remove title and attribution
            CCLabelTTF *attribution = (CCLabelTTF*)[self getChildByTag:kPhotoAttributionTag];
            [attribution removeFromParentAndCleanup:YES];
            
            CCLabelTTF *titleLabel = (CCLabelTTF*)[self getChildByTag:kPhotoTitleTag];
            [titleLabel removeFromParentAndCleanup:YES];
            
            SLCCUIPageControl *p = (SLCCUIPageControl*)[self getChildByTag:kPhotoPageControlTag];
            [p removeFromParentAndCleanup:YES];
        }
        
        //        [slide_reflections reset];
        //        [slide_reflections show];
        
    }
    else {
        // handle network error
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Please check your WiFi or cellular data network and try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
    }
    
}

#pragma mark - SLImageDownloaderDelegate

-(void) slImageDownloaderDidFinish:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    
    NSString *sizeType = [userInfo objectForKey:@"sizeType"];
    
    if ([sizeType isEqualToString:@"huge"]) {    // Perform in background queue (thread)
        dispatch_async(backgroundQueue, ^{
            NSString *photoId = [userInfo objectForKey:@"photoId"];
            NSData *data = [userInfo objectForKey:@"data"];
            UIImage *image = [UIImage imageWithData:data];
            //            NSString *key = [userInfo objectForKey:@"imageURL"];
            
            NSString *imgFileName = [NSString stringWithFormat:@"%@.jpg", photoId];
            [self saveImageDataToDoc:data withImageName:imgFileName];
            
            //            [[CCTextureCache sharedTextureCache] addCGImage:[image CGImage] forKey:imgFileName];
            [self saveImageSizeToDoc:image.size withImageName:imgFileName];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self replaceBigCurrentImage];
            });
        });
    }
    else {
        dispatch_async(backgroundQueue, ^{
            NSString *photoId = [userInfo objectForKey:@"photoId"];
            NSData *data = [userInfo objectForKey:@"data"];
            
            UIImage *image = [UIImage imageWithData:data];
            NSString *key = [userInfo objectForKey:@"imageURL"];
            
            NSString *imgFileName = [NSString stringWithFormat:@"%@.jpg", photoId];
            [self saveImageDataToDoc:data withImageName:imgFileName];
            
            //            [[CCTextureCache sharedTextureCache] addCGImage:[image CGImage] forKey:imgFileName];
            
            [self saveImageSizeToDoc:image.size withImageName:imgFileName];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[CCTextureCache sharedTextureCache] addCGImage:[image CGImage] forKey:imgFileName];
                
                NSNumber *indexNumber = [url2IndexMap objectForKey:key];
                
                if (indexNumber != nil) {
                    int index = [indexNumber intValue];
                    // CCLOG(@"syncing index = %d", index);
                    
                    if (index == slides.cursorVisible || index == slides.cursorVisible - 1 || index == slides.cursorVisible + 1) {
                        
                        [slides syncWithIndex:index];
                        //        [slide_reflections syncWithIndex:index];
                        
                        if (index-1 >= 0) {
                            [slides syncWithIndex:index-1];
                            //            [slide_reflections syncWithIndex:index-1];
                        }
                        
                        if (index+1 < numOfImages) {
                            [slides syncWithIndex:index+1];
                            //            [slide_reflections syncWithIndex:index+1];
                        }
                    }
                }
            });
            
        });
    }
}

#pragma mark - SLImageInfoDownloaderDelegate
-(void) slImageInfoDownloaderDidFinish:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSString *photoId = [userInfo objectForKey:@"photoId"];
    NSDictionary *info = [userInfo objectForKey:@"info"];
    
    [photoInfo setObject:info forKey:photoId];
    
    NSNumber *indexNumber = [photoId2IndexMap objectForKey:photoId];
    
    if (indexNumber != nil) {
        int index = [indexNumber intValue];
        
        if (index == slides.cursorVisible) {
            NSString *title = [[info objectForKey:@"title"] objectForKey:@"_content"];
            NSString *username = [[info objectForKey:@"owner"] objectForKey:@"username"];
            
            CCLOG(@"title = %@", title);
            CCLOG(@"username = %@", username);
            
            CCLabelTTF *attribution = (CCLabelTTF*)[self getChildByTag:kPhotoAttributionTag];
            attribution.string = [NSString stringWithFormat:@"Photo by %@", username];
            attribution.scale = 0.0;
            [attribution runAction:[CCScaleTo actionWithDuration:0.4 scale:1.0]];
            
            CCLabelTTF *titleLabel = (CCLabelTTF*)[self getChildByTag:kPhotoTitleTag];
            titleLabel.string = title;
            titleLabel.scale = 0.0;
            [titleLabel runAction:[CCScaleTo actionWithDuration:0.4 scale:1.0]];
        }
    }
    
    //    if (slides.cursorVisible == [[photoId2IndexMap objectForKey:photoId] intValue]) {
    //        NSString *title = [[info objectForKey:@"title"] objectForKey:@"_content"];
    //        NSString *username = [[info objectForKey:@"owner"] objectForKey:@"username"];
    //
    //        CCLOG(@"title = %@", title);
    //        CCLOG(@"username = %@", username);
    //        
    //        CCLabelTTF *attribution = (CCLabelTTF*)[self getChildByTag:kPhotoAttributionTag];
    ////        attribution.string = username;
    //        attribution.string = [NSString stringWithFormat:@"Photo by %@", username];
    //        attribution.scale = 0.0;
    //        [attribution runAction:[CCScaleTo actionWithDuration:0.4 scale:1.0]];
    //        
    //        CCLabelTTF *titleLabel = (CCLabelTTF*)[self getChildByTag:kPhotoTitleTag];
    //        titleLabel.string = title;
    //        titleLabel.scale = 0.0;
    //        [titleLabel runAction:[CCScaleTo actionWithDuration:0.4 scale:1.0]];
    //    }
    
}


#pragma mark - Zoom In/Out
-(void) handleSwipePhoto:(UISwipeGestureRecognizer *) gesture {
    
    CCLOG(@"Swipe");
    
    [self zoomOutCurrentImage];
}

-(void) replaceBigCurrentImage {
    
    if (zoomed) {
        NSString *imageName = [NSString stringWithFormat:@"%@.jpg", [photoIdArray objectAtIndex:slides.cursorVisible]];
        
        CCSprite *bigImage = (CCSprite *) [self getChildByTag:kPhotoBigImageTag];
        if (bigImage != nil) {
            [self replaceSpriteTextureForSprite:bigImage withSavedImageNamed:imageName];
        }
        
        CGSize size = bigImage.contentSize;
        float scaleX = screenSize.width / size.width;
        float scaleY = screenSize.height / size.height;
        
        float scale = MIN(scaleX, scaleY);
        
        bigImage.scale = scale;
        
    }
}

-(void) zoomInCurrentImage {
    zoomed = YES;
    
    NSString *imageName = [NSString stringWithFormat:@"%@.jpg", [photoIdArray objectAtIndex:slides.cursorVisible]];
    
    if (![self saveImageFoundInDoc:imageName]) {
        SLImageDownloader *bigImgDownloader = [[SLImageDownloader alloc] init];
        bigImgDownloader.imageURL = [self.bigImageURLs objectAtIndex:slides.cursorVisible];
        bigImgDownloader.photoId = [photoIdArray objectAtIndex:slides.cursorVisible];
        bigImgDownloader.huge = YES;
        [bigImgDownloader loadImage];
    }
    
    CCSprite *bigImage = [self makeNewSpriteWithSavedImageNamed:imageName];
    bigImage.position = ccp(screenSize.width*0.5, screenSize.height*0.5);
    bigImage.tag = kPhotoBigImageTag;
    [self addChild:bigImage];
    
    bigImage.scale = 0.6;
    
    CGSize size = bigImage.contentSize;
    float scaleX = screenSize.width / size.width;
    float scaleY = screenSize.height / size.height;
    
    float scale = MIN(scaleX, scaleY);
    
    [bigImage runAction:[CCScaleTo actionWithDuration:0.4 scale:scale]];
    
    //    CCLOG(@"big image size = %.2f, %.2f", size.width, size.height);
    
    // hide page control
    SLCCUIPageControl *pgCtrl = (SLCCUIPageControl*)[self getChildByTag:kPhotoPageControlTag];
    pgCtrl.hidden = YES;
    
    // freeze the slide
    slides.frozen = YES;
    
    // dim the icons, attribution, title, etc.
    CCMenuItemImage *backButton = (CCMenuItemImage *) [self getChildByTag:kPhotoBackButtonTag];
    backButton.opacity = 150;
    
    CCLabelTTF *attrib = (CCLabelTTF *) [self getChildByTag:kPhotoAttributionTag];
    attrib.opacity = 75;
    
    CCLabelTTF *title = (CCLabelTTF *) [self getChildByTag:kPhotoTitleTag];
    title.opacity = 75;
    
    CCSprite *mainTitle = (CCSprite *) [self getChildByTag:kPhotoMainTitleTag];
    mainTitle.opacity = 75;
    
    // add Swipe gesture recognizer
    swipeGestureRecognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipePhoto:)] autorelease];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft;
    
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:swipeGestureRecognizer];
    
}

-(void) zoomOutCurrentImage {
    zoomed = NO;
    
    CCSprite *bigImage = (CCSprite*) [self getChildByTag:kPhotoBigImageTag];
    
    CCFiniteTimeAction *spawnActions = [CCSpawn actions:[CCScaleTo actionWithDuration:0.4 scale:0.6],
                                        [CCFadeOut actionWithDuration:0.4], nil];
    
    CCFiniteTimeAction *killAction = [CCCallBlock actionWithBlock:^{
        [bigImage removeFromParentAndCleanup:YES];
    }];
    
    [bigImage runAction:[CCSequence actions:spawnActions, killAction, nil]];
    
    // unhide page control 
    SLCCUIPageControl *pgCtrl = (SLCCUIPageControl*)[self getChildByTag:kPhotoPageControlTag];
    pgCtrl.hidden = NO;
    
    // unfreeze the slide
    slides.frozen = NO;
    
    // undim the icons, attribution, title, etc.
    CCMenuItemImage *backButton = (CCMenuItemImage *) [self getChildByTag:kPhotoBackButtonTag];
    backButton.opacity = 255;
    
    CCLabelTTF *attrib = (CCLabelTTF *) [self getChildByTag:kPhotoAttributionTag];
    attrib.opacity = 255;
    
    CCLabelTTF *title = (CCLabelTTF *) [self getChildByTag:kPhotoTitleTag];
    title.opacity = 255;
    
    CCSprite *mainTitle = (CCSprite *) [self getChildByTag:kPhotoMainTitleTag];
    mainTitle.opacity = 255;
    
    // remove swipe gesture
    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:swipeGestureRecognizer];
}

#pragma mark - Multi-touches
-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    panned_completed = NO;
    
    NSSet *allTouches = [event allTouches];
    
    UITouch *touch1, *touch2;
    
    switch ([allTouches count]) {
        case 1:
            break;
        case 2:
            //            CCLOG(@"Multi touch");
            
            touch1 = [[allTouches allObjects] objectAtIndex:0];
            touch2 = [[allTouches allObjects] objectAtIndex:1];
            
            CGPoint location1 = [touch1 locationInView:[touch1 view]];
            CGPoint loc1 = [[CCDirector sharedDirector] convertToGL:location1];
            
            CGPoint location2 = [touch2 locationInView:[touch2 view]];
            CGPoint loc2 = [[CCDirector sharedDirector] convertToGL:location2];
            
            //            CCLOG(@"(%f, %f) and (%f, %f)", loc1.x, loc1.y, loc2.x, loc2.y);
            sq_start_distance = (loc1.x - loc2.x)*(loc1.x - loc2.x) + (loc1.y - loc2.y)*(loc1.y - loc2.y);
            
            break;
        default:
            CCLOG(@"%d touches", [allTouches count]);
            break;
    }
    
}

-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSSet *allTouches = [event allTouches];
    
    UITouch *touch1, *touch2;
    
    switch ([allTouches count]) {
        case 1:
            break;
        case 2:
            //            CCLOG(@"Multi touch");
            
            if (!panned_completed) {
                touch1 = [[allTouches allObjects] objectAtIndex:0];
                touch2 = [[allTouches allObjects] objectAtIndex:1];
                
                CGPoint location1 = [touch1 locationInView:[touch1 view]];
                CGPoint loc1 = [[CCDirector sharedDirector] convertToGL:location1];
                
                CGPoint location2 = [touch2 locationInView:[touch2 view]];
                CGPoint loc2 = [[CCDirector sharedDirector] convertToGL:location2];
                
                float d = (loc1.x - loc2.x)*(loc1.x - loc2.x) + (loc1.y - loc2.y)*(loc1.y - loc2.y);
                if (d - sq_start_distance > 10000) {
                    CCLOG(@"current photo id = %@", [photoIdArray objectAtIndex:slides.cursorVisible]);
                    NSString *imageName = [NSString stringWithFormat:@"%@.jpg", [photoIdArray objectAtIndex:slides.cursorVisible]];
                    CCSprite *bigImage = [self makeNewSpriteWithSavedImageNamed:imageName];
                    bigImage.position = ccp(screenSize.width*0.5, screenSize.height*0.5);
                    bigImage.scale = 0.5;
                    [self addChild:bigImage];
                    
                    [bigImage runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
                }
                panned_completed = YES;
            }
            break;
        default:
            //            CCLOG(@"%d touches", [allTouches count]);
            break;
    }
    
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSSet *allTouches = [event allTouches];
    
    UITouch *touch1, *touch2;
    
    switch ([allTouches count]) {
        case 1:
            break;
        case 2:
            //            CCLOG(@"Multi touch");
            
            if (!panned_completed) {
                touch1 = [[allTouches allObjects] objectAtIndex:0];
                touch2 = [[allTouches allObjects] objectAtIndex:1];
                
                CGPoint location1 = [touch1 locationInView:[touch1 view]];
                CGPoint loc1 = [[CCDirector sharedDirector] convertToGL:location1];
                
                CGPoint location2 = [touch2 locationInView:[touch2 view]];
                CGPoint loc2 = [[CCDirector sharedDirector] convertToGL:location2];
                
                float d = (loc1.x - loc2.x)*(loc1.x - loc2.x) + (loc1.y - loc2.y)*(loc1.y - loc2.y);
                if (d - sq_start_distance > 10000) {
                    CCLOG(@"current photo id = %@", [photoIdArray objectAtIndex:slides.cursorVisible]);
                    NSString *imageName = [NSString stringWithFormat:@"%@.jpg", [photoIdArray objectAtIndex:slides.cursorVisible]];
                    CCSprite *bigImage = [self makeNewSpriteWithSavedImageNamed:imageName];
                    bigImage.position = ccp(screenSize.width*0.5, screenSize.height*0.5);
                    bigImage.scale = 0.5;
                    [self addChild:bigImage];
                    
                    [bigImage runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
                }
                panned_completed = YES;
            }
            
            break;
        default:
            CCLOG(@"%d touches", [allTouches count]);
            break;
    }
    
}

-(void)handlePinchPhoto:(UIPinchGestureRecognizer *)gesture {
    //    CCLOG(@"Pinched");
    
    CGPoint loc = [gesture locationInView:[CCDirector sharedDirector].openGLView];
    CGPoint gl_loc = [[CCDirector sharedDirector] convertToGL:loc];
    
    CGRect bound = CGRectMake((screenSize.width-640)*0.5, (screenSize.height-480)*0.5, 640.0, 480.0);
    
    if (CGRectContainsPoint(bound, gl_loc)) {
        //        CCLOG(@"loc = %.f, %.f", loc1.x, loc1.y);
        //        CCLOG(@"scale = %.4f", gesture.scale);
        //        CCLOG(@"current photo id = %@", [photoIdArray objectAtIndex:slides.cursorVisible]);
        if (!zoomed && gesture.scale > 1.0) {
            [self zoomInCurrentImage];
        }
        else if (zoomed && gesture.scale < 1.0) {
            [self zoomOutCurrentImage];
        }
    }
    
}



-(void)setupPhotosForDisplay{
    
    debugLog(@"in setupPhotosForDisplay");
    
    galleryId = [self.topicInfo objectForKey:@"gallery_id"];
    
    CCLOG(@"setup photos for display %@",galleryId);    
    
    
    // Retrieve photo id arrays from doc plist
   // NSArray *lastPhotoIdArray = [self retrievePhotoIdArrayFromDoc:galleryId];
    
    NSString *galleryName = [NSString stringWithFormat:@"%@-photo-%@",galleryId,GALLERY_TAG_PHOTO_GALLERY];
    
    debugLog(@"lookup photos for gallery %@",galleryName);
    
    GalleryManager *gman = [GalleryManager getInstance];
    NSArray *galleryItems = [gman getGalleryFromCache:galleryName].items;
    
       
    
    numOfImages = galleryItems.count;
    
    CCLOG(@"Number of Images %d",numOfImages);
    
    if (numOfImages > 0) {
        
        if (url2IndexMap == nil)
            url2IndexMap = [[NSMutableDictionary alloc] initWithCapacity:10];
        
        int count = 0;
        
        if (photoIdArray == nil)
            photoIdArray = [[NSMutableArray alloc] initWithCapacity:10];
        if (photoInfo == nil)
            photoInfo = [[NSMutableDictionary alloc] initWithCapacity:10];
        if (photoId2IndexMap == nil)
            photoId2IndexMap = [[NSMutableDictionary alloc] initWithCapacity:10];
        
        int k = 0;
        for (GalleryItem *item in galleryItems) {
            [photoIdArray addObject:item.guid];
            
            //                SLImageInfoDownloader *infoDL = [[SLImageInfoDownloader alloc] init];
            //                infoDL.photoId = photoId;
            //                //            infoDL.delegate = self;
            //                [infoDL fetchInfo];
            //                [infoDL release];
            
            [photoId2IndexMap setObject:[NSNumber numberWithInt:k] forKey:item.guid];
            
            k++;
        }
        
    }
    
    
    
    numOfImagesKnown = YES;
    
    // If we know the number of images, reset the slide and re-display it 
    // If we know the number of images, reset the slide and re-display it 
    if (numOfImages > 0) {
        [slides reset];
        [slides show];
    }
    else {
        // handle zero image
        [slides reset];
        
        // remove title and attribution
        CCLabelTTF *attribution = (CCLabelTTF*)[self getChildByTag:kPhotoAttributionTag];
        [attribution removeFromParentAndCleanup:YES];
        
        CCLabelTTF *titleLabel = (CCLabelTTF*)[self getChildByTag:kPhotoTitleTag];
        [titleLabel removeFromParentAndCleanup:YES];
        
        SLCCUIPageControl *p = (SLCCUIPageControl*)[self getChildByTag:kPhotoPageControlTag];
        [p removeFromParentAndCleanup:YES];
    }
    
    //        [slide_reflections reset];
    //        [slide_reflections show];
    
}





-(void)resizeTo:(CCSprite*) sprite toSize:(CGSize) theSize
{
    
    CCLOG(@"Resize the sprite, the displayed photo");
    CGFloat newWidth = theSize.width;
    CGFloat newHeight = theSize.height;
    
    
    float startWidth = sprite.contentSize.width;
    float startHeight = sprite.contentSize.height;
    
    CCLOG(@"%f %f content width and height",startWidth,startHeight);
    
    float newScaleX = newWidth/startWidth;
    float newScaleY = newHeight/startHeight;
    
    CCLOG(@"%f %f scale width and height",newScaleX,newScaleY);
    
    sprite.scaleX = newScaleX;
    sprite.scaleY = newScaleY;
    
}

@end

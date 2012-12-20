//
//  TestPhotoSlidersFromFlickr.m
//  LifeCycle
//
//  Created by Kelvin Chan on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestLayerPhotoSlidersFromFlickr.h"
#import "FlowAndStateManager.h"

@interface TestLayerPhotoSlidersFromFlickr (Private)
//-(void) loadImage;
-(void) replaceSpriteTextureForSprite:(CCSprite *)sprite withTextureCacheKey:(NSString*) key;

@end

@implementation TestLayerPhotoSlidersFromFlickr

-(void)dealloc {
    CCLOG(@"Deallocating TestLayerPhotoSlidersFromFlickr");
    if (urlArray != nil)
        [urlArray release];
    
    if (url2IndexMap != nil)
        [url2IndexMap release];
    
    if (photoIdArray != nil)
        [photoIdArray release];
    
    if (photoInfo != nil)
        [photoInfo release];
    
    if (photoId2IndexMap != nil)
        [photoId2IndexMap release];
    
    if (imgSetDownloader != nil) {
        [imgSetDownloader cancel];
        [imgSetDownloader release];
    }
    
    if (imgGrpDownloader != nil) {
        [imgGrpDownloader cancel];
        [imgGrpDownloader release];
    }
    
    if (imgGalleryDownloader != nil) {
        [imgGalleryDownloader cancel];
        [imgGalleryDownloader release];
    }
        
    if (slImageDownloaders != nil) {
        [slImageDownloaders release];
    }
    
    [super dealloc];
}

-(void)addMenu {
    CCMenuItemImage *home = [CCMenuItemImage itemFromNormalImage:@"home.png" 
                                                   selectedImage:@"home_bigger.png"
                                                   disabledImage:@"home.png"
                                                          target:self selector:@selector(goHome)];
    home.position = ccp(0.0f, 0.0f);
    home.tag = kTestingPhotoSlidersFlickrHomeButtonTag;
    
    SEL testSelector = @selector(testSLCCPhotoSlidesFromFlickr);
    
    CCMenuItemImage *lab = [CCMenuItemImage itemFromNormalImage:@"test.png"
                                                  selectedImage:@"test_bigger.png"
                                                  disabledImage:@"test.png"
                                                         target:self
                                                       selector:testSelector];
    
    lab.tag = kTestingPhotoSlidersFlickrTestButtonTag;
    
    CCMenu *menu = [CCMenu menuWithItems:home, lab, nil];
        
    menu.position = ccp(0.875f * screenSize.width, 0.9375f * screenSize.height);
    [menu alignItemsHorizontallyWithPadding:20.0f];
    
    [self addChild:menu z:0 tag:kTestingPhotoSlidersFlickrMenuTag];
    
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
        numOfImagesKnown = NO;
        numOfImages = 0;
        
        slImageDownloaders = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    return self;
}

-(void)onEnter {
    [super onEnter];
    
    editModeAbler = [EditModeAbler node];
    [editModeAbler retain];
    editModeAbler.delegateLayer = self;
    
    [editModeAbler activate];
    
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

#pragma mark - Test SLCCPhotoSlides from Flickr
-(void) testSLCCPhotoSlidesFromFlickr {
    slides = [SLCCPhotoSlides slCCPhotoSlidesWithParentNode:self];
    slides.tag = kTestingPhotoSlidersFlickrSliderTag;
    slides.dataSource = self;
    slides.delegate = self;
    slides.position = ccp(screenSize.width*0.5f, screenSize.height*0.5f);
    slides.fixedSize = CGSizeMake(640.0, 480.0);
    [slides show];
    
    CCLabelTTF *attribution = [CCLabelTTF labelWithString:@"Loading..." fontName:@"Marker Felt" fontSize:24.0];
    attribution.position = ccp(screenSize.width*0.5f, screenSize.height*0.1f);
    attribution.tag = kTestingPhotoSlidersFlickrAttributionTag;
    [self addChild:attribution];
    
    
//    CCRenderTexture *fakeWindow = [CCRenderTexture renderTextureWithWidth:640 height:480 pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
//    fakeWindow.position = ccp(screenSize.width*0.5f, screenSize.height*0.5f);
//    [fakeWindow clear:0.5 g:0.5 b:0.5 a:0.7];
//    [self addChild:fakeWindow];
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

-(CCSprite *) makeNewSpriteWithSavedImageNamed:(NSString *)imageName {
    CCSprite *s = nil;

    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", docDir, imageName];
    
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    
    if (imageData != nil) {
        UIImage *image = [UIImage imageWithData:imageData];
        s = [CCSprite spriteWithCGImage:image.CGImage key:imageName];
    }
    else 
        s = [self makeNewSpriteWithImageNamed:@"PhotoSlidesPleaseWait.png"];
    
    return s;
}

-(CCSprite *) makeNewSpriteWithTextureCacheKey:(NSString*) key {
    CCSprite *s = nil;
    
    CCTexture2D *t = [[CCTextureCache sharedTextureCache] textureForKey:key];
    
    if (t != nil) 
        s = [CCSprite spriteWithTexture:t];
    else 
        s = [self makeNewSpriteWithImageNamed:@"PhotoSlidesPleaseWait.png"];
    
    return s;
}

-(void) replaceSpriteTextureForSprite:(CCSprite *) sprite withSavedImageNamed:(NSString *)imageName {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", docDir, imageName];
    
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    
    if (imageData != nil) {
        UIImage *image = [UIImage imageWithData:imageData];
        [[CCTextureCache sharedTextureCache] addCGImage:[image CGImage] forKey:imageName];
        [sprite setTexture:[[CCTextureCache sharedTextureCache] textureForKey:imageName]];
        [sprite setTextureRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    }
    else
        [self replaceSpriteTextureForSprite:sprite withTextureCacheKey:@"PhotoSlidesPleaseWait.png"];
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

-(void) replaceSpriteTextureForSprite:(CCSprite *)sprite withTextureCacheKey:(NSString *)key {
    
    CCTexture2D *t = [[CCTextureCache sharedTextureCache] textureForKey:key];
    CGSize size = sprite.contentSize;
    
    if (t != nil) {
        [sprite setTexture:t];
//        [sprite setTextureRect:CGRectMake(0, 0, size.width, size.height)];
    }
    
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
   
    if (!numOfImagesKnown) {
        // We dont know yet how many photos until we ping flickr
        
        // (1) Ping flickr for the certain photo set id
//        imgSetDownloader = [[SLImageSetDownloader alloc] init];
//        imgSetDownloader.setId = @"72157628892081951";
//        imgSetDownloader.delegate = self;
//        [imgSetDownloader fetchImageURLs];
        
        // (1b) Ping flickr for certain photo group id
//        imgGrpDownloader = [[SLImageGroupDownloader alloc] init];
//        imgGrpDownloader.groupId = @"51035612836@N01";              // PublicJoshuaTree @"1912504@N24"
//        imgGrpDownloader.delegate = self;
//        [imgGrpDownloader fetchImageURLs];
        
        // (1c) Ping flickr for certain photo gallery id
        imgGalleryDownloader = [[SLImageGalleryDownloader alloc] init];
//        imgGalleryDownloader.galleryId = @"74019375-72157629265388018";
        imgGalleryDownloader.galleryId = @"76237694-72157629628927595"; // 74019375-72157629265388018
        imgGalleryDownloader.delegate = self;
        [imgGalleryDownloader fetchImageURLs];
        
        // (2) return 1 for now as a dummy
        return 1;
    } else {
        return numOfImages;
    }
        
}

-(id) sLCCPhotoSlides:(SLCCPhotoSlides *)sLCCPhotoSlides objectforIndex:(NSInteger)index {
    
    // We don't know image data yet, put up a "wait" image
//    NSString *imageName = @"PhotoSlidesPleaseWait.png";
    
    NSString *photoId = [photoIdArray objectAtIndex:index];
    CCLOG(@"photoId = %@", photoId);
    
    NSString *imageKey = [urlArray objectAtIndex:index];
//    CCLOG(@"imageKey = %@", imageKey);
    
    CCSprite *imageVisible = nil;
    
    if (imageKey != nil) {
        imageVisible = (CCSprite*)[sLCCPhotoSlides dequeueReusableObject];
        if (imageVisible == nil) {
//            imageVisible = [self makeNewSpriteWithTextureCacheKey:imageKey];
            imageVisible = [self makeNewSpriteWithSavedImageNamed:[NSString stringWithFormat:@"%@.png", photoId]];
        }
        else {
//            [self replaceSpriteTextureForSprite:imageVisible withTextureCacheKey:imageKey];
            [self replaceSpriteTextureForSprite:imageVisible withSavedImageNamed:[NSString stringWithFormat:@"%@.png", photoId]];
        }
    }
    else {
        imageVisible = (CCSprite*)[sLCCPhotoSlides dequeueReusableObject];
        if (imageVisible == nil)
            imageVisible = [self makeNewSpriteWithImageNamed:@"PhotoSlidesPleaseWait.png"];
        else 
            [self replaceSpriteTextureForSprite:imageVisible withTextureCacheKey:@"PhotoSlidesPleaseWait.png"];
    }
    
//    CCLOG(@"ImageVisible.size = %f, %f", imageVisible.contentSize.width, imageVisible.contentSize.height);
    
    return imageVisible;
    
}

#pragma mark - SLCCPhotoSlidesDelegate
-(void) sLCCPhotoSlides:(SLCCPhotoSlides *)sLCCPhotoSlides didScrollToCurrentIndex:(int)index {
//    CCLOG(@"slider current index = %d", index);
    NSString *photoId = [photoIdArray objectAtIndex:index];
    
    NSDictionary *info = [photoInfo objectForKey:photoId];

    NSString *title = nil;
    if (info != nil)
        title = [[info objectForKey:@"title"] objectForKey:@"_content"];
    else 
        title = @"Loading...";
    
    CCLOG(@"title = %@", title);
    
    CCLabelTTF *attribution = (CCLabelTTF*)[self getChildByTag:kTestingPhotoSlidersFlickrAttributionTag];
    attribution.string = title;

}

#pragma mark - SLImageSetDownloaderDelegate
-(void)slImageSetDownloaderDidFinish:(SLImageSetDownloader *)downloader {
    
    numOfImages = [downloader.imageURLs count];
    
    if (numOfImages > 0) {
        
        if (urlArray == nil) 
            urlArray = [[NSMutableArray alloc] initWithCapacity:10];
        if (url2IndexMap == nil)
            url2IndexMap = [[NSMutableDictionary alloc] initWithCapacity:10];
        
        int count = 0;
        for (NSString *imgURL in downloader.imageURLs) {
            SLImageDownloader *imgDownloader = [[SLImageDownloader alloc] init];
            imgDownloader.imageURL = imgURL;
            imgDownloader.delegate = self;
            
            [slImageDownloaders addObject:imgDownloader];
            
            [imgDownloader loadImage];
            [imgDownloader release];
            
            [urlArray addObject:imgURL];
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
        for (NSString *photoId in downloader.photoIds) {
            [photoIdArray addObject:photoId];

            SLImageInfoDownloader *infoDL = [[SLImageInfoDownloader alloc] init];
            infoDL.photoId = photoId;
            infoDL.delegate = self;
            [infoDL fetchInfo];
            
            [photoId2IndexMap setObject:[NSNumber numberWithInt:k] forKey:photoId];

            k++;
        }
        
    }

    numOfImagesKnown = YES;
    
    // If we know the number of images, reset the slide and re-display it 
    [slides reset];
    [slides show];
    
}

#pragma mark - SLImageGroupDownloaderDelegate methods
-(void)slImageGroupDownloaderDidFinish:(SLImageGroupDownloader *)downloader {
    
    numOfImages = [downloader.imageURLs count];
    
    if (numOfImages > 0) {
        
        if (urlArray == nil) 
            urlArray = [[NSMutableArray alloc] initWithCapacity:10];
        if (url2IndexMap == nil)
            url2IndexMap = [[NSMutableDictionary alloc] initWithCapacity:10];
        
        int count = 0;
        for (NSString *imgURL in downloader.imageURLs) {
            SLImageDownloader *imgDownloader = [[SLImageDownloader alloc] init];
            imgDownloader.imageURL = imgURL;
            imgDownloader.delegate = self;
            
            [slImageDownloaders addObject:imgDownloader];
            
            [imgDownloader loadImage];
            [imgDownloader release];
            
            [urlArray addObject:imgURL];
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
        for (NSString *photoId in downloader.photoIds) {
            [photoIdArray addObject:photoId];
            
            SLImageInfoDownloader *infoDL = [[SLImageInfoDownloader alloc] init];
            infoDL.photoId = photoId;
            infoDL.delegate = self;
            [infoDL fetchInfo];
            
            [photoId2IndexMap setObject:[NSNumber numberWithInt:k] forKey:photoId];
            
            k++;
        }
    }
    
    numOfImagesKnown = YES;
    
    // If we know the number of images, reset the slide and re-display it 
    [slides reset];
    [slides show];
        
}

#pragma mark - SLImageGalleryDownloaderDelegate
-(void)slImageGalleryDownloaderDidFinish:(SLImageGalleryDownloader *)downloader {
    numOfImages = [downloader.imageURLs count];
    
    if (numOfImages > 0) {
        
        if (urlArray == nil) 
            urlArray = [[NSMutableArray alloc] initWithCapacity:10];
        if (url2IndexMap == nil)
            url2IndexMap = [[NSMutableDictionary alloc] initWithCapacity:10];
        
        int count = 0;
        for (NSString *imgURL in downloader.imageURLs) {
            SLImageDownloader *imgDownloader = [[SLImageDownloader alloc] init];
            imgDownloader.imageURL = imgURL;
            imgDownloader.photoId = [downloader.photoIds objectAtIndex:count];
            imgDownloader.delegate = self;
            [imgDownloader loadImage];
            
            [urlArray addObject:imgURL];
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
        for (NSString *photoId in downloader.photoIds) {
            [photoIdArray addObject:photoId];
            
            SLImageInfoDownloader *infoDL = [[SLImageInfoDownloader alloc] init];
            infoDL.photoId = photoId;
            infoDL.delegate = self;
            [infoDL fetchInfo];
            
            [photoId2IndexMap setObject:[NSNumber numberWithInt:k] forKey:photoId];
            
            k++;
        }
    }
    
    numOfImagesKnown = YES;
    
    // If we know the number of images, reset the slide and re-display it 
    [slides reset];
    [slides show];
       
}

-(void)saveImageDataToDoc:(NSData*)data withPhotoId:(NSString*)photoId {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

    NSString *filePath = [NSString stringWithFormat:@"%@/%@.png", docDir, photoId];
    [data writeToFile:filePath atomically:YES];
    
}

#pragma mark - SLImageDownloaderDelegate
-(void)slImageDownloaderDidFinish:(SLImageDownloader *)downloader withNSData:(NSData *)data {
    
    NSString *photoId = downloader.photoId;
    [self saveImageDataToDoc:data withPhotoId:photoId];
        
//    UIImage *image = [UIImage imageWithData:data];
    
    NSString *key = downloader.imageURL;
    
//    [[CCTextureCache sharedTextureCache] addCGImage:[image CGImage] forKey:key];
        
    NSNumber *indexNumber = [url2IndexMap objectForKey:key];
    
    if (indexNumber != nil) {
        int index = [indexNumber intValue];
//        CCLOG(@"syncing index = %d", index);
        [slides syncWithIndex:index];
        
        if (index-1 >= 0)
            [slides syncWithIndex:index-1];
        
        if (index+1 < numOfImages)
            [slides syncWithIndex:index+1];
    }    
}

#pragma mark - SLImageInfoDownloaderDelegate
-(void) slImageInfoDownloaderDidFinish:(SLImageInfoDownloader *)downloader {
    
//    NSString *username = [[downloader.info objectForKey:@"owner"] objectForKey:@"username"];
    
    NSString *photoId = downloader.photoId;
    
    [photoInfo setObject:downloader.info forKey:photoId];
    
    if (slides.cursorVisible == [[photoId2IndexMap objectForKey:photoId] intValue]) {
        NSString *title = [[downloader.info objectForKey:@"title"] objectForKey:@"_content"];
        CCLOG(@"title = %@", title);
        CCLabelTTF *attribution = (CCLabelTTF*)[self getChildByTag:kTestingPhotoSlidersFlickrAttributionTag];
        attribution.string = title;
    }
                                 
    [downloader release];
    
}


@end

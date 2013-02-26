// Starting Point for App
//  AppDelegate.m
//  LifeCycle
//
//  Created by Kelvin Chan on 12/17/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameConfig.h"
#import "RootViewController.h"
#import "FlowAndStateManager.h"
#import "PlistValidator.h"
#import "PlistManager.h"
#import "GalleryManager.h"
#import "Gallery.h"
#import "GalleryItem.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "AppConfigManager.h"
#import "Constants.h"
#import "CCBReader.h"
#import "ModelManager.h"
#import "AppInfo.h"
#import "TopicInfo.h"
#import "ImageInfo.h"
#import "DidYouKnowInfo.h"
#import "YoutubeVideoInfo.h"
#import "StarterImageInfo.h"
#import "GalleryItemInfo.h"
#import "QuestionItemInfo.h"
#import "ChoiceInfo.h"
#import "HotspotInfo.h"
#import "NavigationItemInfo.h"
#import "GalleryManager.h"

@implementation AppDelegate

@synthesize window, navController, director;

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
    
    //	CC_ENABLE_DEFAULT_GL_STATES();
    //	CCDirector *director = [CCDirector sharedDirector];
    //	CGSize size = [director winSize];
    //	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
    //	sprite.position = ccp(size.width/2, size.height/2);
    //	sprite.rotation = -90;
    //	[sprite visit];
    //	[[director openGLView] swapBuffers];
    //	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController
}
- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	
    
    // Create the main window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	
	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
    
	// Enable multiple touches
	[glView setMultipleTouchEnabled:YES];
    
	director = (CCDirectorIOS*) [CCDirector sharedDirector];
	
	director.wantsFullScreenLayout = YES;
    
    [CCBFileUtils sharedFileUtils];
	
	// Display FSP and SPF
	[director setDisplayStats:YES];
	
	// set FPS at 60
	[director setAnimationInterval:1.0/60];
	
	// attach the openglView to the director
	[director setView:glView];
	
	// for rotation and other messages
	[director setDelegate:self];
	
	// 2D projection
    //	[director_ setProjection:kCCDirectorProjection2D];
	[director setProjection:kCCDirectorProjection3D];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
        CCLOG(@"Retina Display Not supported");
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
    
	[sharedFileUtils setEnableFallbackSuffixes:YES];				// Default: NO. No fallback suffixes are going to be
    [sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
   [sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
    [sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
	
    
	// Create a Navigation Controller with the Director
	navController = [[UINavigationController alloc] initWithRootViewController:director];
	navController.navigationBarHidden = YES;
	
    [[ModelManager sharedModelManger] setDataSrcName:@"ecosystem_master"];
    [self testXML];
    

    
    
	// make main window visible
	[window makeKeyAndVisible];
    
    
    debugLog(@"Version %@",[[UIDevice currentDevice] systemVersion]);
    
    
    if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
    {
        debugLog(@"IOS version 6 or greater");
        // set the Navigation Controller as the root view controller
        [window setRootViewController:navController];
    }
    else
    {
        //[window_ addSubview:navController_.view];
        debugLog(@"IOS version < 6");
        // make the View Controller a child of the main window
        [window addSubview: navController.view];
    }
	
	[window makeKeyAndVisible];
	
	
	// Removes the startup flicker
	[self removeStartupFlicker];
    
    // Setup Audio
	[[FlowAndStateManager sharedFlowAndStateManager] setupAudioEngine];
    
    // Basic plist validation
    [[PlistValidator sharedPlistValidator] validateQuizDictionary];
    
    AppInfo *appInfo = [ModelManager sharedModelManger].appInfo;
    int totalTopics = appInfo.numberOfTopics.intValue;
    
    GalleryManager *gman = [GalleryManager getInstance];
    
    CCLOG(@"Total topics %d", totalTopics);
    
    CCLOG(@"Check whether App Setup is done");
    // check for app setup
    if ([AppDelegate isAppSetupDone])
    {
        CCLOG(@"Setup is already done");
        
        
    }
    else {
        CCLOG(@"About to Perform App Setup");
        
        // get the number of topics
        
        for (int i =1; i <= totalTopics;i++) {
            
            
            
            // get the starter images
            NSMutableArray *starterImages = [[[NSMutableArray alloc] init] autorelease];
            
            TopicInfo * topicInfo = [appInfo.topics objectAtIndex:i-1];
            GalleryInfo *gallery = topicInfo.gallery;
            
            // populate starter images
            for (int k=0; k< [gallery.items count]; k++) {
                GalleryItemInfo *item = [gallery.items objectAtIndex:k];
                item.guid = [NSString stringWithFormat:@"%@-%@",gallery.uid,item.uid];
                item.filename = [NSString stringWithFormat:@"%@.jpg",item.guid];

                

                
                [starterImages addObject:item.guid];
            }
            
            
            
            
            
            
            for (int j=0; j< starterImages.count; j++) {
                
                NSString *starterImage = [NSString  stringWithFormat:@"%@.jpg",[starterImages objectAtIndex:j]];
                
                CCLOG(@"Copy starter Image %@ for gallery %@",starterImage,gallery.uid );
                
                UIImage *image = [UIImage imageNamed:starterImage];
                NSData *data = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];//1.0f = 100% quality
                [AppDelegate saveImageDataToDoc:data withImageName:starterImage];
                
                
                
                NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString *filePath = [NSString stringWithFormat:@"%@/%@", docDir, starterImage];
                
                CCLOG(@"File path %@",filePath);
                [self addSkipBackupAttributeToItemAtURL:filePath];
                
                
            }
            
            
        }
        
        
    }
    
    
        [[GalleryManager getInstance] buildCaches];
    
    

    
    
    
    
    CCLOG(@"Display the Home Screen");
    // Run the intro Scene
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kHomeScene withTranstion:kCCTransitionNoneSpecified];
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    [[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
    [[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
    [[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    
    
    
    [navController release];
    
    [window release];
    
    
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
    [[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
    [[CCDirector sharedDirector] end];
    [window release];
    [super dealloc];
}

+(BOOL) isAppSetupDone
{
    CCLOG(@"isAppSetupDone");
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/gallery-tundra.xml", docDir];
    
    BOOL destFileExits = [[NSFileManager defaultManager]  fileExistsAtPath:filePath];
    
    if (destFileExits)
    {
        return  true;
    }
    else {
        return  FALSE;
    }
    
}



+(void)saveImageDataToDoc:(NSData*)data withImageName:(NSString*)imageName {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", docDir, imageName];
    
    debugLog(@"Saving to %@",filePath);
    [data writeToFile:filePath atomically:YES];
}


+(void) saveImageSizeToDoc:(CGSize)size withImageName:(NSString*)imageName {
    
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




- (BOOL)addSkipBackupAttributeToItemAtURL:(NSString*) filePath
{
    
    
    
    if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.1"))
    {
        
        NSString *filePathWith = [NSString stringWithFormat:@"file://%@",filePath];
        NSURL *URL = [NSURL URLWithString:filePathWith];
        
        return [self addSkipBackupAttributeToItemAtURLForiOS5_1AndAbove:URL];
    }
    else{
        NSURL *URL = [NSURL URLWithString:filePath];
        return [self addSkipBackupAttributeToItemAtURLForBelowiOS5_1 :URL];
    }
    
    
    
}

- (BOOL)addSkipBackupAttributeToItemAtURLForiOS5_1AndAbove:(NSURL *)URL
{
    //assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

- (BOOL)addSkipBackupAttributeToItemAtURLForBelowiOS5_1:(NSURL *)URL
{
    const char* filePath = [[URL path] fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    
    if (result !=0)
    {
        debugLog(@"Failed to set backup attribute");
    }
    return result == 0;
}


#pragma mark - Testing XML
-(void) testXML {
    
    AppInfo *appInfo = [ModelManager sharedModelManger].appInfo;
    
    CCLOG(@"appInfo.version = %.2f", appInfo.version.floatValue);
    CCLOG(@"appInfo.uid = %d", appInfo.uid.intValue);
    CCLOG(@"appInfo.name = %@", appInfo.name);
    CCLOG(@"appInfo.numberOfTopics = %d", appInfo.numberOfTopics.intValue);
    CCLOG(@"appInfo.info = %@", appInfo.info);
    CCLOG(@"appInfo.curriculum = %@", appInfo.curriculum);
    
    CCLOG(@"appInfo.introTexts.version = %.2f", appInfo.introTexts.version.floatValue);
    
    // test some KVCs
    
    //    CCLOG(@"KVC: app name = %@", [appInfo valueForKey:@"version"]);
    //    InfoLines *infoLines = (InfoLines *)[appInfo valueForKey:@"infoLines"];
    //    for (NSString *text in infoLines.texts) {
    //        CCLOG(@"info line = %@", text);
    //    }
    
    // test list all topics
    for (TopicInfo *topicInfo in appInfo.topics) {
        CCLOG(@"topic: version = %.2f, uid = %d, bgImage = %@", topicInfo.version.floatValue, topicInfo.uid.intValue, topicInfo.backgroundImage);
        CCLOG(@"topic: number = %d, name = %@, topicImageName = %@, mainText = %@", topicInfo.number.intValue, topicInfo.name, topicInfo.topicImageName, topicInfo.mainText);
        CCLOG(@"topic: maintext title image = %@, bg trackname = %@", topicInfo.mainTextTitleImageName, topicInfo.backgroundTrackName);
    }
    
    // test one topic
    TopicInfo *topic = appInfo.topics[0];
    
    // test images (polaroid)
    for (ImageInfo *imgInfo in topic.images.items) {
        CCLOG(@"imgInfo: name = %@, title = %@, scale = %.2f", imgInfo.name, imgInfo.title, imgInfo.scale.floatValue);
    }
    
    // test Did You Know
    for (DidYouKnowInfo *dykInfo in topic.didYouKnows.items) {
        CCLOG(@"did you know: text = %@", dykInfo.text);
    }
    
    // test voice over pacings
    CCLOG(@"voice over pacing times: %@", topic.voiceoverPacings.voiceoverPacingsTime.time);
    CCLOG(@"voice over pacing spaces: %@", topic.voiceoverPacings.voiceoverPacingsSpace.space);
    
    // test youtube video listing
    
    for (YoutubeVideoInfo *youtube in topic.youtubeVideos.items) {
        CCLOG(@"youtube video title = %@", youtube.title);
    }
    
    // test flickr photo
    CCLOG(@"Flickr gallery id = %@", topic.flickrPhotos.photoGallery.galleryId);
    
    // test background image
    CCLOG(@"background image = %@", topic.backgroundImage);
    
    // testing starter images
    for (StarterImageInfo *startImage in topic.starterImages.items) {
        CCLOG(@"starter image id = %@", startImage.startImageId);
    }
    
    // testing gallery
    CCLOG(@"gallery title = %@", topic.gallery.title);
    
    for (GalleryItemInfo *item in topic.gallery.items) {
        CCLOG(@"gallery item: version = %.0f, uid = %d, title = %@, type=%@", item.version.floatValue, item.uid.intValue, item.title, item.type);
        CCLOG(@"gallery item: url = %@, attribution = %@", item.url, item.attribution);
    }
    
    // testing questions
    for (QuestionItemInfo *item in topic.questions.items) {
        CCLOG(@"question = %@, level = %@", item.question, item.level);
        for (ChoiceInfo *choice in item.answers.choices) {
            CCLOG(@"\tAnswer = %@, Truth = %@", choice.answer, choice.truth);
        }
    }
    
    // optional text
    CCLOG(@"Optional Text = %@", topic.optionalText);
    CCLOG(@"Optional Text 2 = %@", ((TopicInfo*)appInfo.topics[1]).optionalText);
    if (((TopicInfo*)appInfo.topics[1]).optionalText == nil) {
        CCLOG(@"Topic 2 optional text is not set ");
    }
    
    // testing hotspots
    if (topic.hotspotsOnBackgrounds != nil && topic.hotspotsOnBackgrounds.count > 0) {
        HotspotsOnBackgroundInfo *bg = topic.hotspotsOnBackgrounds[0];
        
        CCLOG(@"There are %d hotspots", bg.hotspots.count);
        
        HotspotInfo *australia_hotspot = bg.hotspots[1];
        
        CCLOG(@"Hotspot key image = %@", australia_hotspot.keyImage);
        CGRect bound = australia_hotspot.bound;
        CCLOG(@"Australia hotspot bound = (%.2f, %.2f, %.2f, %.2f)", bound.origin.x, bound.origin.y, bound.size.width, bound.size.height);
        
       CCLOG(@"hotspot gallery %@", australia_hotspot.gallery.items);
        
    }
    
    // Navigation
    if (appInfo.navigation.navigationItems.count > 0)
        for (NavigationItemInfo *navItem in appInfo.navigation.navigationItems) {
            CCLOG(@"Navigation %@:%@", navItem.uid, navItem.destination);
        }
}

@end

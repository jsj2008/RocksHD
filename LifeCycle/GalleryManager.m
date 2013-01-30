//
//  GalleryManager.m
//  ButterflyHD
//
//  Created by Manpreet Vohra on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GalleryManager.h"
#import "cocos2d.h"
#import "Constants.h"
#import "GDataXMLNode.h"
#import "SLImageDownloader.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "PlistManager.h"
#import "AppConfigManager.h"
#include <sys/xattr.h>
#import "GalleryInfo.h"
#import "GalleryItemInfo.h"
#import "ModelManager.h"
#import "AppInfo.h" 
#import "TopicInfo.h"

@implementation GalleryManager


static GalleryManager *instance;
@synthesize galleries,itemMap;


+(GalleryManager*) getInstance {
    @synchronized([GalleryManager class]) {
        if (!instance)
            [[self alloc] init];
        return instance;
    }
    return nil;
}

+(id)alloc {
    @synchronized([GalleryManager class]) {
        NSAssert(instance == nil, @"Attempted to allocate a 2nd instance of the Gallery Manager singleton");
        instance = [super alloc];
        return instance;
    }
    return nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        galleries = [[NSMutableDictionary alloc] init];
        itemMap = [[NSMutableDictionary alloc] init];
        backgroundQueue = dispatch_queue_create("com.appilly.lifecycle.bgqueue", NULL);
    }
    
    return self;
}



-(void) buildGlobalItemMapFromGalleriesInCache: (NSMutableArray*) galleryIds withKey :(NSString *) key
{
    debugLog(@"in buildGlobalItemMapFromGalleriesInCache");
    NSMutableArray *dict = nil;
    // check if the map exits
    
    debugLog(@"Create dict as it not there");
    dict = [[NSMutableArray alloc] init];
    
    for (int i=0; i< [galleryIds count]; i++) {
        
        NSString *galleryId = [galleryIds objectAtIndex:i];
        
        debugLog(@"Gallery Id to retrieve %@",galleryId);
        
        GalleryInfo *gallery = [self getGalleryFromCache:galleryId];
        
        for (int j=0; j< [gallery.items count]; j++) {
            
            [dict addObject:[gallery.items objectAtIndex:j]];
        }
    }
    
    debugLog(@"Adding item map %d", dict.count);
    
    [itemMap setObject:dict forKey:key];
}




-(NSString *) downloadGallerySpecification :(NSString*) galleryUid
{
    
    CCLOG(@"in downloadGallerySpecification");
    
    
    NSString *url = [[NSString alloc] initWithFormat: @"%@/gallery/gallery-%@.xml", WEB_SERVICE_URL, galleryUid];
    
    debugLog(@"url : %@",url);
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString: url]];
    NSString *xmlString = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    debugLog(@"%@",xmlString);
    
    return xmlString;
}


-(void) addGalleryToCache :(GalleryInfo*) gallery
{
    
    debugLog(@"adding gallery to cache %@", gallery.uid);
    [galleries setObject:gallery forKey:gallery.uid];
}
-(GalleryInfo*) getGalleryFromCache :(NSString*) galleryUid
{
    return [galleries objectForKey:galleryUid];
}

-(void) dealloc
{
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IMAGE_DOWNLOADER_DIDFINISH_NOTIFICATIONNAME object:nil];
    
    dispatch_release(backgroundQueue);
    
    
    [galleries release];
    [super dealloc];
}

-(GalleryInfo*) filterGalleryLocal:(GalleryInfo*) gallery
{
    // check if the item is local
    GalleryInfo *localGallery = [[GalleryInfo alloc] init];
    localGallery.version = gallery.version;
    localGallery.title = gallery.title;
    localGallery.uid = gallery.uid;
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    for (int i=0; i<=[gallery.items count]; i++) {
        
        GalleryItemInfo *item = [gallery.items objectAtIndex:i];
        
        
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", docDir, item.filename];
        
        
        //Using NSFileManager we can perform many file system operations.
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL success = [fileManager fileExistsAtPath:filePath];
        
        if(success) {
            
            CCLOG(@"File exists %@",filePath );
            
            if ([item.status isEqualToString:@"A"])
            {
                CCLOG(@"Item status Active,add it");
                [localGallery addItem:item];
            }
            else {
                CCLOG(@"Item status inActive skip it");
            }
        }
        else {
            CCLOG(@"File does not exists %@",filePath );
        }
    }
    
    return localGallery;
}

-(GalleryInfo*) filterGallery:(GalleryInfo*) gallery byType:(NSString *)type
{
    
    debugLog(@"filterGallery by type %@", type);
    // check if the item is local
    GalleryInfo *localGallery = [[GalleryInfo alloc] init];
    localGallery.version = gallery.version;
    localGallery.title = gallery.title;
    
    localGallery.uid=  [NSString stringWithFormat:@"%@-%@",gallery.uid,type];
    
    
    
    NSMutableArray *localItems = [[NSMutableArray alloc] init];
    NSMutableDictionary *localItemMap = [[NSMutableDictionary alloc] init];
    for (int i=0; i<[gallery.items count]; i++) {
        
        debugLog(@"Filter item %d",i);
        
        GalleryItemInfo *item = [gallery.items objectAtIndex:i];
        item.guid = [NSString stringWithFormat:@"%@-%@",gallery.uid,item.uid];
        debugLog(@"Item guid %@",item.guid);
       item.filename = [NSString stringWithFormat:@"%@.jpg",item.guid];
        debugLog(@"Item filename %@",item.filename);
        
        if ([item.type isEqualToString:type])
        {
            
            if ([type isEqualToString:@"video"])
            {
                debugLog(@"Found video item %@ for gallery %@",item.guid,gallery.title);
            }
            
            [localItems addObject:item];
            [localItemMap setObject:item forKey:item.guid];
        }
        else {
            
        }
        
        
        
    }
    
    localGallery.items = localItems;
    gallery.itemMap = localItemMap;
    
    
    if ([type isEqualToString:@"video"])
    {
        debugLog(@"Local gallery items %d",[localGallery.items count]);
    }
    
    
    return localGallery;
}


-(GalleryInfo*) filterGallery:(GalleryInfo*) gallery byTags:(NSString *)tags
{
    debugLog(@"filter gallery by tags");
    // check if the item is local
    GalleryInfo *localGallery = [[GalleryInfo alloc] init];
    localGallery.version = gallery.version;
    localGallery.title = gallery.title;
    
    localGallery.uid=  [NSString stringWithFormat:@"%@-%@",gallery.uid,tags];
    
    
    NSMutableArray *localItems = [[NSMutableArray alloc]init];
    
    for (int i=0; i<[gallery.items count]; i++) {
        
        GalleryItemInfo *item = [gallery.items objectAtIndex:i];
        
        if ([item.tags rangeOfString:tags].location == NSNotFound)
        {
            debugLog(@"Tag does not match, %@ skip it",item.tags);
        }
        else
        {
            [localItems addObject:item];
        }
        
        
        localGallery.items = localItems;
        
    }
    
    return localGallery;
}




-(void ) saveGallerySpecificationAsFile : (NSString*) galleryXmlSpec withID :(NSString*) galleryUid
{
    debugLog(@"saveGallerySpecificationAsFile");
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *galleryXmlFile = [NSString stringWithFormat:@"%@/gallery-%@.xml", docDir, galleryUid];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager fileExistsAtPath:galleryXmlFile];
    if (success)
    {
        [fileManager removeItemAtPath:galleryXmlFile error:NULL];
    }
    [fileManager createFileAtPath:galleryXmlFile contents:[galleryXmlSpec dataUsingEncoding:NSUTF8StringEncoding ] attributes:nil];
    
}



-(void) slImageDownloaderDidFinish:(NSNotification *)notification {
    
    CCLOG(@"in : slImageDownloaderDidFinish (Image Download)");
    
    NSDictionary *userInfo = [notification userInfo];
    
    
    dispatch_async(backgroundQueue, ^{
        NSString *photoId = [userInfo objectForKey:@"photoId"];
        NSData *data = [userInfo objectForKey:@"data"];
        
        
        
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", docDir, photoId];
        CCLOG(@"Save image to %@",filePath);
        [data writeToFile:filePath atomically:YES];
        
        
        
    });
    
    
    
}


-(void) syncGalleryAndReloadCache:(NSString *)galleryUid
{
    
    
    debugLog(@"syncGalleryAndReloadCacheAsThread");
    
    // download it
    NSString *xmlSpec = [self downloadGallerySpecification:galleryUid];
    debugLog(@"Xml Spec %@",xmlSpec);
    [self saveGallerySpecificationAsFile:xmlSpec withID:galleryUid];
    
    // get current spec
    GalleryInfo *currentGallery = [self getGalleryFromCache:galleryUid];
    if (currentGallery == nil)
    {
        currentGallery = [[[GalleryInfo alloc] init] autorelease];
    }
    
    // GalleryInfo *newGallery = [self parseGallerySpecification:xmlSpec];
    GalleryInfo *newGallery = nil; // TODO FIX IT
    debugLog(@"New Gallery item count %d",[newGallery.items count]);
    
    for(int i =0; i < [newGallery.items count];i++)
    {
        
        GalleryItemInfo *newItem = [newGallery.items objectAtIndex:i];
        // GalleryItemInfo *currentItem = [currentGallery.itemMap objectForKey:newItem.guid];
        GalleryItemInfo *currentItem =  nil; // TODO Fix it
        
        debugLog(@"Current version %d, new version %d",currentItem.version,newItem.version);
        
        // compare version
        if (currentItem.version != newItem.version)
        {
            
            debugLog(@"New version found");
            
            // download item
            
            // Get an image from the URL below
            NSURL *url = [[NSURL alloc] initWithString:newItem.url];
            NSData *data = [NSData dataWithContentsOfURL:url];
            
            if (data != nil)
            {
                
                //NSLog(@"%f,%f",image.size.width,image.size.height);
                
                // Let's save the file into Document folder.
                // You can also change this to your desktop for testing. (e.g. /Users/kiichi/Desktop/)
                // NSString *deskTopDir = @"/Users/kiichi/Desktop";
                
                NSLog(@"saving image");
                
                //                NSData *data = [NSData dataWithData:UIImageJPEGRepresentation(image, 0)];
                
                
                NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                
                NSString *filePath = [NSString stringWithFormat:@"%@/%@", docDir, newItem.filename];
                CCLOG(@"Save image to %@",filePath);
                [data writeToFile:filePath atomically:YES];
                
                
                
                CCLOG(@"File path %@",filePath);
                [self addSkipBackupAttributeToItemAtURL:filePath];
                
                
                // [image release];
            }
            else
            {
                debugLog(@"Image not avaiable on the server");
            }
            
            
            
        }
        else {
            
            debugLog(@"Version is same, skip it");
            
            
        }
        
        
    }
    
    
    
    
    
    
}

-(void) syncAllGalleries
{
    
    
    AppConfigManager *mgr = [AppConfigManager getInstance];
	
	NSString *dated = [mgr getLocalProperty:@"last.gallery.sync"];
	BOOL syncNow = FALSE;
	if(dated == @"")
	{
		syncNow = TRUE;
    }
	else {
		
		
		NSDateFormatter *format = [[NSDateFormatter alloc] init];
		[format setDateFormat:@"MM/dd/yyyy"];
		
		NSDate *syncDate = [format dateFromString:dated];
		
        
		
		// compare
		NSDate *dtNow = [NSDate date];
		
        debugLog(@"Dated now  %@ and next sync date %@",dtNow,syncDate);
		
		
		NSComparisonResult result = [dtNow compare:syncDate];
		
		if(result==NSOrderedAscending)
		{
			debugLog(@"Sync Date is in the future");
			
			//
		}
		else if(result==NSOrderedDescending)
		{
			debugLog(@"Sync Date is in the past");
			syncNow = TRUE;
		}
		else
		{
			debugLog(@"Both dates are the same");
            syncNow = TRUE;
			
		}
        
		
		[format release];
        
        
	}
    
    if (syncNow) {
        [NSThread detachNewThreadSelector:@selector(syncAllGalleriesAsThread:) toTarget:self withObject:nil];
    }
    else {
        debugLog(@"It not time yet to sync");
    }
    
}

-(void) syncAllGalleriesAsThread :(id) sender
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (syncInProgress)
    {
        debugLog(@"Another Sync in Progress");
        return;
    }
    syncInProgress = true;
    
    AppConfigManager *cfg = [AppConfigManager getInstance];
    [cfg load];
    
    BOOL somethingChanged = FALSE;
    int totalTopics = [[[[PlistManager sharedPlistManager] appDictionary] objectForKey:@"numberOfTopics"] intValue];
    
    for (int i =1; i <= totalTopics;i++) {
        
        NSDictionary *dict = [[PlistManager sharedPlistManager] getDictionaryForTopic:i+1];
        NSString *galleryId =   [dict objectForKey:@"gallery_id"];
        
        
        NSString *galleryNameProperty = [NSString stringWithFormat:@"gallery.%@.version",galleryId];
        // check if version changed
        NSString *serverVersion =   [[AppConfigManager getInstance] getProperty:galleryNameProperty];
        
        // get gallery from cache
        GalleryInfo *localGallery = [self getGalleryFromCache:galleryId];
        
        debugLog(@"Gallery Local version %d, server version %d",localGallery.version,[serverVersion intValue]);
        
        if ([serverVersion intValue] > localGallery.version)
        {
            debugLog(@"Sync gallery %@",galleryId)  ;
            [self syncGalleryAndReloadCache:galleryId];
            somethingChanged = true;
        }
        else {
            debugLog(@"No need to sync gallery %@",galleryId);
        }
        
    }
    
    if (somethingChanged)
    {
        [self buildCaches];
    }
    else {
        debugLog(@"Nothing changed, no need to rebuild caches");
    }
    
    [self setNewSyncDate:1];
    
    syncInProgress = FALSE;
    [pool release];
}




-(void) buildCaches
{
    CCLOG(@"in buildCaches");
    
    AppInfo *appInfo = [ModelManager sharedModelManger].appInfo;

    int totalTopics = appInfo.numberOfTopics.intValue;
    
    
    CCLOG(@"Total topics %d", totalTopics);
    
    NSMutableArray *matchingGalleryIdsForItemMap = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *portfolioGalleryIdsForItemMap = [[[NSMutableArray alloc] init] autorelease];
    
    CCLOG(@"Total topics %d", totalTopics);
    for (int i =1; i <= totalTopics;i++) {
        
        
        TopicInfo *topicInfo = [appInfo.topics objectAtIndex:i-1];
        
        CCLOG(@"Loding gallery from local xml");
        GalleryInfo *gallery = topicInfo.gallery;
        
        GalleryInfo *videoGallery = [self filterGallery:gallery byType:GALLERY_ITEM_TYPE_VIDEO];
        GalleryInfo *photoGallery = [self filterGallery:gallery byType:GALLERY_ITEM_TYPE_PHOTO];
        
        GalleryInfo *matchingGamePhotoGallery = [self filterGallery:photoGallery byTags:GALLERY_TAG_MATCHING_GAME];
        GalleryInfo *galleryPhotoGallery = [self filterGallery:photoGallery byTags:GALLERY_TAG_PHOTO_GALLERY];
        
        
        [self addGalleryToCache:matchingGamePhotoGallery];
        [self addGalleryToCache:galleryPhotoGallery];
        [self addGalleryToCache:videoGallery];
        [self addGalleryToCache:photoGallery];
        [self addGalleryToCache:gallery];
        
        [matchingGalleryIdsForItemMap addObject:matchingGamePhotoGallery.uid];
        [portfolioGalleryIdsForItemMap addObject:galleryPhotoGallery.uid];
    }
    
    [self buildGlobalItemMapFromGalleriesInCache:matchingGalleryIdsForItemMap withKey:GALLERIES_PHOTO_FOR_MATCHING_GAME_ITEM_MAP];
    [self buildGlobalItemMapFromGalleriesInCache:portfolioGalleryIdsForItemMap withKey:GALLERIES_PHOTO_FOR_PHOTO_GALLERY_ITEM_MAP];
    
    
    
}


-(void) setNewSyncDate:(int) days
{
    
	NSDate *today = [NSDate date];
	today = [today addTimeInterval:60*60*24*days];
	
    NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
	[format setDateFormat:@"MM/dd/yyyy"];
	
	NSString *dateStr = [format stringFromDate:today];
	
	AppConfigManager *cfg = [AppConfigManager getInstance];
	[cfg setLocalProperty:@"last.gallery.sync" withValue:dateStr];
    
	
	debugLog(@"New Sync Date %d -- %@",days,dateStr);
    
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


@end

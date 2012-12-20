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
#import "Gallery.h"
#import "GalleryItem.h"
#import "SLImageDownloader.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "PlistManager.h"
#import "AppConfigManager.h"
#include <sys/xattr.h>

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
            
            Gallery *gallery = [self getGalleryFromCache:galleryId];
        
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


-(Gallery*) parseGallerySpecification :(NSString*) galleryXml
{
    
    CCLOG(@"in : fromXml");
    CCLOG(@"%@",galleryXml);
    
    Gallery *gallery  = [[Gallery alloc] init] ;

    
    NSError *error;
    
    NSData *data = [galleryXml dataUsingEncoding:NSUTF8StringEncoding];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:  data options: 0 error: &error];
    
    
    NSArray *galleryUidTagList = [doc.rootElement elementsForName:TAG_UID];
    
    if (galleryUidTagList.count >0)
    {
        GDataXMLElement *galleryUidTag = (GDataXMLElement*) [galleryUidTagList objectAtIndex:0];   
        gallery.uid = galleryUidTag.stringValue;
        
    }
    
    
    NSArray *galleryTitleTagList = [doc.rootElement elementsForName:TAG_TITLE];
    
    if (galleryTitleTagList.count >0)
    {
        GDataXMLElement *galleryTitleTag = (GDataXMLElement*) [galleryTitleTagList objectAtIndex:0];   
        gallery.title = galleryTitleTag.stringValue;
        
    }
    
    NSArray *galleryVersionTagList = [doc.rootElement elementsForName:TAG_VERSION];
    
    if (galleryVersionTagList.count >0)
    {
        GDataXMLElement *galleryVersionTag = (GDataXMLElement*) [galleryVersionTagList objectAtIndex:0];   
        gallery.version = [galleryVersionTag.stringValue intValue];
        
    }
    
    
    NSArray *itemTagList = [doc.rootElement elementsForName:TAG_ITEM];
    if (itemTagList.count >0)
    {
        CCLOG(@"Item Tags, iterate through");
        
        for (int i=0; i< [itemTagList count]; i++) {
            
            CCLOG(@"Item Tag Found %d",i);
            GDataXMLElement *itemTag = (GDataXMLElement*) [itemTagList objectAtIndex:i];
            
            GalleryItem *item = [[GalleryItem alloc] init];
            
            // set reference
            item.galleryUid = gallery.uid;
            
            NSArray *itemUidTagList = [itemTag elementsForName:TAG_UID];
            
            if (itemUidTagList.count >0)
            {
                GDataXMLElement *itemUidTag = (GDataXMLElement*) [itemUidTagList objectAtIndex:0];   
                item.uid = itemUidTag.stringValue;
                
            }
            
            NSArray *galleryItemVersionTagList = [itemTag elementsForName:TAG_VERSION];
            
            if (galleryItemVersionTagList.count >0)
            {
                GDataXMLElement *galleryItemVersionTag = (GDataXMLElement*) [galleryItemVersionTagList objectAtIndex:0];   
                item.version = [galleryItemVersionTag.stringValue intValue];
                
            }
            
            
            NSArray *itemTypeTagList = [itemTag elementsForName:TAG_TYPE];
            
            if (itemTypeTagList.count >0)
            {
                GDataXMLElement *itemTypeTag = (GDataXMLElement*) [itemTypeTagList objectAtIndex:0];   
                item.type = itemTypeTag.stringValue;
                
            }
            
            NSArray *galleryTitleTagList = [doc.rootElement elementsForName:TAG_TITLE];
            
            if (galleryTitleTagList.count >0)
            {
                GDataXMLElement *galleryTitleTag = (GDataXMLElement*) [galleryTitleTagList objectAtIndex:0];   
                item.title = galleryTitleTag.stringValue;
                
            }

            

            
            NSArray *itemTagsTagList = [itemTag elementsForName:TAG_TAGS];
            
            if (itemTagsTagList.count >0)
            {
                GDataXMLElement *itemTagsTag = (GDataXMLElement*) [itemTagsTagList objectAtIndex:0];   
                item.tags = itemTagsTag.stringValue;
                
            }
            
            
            NSArray *itemThumUrlTagList = [itemTag elementsForName:TAG_THUMBNAIL];
            
            if (itemThumUrlTagList.count >0)
            {
                GDataXMLElement *itemThumbTag = (GDataXMLElement*) [itemThumUrlTagList objectAtIndex:0];   
                item.thumbUrl = itemThumbTag.stringValue;
                
            }
            
            
            
            
            NSArray *itemUrlTagList = [itemTag elementsForName:TAG_URL];
            
            if (itemUrlTagList.count >0)
            {
                GDataXMLElement *itemUrlTag = (GDataXMLElement*) [itemUrlTagList objectAtIndex:0];   
                item.url = itemUrlTag.stringValue;
                
            }
            
            
            NSArray *itemDescrTagList = [itemTag elementsForName:TAG_DESCRIPTION];
            
            if (itemDescrTagList.count >0)
            {
                GDataXMLElement *itemDescrTag = (GDataXMLElement*) [itemDescrTagList objectAtIndex:0];   
                item.description = itemDescrTag.stringValue;
                
            }
            
            NSArray *itemAttributionTagList = [itemTag elementsForName:TAG_ATTRIBUTION];
            
            if (itemAttributionTagList.count >0)
            {
                GDataXMLElement *itemAttributionTag = (GDataXMLElement*) [itemAttributionTagList objectAtIndex:0];   
                item.attribution = itemAttributionTag.stringValue;
                
            }
            
            NSArray *itemStatusTagList = [itemTag elementsForName:TAG_STATUS];
            
            if (itemStatusTagList.count >0)
            {
                GDataXMLElement *itemStatusTag = (GDataXMLElement*) [itemStatusTagList objectAtIndex:0];   
                item.status = itemStatusTag.stringValue;
                
            }
            
            item.guid = [NSString stringWithFormat:@"%@-%@",item.galleryUid,item.uid];
            item.fileName = [NSString stringWithFormat:@"%@.jpg",item.guid];
            
            
                /*
            <question answer="1">
                 
            <text>How do exterme climate effect?</text>
                <answers>
                <option value="1">True</option>
                <option value="2">False</option>
                </answers>
            </question>
                 */
            
            NSArray *itemQuestionTagList = [itemTag elementsForName:TAG_QUESTION];
            
            if (itemQuestionTagList.count >0)
            {
                GDataXMLElement *itemQuestionTag = (GDataXMLElement*) [itemQuestionTagList objectAtIndex:0];   
                
                GDataXMLNode *answerAttrib = [itemQuestionTag attributeForName:TAG_ANSWER];
                item.correctAnswer =  answerAttrib.stringValue;
                
                //item.status = itemStatusTag.stringValue;
                // get the attribute
                NSArray *questionTextTagList = [itemQuestionTag elementsForName:TAG_TEXT];
                
                if (questionTextTagList.count >0)
                {
                    GDataXMLElement *questionTextTag = (GDataXMLElement*) [questionTextTagList objectAtIndex:0];   
                    item.question = questionTextTag.stringValue;
                }
                
                NSArray *answersTagList = [itemQuestionTag elementsForName:TAG_ANSWERS];
                
                if (answersTagList.count >0)
                {
                    GDataXMLElement *answersTag = (GDataXMLElement*) [answersTagList objectAtIndex:0];   
                    
                    NSArray *optionsTagList = [answersTag elementsForName:TAG_OPTION];
                    
                    NSMutableArray *answers = [[NSMutableArray alloc] init];
                    for (int i=0; i<optionsTagList.count; i++) {
                        GDataXMLElement *optionTag = (GDataXMLElement*) [optionsTagList objectAtIndex:0];   
                        [answers addObject:optionTag.stringValue];
                    }
                }
                
            }
            
            
            CCLOG(@"Added Item %@ to gallery %@",item.fileName,item.galleryUid);
            // add item
            [gallery addItem:item];
            
            // item
        }
        
        
    }
    
    return  gallery;
}


-(void) addGalleryToCache :(Gallery*) gallery
{
    
    debugLog(@"adding gallery to cache %@", gallery.uid);
    [galleries setObject:gallery forKey:gallery.uid];
}
-(Gallery*) getGalleryFromCache :(NSString*) galleryUid
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

-(Gallery*) filterGalleryLocal:(Gallery*) gallery
{
    // check if the item is local
    Gallery *localGallery = [[Gallery alloc] init];
    localGallery.version = gallery.version;
    localGallery.title = gallery.title;
    localGallery.uid = gallery.uid;
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    for (int i=0; i<=[gallery.items count]; i++) {
        
        GalleryItem *item = [gallery.items objectAtIndex:i];
        
        
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", docDir, item.fileName];
        
        
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

-(Gallery*) filterGallery:(Gallery*) gallery byType:(NSString *)type
{
    
    debugLog(@"filterGallery by type %@", type);
    // check if the item is local
    Gallery *localGallery = [[Gallery alloc] init];
    localGallery.version = gallery.version;
    localGallery.title = gallery.title;
    
  localGallery.uid=  [NSString stringWithFormat:@"%@-%@",gallery.uid,type];
    
    
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    for (int i=0; i<[gallery.items count]; i++) {
        
        GalleryItem *item = [gallery.items objectAtIndex:i];
       
        if ([item.type isEqualToString:type])
        {
            
            if ([type isEqualToString:@"video"])
                {
                    debugLog(@"Found video item %@ for gallery %@",item.guid,gallery.title);
                }
                 
            [localGallery addItem:item];            
        }
        else {
            
        }

       
    }

    if ([type isEqualToString:@"video"])
    {
        debugLog(@"Local gallery items %d",[localGallery.items count]);
    }

    
    return localGallery;
}


-(Gallery*) filterGallery:(Gallery*) gallery byTags:(NSString *)tags
{
    // check if the item is local
    Gallery *localGallery = [[Gallery alloc] init];
    localGallery.version = gallery.version;
    localGallery.title = gallery.title;
    
    localGallery.uid=  [NSString stringWithFormat:@"%@-%@",gallery.uid,tags];
    
        
//    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    for (int i=0; i<[gallery.items count]; i++) {
        
        GalleryItem *item = [gallery.items objectAtIndex:i];
        
        if ([item.tags rangeOfString:tags].location == NSNotFound)
        {
            debugLog(@"Tag does not match, %@ skip it",item.tags);
        }
            else
            {
                [localGallery addItem:item];                    
            }
        
        
        
        
    }
    
    return localGallery;
}




-(Gallery*)loadGalleryFromSpecification :(NSString*) galleryUid
{
    CCLOG(@"loadGalleryFromSpecification");
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *galleryXmlFile = [NSString stringWithFormat:@"%@/gallery-%@.xml", docDir, galleryUid];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager fileExistsAtPath:galleryXmlFile]; 				
    
    NSString *xmlSpec;
    if(success) {
        
        CCLOG(@"File exists %@",galleryXmlFile );
        
        NSURL *url = [NSURL URLWithString:galleryXmlFile];
        // get the xml
        NSError *err = nil;
        NSData *databuffer = [NSData dataWithContentsOfFile:galleryXmlFile options:NSDataReadingMappedIfSafe error:&err];
  //       NSData *databuffer = [NSData dataWithContentsOfFile:galleryXmlFile];
       xmlSpec = [[NSString alloc] initWithData:databuffer encoding:NSUTF8StringEncoding];
    //    xmlSpec = [NSString stringWithUTF8String:[databuffer bytes]];

        
        if (err!= nil)
        {
            CCLOG(@"errror reading gallery : %@",err.localizedDescription);
        }
        CCLOG(@"XMl %@",xmlSpec);
    }
    else {
        CCLOG(@"File does not exists %@",galleryXmlFile );
        
        // download it
        xmlSpec = [self downloadGallerySpecification:galleryUid];
        [self saveGallerySpecificationAsFile:xmlSpec withID:galleryUid ];
    }
    
    // parse it
    return [self parseGallerySpecification:xmlSpec];
    
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
    Gallery *currentGallery = [self getGalleryFromCache:galleryUid];
    if (currentGallery == nil)
    {
        currentGallery = [[[Gallery alloc] init] autorelease];
    }
    
    Gallery *newGallery = [self parseGallerySpecification:xmlSpec];
    
    debugLog(@"New Gallery item count %d",[newGallery.items count]);
    
    for(int i =0; i < [newGallery.items count];i++)
    {

        GalleryItem *newItem = [newGallery.items objectAtIndex:i];
        GalleryItem *currentItem = [currentGallery.itemMap objectForKey:newItem.guid];

        
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
                
                NSString *filePath = [NSString stringWithFormat:@"%@/%@", docDir, newItem.fileName];
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
    
    
    /*
    // get the starter images
    NSMutableArray *starterImages = [[[NSMutableArray alloc] init] autorelease];
    
    // populate starter images
    for (int k=0; k< [newGallery.items count]; k++) {
        GalleryItem *item = [newGallery.items objectAtIndex:k];
        
        if ([item.status isEqualToString:@"A"])
        {
            [starterImages addObject:item.guid];
        }
        else {
            debugLog(@"Skip as the status is not A");
        }
    }
    
        
    [AppDelegate savePhotoIdArrayToDoc:starterImages withGalleryId:newGallery.uid];
    
    [[GalleryManager getInstance] addGalleryToCache:newGallery];
    */
    
       
    
    
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
        Gallery *localGallery = [self getGalleryFromCache:galleryId]; 
        
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

    int totalTopics = [[[[PlistManager sharedPlistManager] appDictionary] objectForKey:@"numberOfTopics"] intValue];
    
    
    CCLOG(@"Total topics %d", totalTopics);

    NSMutableArray *matchingGalleryIdsForItemMap = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *portfolioGalleryIdsForItemMap = [[[NSMutableArray alloc] init] autorelease];
    
    CCLOG(@"Total topics %d", totalTopics);
    for (int i =1; i <= totalTopics;i++) {
        
        NSDictionary *dict = [[PlistManager sharedPlistManager] getDictionaryForTopic:i+1];
        //            NSString *galleryId =   [dict objectForKey:@"flickrphotos"];
        NSString *galleryId =   [dict objectForKey:@"gallery_id"];
        
        
        CCLOG(@"Loding gallery from local xml"); 
        Gallery *gallery = [self loadGalleryFromSpecification:galleryId];
        
        Gallery *videoGallery = [self filterGallery:gallery byType:GALLERY_ITEM_TYPE_VIDEO];
        Gallery *photoGallery = [self filterGallery:gallery byType:GALLERY_ITEM_TYPE_PHOTO];
        
        Gallery *matchingGamePhotoGallery = [self filterGallery:photoGallery byTags:GALLERY_TAG_MATCHING_GAME];
        Gallery *galleryPhotoGallery = [self filterGallery:photoGallery byTags:GALLERY_TAG_PHOTO_GALLERY];            
        
        
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

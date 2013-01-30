//
//  GalleryManager.h
//  ButterflyHD
//
//  Created by Manpreet Vohra on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GalleryInfo.h"
#include <sys/xattr.h>



#define GALLERY_ITEM_TYPE_PHOTO @"photo"
#define GALLERY_ITEM_TYPE_VIDEO @"video"
#define GALLERY_ITEM_TYPE_AUDIO @"audio"
#define GALLERY_ITEM_TYPE_DOC @"doc"

#define GALLERY_TAG_MATCHING_GAME @"match"
#define GALLERY_TAG_PHOTO_GALLERY @"gallery"

#define GALLERIES_PHOTO_ITEM_MAP @"photo-item-map"
#define GALLERIES_PHOTO_FOR_MATCHING_GAME_ITEM_MAP @"photo-match-item-map"
#define GALLERIES_PHOTO_FOR_PHOTO_GALLERY_ITEM_MAP @"photo-gallery-item-map"

@interface GalleryManager : NSObject
{
    NSMutableDictionary *itemMap;
    NSMutableDictionary *galleries;
    dispatch_queue_t backgroundQueue;
    
    BOOL syncInProgress;
}

-(void ) saveGallerySpecificationAsFile : (NSString*) galleryUid withID :(NSString*) galleryUid;

+(GalleryManager *)getInstance;
-(void) addGalleryToCache :(GalleryInfo*) gallery;
-(GalleryInfo*) getGalleryFromCache :(NSString*) galleryUid;

-(GalleryInfo*) filterGalleryLocal:(GalleryInfo*) gallery;
-(GalleryInfo*) filterGallery:(GalleryInfo*) gallery byType:(NSString*) type;
-(GalleryInfo*) filterGallery:(GalleryInfo*) gallery byTags:(NSString*) tags;
-(GalleryInfo*)loadGalleryFromSpecification :(NSString*) galleryUid;
-(void) syncGalleryAndReloadCache :(NSString*) galleryUid;
-(void) syncGalleryAndReloadCacheAsThread:(NSString *)galleryUid;
-(void) buildGlobalItemMapFromGalleriesInCache: (NSMutableArray*) galleryIds withKey :(NSString *) key;
-(void) buildCaches;
-(void) syncAllGalleries;
@property(nonatomic,retain) NSMutableDictionary *galleries;
@property(nonatomic,retain) NSMutableDictionary *itemMap;
@end

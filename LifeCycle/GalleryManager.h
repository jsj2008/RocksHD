//
//  GalleryManager.h
//  ButterflyHD
//
//  Created by Manpreet Vohra on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Gallery.h"
#include <sys/xattr.h>

#define TAG_GALLERY @"gallery"
#define TAG_ITEM @"item"
#define TAG_VERSION @"version"
#define TAG_UID @"uid"
#define TAG_TITLE @"title"
#define TAG_DESCRIPTION @"description"
#define TAG_TYPE @"type"
#define TAG_ATTRIBUTION @"attribution"
#define TAG_STATUS @"status"
#define TAG_THUMBNAIL @"thumbnail"
#define TAG_URL @"url"
#define TAG_TAGS @"tags"
#define TAG_QUESTION @"question"
#define TAG_TEXT @"text"
#define TAG_OPTION @"option"
#define TAG_ANSWERS @"answers"
#define TAG_VALUE @"value"
#define TAG_ANSWER @"answer"

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

-(NSString *) downloadGallerySpecification :(NSString*) galleryUid;
-(Gallery*) parseGallerySpecification :(NSString*) galleryXml;


+(GalleryManager *)getInstance;
-(void) addGalleryToCache :(Gallery*) gallery;
-(Gallery*) getGalleryFromCache :(NSString*) galleryUid;

-(Gallery*) filterGalleryLocal:(Gallery*) gallery;
-(Gallery*) filterGallery:(Gallery*) gallery byType:(NSString*) type;
-(Gallery*) filterGallery:(Gallery*) gallery byTags:(NSString*) tags;
-(Gallery*)loadGalleryFromSpecification :(NSString*) galleryUid;
-(void) syncGalleryAndReloadCache :(NSString*) galleryUid;
-(void) syncGalleryAndReloadCacheAsThread:(NSString *)galleryUid;
-(void) buildGlobalItemMapFromGalleriesInCache: (NSMutableArray*) galleryIds withKey :(NSString *) key;
-(void) buildCaches;
-(void) syncAllGalleries;
@property(nonatomic,retain) NSMutableDictionary *galleries;
@property(nonatomic,retain) NSMutableDictionary *itemMap;
@end

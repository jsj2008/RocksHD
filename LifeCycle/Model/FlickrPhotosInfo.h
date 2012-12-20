//
//  FlickrPhotosInfo.h
//  SLPOC
//
//  Created by Kelvin Chan on 10/15/12.
//
//

#import "SLInfo.h"
#import "PhotoGalleryInfo.h"

@interface FlickrPhotosInfo : SLInfo

@property (nonatomic, retain) PhotoGalleryInfo *photoGallery;   // no meta, rule violation

@end

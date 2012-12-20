//
//  FlickrPhotosInfo.m
//  SLPOC
//
//  Created by Kelvin Chan on 10/15/12.
//
//

#import "FlickrPhotosInfo.h"

@implementation FlickrPhotosInfo

-(void) dealloc {
    [_photoGallery release];
    [super dealloc];
}

#pragma mark - the Meat
-(void) parseAndBuildObject:(GDataXMLElement *)root {
    GDataXMLElement *photoGalleryElem = [root elementsForName:@"galleryId"][0];
    self.photoGallery = [PhotoGalleryInfo loadContentsFromGDataXMLElement:photoGalleryElem];
}


@end

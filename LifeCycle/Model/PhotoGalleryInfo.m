//
//  PhotoGalleryInfo.m
//  SLPOC
//
//  Created by Kelvin Chan on 10/15/12.
//
//

#import "PhotoGalleryInfo.h"

@implementation PhotoGalleryInfo

-(void) dealloc {
    [_galleryId release];
    
    [super dealloc];
}

#pragma mark - the Meat
-(void) parseAndBuildObject:(GDataXMLElement *)root {
    self.galleryId = root.stringValue;
}

@end

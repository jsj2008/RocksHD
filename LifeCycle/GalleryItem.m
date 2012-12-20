//
//  GalleryPhoto.m
//  ButterflyHD
//
//  Created by Manpreet Vohra on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GalleryItem.h"

@implementation GalleryItem

@synthesize uid,galleryUid,title,thumbUrl,description,attribution,version,url,type,status,fileName,guid,tags,question,correctAnswer,answers;


-(void) dealloc
{
    [uid release];
    [guid release];
    [tags release];
    [galleryUid release];
    [title release];
    [thumbUrl release];
    [description release];
    [attribution release];
    [url release];
    [type release];
    [status release];
    [question release];
    [correctAnswer release];
    [answers release];
    
    [super dealloc];
}
@end

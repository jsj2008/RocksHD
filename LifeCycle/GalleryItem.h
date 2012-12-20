//
//  GalleryPhoto.h
//  ButterflyHD
//
//  Created by Manpreet Vohra on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GalleryItem : NSObject

{
    NSString *uid;

    int version;
    NSString *url;
    NSString *thumbUrl;
    NSString *title;

    NSString *attribution;
    NSString *description;
    NSString *galleryUid;
    NSString *type;
    NSString *status;
    NSString *fileName;
    NSString *guid;
    NSString *tags;
    NSString *question;
    NSString *correctAnswer;
    NSMutableArray *answers;
}

@property(nonatomic,retain) NSString *uid;
@property(nonatomic,retain) NSString *status;
@property(nonatomic,assign) int version;
@property(nonatomic,retain) NSString *thumbUrl;
@property(nonatomic,retain) NSString *url;
@property(nonatomic,retain) NSString *title;
@property(nonatomic,retain) NSString *attribution;
@property(nonatomic,retain) NSString *description;
@property(nonatomic,retain) NSString *galleryUid;
@property(nonatomic,retain) NSString *type;
@property(nonatomic,retain) NSString *fileName;
@property(nonatomic,retain) NSString *guid;
@property(nonatomic,retain) NSString *tags;
@property(nonatomic,retain) NSString *question;
@property(nonatomic,retain) NSString *correctAnswer;
@property(nonatomic,retain) NSMutableArray *answers;

@end

/*
<question answer="1">
<text>How do exterme climate effect?</text>
<answers>
<option value="1" >True</option>
<option value="2">False</option>
</answers>
</question>
*/
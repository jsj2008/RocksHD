//
//  GalleryItemInfo.h
//  SLPOC
//
//  Created by Kelvin Chan on 10/15/12.
//
//

#import "SLInfo.h"

@interface GalleryItemInfo : SLInfo

@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSNumber *version;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *thumbnail;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *attribution;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *tags;
@property (nonatomic, retain) NSString *filename;
@property (nonatomic, retain) NSString *guid;

@end

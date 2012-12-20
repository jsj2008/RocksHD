//
//  ImageInfo.h
//  SLPOC
//
//  Created by Kelvin Chan on 10/15/12.
//
//

#import "SLInfo.h"

@interface ImageInfo : SLInfo

@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSNumber *version;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *attribution;
@property (nonatomic, retain) NSNumber *scale;

@end

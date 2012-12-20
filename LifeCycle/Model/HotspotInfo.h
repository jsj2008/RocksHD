//
//  HotspotInfo.h
//  SLPOC
//
//  Created by Kelvin Chan on 10/16/12.
//
//

#import "SLInfo.h"
#import "GalleryInfo.h"

@interface HotspotInfo : SLInfo

@property (nonatomic, retain) NSNumber *version;
@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSString *type;

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSNumber *fontSize;
@property (nonatomic, retain) NSString *backgroundColor;
@property (nonatomic, retain) NSString *textColor;
@property (nonatomic, assign) BOOL flippable;
@property (nonatomic, retain) NSString *keyImage;
@property (nonatomic, retain) NSString *keyImageTitle;
@property (nonatomic, assign) CGRect bound;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) CGRect largerFrame;

@property (nonatomic, retain) GalleryInfo *gallery;

-(UIColor *)colorFromStringValue:(NSString *)stringValue;

@end

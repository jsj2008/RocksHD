//
//  HotspotsOnBackgroundInfo.h
//  SLPOC
//
//  Created by Kelvin Chan on 10/16/12.
//
//

#import "SLInfo.h"

@interface HotspotsOnBackgroundInfo : SLInfo

@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSNumber *version;
@property (nonatomic, retain) NSString *backgroundImage;
@property (nonatomic, retain) NSString *backgroundText;
@property (nonatomic, retain) NSString *textBackgroundImage;
@property (nonatomic, retain) NSString *backgroundTrackName;
@property (nonatomic, retain) NSMutableArray *hotspots;

@end

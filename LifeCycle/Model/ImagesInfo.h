//
//  ImagesInfo.h
//  SLPOC
//
//  Created by Kelvin Chan on 10/15/12.
//
//

#import "SLInfo.h"

@interface ImagesInfo : SLInfo

@property (nonatomic, retain) NSMutableArray *items;   // No meta, deviate from NSMutableArray rule

@end
//
//  QuestionsInfo.h
//  SLPOC
//
//  Created by Kelvin Chan on 10/16/12.
//
//

#import "SLInfo.h"

@interface QuestionsInfo : SLInfo

@property (nonatomic, retain) NSNumber *version;
@property (nonatomic, retain) NSMutableArray *items;  // no meta

@end

//
//  AnswerItemInfo.h
//  SLPOC
//
//  Created by Kelvin Chan on 10/16/12.
//
//

#import "SLInfo.h"

@interface ChoiceInfo : SLInfo

@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSString *answer;
@property (nonatomic, retain) NSString *truth;

@end

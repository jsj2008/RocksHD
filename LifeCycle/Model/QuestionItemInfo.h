//
//  QuestionItemInfo.h
//  SLPOC
//
//  Created by Kelvin Chan on 10/16/12.
//
//

#import "SLInfo.h"
#import "AnswersInfo.h"

@interface QuestionItemInfo : SLInfo

@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSString *question;
@property (nonatomic, retain) NSString *level;
@property (nonatomic, retain) AnswersInfo *answers;

@end

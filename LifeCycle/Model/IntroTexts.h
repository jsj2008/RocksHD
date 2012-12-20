//
//  InfoLine.h
//  SLPOC
//
//  Created by Kelvin Chan on 10/14/12.
//
//

#import "SLInfo.h"

@interface IntroTexts : SLInfo

@property (nonatomic, retain) NSNumber *version;
@property (nonatomic, retain) NSString *backgroundImage;
@property (nonatomic, retain) NSMutableArray *texts;   // this is an array of item, exception to the rule, may need fixing, no meta

@end

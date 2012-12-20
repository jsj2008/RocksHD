//
//  AppInfo.h
//  SLPOC
//
//  Created by Kelvin Chan on 10/12/12.
//
//

#import "SLInfo.h"
#import "IntroTexts.h"
#import "NavigationInfo.h"

@interface AppInfo : SLInfo

// primitive elements (@dynamic)
@property (nonatomic, retain) NSNumber *version;
@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *numberOfTopics;
@property (nonatomic, retain) NSString *backgroundImage;
@property (nonatomic, retain) NSString *info;
@property (nonatomic, retain) NSString *curriculum;

// elements with child structure
@property (nonatomic, retain) IntroTexts *introTexts;
@property (nonatomic, retain) NSMutableArray *topics;
@property (nonatomic, retain) NavigationInfo *navigation;

@end

//
//  ModelManager.h
//  SLPOC
//
//  Created by Kelvin Chan on 10/21/12.
//
//

#import <Foundation/Foundation.h>
#import "SLInfo.h"
#import "AppInfo.h"

@interface ModelManager : NSObject

+(ModelManager *)sharedModelManger;

-(void) setDataSrcName:(NSString *)sourceName;

@property (nonatomic, readonly) NSString *sourceName;
@property (nonatomic, readonly) AppInfo *appInfo;


@end

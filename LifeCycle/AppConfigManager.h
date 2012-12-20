//
//  AppConfig.h
//  JustSikh
//
//  Created by admin on 9/17/09.
//  Copyright 2009 Livrona.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Properties.h"


@interface AppConfigManager : NSObject {

	Properties *props;
    NSUserDefaults *defaults;
    bool isLoaded;
    int currentTopic;
}

+ (AppConfigManager *)getInstance;
- (void) load;
-(NSString*) getProperty: (NSString*)key;
-(NSString*) getDeviceToken;
-(void) setDeviceToken: (NSString*)key;
-(void) setLocalProperty : (NSString*) prop withValue :(NSString*) value;



@property (nonatomic,assign) int currentTopic;
@property (nonatomic,assign) bool isLoaded; 
@end

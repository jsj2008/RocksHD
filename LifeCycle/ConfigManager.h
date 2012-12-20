//
//  ConfigManager.h
//  LifeCycle
//
//  Created by Kelvin Chan on 1/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ConfigManager : NSObject {
    NSUserDefaults *defaults;
    CGSize screenSize;
}

+(ConfigManager*) sharedConfigManager;

-(void)initialSetup;

-(CGPoint) positionFromDefaultsForNodeHierPath:(NSString*)nodePath andTag:(NSInteger)tag;
-(float) angleFromDefaultsForNodeHierPath:(NSString*)nodePath andTag:(NSInteger)tag;


-(void) writeToDefaultsForNode:(CCNode *)node NodeHierPath:(NSString *)nodePath forPosition:(CGPoint)position;

-(float) lengthInUnitOfScreenHeightFromDefaultsWithKey:(NSString*)key;
-(float) absoluteValueFromDefaultsWithKey:(NSString*)key;

-(void) resetToFactorySettings;

@end

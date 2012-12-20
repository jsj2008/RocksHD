//
//  ConfigManager.m
//  LifeCycle
//
//  Created by Kelvin Chan on 1/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConfigManager.h"
#import "PlistManager.h"

@implementation ConfigManager

static ConfigManager* _sharedConfigManager = nil;

+(ConfigManager*) sharedConfigManager {
    @synchronized([ConfigManager class]) {
        if (!_sharedConfigManager) 
            [[self alloc] init];
        return _sharedConfigManager;
    }
    return nil;
}

+(id)alloc {
    @synchronized([ConfigManager class]) {
        NSAssert(_sharedConfigManager == nil, @"Attempted to allocate a 2nd instance of the Config Manager singleton");
        _sharedConfigManager = [super alloc];
        return _sharedConfigManager;
    }
    return nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Flow/State Manager initialization
        // CCLOG(@"Config Manager Singleton init");
        defaults = [NSUserDefaults standardUserDefaults];
        screenSize = [CCDirector sharedDirector].winSize;
        [self initialSetup];
    }
    
    return self;
}

-(CGPoint)getPositionFromUserDefaultsForKey:(NSString*)key {
    NSString *coords = (NSString*) [defaults objectForKey:key];
    
    if (coords == nil)
        return CGPointZero;
    
    NSArray *a = [coords componentsSeparatedByString:@","];
    NSString *xStr = [a objectAtIndex:0];
    NSString *yStr = [a objectAtIndex:1];
        
    float x = [xStr floatValue] * screenSize.width;
    float y = [yStr floatValue] * screenSize.height;
    
    CGPoint pt = CGPointMake(x, y);
    
    return pt;
    
}

-(float) getAngleFromUserDefaultsForKey:(NSString*)key {
    NSString *coords = (NSString*) [defaults objectForKey:key];
    
    if (coords == nil)
        return 0.0;
    
    NSArray *a = [coords componentsSeparatedByString:@","];
    if ([a count] == 3) {
        NSString *angStr = [a objectAtIndex:2];
        return [angStr floatValue];
    }
    else 
        return 0.0;
}

-(CGPoint) positionFromDefaultsForNodeHierPath:(NSString*)nodePath andTag:(NSInteger)tag {
    NSString *key = [NSString stringWithFormat:@"%@:%d", nodePath, tag];
    CGPoint pt = [self getPositionFromUserDefaultsForKey:key];  
    
    return pt;

}

-(float) angleFromDefaultsForNodeHierPath:(NSString*)nodePath andTag:(NSInteger)tag {
    NSString *key = [NSString stringWithFormat:@"%@:%d", nodePath, tag];
    
    float angle = [self getAngleFromUserDefaultsForKey:key];
    return angle;
}

-(void) writeToDefaultsForNode:(CCNode *)node NodeHierPath:(NSString *)nodePath forPosition:(CGPoint)position {
    NSString *cs = [NSString stringWithFormat:@"%.4f,%.4f", position.x/screenSize.width, position.y/screenSize.height];
    
    NSString *key = [NSString stringWithFormat:@"%@:%d", nodePath, node.tag];
    
    NSMutableString *coords = [cs mutableCopy]; 
    
    if ([defaults objectForKey:key] != nil) {
        float angle = [self getAngleFromUserDefaultsForKey:key];
        if (angle != 0.0) {
            [coords appendFormat:@".2f", angle];
        }
    }
    
    [defaults setObject:coords forKey:key];
    [defaults synchronize];
    
    [coords release];
}

-(float) lengthInUnitOfScreenHeightFromDefaultsWithKey:(NSString*)key {
    
    NSString *valStr = [defaults objectForKey:key];
    
    if (valStr != nil) 
        return [valStr floatValue] * screenSize.height;
    else
        return 0.0;

}

-(float) absoluteValueFromDefaultsWithKey:(NSString*) key { 
    NSString *valStr = [defaults objectForKey:key];
    
    if (valStr != nil) 
        return [valStr floatValue];
    else
        return 0.0;   
}

-(void) resetToFactorySettings {
    // Find the factory settings from the plist bundle
    NSDictionary *factorySettings = [[PlistManager sharedPlistManager] factorySettingsDictionary];
    
    // (1) if factory settings is found, copy it onto NSUserDefaults
    if (factorySettings != nil) {
        for (NSString *k in factorySettings) {
            [defaults setObject:[factorySettings objectForKey:k] forKey:k];
        }
        [defaults synchronize];
    }
}

-(void) initialSetup {
    
    // check if user defaults exists 
    if ([defaults objectForKey:@"version"] == nil) {        
        [self resetToFactorySettings];
    }
    else {
        //... and if it has the right version.
        float versionNumber = [[[[PlistManager sharedPlistManager] factorySettingsDictionary] objectForKey:@"version"] floatValue];
        float userVersion = [[defaults objectForKey:@"version"] floatValue];
        
        if (versionNumber != userVersion) 
            [self resetToFactorySettings];
        
    }
//    // Scalar value
//    [defaults setObject:@"0.625" forKey:@"MAINTEXTIMAGE_VIEWPORT_HEIGHT"];
//    [defaults setObject:@"10.0" forKey:@"MAINTEXTIMAGE_STACK_X_OFFSET"];
//    [defaults setObject:@"-80.0" forKey:@"MAINTEXTIMAGE_STACK_Y_OFFSET"];
//    
//    [defaults setObject:@"550.0" forKey:@"INFO_TEXT_VIEWPORT_HEIGHT"];
//    
//    // Center Menu
//    [defaults setObject:@"0.5000,0.5260" forKey:@"IntroLayer/CCMenu:120"];
//    
//    // Life Stages (centered around menu), positions are relative to menu
//    [defaults setObject:@"0.0770,0.3209" forKey:@"IntroLayer/CCMenu:120/CCMenuItemImage:113"];
//    [defaults setObject:@"0.2832,0.1745" forKey:@"IntroLayer/CCMenu:120/CCMenuItemImage:114"];
//    [defaults setObject:@"0.2979,-0.1315" forKey:@"IntroLayer/CCMenu:120/CCMenuItemImage:115"];
//    [defaults setObject:@"0.0928,-0.3320" forKey:@"IntroLayer/CCMenu:120/CCMenuItemImage:116"];
//    [defaults setObject:@"-0.1826,-0.2904" forKey:@"IntroLayer/CCMenu:120/CCMenuItemImage:117"];
//    [defaults setObject:@"-0.3203,-0.0238" forKey:@"IntroLayer/CCMenu:120/CCMenuItemImage:118"];
//    [defaults setObject:@"-0.1953,0.2669" forKey:@"IntroLayer/CCMenu:120/CCMenuItemImage:119"];
//    
//    // Arrows leading from one stage to another
//    [defaults setObject:@"0.4160,0.8581" forKey:@"IntroLayer/CCSprite:101"];
//    [defaults setObject:@"0.7148,0.8581" forKey:@"IntroLayer/CCSprite:102"];
//    [defaults setObject:@"0.8789,0.5742" forKey:@"IntroLayer/CCSprite:103"];
//    [defaults setObject:@"0.7227,0.1810" forKey:@"IntroLayer/CCSprite:104"];
//    [defaults setObject:@"0.4414,0.1250" forKey:@"IntroLayer/CCSprite:105"];    
//    [defaults setObject:@"0.1807,0.2799" forKey:@"IntroLayer/CCSprite:106"];
//    [defaults setObject:@"0.1807,0.7083" forKey:@"IntroLayer/CCSprite:107"];
//    [defaults setObject:@"0.1807,0.7083" forKey:@"IntroLayer/CCSprite:108"];
//    
//    // Main Text
//    
//    // Top right menu
//    [defaults setObject:@"0.7402,0.9352" forKey:@"MainTextImagesLayer/CCMenu:114"];
//    
//    // Top right rows of menu icons
//    [defaults setObject:@"-0.1250,0.0000" forKey:@"MainTextImagesLayer/CCMenu:114/CCMenuItemImage:111"];
//    [defaults setObject:@"0.0000,0.0000" forKey:@"MainTextImagesLayer/CCMenu:114/CCMenuItemImage:112"];
//    [defaults setObject:@"0.1250,0.0000" forKey:@"MainTextImagesLayer/CCMenu:114/CCMenuItemImage:113"];
//    
//    // Top left title/image
//    [defaults setObject:@"0.0976,0.8958" forKey:@"MainTextImagesLayer/CCSprite:101"];
//    
//    // Main Text pane position (the long text)
//    [defaults setObject:@"0.4840,0.8750" forKey:@"MainTextImagesLayer/ScrollableCCLabelTTF:108"];
//    
//    // Voice over slider initial position 
//    [defaults setObject:@"0.4785,0.7780" forKey:@"MainTextImagesLayer/CCSprite:109"];
//    
//    // Did you know
//    [defaults setObject:@"0.0195,0.1800" forKey:@"MainTextImagesLayer/CCSprite:102"];
//    [defaults setObject:@"0.0664,0.0938" forKey:@"MainTextImagesLayer/CCMenu:103"];
//    [defaults setObject:@"0.9440,0.1020" forKey:@"MainTextImagesLayer/CCMenu:104"];
//    [defaults setObject:@"0.1000,0.1106" forKey:@"MainTextImagesLayer/CCLabelTTF:105"];
//    
//    // Quiz section
//    [defaults setObject:@"0.8359,0.2552" forKey:@"QuizLayer/CCMenu:105"];
//    [defaults setObject:@"0.7012,0.3984" forKey:@"QuizLayer/CCSprite:103"];
//    [defaults setObject:@"0.7012,0.3984" forKey:@"QuizLayer/CCSprite:104"];
//    [defaults setObject:@"0.5000,0.5651" forKey:@"QuizLayer/SizeSmartCCLabelTTF:107"];
//    [defaults setObject:@"0.1250,0.7500" forKey:@"QuizLayer/SizeSmartCCLabelTTF:100"];
//    
//    // Info scene
//    [defaults setObject:@"0.2500,0.8620" forKey:@"InfoLayer/ScrollableCCLabelTTF:101"];
//    [defaults setObject:@"0.5000,0.5000" forKey:@"InfoLayer/CCSprite:100"];
//    [defaults setObject:@"0.8750,0.9375" forKey:@"InfoLayer/CCMenu:104"];
//    
//    // Test scene
//    [defaults setObject:@"0.4317,0.6237" forKey:@"TestLayer/CCSprite:10000"];
//    [defaults setObject:@"0.3497,0.3489" forKey:@"TestLayer/CCSprite:10001"];
//    [defaults setObject:@"0.7471,0.4687" forKey:@"TestLayer/CCSprite:10002"];

//    [defaults synchronize];
    
}

@end

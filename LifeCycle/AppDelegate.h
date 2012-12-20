//
//  AppDelegate.h
//  SLPOC
//
//  Created by Kelvin Chan on 8/27/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@interface AppDelegate : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{
	UIWindow *window;
	UINavigationController *navController;
	
	CCDirectorIOS	*director;							// weak ref
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UINavigationController *navController;
@property (readonly) CCDirectorIOS *director;

@end

//
//  EditModeAbleCCMenu.m
//  PlantHD
//
//  Created by Kelvin Chan on 11/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EditModeAbleCCMenu.h"

@implementation EditModeAbleCCMenu

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:kCCMenuTouchPriority swallowsTouches:NO];
}

@end

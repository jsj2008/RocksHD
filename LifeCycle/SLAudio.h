//
//  SLAudio.h
//  LifeCycle
//
//  Created by Kelvin Chan on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CDAudioManager.h"

@interface CDLongAudioSource (SL)
-(void)playAt:(NSTimeInterval)currentTime;
-(NSTimeInterval)currentTime;
@end

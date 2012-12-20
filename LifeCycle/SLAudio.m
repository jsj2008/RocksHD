//
//  SLAudio.m
//  LifeCycle
//
//  Created by Kelvin Chan on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLAudio.h"

@implementation CDLongAudioSource (SL)

-(void)playAt:(NSTimeInterval)currentTime {
    [audioSourcePlayer setCurrentTime:currentTime];
}
-(NSTimeInterval)currentTime {
    return audioSourcePlayer.currentTime;
}

@end

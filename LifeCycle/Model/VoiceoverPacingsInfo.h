//
//  VoiceoverPacings.h
//  SLPOC
//
//  Created by Kelvin Chan on 10/15/12.
//
//

#import "SLInfo.h"
#import "VoiceoverPacingsTimeInfo.h"
#import "VoiceoverPacingsSpaceInfo.h"

@interface VoiceoverPacingsInfo : SLInfo

@property (nonatomic, retain) VoiceoverPacingsTimeInfo *voiceoverPacingsTime;
@property (nonatomic, retain) VoiceoverPacingsSpaceInfo *voiceoverPacingsSpace;

@end

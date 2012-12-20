//
//  VoiceoverPacingsTimeInfo.m
//  SLPOC
//
//  Created by Kelvin Chan on 10/15/12.
//
//

#import "VoiceoverPacingsTimeInfo.h"

@implementation VoiceoverPacingsTimeInfo

-(void) dealloc {
    [_time release];
    
    [super dealloc];
}

#pragma mark - Getter & Setters
-(NSMutableArray *)time {
    if (_time == nil)
        _time = [[NSMutableArray alloc] init];
    return _time;
}

#pragma mark - the Meat
-(void) parseAndBuildObject:(GDataXMLElement *)root {
    NSString *timeStr = root.stringValue.cleanse;
    NSArray *timesStr = [timeStr componentsSeparatedByString:@","];
    for (NSString *tStr in timesStr) {
        [self.time addObject: [NSNumber numberWithFloat:tStr.cleanse.floatValue] ];
    }
}


@end

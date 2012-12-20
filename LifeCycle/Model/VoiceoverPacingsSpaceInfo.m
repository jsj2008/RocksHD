//
//  VoiceoverPacingsSpaceInfo.m
//  SLPOC
//
//  Created by Kelvin Chan on 10/15/12.
//
//

#import "VoiceoverPacingsSpaceInfo.h"

@implementation VoiceoverPacingsSpaceInfo

-(void) dealloc {
    [_space release];
    
    [super dealloc];
}

#pragma mark - Getter & Setters
-(NSMutableArray *)space {
    if (_space == nil)
        _space = [[NSMutableArray alloc] init];
    return _space;
}

#pragma mark - the Meat
-(void) parseAndBuildObject:(GDataXMLElement *)root {
    NSString *spaceStr = root.stringValue.cleanse;
    NSArray *spacesStr = [spaceStr componentsSeparatedByString:@","];
    for (NSString *tStr in spacesStr) {
        [self.space addObject: [NSNumber numberWithFloat:tStr.cleanse.floatValue] ];
    }
}

@end

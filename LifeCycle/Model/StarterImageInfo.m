
//
//  StarterImageInfo.m
//  SLPOC
//
//  Created by Kelvin Chan on 10/15/12.
//
//

#import "StarterImageInfo.h"

@implementation StarterImageInfo

@dynamic uid;

-(void) dealloc {
    [_startImageId release];
    [super dealloc];
}

#pragma mark - the Meat 
-(void) parseAndBuildObject:(GDataXMLElement *)root {    
    self.startImageId = root.stringValue.cleanse;
}

@end

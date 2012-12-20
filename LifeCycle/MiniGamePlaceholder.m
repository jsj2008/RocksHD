//
//  MiniGamePlaceholder.m
//  PlantHD
//
//  Created by Kelvin Chan on 11/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MiniGamePlaceholder.h"

@implementation MiniGamePlaceholder

@synthesize isOccupied;

-(void) dealloc {
    [super dealloc];
}

+(MiniGamePlaceholder *) miniGamePlaceholder {
    MiniGamePlaceholder *ret = [[[MiniGamePlaceholder alloc] initWithFile:@"placeholder.png"] autorelease];
    return ret;
}

-(id)init {
    self = [super init];
    if (self) {
        occupation_count = 0;
    }
    return self;
}

-(BOOL)isOccupied {
    if (occupation_count > 0)
        return YES;
    else 
        return NO;
}

-(void)setIsOccupied:(BOOL)o {
    if (o) {
        occupation_count++;
    }
    else 
        occupation_count--;
}

@end

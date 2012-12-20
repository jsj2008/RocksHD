//
//  CCArrayShuffle.m
//  PlantHD
//
//  Created by Kelvin Chan on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSMutableArrayShuffle.h"


@implementation NSMutableArray (Shuffle)

-(void)shuffle {
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        int nElements = count - i;
        int n = (random() % nElements) + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

@end


@implementation CCArray (Shuffle)

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
	[self removeObjectAtIndex: index];
	[self insertObject:anObject atIndex:index];
}

@end
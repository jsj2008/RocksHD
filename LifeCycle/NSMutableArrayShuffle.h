//
//  CCArrayShuffle.h
//  PlantHD
//
//  Created by Kelvin Chan on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface NSMutableArray (Shuffle)
-(void)shuffle;
@end


@interface CCArray (Shuffle)
-(void)shuffle;
-(void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
@end
//
//  SLObjectPool.h
//  LifeCycle
//
//  Created by Kelvin Chan on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface SLObjectPool : NSObject {
    int queue_head;     // always pt to the lowest number object thats "reuable" (but not necessary allocated).
    CCArray *objects;
    NSMutableArray *inUseFlags;
}

@property (nonatomic, retain) CCArray *objects;

+(SLObjectPool *) objectsPoolWithCapacity:(NSUInteger)n;
-(id)initWithCapacity:(NSUInteger)n;
-(id)dequeueReusableObject;
-(void)assignObjectToPool:(id)object;
-(void)freeObjectForReuse:(id)object;

-(NSInteger)numberOfObjectAllocation;
-(void)printPoolState;

@end

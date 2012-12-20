//
//  SLObjectPool.m
//  LifeCycle
//
//  Created by Kelvin Chan on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLObjectPool.h"

@implementation SLObjectPool 

@synthesize objects;

-(void) dealloc {
    CCLOG(@"Deallocating SLObjectPool");
    
    [objects release];
    [inUseFlags release];
    
    [super dealloc];
}

+(SLObjectPool *) objectsPoolWithCapacity:(NSUInteger)n {
    SLObjectPool *sp = [[SLObjectPool alloc] initWithCapacity:n];
    [sp autorelease];
    return sp;
}


-(id)init {
    
    self = [super init];
    if (self) {
        objects = [[CCArray alloc] init];
        inUseFlags = [[NSMutableArray alloc] init];
        queue_head = 0;
    }
    return self;
}

-(id)initWithCapacity:(NSUInteger)n {
    
    self = [super init];
    if (self) {
        objects = [[CCArray alloc] initWithCapacity:n];
        inUseFlags = [[NSMutableArray alloc] initWithCapacity:n];
        queue_head = 0;
    }
    return self;
}

-(id)dequeueReusableObject {
    if (queue_head >= [objects count])
        return nil;
    else {
        id returnObject = [objects objectAtIndex:queue_head];   // dequeue this into use
        [inUseFlags replaceObjectAtIndex:queue_head withObject:@"Y"];
        
        BOOL reusableAvailable = NO;
        for (int k = queue_head+1; k < [objects count]; k++) {
            if ([(NSString*)[inUseFlags objectAtIndex:k] isEqualToString:@"N"]) {
                queue_head = k;
                reusableAvailable = YES;
                break;
            }
        }
        
        if (!reusableAvailable)
            queue_head = [objects count];
            
        return returnObject;
    }
}

-(void)assignObjectToPool:(id)object {
    
    // check if this object is already in the pool, if so, do nothing and return
    for (NSObject *o in objects) {
        if (o == object)
            return;
    }
    
    [objects addObject:object];
    [inUseFlags addObject:@"Y"];   // mark it as in-use        
    queue_head++;
}

-(NSInteger)numberOfObjectAllocation {
    return [objects count];
}


-(void)freeObjectForReuse:(id)object {
    for (int k = 0; k < [objects count]; k++) {
        if (object == [objects objectAtIndex:k]) {
            [inUseFlags replaceObjectAtIndex:k withObject:@"N"];
            if (k < queue_head)
                queue_head = k;
            break;
        }
    }
}

-(void)printPoolState {
    CCLOG(@"Object count %d", [objects count]);
    CCLOG(@"queue_head = %d", queue_head);
    for (int k = 0; k < [objects count]; k++) {
        CCLOG(@"(%@,%@)", [objects objectAtIndex:k], (NSString*) [inUseFlags objectAtIndex:k]);
    }
}

@end

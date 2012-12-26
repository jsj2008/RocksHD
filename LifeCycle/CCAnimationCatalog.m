//
//  CCAnimationCatalog.m
//  SLPOC
//
//  Created by Kelvin Chan on 10/28/12.
//
//

#import "CCAnimationCatalog.h"

@implementation CCAnimationCatalog

static CCAnimationCatalog* sSharedAnimationCatalog = nil;

+(void)initialize {
    NSAssert(self == [CCAnimationCatalog class], @"CCAnimationCatalog is not designed to be subclassed");
    sSharedAnimationCatalog = [CCAnimationCatalog new];
}

+(CCAnimationCatalog*)sharedAnimationCatalog {
    return sSharedAnimationCatalog;
}

+(id)scaleUpToOneFadein {
    id action = [CCSpawn actions:
                 [CCScaleTo actionWithDuration:0.5 scale:1.0],
                 [CCFadeIn actionWithDuration:0.5],
                 nil];
    return action;
}

+(id) bounceScaleAction {
    id action = [CCSequence actions:
                 [CCEaseExponentialOut actionWithAction:[CCScaleTo actionWithDuration:0.15 scale:1.25]],
                 [CCEaseElasticOut actionWithAction:[CCScaleTo actionWithDuration:0.2 scale:1.0] period:0.45], nil];
    return action;
}

+(id) scaleUpToOneAndBounce {
    // node may want to set to scale = 0.0;
    id action = [CCSequence actions:
                 [CCScaleTo actionWithDuration:0.6 scale:1.0],
                 [self bounceScaleAction],
                 nil];
    return action;
}

+(id) bounceMoveToAction:(CGPoint)position withDuration:(ccTime)duration {
    id action = [CCSequence actions:
                 [CCEaseElasticOut actionWithAction:[CCMoveTo actionWithDuration:duration position:position] period:0.5], nil];
    
    return action;
}

+(id) moveToFadeOut:(CGPoint)position withDuration:(ccTime)duration withCompletion:(void (^)(void)) block {
    id moveAction = [CCMoveTo actionWithDuration:duration position:position];
    id fadeAction = [CCFadeOut actionWithDuration:duration];
    
    id action = [CCSequence actions:
                 [CCSpawn actions:moveAction, fadeAction, nil],
                 [CCCallBlock actionWithBlock:^{
        block();
    }],
                 nil];
    
    return action;
}

+(id) fadeInOutForever {
    return [CCRepeatForever actionWithAction: [CCSequence actions:
                                        [CCFadeTo actionWithDuration:1.5 opacity:155],
                                        [CCFadeTo actionWithDuration:1.5 opacity:0],
                                        [CCDelayTime actionWithDuration:0.75],
                                               nil] ];
}

+(id) fadeInOutForDuration:(ccTime)duration withTimes:(int)times {
    return [CCSequence actions:
            [CCRepeat actionWithAction:[CCSequence actions:
                                        [CCFadeTo actionWithDuration:duration opacity:155],
                                        [CCFadeTo actionWithDuration:duration opacity:0],
                                        nil]
                                 times:times], nil];

}

@end

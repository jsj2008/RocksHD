//
//  CCAnimationCatalog.h
//  SLPOC
//
//  Created by Kelvin Chan on 10/28/12.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCAnimationCatalog : NSObject

+(CCAnimationCatalog *)sharedAnimationCatalog;


+(id) bounceScaleAction;
+(id) scaleUpToOneAndBounce;

+(id) bounceMoveToAction:(CGPoint)position withDuration:(ccTime)duration;
+(id) moveToFadeOut:(CGPoint)position withDuration:(ccTime)duration withCompletion:(void (^)(void)) block;

+(id) scaleUpToOneFadein;

+(id) fadeInOutForever;
+(id) fadeInOutForDuration:(ccTime)duration withTimes:(int)times;
@end

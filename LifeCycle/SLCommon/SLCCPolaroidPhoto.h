//
//  SLCCPolaroidPhoto.h
//  LifeCycle
//
//  Created by Kelvin Chan on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CCNode.h"

@interface SLCCPolaroidPhoto : CCNode {
    
    float titleBottomMargin;
    float attributionBottomMargin;
    float imgTopMargin;
    
    CCSprite *image;
    CCSprite *frame;
    CCLabelTTF *titleLabel;
    CCLabelTTF *attributionLabel;
}

@property (nonatomic, retain) CCSprite *image;
@property (nonatomic, retain) CCSprite *frame;
@property (nonatomic, retain) CCLabelTTF *titleLabel;
@property (nonatomic, retain) CCLabelTTF *attributionLabel;

+(id) slCCPolaroidPhotoWithImageName:(NSString *)imageName withTitle:(NSString*)title withAttribution:(NSString*)attribution;

-(id) initWithImageName:(NSString *)imageName withTitle:(NSString*)title withAttribution:(NSString*)attribution;

-(void) replaceWithImageName:(NSString *)imageName withTitle:(NSString*)title withAttribution:(NSString*)attribution;

-(void) setOpacity:(GLubyte) anOpacity;
@end

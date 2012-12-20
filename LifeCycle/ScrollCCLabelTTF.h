//
//  ScrollCCLabelTTF.h
//  PlantHD
//
//  Created by Kelvin Chan on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CCLabelTTF.h"
#import "cocos2d.h"

@interface ScrollCCLabelTTF : CCLabelTTF <CCTargetedTouchDelegate> {
    
}

-(id)initWithString:(NSString *)string withFixedWidth:(float)width alignment:(UITextAlignment)alignment fontName:(NSString *)name fontSize:(CGFloat)size;

+(id)labelWithString:(NSString *)string withFixedWidth:(float)width alignment:(UITextAlignment)alignment fontName:(NSString *)name fontSize:(CGFloat)size;

@end

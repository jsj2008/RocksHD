//
//  SizeSmartCCLabelTTF.h
//  SLCommon
//
//  Created by Kelvin Chan on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCLabelTTF.h"

@interface SizeSmartCCLabelTTF : CCLabelTTF

+(id)labelWithString:(NSString *)string withFixedWidth:(float)width alignment:(UITextAlignment)alignment fontName:(NSString *)name fontSize:(CGFloat)size;

-(id)initWithString:(NSString *)string withFixedWidth:(float)width alignment:(UITextAlignment)alignment fontName:(NSString *)name fontSize:(CGFloat)size;

@end

//
//  ScrollCCLabelTTF.m
//  PlantHD
//
//  Created by Kelvin Chan on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ScrollCCLabelTTF.h"

@implementation ScrollCCLabelTTF

+(id)labelWithString:(NSString *)string withFixedWidth:(float)width alignment:(UITextAlignment)alignment fontName:(NSString *)name fontSize:(CGFloat)size {
    return [[[self alloc] initWithString:string withFixedWidth:width alignment:alignment fontName:name fontSize:size] autorelease];
}

-(id)initWithString:(NSString *)string withFixedWidth:(float)width alignment:(UITextAlignment)alignment fontName:(NSString *)name fontSize:(CGFloat)size {
    
    // fix the width and try to get an estimate on how tall the text will be.
    CGSize maximumLabelSize = CGSizeMake(width, 9999);
    CGSize expectedLabelSize = [string sizeWithFont:[UIFont fontWithName:name size:size] 
                                  constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
    
    self = [super initWithString:string dimensions:expectedLabelSize alignment:alignment fontName:name fontSize:size];
    if (self) {
        //
    }
    
    return self;
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    return NO;
}

@end

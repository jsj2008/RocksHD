//
//  SizeSmartCCLabelTTF.m
//  SLCommon
//
//  Created by Kelvin Chan on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SizeSmartCCLabelTTF.h"

@implementation SizeSmartCCLabelTTF

+(id)labelWithString:(NSString *)string withFixedWidth:(float)width alignment:(UITextAlignment)alignment fontName:(NSString *)name fontSize:(CGFloat)size {
    return [[[self alloc] initWithString:string withFixedWidth:width alignment:alignment fontName:name fontSize:size] autorelease];
}

-(id)initWithString:(NSString *)string withFixedWidth:(float)width alignment:(UITextAlignment)alignment fontName:(NSString *)name fontSize:(CGFloat)size {
    CGSize maximumLabelSize = CGSizeMake(width, 9999);
    CGSize expectedLabelSize = [string sizeWithFont:[UIFont fontWithName:name size:size] 
                                       constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
    
    self = [super initWithString:string dimensions:expectedLabelSize alignment:alignment fontName:name fontSize:size];
    if (self) {
        //
    }
    
    return self;
}

            
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

@end

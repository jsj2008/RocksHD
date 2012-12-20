//
//  HotspotInfo.m
//  SLPOC
//
//  Created by Kelvin Chan on 10/16/12.
//
//

#import "HotspotInfo.h"

@implementation HotspotInfo

@dynamic version;
@dynamic uid;
@dynamic title;
@dynamic text;
@dynamic fontSize;
@dynamic backgroundColor;
@dynamic textColor;
@dynamic keyImage;
@dynamic keyImageTitle;

@dynamic gallery;

-(void) dealloc {
    [_type release];
    
    [super dealloc];
}

#pragma mark - the Meat
-(void) parseAndBuildObject:(GDataXMLElement *)root {
    
    self.type = [root attributeForName:@"type"].stringValue.cleanse;
    
    GDataXMLElement *flippableElem = [root elementsForName:@"flippable"][0];
    if ([flippableElem.stringValue.cleanse isEqualToString:@"YES"]) {
        self.flippable = YES;
    } else {
        self.flippable = NO;
    }
    
    GDataXMLElement *boundElem = [root elementsForName:@"bound"][0];
    GDataXMLElement *xElem = [boundElem elementsForName:@"x"][0];
    GDataXMLElement *yElem = [boundElem elementsForName:@"y"][0];
    GDataXMLElement *wElem = [boundElem elementsForName:@"width"][0];
    GDataXMLElement *hElem = [boundElem elementsForName:@"height"][0];
    float x = xElem.stringValue.cleanse.floatValue;
    float y = yElem.stringValue.cleanse.floatValue;
    float w = wElem.stringValue.cleanse.floatValue;
    float h = hElem.stringValue.cleanse.floatValue;
    self.bound = CGRectMake(x, y, w, h);
    
    GDataXMLElement *frameElem = [root elementsForName:@"frame"][0];
    GDataXMLElement *x1Elem = [frameElem elementsForName:@"x"][0];
    GDataXMLElement *y1Elem = [frameElem elementsForName:@"y"][0];
    GDataXMLElement *w1Elem = [frameElem elementsForName:@"width"][0];
    GDataXMLElement *h1Elem = [frameElem elementsForName:@"height"][0];
    float x1 = x1Elem.stringValue.cleanse.floatValue;
    float y1 = y1Elem.stringValue.cleanse.floatValue;
    float w1 = w1Elem.stringValue.cleanse.floatValue;
    float h1 = h1Elem.stringValue.cleanse.floatValue;
    self.frame = CGRectMake(x1, y1, w1, h1);
    
    GDataXMLElement *largeFrameElem = [root elementsForName:@"largerFrame"][0];
    GDataXMLElement *x2Elem = [largeFrameElem elementsForName:@"x"][0];
    GDataXMLElement *y2Elem = [largeFrameElem elementsForName:@"y"][0];
    GDataXMLElement *w2Elem = [largeFrameElem elementsForName:@"width"][0];
    GDataXMLElement *h2Elem = [largeFrameElem elementsForName:@"height"][0];
    float x2 = x2Elem.stringValue.cleanse.floatValue;
    float y2 = y2Elem.stringValue.cleanse.floatValue;
    float w2 = w2Elem.stringValue.cleanse.floatValue;
    float h2 = h2Elem.stringValue.cleanse.floatValue;
    self.largerFrame = CGRectMake(x2, y2, w2, h2);
    
}

-(UIColor *)colorFromStringValue:(NSString *)stringValue {
    UIColor *retColor;
    NSArray *tokens = [stringValue componentsSeparatedByString:@","];
    
    //eg. white=0.0, alpha=0.3
    if (tokens.count == 2) {
        NSString *tok1 = ((NSString *)tokens[0]).cleanse;
        NSArray *kv1 = [tok1 componentsSeparatedByString:@"="];
        NSString *color = ((NSString *)kv1[0]).cleanse;
        float colorValue = ((NSString *)kv1[1]).cleanse.floatValue;
        
        NSString *tok2 = ((NSString *)tokens[1]).cleanse;
        NSArray *kv2 = [tok2 componentsSeparatedByString:@"="];
        //        NSString *alpha = ((NSString *)kv2[0]).cleanse;
        float alphaValue = ((NSString*)kv2[1]).cleanse.floatValue;
        
        if ([color isEqualToString:@"white"]) {
            retColor = [UIColor colorWithWhite:colorValue alpha:alphaValue];
        }
    }
    else if (tokens.count == 1) {
        NSString *color = stringValue.cleanse;
        
        if ([color isEqualToString:@"black"]) {
            retColor = [UIColor blackColor];
        }
        else if ([color isEqualToString:@"blue"]) {
            retColor = [UIColor blueColor];
        }
        else if ([color isEqualToString:@"brown"]) {
            retColor = [UIColor brownColor];
        }
        else if ([color isEqualToString:@"clear"]) {
            retColor = [UIColor clearColor];
        }
        else if ([color isEqualToString:@"cyan"]) {
            retColor = [UIColor cyanColor];
        }
        else if ([color isEqualToString:@"darkGray"]) {
            retColor = [UIColor darkGrayColor];
        }
        else if ([color isEqualToString:@"gray"]) {
            retColor = [UIColor grayColor];
        }
        else if ([color isEqualToString:@"green"]) {
            retColor = [UIColor greenColor];
        }
        else if ([color isEqualToString:@"lightGray"]) {
            retColor = [UIColor lightGrayColor];
        }
        else if ([color isEqualToString:@"magenta"]) {
            retColor = [UIColor magentaColor];
        }
        else if ([color isEqualToString:@"orange"]) {
            retColor = [UIColor orangeColor];
        }
        else if ([color isEqualToString:@"purple"]) {
            retColor = [UIColor purpleColor];
        }
        else if ([color isEqualToString:@"red"]) {
            retColor = [UIColor redColor];
        }
        else if ([color isEqualToString:@"white"]) {
            retColor = [UIColor whiteColor];
        }
        else if ([color isEqualToString:@"yellow"]) {
            retColor = [UIColor yellowColor];
        }
        else
            ;
    }
    else
        ;
    
    return retColor;
}


@end

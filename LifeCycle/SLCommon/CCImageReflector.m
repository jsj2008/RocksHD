//
//  CCImageReflector.m
//  ButterflyPOC
//
//  Created by Kelvin Chan on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CCImageReflector.h"

@implementation CCImageReflector

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (UIImage *) convertSpriteToImage:(CCSprite *)sprite {
    CGPoint p = sprite.anchorPoint;
    [sprite setAnchorPoint:ccp(0,0)];
    CCRenderTexture *renderer = [CCRenderTexture renderTextureWithWidth:sprite.contentSize.width height:sprite.contentSize.height];
    [renderer begin];
    [sprite visit];
    [renderer end];
    [sprite setAnchorPoint:p];
    //    UIImage *newImage = [UIImage imageWithData:[renderer getUIImageAsDataFromBuffer:kCCImageFormatPNG]];
    UIImage *newImage = renderer.getUIImage;
    return newImage;
}

//Taken from the Apple Reflection example.
- (CGContextRef) createBitmapContext:(int) pixelsWide pixelsHigh:(int) pixelsHigh {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // create the bitmap context
    CGContextRef bitmapContext = CGBitmapContextCreate (NULL, pixelsWide, pixelsHigh, 8,
                                                        0, colorSpace,
                                                        // this will give us an optimal BGRA format for the device:
                                                        (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
    CGColorSpaceRelease(colorSpace);
    return bitmapContext;
}

- (CGImageRef) createGradientImage:(int) pixelsWide pixelsHigh:(int) pixelsHigh {
    CGImageRef theCGImage = NULL;
    // gradient is always black-white and the mask must be in the gray colorspace
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    // create the bitmap context
    CGContextRef gradientBitmapContext = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh,
                                                               8, 0, colorSpace, kCGImageAlphaNone);
    // define the start and end grayscale values (with the alpha, even though
    // our bitmap context doesn't support alpha the gradient requires it)
    CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};
    // create the CGGradient and then release the gray color space
    CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
    CGColorSpaceRelease(colorSpace);
    // create the start and end points for the gradient vector (straight down)
    CGPoint gradientStartPoint = CGPointZero;
    CGPoint gradientEndPoint = CGPointMake(0, pixelsHigh);
    // draw the gradient into the gray bitmap context
    CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint,
                                gradientEndPoint, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(grayScaleGradient);
    
    // convert the context into a CGImageRef and release the context
    theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
    CGContextRelease(gradientBitmapContext);
    
    // return the imageref containing the gradient
    return theCGImage;
}

- (UIImage *)reflectedImage:(UIImageView *)fromImage withHeight:(NSUInteger)height
{
    if(height == 0)
        return nil;
    
    // create a bitmap graphics context the size of the image
    CGContextRef mainViewContentContext = [self createBitmapContext:fromImage.bounds.size.width pixelsHigh:height];
    
    // create a 2 bit CGImage containing a gradient that will be used for masking the
    // main view content to create the 'fade' of the reflection.  The CGImageCreateWithMask
    // function will stretch the bitmap image as required, so we can create a 1 pixel wide gradient
    CGImageRef gradientMaskImage = [self createGradientImage:1 pixelsHigh:height];
    
    // create an image by masking the bitmap of the mainView content with the gradient view
    // then release the  pre-masked content bitmap and the gradient bitmap
    CGContextClipToMask(mainViewContentContext, CGRectMake(0.0, 0.0, fromImage.bounds.size.width, height), gradientMaskImage);
    CGImageRelease(gradientMaskImage);
    
    // In order to grab the part of the image that we want to render, we move the context origin to the
    // height of the image that we want to capture, then we flip the context so that the image draws upside down.
    CGContextTranslateCTM(mainViewContentContext, 0.0, height);
    CGContextScaleCTM(mainViewContentContext, 1.0, -1.0);
    
    // draw the image into the bitmap context
    CGContextDrawImage(mainViewContentContext, fromImage.bounds, fromImage.image.CGImage);
    
    // create CGImageRef of the main view bitmap content, and then release that bitmap context
    CGImageRef reflectionImage = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    
    // convert the finished reflection image to a UIImage
    UIImage *theImage = [UIImage imageWithCGImage:reflectionImage];
    
    // image is retained by the property setting above, so we can release the original
    CGImageRelease(reflectionImage);
    
    return theImage;
}


- (CCSprite*) drawSpriteReflection:(CCSprite *) sprite withHeight:(NSUInteger) height {
    
    UIImage *theReflect = [self convertSpriteToImage:sprite];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:theReflect];
    UIImage *reflect = [self reflectedImage:imageView withHeight:height];
    
    //    CCTexture2D *texture=[[CCTexture2D alloc] initWithImage:reflect];
    CCTexture2D *texture = [[CCTexture2D alloc] initWithCGImage:reflect.CGImage resolutionType:kCCResolutioniPadRetinaDisplay];
    
    CCSprite *returnSprite = [CCSprite spriteWithTexture:texture];
    
    [imageView release];
    [texture release];
    
    return returnSprite;
}

@end

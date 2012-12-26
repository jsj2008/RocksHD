//
//  CCUIPopupView.h
//  SLPOC
//
//  Created by Kelvin Chan on 8/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCUIViewWrapper.h"

typedef enum {
    CCUIPopupViewTypeDefault,
    CCUIPopupViewTypeLarge
} CCUIPopupViewType;

@class CCUIPopupView;

@protocol CCUIPopupViewDelegate <NSObject>
@optional
-(void) ccUIPopupViewPhotoLinkTapped:(CCUIPopupView *) sender;
-(void) ccUIPopupViewVideoLinkTapped:(CCUIPopupView *) sender;
@end

@interface CCUIPopupView : CCNode

+(id)ccUIPopupViewWithParentNode:(CCNode *)parentNode withType:(CCUIPopupViewType)type withGlFrame:(CGRect)glFrame animateToLargerGlFrame:(CGRect)largeGlFrame withKeyImage:(UIImage*)keyImage withText:(NSString *)text;

-(id)initWithParentNode:(CCNode *)parentNode withType:(CCUIPopupViewType)type withGlFrame:(CGRect)glFrame animateToLargerGlFrame:(CGRect)largeGlFrame withKeyImage:(UIImage*)keyImage withText:(NSString *)text;

// ******************************************************************
// These matter only when popup is flippable
-(void)setBackgroundImageForFlipping:(UIImage*)bgImage withFlipAngle:(float)flipAngle withScale:(float)scale;

-(void) flipOpen;
-(void) flipClose;
-(void) flipCloseAndRemoveFromParentAndCleanup;
// ******************************************************************

@property (nonatomic, assign) id<CCUIPopupViewDelegate> delegate;

@property (nonatomic, assign) CCUIPopupViewType type;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) UIImage *keyImage;
@property (nonatomic, copy) NSString *keyImageTitle;
@property (nonatomic, assign) CGRect frame;    // Note: will in UIKit coordinate
@property (nonatomic, assign) CGRect largerFrame;  // Note: will in UIKit coordinate
@property (nonatomic, assign) float fontSize;
@property (nonatomic, assign) BOOL flippable;
@property (nonatomic, assign) UIColor *backgroundColor;
@property (nonatomic, assign) UIColor *textColor;
@property (nonatomic, assign) float alpha;

// Data for Photo Strips (a tableview) 
@property (nonatomic, retain) NSArray *photoThumbnailArray;
@property (nonatomic, retain) NSArray *videoUrlArray;
@property (nonatomic, retain) NSArray *videoThumbnailArray;
@end

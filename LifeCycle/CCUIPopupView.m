//
//  CCUIPopupView.m
//  SLPOC
//
//  Created by Kelvin Chan on 8/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCUIPopupView.h"
#import "SLWebViewVideoPlayer.h"

typedef enum {
    kTextViewTag=1001,
    kKeyImageViewTag=1002,
    kFlippableCoverImageView=1003,
    kPhotoButtonTag=1004,
    kVideoButtonTag=1005,
    kPhotosTableViewTag=1006,
    kVideosTableViewTag=1007,
    kPhotoTableViewCellTag=1008,
    kKeyImageTitleLabelTag=1009,
    kWebViewVideoPlayerTag=1010,
    kBackgroundVeilViewTag=1011
} CCUIPopupViewChildTags;

@interface CCUIPopupView () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, SLWebViewVideoPlayerDelegate>
// The following are relevant if flippable is true
@property (nonatomic, assign) float flipAngle;
@property (nonatomic, assign) float scale;   // 1.0 for non-retina, 2.0 for retina
@end

@implementation CCUIPopupView {
    CGSize screenSize;
    
    CCUIViewWrapper *wrapper;
    UIView *uiView;
    
    BOOL flippedOpen;
    
    float imageScale;
    
    UITableView *photosTableView;
    UITableView *videosTableView;
    
    BOOL keyImageShowing;
}

// Not sure yet why synthesizers need to be defined for these 3 ivars, in xcode 4.5
@synthesize text = _text;
@synthesize keyImage = _keyImage;
@synthesize scale = _scale;

-(void) dealloc {
    
    CCLOG(@"Deallocating CCUIPopupView");
    
    if (uiView != nil)
        [uiView release];
    
    [self removeChild:wrapper cleanup:YES];
    wrapper = nil;
    
    [_title release];
    [_text release];
    [_keyImage release];
    [_keyImageTitle release];
    
    [_photoThumbnailArray release];
    [_videoUrlArray release];
    [_videoThumbnailArray release];
    
    [super dealloc];
}

+(id)ccUIPopupViewWithParentNode:(CCNode *)parentNode withType:(CCUIPopupViewType)type withGlFrame:(CGRect)glFrame animateToLargerGlFrame:(CGRect)largeGlFrame withKeyImage:(UIImage *)keyImage withText:(NSString *)text {
    return [[[self alloc] initWithParentNode:parentNode withType:type withGlFrame:glFrame animateToLargerGlFrame:largeGlFrame withKeyImage:keyImage withText:text] autorelease];
}

-(id)initWithParentNode:(CCNode *)parentNode withType:(CCUIPopupViewType)type withGlFrame:(CGRect)glFrame animateToLargerGlFrame:(CGRect)largeGlFrame withKeyImage:(UIImage*)keyImage withText:(NSString *)text {
    self = [super init];
    if (self) {
        [parentNode addChild:self];
        
        _type = type;
        
        // Setup general positions and sizes
        screenSize = [CCDirector sharedDirector].winSize;
        
        if (CGRectIsNull(glFrame)) {   // Provide default if NULL
            CGPoint o = ccp(screenSize.width * 0.25, screenSize.height * 0.875);
            CGSize s = CGSizeMake(screenSize.width*0.5, 600.0);
            glFrame = CGRectMake(o.x, o.y, s.width, s.height);
        }
        
        CGPoint origin = [[CCDirector sharedDirector] convertToUI:glFrame.origin];
        CGSize size = glFrame.size;
        
        // Since this is really a CCNode, we would like to think in GL coordinate, and let the frame extend to the top right of the origin, we need to adjust for this.
        origin.y -= size.height;
        
        CGRect frame = CGRectMake(origin.x, origin.y, size.width, size.height);
        _frame = frame;
        
        uiView = [[UIView alloc] init];
        uiView.backgroundColor = [UIColor whiteColor];
        uiView.frame = frame;
        uiView.layer.cornerRadius = 10;
        uiView.clipsToBounds = YES;
        uiView.layer.borderColor = [[UIColor colorWithRed:41.0/255.0 green:219.0/255.0 blue:57.0/255.0 alpha:1] CGColor];
        uiView.layer.borderWidth = 4.0f;
        
        uiView.layer.masksToBounds = NO;
        uiView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        uiView.layer.shadowOffset = CGSizeMake(3, 3);
        uiView.layer.shadowRadius = 2.0;
        uiView.layer.shadowOpacity = 1.0;
        
        uiView.layer.shouldRasterize = YES;
        uiView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        
        if (keyImage != nil) {
            UIImageView *imgView = [[UIImageView alloc] initWithImage:keyImage];
            float aspectRatio = keyImage.size.width / keyImage.size.height;
            if (_type == CCUIPopupViewTypeLarge) {
                imageScale = 0.5;
                imgView.frame = CGRectMake(10, 10, frame.size.width*imageScale, frame.size.width*imageScale/aspectRatio);
                imgView.userInteractionEnabled = YES;
                
            } else {
                imageScale = 0.3;
                imgView.frame = CGRectMake(10, 10, frame.size.width*imageScale*aspectRatio, frame.size.width*imageScale);
            }
            
            imgView.tag = kKeyImageViewTag;
            [uiView addSubview:imgView];
            [imgView release];
            
            keyImageShowing = YES;
        }
        // Popup Text
        UITextView *textView = [[UITextView alloc] init];
        if (_type == CCUIPopupViewTypeLarge) {
            textView.frame = CGRectMake(20.0 + frame.size.width*imageScale, 10,
                                        size.width - (30.0 + frame.size.width*imageScale),
                                        size.height - 20.0);
        }
        else {
            textView.frame = CGRectMake(10, 20+frame.size.width*imageScale, size.width-20, size.height-(20+frame.size.width*imageScale));
        }
        
        // Popup Text
        textView.tag = kTextViewTag;
        textView.delegate = self;
        textView.font = [UIFont systemFontOfSize:20];
        textView.editable = NO;
        textView.opaque = NO;
        textView.text = text;
        [uiView addSubview:textView];
        //        uiView.alpha = 0.0;
        [textView release];
        
        wrapper = [CCUIViewWrapper wrapperForUIView:uiView bringGLViewToFront:NO defaultViewHierStruct:YES];
        
        [self addChild:wrapper];
                
        // Try to animate to larger frame
        if (largeGlFrame.size.width > 0.0 && largeGlFrame.size.height > 0.0) {
            
            UIImageView *imgView = (UIImageView *) [uiView viewWithTag:kKeyImageViewTag];
            UITextView *textView = (UITextView *) [uiView viewWithTag:kTextViewTag];
            
            CGPoint origin = [[CCDirector sharedDirector] convertToUI:largeGlFrame.origin];
            CGSize size = largeGlFrame.size;
            origin.y -= size.height;
            CGRect f = CGRectMake(origin.x, origin.y, size.width, size.height);
            
            _largerFrame = f;
            
            float imgAspectRatio = imgView.frame.size.width / imgView.frame.size.height;
            CCLOG(@"uiView size = %.2f, %.2f", _largerFrame.size.width, _largerFrame.size.height);

            if (_type == CCUIPopupViewTypeLarge) {
                [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    uiView.frame = _largerFrame;
                    imgView.frame = CGRectMake(10, 10, _largerFrame.size.width*imageScale, _largerFrame.size.width*imageScale/imgAspectRatio);

                    textView.frame = CGRectMake(20.0 + _largerFrame.size.width*imageScale, 10,
                                                size.width - (30.0 + _largerFrame.size.width*imageScale),
                                                size.height - 20.0);

                } completion:^(BOOL finished) {
                    
                    [self addVideoAndPhotoButtonWithContainerSize:_largerFrame.size];
                    [self addPhotoTableViewToBottomOf:imgView];
                    [self addVideoTableViewToBottomOf:photosTableView];
                    [self addKeyImageTitle];
                    [self addGestureRecognizers];
                    [self addBackgroundVeilView];
                }];
            }
            else {
                [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    uiView.frame = _largerFrame;

                    imgView.frame = CGRectMake(10, 10, _largerFrame.size.width*imageScale*imgAspectRatio, _largerFrame.size.width*imageScale);
                    textView.frame = CGRectMake(10, 20+_largerFrame.size.width*imageScale, size.width-20, size.height-(20+_largerFrame.size.width*imageScale));
                } completion:^(BOOL finished) {
                                        
                    [self addVideoAndPhotoButtonWithContainerSize:_largerFrame.size];
                    [self addPhotoTableViewToBottomOf:imgView];
                    [self addVideoTableViewToBottomOf:photosTableView];
                    [self addKeyImageTitle];
                    [self addGestureRecognizers];
                }];
            }
            
        }
        else {
            
            [self addVideoAndPhotoButtonWithContainerSize:size];
            
        }
        
    }
    return self;
}

-(void)addVideoAndPhotoButtonWithContainerSize:(CGSize)size {
    // Photo & Video link (impl. as a UIButton of 44x44 pts)
    CGRect photoButtonFrame;
    if (_type == CCUIPopupViewTypeLarge)
        photoButtonFrame = CGRectMake(8 + 44+8, size.height-44-8, 44, 44);
    else
        photoButtonFrame = CGRectMake(size.width-8-44, 8, 44, 44);
    
    if (self.type == CCUIPopupViewTypeDefault) {
        UIButton *photoButton = [[UIButton alloc] initWithFrame:photoButtonFrame];
        photoButton.tag = kPhotoButtonTag;
        [photoButton setBackgroundImage:[UIImage imageNamed:@"photo-button-ipad.png"] forState:UIControlStateNormal];
        [photoButton addTarget:self action:@selector(photoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [uiView addSubview:photoButton];
        [photoButton release];
    }
    
    CGRect videoButtonFrame;
    if (_type == CCUIPopupViewTypeLarge)
        videoButtonFrame = CGRectMake(8, size.height-44-8, 44, 44);
    else
        videoButtonFrame = CGRectMake(size.width-(8+44)*2+4, 8, 44, 44);
    
    if (self.type == CCUIPopupViewTypeDefault) {
        UIButton *videoButton = [[UIButton alloc] initWithFrame:videoButtonFrame];
        videoButton.tag = kVideoButtonTag;
        [videoButton setBackgroundImage:[UIImage imageNamed:@"video-button-ipad.png"] forState:UIControlStateNormal];
        [videoButton addTarget:self action:@selector(videoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [uiView addSubview:videoButton];
        [videoButton release];
    }
}

-(void) addPhotoTableViewToBottomOf:(UIView *)view {
    // UITableView only for large style
    if (_type == CCUIPopupViewTypeLarge) {
        UITableView *tv = [[UITableView alloc] initWithFrame:CGRectMake(10, view.frame.origin.y + view.frame.size.height+10, 84, view.frame.size.width) style:UITableViewStylePlain];
        
        tv.dataSource = self;
        tv.delegate = self;
        
        tv.backgroundColor = [UIColor clearColor];
        tv.separatorColor = [UIColor clearColor];
        
        CGAffineTransform t = CGAffineTransformMakeRotation(M_PI/2.0);
        CGAffineTransform tt = CGAffineTransformTranslate(t, -tv.frame.size.height*0.5+tv.frame.size.width*0.5, -tv.frame.size.height*0.5+tv.frame.size.width*0.5);
        
        tv.transform = tt;
        
        tv.tag = kPhotosTableViewTag;
        [uiView addSubview:tv];
        
        // Keep a reference (private member)
        photosTableView = tv;
        
        [tv release];
    }
}

-(void) addVideoTableViewToBottomOf:(UIView *)view {
    if (_type == CCUIPopupViewTypeLarge) {
        UITableView *tv = [[UITableView alloc] initWithFrame:CGRectMake(10, view.frame.origin.y + view.frame.size.height+10, 120, view.frame.size.width) style:UITableViewStylePlain];
        
        tv.dataSource = self;
        tv.delegate = self;
        
        tv.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.1];
        tv.separatorColor = [UIColor clearColor];
        
        CGAffineTransform t = CGAffineTransformMakeRotation(M_PI/2.0);
        CGAffineTransform tt = CGAffineTransformTranslate(t, -tv.frame.size.height*0.5+tv.frame.size.width*0.5, -tv.frame.size.height*0.5+tv.frame.size.width*0.5);
        
        tv.transform = tt;
        
        tv.tag = kVideosTableViewTag;
        [uiView addSubview:tv];
        
        // Keep a reference (private member)
        videosTableView = tv;
        
        [tv release];
    }
}

-(void) addKeyImageTitle {
    
    UIImageView *keyImageView = (UIImageView *)[uiView viewWithTag:kKeyImageViewTag];
    CGPoint o = keyImageView.frame.origin;
    CGSize s = keyImageView.frame.size;
    
    UILabel *keyImageTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(o.x, o.y+10, s.width*0.9, 30.0)];
    keyImageTitleLabel.tag = kKeyImageTitleLabelTag;
    keyImageTitleLabel.text = [NSString stringWithFormat:@" %@", self.keyImageTitle];
    keyImageTitleLabel.font = [UIFont systemFontOfSize:18.0];
    keyImageTitleLabel.textColor = [UIColor whiteColor];
    keyImageTitleLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    
    keyImageTitleLabel.hidden = YES;
    
    [uiView addSubview:keyImageTitleLabel];
    
    [keyImageTitleLabel release];
}

-(void)showKeyImageTitle {
    if (keyImageShowing && self.type == CCUIPopupViewTypeLarge) {
        UILabel *keyImageTitleLabel = (UILabel *) [uiView viewWithTag:kKeyImageTitleLabelTag];
        if (keyImageTitleLabel.hidden == YES) {
            keyImageTitleLabel.hidden = NO;
            
            [UIView animateWithDuration:1.0 delay:3.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                keyImageTitleLabel.alpha = 0.0;
            } completion:^(BOOL finished) {
                keyImageTitleLabel.hidden = YES;
                keyImageTitleLabel.alpha = 1.0;
            }];
        }
    }
}

-(void)hideKeyImageTitle {
    UILabel *keyImageTitleLabel = (UILabel *) [uiView viewWithTag:kKeyImageTitleLabelTag];
    keyImageTitleLabel.hidden = YES;
}

-(void)handleKeyImagePinch:(UIPinchGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        CCLOG(@"pinch scale = %.2f", gesture.scale);

        if (gesture.scale > 1.0) {
            // expand photo to occupy to full extent
            UIImageView *keyImageView = (UIImageView *) gesture.view;
            
            // UIKit Frame
            // Compute new frame
            float aspect_ratio = keyImageView.frame.size.width / keyImageView.frame.size.height;
            
            float newHeight = screenSize.height;
            float newWidth = newHeight * aspect_ratio;
            
            if (newWidth > screenSize.width) {  // width too much, readjust height
                newWidth = screenSize.width;
                newHeight = newWidth / aspect_ratio;
            }
            
            float newOriginX = (screenSize.width - newWidth) * 0.5;
            float newOriginY = (screenSize.height - newHeight) * 0.5;
            
            CGRect newFrame = CGRectMake(newOriginX, newOriginY, newWidth, newHeight);
            CGRect localNewFrame = [uiView convertRect:newFrame fromView:[CCDirector sharedDirector].view];
            
            
            [uiView bringSubviewToFront:keyImageView];
            [UIView animateWithDuration:0.5 animations:^{
                keyImageView.frame = localNewFrame;
            }];
            
            uiView.layer.borderWidth = 0.0f;  // Remove popup border width
            
            // Activate the veil
            UIView *v = [uiView viewWithTag:kBackgroundVeilViewTag];
            v.hidden = NO;
        }
        else {
            // shrink photo back to original size
            [self shrinkKeyImageBackToOriginal];
        }
        
    }
}

-(void) shrinkKeyImageBackToOriginal {
    UIImageView *imgView = (UIImageView *) [uiView viewWithTag:kKeyImageViewTag];
    imageScale = 0.5;
    
    float aspect_ratio = imgView.frame.size.width / imgView.frame.size.height;
    
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        imgView.frame = CGRectMake(10, 10, _largerFrame.size.width*imageScale, _largerFrame.size.width*imageScale/aspect_ratio);
    } completion:^(BOOL finished) {
        uiView.layer.borderWidth = 4.0f;  // rerender popup border width
        
        // Deactivate the veil
        UIView *v = [uiView viewWithTag:kBackgroundVeilViewTag];
        v.hidden = YES;
    }];
}

-(void)handleTouchOnBgVeil:(UIGestureRecognizer *)gesture {
    [self shrinkKeyImageBackToOriginal];
    
    // dismiss any webview video present
    SLWebViewVideoPlayer *v = (SLWebViewVideoPlayer *) [self getChildByTag:kWebViewVideoPlayerTag];
    [v removeFromParentAndCleanup:YES];
}

-(void) addGestureRecognizers {
    UIImageView *keyImageView = (UIImageView *)[uiView viewWithTag:kKeyImageViewTag];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showKeyImageTitle)];
    [keyImageView addGestureRecognizer:tap];
    [tap release];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showKeyImageTitle)];
    [keyImageView addGestureRecognizer:longPress];
    [longPress release];
    
    UISwipeGestureRecognizer *swipeLR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showKeyImageTitle)];
    swipeLR.direction = (UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight);
    [keyImageView addGestureRecognizer:swipeLR];
    [swipeLR release];
    
    UISwipeGestureRecognizer *swipeUD = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showKeyImageTitle)];
    swipeUD.direction = (UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown);
    [keyImageView addGestureRecognizer:swipeUD];
    [swipeUD release];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleKeyImagePinch:)];
    [keyImageView addGestureRecognizer:pinch];
    [pinch release];
    
    //    UITextView *textView = (UITextView *)[uiView viewWithTag:kTextViewTag];
    //    UITapGestureRecognizer *tapOnTextView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showKeyImageTitle)];
    //    [textView addGestureRecognizer:tapOnTextView];
    //    [tapOnTextView release];
}

-(void) addBackgroundVeilView {
    UIView *bgVeilView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    bgVeilView.tag = kBackgroundVeilViewTag;
    bgVeilView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
    bgVeilView.hidden = YES;
    bgVeilView.userInteractionEnabled = YES;
    
    CGPoint o = [uiView convertPoint:CGPointZero fromView:[CCDirector sharedDirector].view];
    bgVeilView.frame  = CGRectMake(o.x, o.y, screenSize.width, screenSize.height);
    
    // add gesture handlers for touches
    UITapGestureRecognizer *t = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchOnBgVeil:)] autorelease];
    t.numberOfTapsRequired = 1;
    [bgVeilView addGestureRecognizer:t];

    UISwipeGestureRecognizer *s = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchOnBgVeil:)] autorelease];
    [bgVeilView addGestureRecognizer:s];
    
    UIPanGestureRecognizer *p =[[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchOnBgVeil:)] autorelease];
    [bgVeilView addGestureRecognizer:p];
    
    UIPinchGestureRecognizer *pi = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchOnBgVeil:)] autorelease];
    [bgVeilView addGestureRecognizer:pi];
    
    [uiView addSubview:bgVeilView];
    [bgVeilView release];
}

#pragma mark - Life Cycle
-(id)init {
    return [self initWithParentNode:nil withType:CCUIPopupViewTypeDefault withGlFrame:CGRectMake(10, 10, 10, 10) animateToLargerGlFrame:CGRectMake(10, 10, 10, 10) withKeyImage:nil withText:@"I am CCUIPopupView"];
}

-(void) removeFromParentAndCleanup:(BOOL)cleanup {
    UIImageView *imgView = (UIImageView *) [uiView viewWithTag:kKeyImageViewTag];
    UITextView *textView = (UITextView *) [uiView viewWithTag:kTextViewTag];
    
    imgView.alpha = 0.0;
    textView.alpha = 0.0;
    
    [UIView animateWithDuration:0.4 animations:^{
        uiView.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        [super removeFromParentAndCleanup:cleanup];
    }];
}

#pragma mark - Getters & Setters
//-(CGRect)boundingBox {
//    return CGRectMake(self.position.x - self.contentSize.width*self.anchorPoint.x, self.position.y - self.contentSize.height*self.anchorPoint.y, self.contentSize.width, self.contentSize.height);
//}

-(void) setText:(NSString *)text {
    _text = text;
    UITextView *textView = (UITextView *) [uiView viewWithTag:kTextViewTag];
    textView.text = _text;
}

-(NSString*) text {
    return _text;
}

-(void) setKeyImage:(UIImage *)keyImage {
    _keyImage = keyImage;
    UIImageView *imgView = (UIImageView *) [uiView viewWithTag:kKeyImageViewTag];
    imgView.image = _keyImage;
}

-(UIImage*) keyImage {
    return _keyImage;
}

-(void) setFrame:(CGRect)frame {
    
    _frame = frame;
    
    CGPoint origin = [[CCDirector sharedDirector] convertToUI:frame.origin];
    CGSize size = frame.size;
    
    // Since this is really a CCNode, we would like to think in GL coordinate, and let the frame extend to the top right of the origin, we need to adjust for this.
    origin.y -= size.height;
    
    CGRect f = CGRectMake(origin.x, origin.y, size.width, size.height);
    
    uiView.frame = f;
    
    UITextView *textView = (UITextView *) [uiView viewWithTag:kTextViewTag];
    UIImageView *imgView = (UIImageView *) [uiView viewWithTag:kKeyImageViewTag];
    float imgAspectRatio = imgView.frame.size.width / imgView.frame.size.height;
    
    if (_type == CCUIPopupViewTypeLarge) {
        textView.frame = CGRectMake(20.0 + frame.size.width*imageScale, 10,
                                    size.width - (30.0 + frame.size.width*imageScale),
                                    size.height - 20.0);
        imgView.frame = CGRectMake(10, 10, frame.size.width*imageScale, frame.size.width*imageScale/imgAspectRatio);
    }
    else {
        textView.frame = CGRectMake(10, 20+frame.size.width*imageScale, size.width-20, size.height-(20+frame.size.width*imageScale));
        imgView.frame = CGRectMake(10, 10, frame.size.width*imageScale*imgAspectRatio, frame.size.width*imageScale);
    }
    
}

-(void)setBackgroundImageForFlipping:(UIImage *)bgImage withFlipAngle:(float)flipAngle withScale:(float)scale {
    
    self.flipAngle = flipAngle;
    self.scale = scale;
    
    // since we are going to make the anchor at (0.0, 0.5), we will left shift
    // the position of this flippableCover
    UIImageView *flippableCover = [[UIImageView alloc] initWithFrame:CGRectMake(-_frame.size.width*0.5, 0, _frame.size.width, _frame.size.height)];
    
    CGPoint origin  = _frame.origin;
    
    CGRect boundInUICoord = CGRectMake(origin.x*_scale, origin.y*_scale, _frame.size.width*_scale, _frame.size.height*_scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(bgImage.CGImage, boundInUICoord);
    
    flippableCover.image = [UIImage imageWithCGImage:imageRef];
    flippableCover.layer.cornerRadius = 10;
    flippableCover.clipsToBounds = YES;
    flippableCover.layer.borderColor = [[UIColor colorWithRed:41.0/255.0 green:219.0/255.0 blue:57.0/255.0 alpha:1] CGColor];
    flippableCover.layer.borderWidth = 1.0f;
    
    flippableCover.layer.masksToBounds = YES;
    
    
    CGImageRelease(imageRef);
    
    // check if flippableCover has been a subview, if so remove it
    UIImageView *previousFlippableCover = (UIImageView *)[uiView viewWithTag:kFlippableCoverImageView];
    if (previousFlippableCover != nil)
        [previousFlippableCover removeFromSuperview];
    
    [uiView addSubview:flippableCover];
    flippableCover.tag = kFlippableCoverImageView;
    [uiView bringSubviewToFront:flippableCover];
    
    flippableCover.layer.anchorPoint = CGPointMake(0.0, 0.5);
    
    [flippableCover release];
    
}

-(void) setPosition:(CGPoint)position {
    
    position = position;
    
    float x = position.x - _contentSize.width * 0.5;
    float y = position.y - _contentSize.height * 0.5;
    
    CGSize size = _frame.size;
    self.frame = CGRectMake(x, y, size.width, size.height);
    
}

-(void) setContentSize:(CGSize)contentSize {
    _contentSize = contentSize;
    
    CGPoint o = _frame.origin;
    self.frame = CGRectMake(o.x, o.y, contentSize.width, contentSize.height);
}

-(void)setFontSize:(float)fontSize {
    if (_fontSize != fontSize) {
        UITextView *textView = (UITextView *) [uiView viewWithTag:kTextViewTag];
        textView.font = [UIFont systemFontOfSize:fontSize];
    }
}

-(void)setAlpha:(float)alpha {
    _alpha = alpha;
    uiView.alpha = alpha;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    uiView.backgroundColor = backgroundColor;
    UITextView *textView = (UITextView *)[uiView viewWithTag:kTextViewTag];
    textView.backgroundColor = backgroundColor;
}

-(void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    UITextView *textView = (UITextView *)[uiView viewWithTag:kTextViewTag];
    textView.textColor = textColor;
}

-(void) setPhotoThumbnailArray:(NSArray *)photoThumbnailArray {
    NSArray *tmp = _photoThumbnailArray;
    if (_photoThumbnailArray != photoThumbnailArray) {
        _photoThumbnailArray = photoThumbnailArray;
        [_photoThumbnailArray retain];
        [tmp release];
        
        UITableView *photos = (UITableView*) [uiView viewWithTag:kPhotosTableViewTag];
        [photos reloadData];
    }
}

-(void) setVideoThumbnailArray:(NSArray *)videoThumbnailArray {
    NSArray *tmp = _videoThumbnailArray;
    if (_videoThumbnailArray != videoThumbnailArray) {
        _videoThumbnailArray = videoThumbnailArray;
        [_videoThumbnailArray retain];
        [tmp release];
        
        UITableView *videos = (UITableView *)[uiView viewWithTag:kVideosTableViewTag];
        [videos reloadData];
    }
}

-(void)setVideoUrlArray:(NSArray *)videoUrlArray {
    NSArray *tmp = _videoUrlArray;
    if (_videoUrlArray != videoUrlArray) {
        _videoUrlArray = videoUrlArray;
        [_videoUrlArray retain];
        [tmp release];
        
        UITableView *videos = (UITableView*)[uiView viewWithTag:kVideosTableViewTag];
        [videos reloadData];
    }
}

#pragma mark - Animations
-(void) flipOpen {
    
    if (!flippedOpen) {
        UIImageView *flippableCover = (UIImageView *)[uiView viewWithTag:kFlippableCoverImageView];
        CALayer *layer = flippableCover.layer;
        
        [UIView animateWithDuration:0.6 animations:^{
            CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
            rotationAndPerspectiveTransform.m34 = -1.0 / 1500.0;
            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, -self.flipAngle*2.0*M_PI/360.0, 0.0, 1.0, 0.0);
            layer.transform = rotationAndPerspectiveTransform;
        } completion:^(BOOL finished) {
            
        }];
        flippedOpen = YES;
    }
}

-(void) flipClose {
    if (flippedOpen) {
        UIImageView *flippableCover = (UIImageView *)[uiView viewWithTag:kFlippableCoverImageView];
        CALayer *layer = flippableCover.layer;
        
        [UIView animateWithDuration:0.5 animations:^{
            layer.transform = CATransform3DIdentity;
        } completion:^(BOOL finished) {
            
        }];
        flippedOpen = NO;
    }
}

-(void) flipCloseAndRemoveFromParentAndCleanup {
    if (flippedOpen) {
        
        // animate shrink view
        UIImageView *imgView = (UIImageView *) [uiView viewWithTag:kKeyImageViewTag];
        UITextView *textView = (UITextView *) [uiView viewWithTag:kTextViewTag];
        
        float imgAspectRatio = imgView.frame.size.width / imgView.frame.size.height;
        
        [UIView animateWithDuration:0.5 animations:^{
            CGSize size = _frame.size;
            uiView.frame = _frame;
            if (_type == CCUIPopupViewTypeLarge) {
                imgView.frame = CGRectMake(10, 10, _frame.size.width*imageScale, _frame.size.width*imageScale/imgAspectRatio);
                textView.frame = CGRectMake(20.0 + _frame.size.width*imageScale, 10,
                                            size.width - (30.0 + _frame.size.width*imageScale),
                                            size.height - 20.0);
            }
            else {
                imgView.frame = CGRectMake(10, 10, _frame.size.width*imageScale*imgAspectRatio, _frame.size.width*imageScale);
                textView.frame = CGRectMake(10, 20+_frame.size.width*imageScale, size.width-20, size.height-(20+_frame.size.width*imageScale));
            }
        }];
        
        UIImageView *flippableCover = (UIImageView *)[uiView viewWithTag:kFlippableCoverImageView];
        UIButton *videoButton = (UIButton *) [uiView viewWithTag:kVideoButtonTag];
        UIButton *photoButton = (UIButton *) [uiView viewWithTag:kPhotoButtonTag];
        videoButton.hidden = YES;
        photoButton.hidden = YES;
        CALayer *layer = flippableCover.layer;
        
        [UIView animateWithDuration:0.5 animations:^{
            layer.transform = CATransform3DIdentity;
        } completion:^(BOOL finished) {
            [self removeFromParentAndCleanup:YES];
        }];
        flippedOpen = NO;
    }
}

#pragma mark - Video/Photo link
-(void) photoButtonTapped:(UIButton*) sender {
    if ([self.delegate respondsToSelector:@selector(ccUIPopupViewPhotoLinkTapped:)]) {
        [self.delegate ccUIPopupViewPhotoLinkTapped:self];
    }
}

-(void) videoButtonTapped:(UIButton *) sender {
    if ([self.delegate respondsToSelector:@selector(ccUIPopupViewVideoLinkTapped:)]) {
        [self.delegate ccUIPopupViewVideoLinkTapped:self];
    }
}

#pragma mark - UITextView Delegates
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView.tag == kTextViewTag) {
        [self showKeyImageTitle];
    }
}

#pragma mark - Table View Source delegates
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == photosTableView)
        return [self.photoThumbnailArray count];
    else
        return [self.videoThumbnailArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //    UIImage *img = [self.photoThumbnailArray objectAtIndex:indexPath.row];
    //    return img.size.width;
    if (tableView == photosTableView)
        return 84;
    else
        return 110;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    if (tableView == photosTableView) {
        static NSString *PhotoCellIdentifier = @"Photo";
        
        cell = [tableView dequeueReusableCellWithIdentifier:PhotoCellIdentifier];
        //        UIImageView *photo;
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PhotoCellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.imageView.transform = CGAffineTransformMakeRotation(-M_PI/2.0);
            cell.backgroundColor = [UIColor clearColor];
        }
        
        UIImage *img = [self.photoThumbnailArray objectAtIndex:indexPath.row];
        
        cell.imageView.image = img;
        
        //    float r = img.size.height / img.size.width;
        
        //    photo.image = img;
    }
    else {
        static NSString *VideoCellIdentifier = @"Video";
        cell = [tableView dequeueReusableCellWithIdentifier:VideoCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:VideoCellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //            cell.imageView.transform = CGAffineTransformMakeRotation(-M_PI/2.0);
            
            cell.backgroundColor = [UIColor clearColor];
            cell.transform = CGAffineTransformMakeRotation(-M_PI/2.0);
            
            float r = 16.0/9.0;
            UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 84*r, 84)];
            webView.scalesPageToFit = YES;
            webView.backgroundColor = [UIColor blackColor];
            webView.userInteractionEnabled = YES;
            //        webView.transform = CGAffineTransformMakeRotation(-M_PI/2.0);
            if ([webView respondsToSelector:@selector(scrollView)])   // this is not available until iOS 5.0
                webView.scrollView.scrollEnabled = NO;
            else {
                for (id subview in webView.subviews) {
                    if ([[subview class] isSubclassOfClass:[UIScrollView class]])
                        //                    ((UIScrollView *)subview).scrollEnabled = NO;
                        ;
                }
            }
            webView.tag = 12345;
            [cell.contentView addSubview:webView];
            
            UIView *pane = [[UIView alloc] initWithFrame:webView.frame];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoThumbNailTapped:)];
            tap.numberOfTapsRequired = 1;
            [pane addGestureRecognizer:tap];
            [tap release];
            
            [cell.contentView addSubview:pane];
            [cell.contentView bringSubviewToFront:pane];
            
            [pane release];
            [webView release];
            

        }
        
        NSString *thumbnailUrlStr = [self.videoThumbnailArray objectAtIndex:indexPath.row];
        
        UIWebView *webView = (UIWebView *)[cell.contentView viewWithTag:12345];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:thumbnailUrlStr]]];
        
        // package the video url in cell's text, but dont show it.
        cell.textLabel.text = self.videoUrlArray[indexPath.row];
        cell.textLabel.hidden = YES;

//        float r = 16.0/9.0;
//        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 84*r, 84)];
//        webView.scalesPageToFit = YES;
//        webView.backgroundColor = [UIColor blackColor];
//        //        webView.transform = CGAffineTransformMakeRotation(-M_PI/2.0);
//        if ([webView respondsToSelector:@selector(scrollView)])   // this is not available until iOS 5.0
//            webView.scrollView.scrollEnabled = NO;
//        else {
//            for (id subview in webView.subviews) {
//                if ([[subview class] isSubclassOfClass:[UIScrollView class]])
//                    //                    ((UIScrollView *)subview).scrollEnabled = NO;
//                    ;
//            }
//        }
    }
    
    return cell;
}

#pragma mark - Table View Delegates


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CCLOG(@"%d selected in photo slide", indexPath.row);
    // load it as big key photo
    UIImage *img = [self.photoThumbnailArray objectAtIndex:indexPath.row];
    
    UIImageView *keyImageView = (UIImageView *)[uiView viewWithTag:kKeyImageViewTag];
//    keyImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    float originalWidth = keyImageView.frame.size.width;
    
    float availableVerticalHeight = tableView.frame.origin.y;
        
    float aspect_ratio = img.size.width / img.size.height;
    float newHeight = originalWidth/aspect_ratio;
    
    keyImageView.image = img;
    
    CGPoint origin = ccp(10.0, availableVerticalHeight*0.5 - newHeight*0.5 + 10);
    
    keyImageView.frame = CGRectMake(origin.x, origin.y, originalWidth, newHeight);
    
    keyImageShowing = NO;   // key image view no long showing the key image, but one from the photo strips
}

-(void) videoThumbNailTapped:(UITapGestureRecognizer *)sender {
    if ([[[sender.view superview] superview] isMemberOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = (UITableViewCell *)[[sender.view superview] superview];
        NSString *urlStr = cell.textLabel.text;
        
        // Install a video player based on a webview if one doesnt exist
        SLWebViewVideoPlayer *webViewViewPlayer = (SLWebViewVideoPlayer*)[self getChildByTag:kWebViewVideoPlayerTag];
        if (webViewViewPlayer == nil) {
            webViewViewPlayer = [SLWebViewVideoPlayer slWebViewVideoPlayerWithParentNode:self withVideoURL:urlStr withDelegate:self];
            webViewViewPlayer.tag = kWebViewVideoPlayerTag;
            
            // Activate the veil
            UIView *v = [uiView viewWithTag:kBackgroundVeilViewTag];
            v.hidden = NO;
            return;
        }
        
        [webViewViewPlayer reloadWithVideoURL:urlStr];
        
        // Activate the veil
        UIView *v = [uiView viewWithTag:kBackgroundVeilViewTag];
        v.hidden = NO;
    }
}

#pragma mark - SLWebViewVideoPlayerDelegate
-(void)sLWebViewVideoPlayerDidFinishLoad:(SLWebViewVideoPlayer *)wvPlayer {
    
}

-(void)sLWebViewVideoPlayer:(SLWebViewVideoPlayer *)webView didFailLoadWithError:(NSError *)error {
    NSString *desc = [error localizedDescription];
    NSInteger code = [error code];
    NSString *domain = [error domain];
    CCLOG(@"Failed with code = %d, domain=%@, desc=%@", code, domain, desc);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Please check your WiFi or cellular data network and try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}


@end

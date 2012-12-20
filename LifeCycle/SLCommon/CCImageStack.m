//
//  CCImageStack.m
//  SLCommon
//
//  Created by Kelvin Chan on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CCImageStack.h"

@interface CCImageStack (Private)
-(CCSprite *) makeNewSpriteWithImageNamed:(NSString *)imageName;
-(void) replaceSpriteTextureForSprite:(CCSprite *) sprite withImageNamed:(NSString *)imageName;
@end

@interface CCImageStack ()
@property (nonatomic, retain) CCArray *imageSprites;
@property (nonatomic, retain) CCArray *imageFrameSprites;
@end

@implementation CCImageStack

@synthesize images, imageScales, imageTitles, imageAttributions;
@synthesize imageAtlasPlistName, imageAtlasPngName;
//@synthesize imagesBatchNode;

@synthesize imageSprites=_imageSprites;
@synthesize imageFrameSprites=_imageFrameSprites;

-(void)dealloc{

    [images release];
    [imageScales release];
    [imageTitles release];
    [imageAttributions release];
    
    [_imageSprites release];
    [_imageFrameSprites release];
    
    [imageAtlasPlistName release];
    [imageAtlasPngName release];
//    [imagesBatchNode release];
    
    [super dealloc];
}

#pragma mark - Initializers

+ (CCImageStack *) ccImageStack {
    // figure out the size
    // CCSprite *dummy = [CCSprite spriteWithFile:@"ImageFrameLite.png"];
    // CGSize size = dummy.boundingBox.size;
    // CCLOG(@"dummy size = %f, %f", size.width, size.height);
    
    CGSize size = CGSizeMake(435.0, 443.0);
    
    CCImageStack *c = [[CCImageStack alloc] init];
    c.contentSize = size;
    [c autorelease];
    return c;
}

-(id)init {

    self = [super init];
    if (self) {
        screenSize = [CCDirector sharedDirector].winSize;
    }
    return self;
}

#pragma mark - Lazy Getters

-(CCArray *) imageSprites {
    if (_imageSprites == nil) 
        _imageSprites = [[CCArray alloc] init];
    return _imageSprites;
}

-(CCArray *) imageFrameSprites {
    if (_imageFrameSprites == nil) 
        _imageFrameSprites = [[CCArray alloc] init];
    return _imageFrameSprites;
}

#pragma mark - lifecycle hooks

-(void)onEnter {
    [super onEnter];
    
    if (self.images == nil || [self.images count] == 0) {
        return;
    }
    
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    
    CGSize size = self.boundingBox.size;
    CGPoint origin = self.boundingBox.origin;
    
    dAngle = 8.0f / [self.images count];
    dX = 40.0f / [self.images count];

//    [imagesBatchNode.texture setAntiAliasTexParameters];
    
    N = [self.images count];
    
    numberOfRecyclableImageSprites = 3;

    imageIndexOnTop = 0;
    imageIndexAtBack = N-1;
    
    imgHeightAdjustment = -35.0f;
//    w = size.width/2.0f + origin.x;
//    h2 = size.height/2.0f + origin.y;
//    h = size.height + origin.y;
    w = size.width/2.0f;
    h2 = size.height/2.0f;
    h = size.height;
    textLeftMargin = 0.0;
    
    titleLabelHeight = 80;
    attributionLabelHeight = 30;
    
    int order = 0;
    int i;
    for (int k = imageIndexOnTop; ; k++) {
        
        if (order == N - 1) break;
        
        i = k % N;
        
        // Constructing the images themselves, optimize to only render top 2 and the back
        if (order < numberOfRecyclableImageSprites-1) {
            // The polaroid-like frame
            CCSprite *iframe = [self makeNewSpriteWithImageNamed:@"ImageFrameLite.png"];

            iframe.position = ccp(w + order*dX, h2);
            iframe.rotation = order*dAngle;
                        
//            [imagesBatchNode addChild:iframe z:(N-order-1)];
            [self addChild:iframe z:(N-order-1)];

            [self.imageFrameSprites insertObject:iframe atIndex:order];
            
            // The image
            CCSprite *imgSprite = [self makeNewSpriteWithImageNamed:[self.images objectAtIndex:order]];

            imgSprite.anchorPoint = ccp(0.5, 1.0);
            imgSprite.scale = [[self.imageScales objectAtIndex:order] floatValue];
            imgSprite.position = ccp(w + order*dX, h + imgHeightAdjustment);
                        
//            [imagesBatchNode addChild:imgSprite z:(N-order-1)];
            [self addChild:imgSprite z:(N-order-1)];

            [self.imageSprites insertObject:imgSprite atIndex:order];
        }
        order++;
    }
    // Treat the last card specially, it's will have twice displacement and angle.
    
    int last_count_index = MIN([self.images count], numberOfRecyclableImageSprites) - 1;
    
    CCSprite *iframe = [self makeNewSpriteWithImageNamed:@"ImageFrameLite.png"];
    CCSprite *imgSprite = [self makeNewSpriteWithImageNamed:[self.images objectAtIndex:last_count_index]];
    
    iframe.position = ccp(w + last_count_index*dX, h2);
    iframe.rotation = last_count_index*dAngle;
    
//    [imagesBatchNode addChild:iframe z:(N-order-1)];    
    [self addChild:iframe z:(N-order-1)];    

    [self.imageFrameSprites insertObject:iframe atIndex:last_count_index];
    
    // Constructing the images themselves
    imgSprite.anchorPoint = ccp(0.5, 1.0);
    imgSprite.scale = [[self.imageScales objectAtIndex:order] floatValue];
    imgSprite.position = ccp(w + last_count_index*dX, h + imgHeightAdjustment);
    // imgSprite.rotation = order*dAngle;
    
    [self addChild:imgSprite z:(N-order-1)];

    [self.imageSprites insertObject:imgSprite atIndex:last_count_index];

    // put label and attribution
    
    NSString *title = [self.imageTitles objectAtIndex:imageIndexOnTop];
    NSString *attribution = [NSString stringWithFormat:@"-%@",[self.imageAttributions objectAtIndex:imageIndexOnTop]];
    CCSprite *topSprite = [self.imageSprites objectAtIndex:imageIndexOnTop];
    
    CGSize dimension = CGSizeMake(topSprite.boundingBox.size.width, 50);
    
    titleLabel = [CCLabelTTF labelWithString:title dimensions:dimension alignment:UITextAlignmentLeft fontName:@"ArialMT" fontSize:16.0];
    titleLabel.color = ccc3(0, 0, 0);
    titleLabel.anchorPoint = ccp(0.5, 0.5);
    titleLabel.position = ccp(w + textLeftMargin, titleLabelHeight);
//    [self addChild:titleLabel z:(N-1)];
    [self addChild:titleLabel z:20];
    
    attributionLabel = [CCLabelTTF labelWithString:attribution dimensions:dimension alignment:UITextAlignmentRight fontName:@"ArialMT" fontSize:11.0];
    attributionLabel.color = ccc3(0.0, 0.0, 0.0);
    attributionLabel.anchorPoint = ccp(0.5, 0.5);
    attributionLabel.position = ccp(w + textLeftMargin, attributionLabelHeight);
//    [self addChild:attributionLabel z:(N-1)];
    [self addChild:attributionLabel z:20];
    
    // Execute move card demo (show ppl know the stack can be swiped
    CCSprite *ifr = [self.imageFrameSprites objectAtIndex:0];
    CCSprite *img = [self.imageSprites objectAtIndex:0];
    
    id showAndHideAction1 = [CCSequence actions:
                             [CCMoveBy actionWithDuration:0.6 position:ccp(-40, 0)],
                             [CCMoveBy actionWithDuration:0.6 position:ccp(40, 0)],
                            nil];
    
    id showAndHideAction2 = [CCSequence actions:
                             [CCMoveBy actionWithDuration:0.6 position:ccp(-40, 0)],
                             [CCMoveBy actionWithDuration:0.6 position:ccp(40, 0)],
                             nil];
    
    id showAndHideAction3 = [CCSequence actions:
                             [CCMoveBy actionWithDuration:0.6 position:ccp(-40, 0)],
                             [CCMoveBy actionWithDuration:0.6 position:ccp(40, 0)],
                             nil];
    
    id showAndHideAction4 = [CCSequence actions:
                             [CCMoveBy actionWithDuration:0.6 position:ccp(-40, 0)],
                             [CCMoveBy actionWithDuration:0.6 position:ccp(40, 0)],
                             nil];
    
    [ifr runAction:showAndHideAction1];
    [img runAction:showAndHideAction2];
    [titleLabel runAction:showAndHideAction3];
    [attributionLabel runAction:showAndHideAction4];
    // */
}

-(void)onExit {
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super onExit];
}

#pragma mark - Sprite Creating Logic
-(CCSprite *) makeNewSpriteWithImageNamed:(NSString *)imageName {
    
//    CCSprite *s = [CCSprite spriteWithFile:imageName];
    
    CCSprite *s = nil;
    @try {
        CCSpriteFrame *f = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:imageName];
        if (f != nil)
            s = [CCSprite spriteWithSpriteFrame:f];
        else 
            s = [CCSprite spriteWithFile:imageName];
    }
    @catch (NSException *NSInternalInconsistencyException) {
        s = [CCSprite spriteWithFile:imageName];
    }
    @finally {
        ;
    }
    
    return s;
}

-(void) replaceSpriteTextureForSprite:(CCSprite *) sprite withImageNamed:(NSString *)imageName {
    CCSpriteFrame *spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:imageName];
    if (spriteFrame != nil)
        [sprite setDisplayFrame:spriteFrame];
    else {
        UIImage *image = [UIImage imageNamed:imageName];
        [[CCTextureCache sharedTextureCache] addImage:imageName];
        
        [sprite setTexture:[[CCTextureCache sharedTextureCache] textureForKey:imageName]];
        [sprite setTextureRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    }
}

#pragma mark - Deck animations
-(void)setAndAnimateTopImageToBack {
    
    imageIndexOnTop = (imageIndexOnTop+1) % N;
    imageIndexAtBack = (imageIndexAtBack+1) % N;
    float duration = 0.5f;
    
    CCAction *actionForTitle = [CCEaseOut actionWithDuration:0.5];
    CCAction *actionForAttribution = [CCEaseOut actionWithDuration:0.5];
    [titleLabel runAction:actionForTitle];
    [attributionLabel runAction:actionForAttribution];

    int order = 0;
    int i;
    int k;
    for (k = imageIndexOnTop;; k++) {
        if (order == N - 1) break;
        
        i = k % N;
        
        if (order < numberOfRecyclableImageSprites-1) {
            
            // The frame
            // CCSprite *iframe = [self.imageFrameSprites objectAtIndex:i];
            CCSprite *iframe = [self.imageFrameSprites objectAtIndex:order+1];

            [self reorderChild:iframe z:(N-order-1)];

            
            CCAction *actionForIframe = [CCSpawn actions:
                                         [CCMoveTo actionWithDuration:duration position:ccp(w + order*dX, h2)],
                                         [CCRotateTo actionWithDuration:duration angle:(order*dAngle)],
                                         nil];
            [iframe runAction:actionForIframe];

            // The image

            NSString *imageName = [self.images objectAtIndex:i];
            UIImage *image = [UIImage imageNamed:imageName];
            [[CCTextureCache sharedTextureCache] addImage:imageName];
            
            CCSprite *img = [self.imageSprites objectAtIndex:order+1];
            [img setTexture:[[CCTextureCache sharedTextureCache] textureForKey:imageName]];
            [img setTextureRect:CGRectMake(0, 0, image.size.width, image.size.height)];
            
            [self reorderChild:img z:(N-order-1)];
            
            CCAction *actionForImg = [CCSpawn actions:
                                      [CCMoveTo actionWithDuration:duration position:ccp(w + order*dX, h + imgHeightAdjustment)],
                                      [CCRotateTo actionWithDuration:duration angle:(order*dAngle)],
                                      nil];
            
            [img runAction:actionForImg];
        }
        
        order++;
    }
    
    int last_count_index = MIN([self.images count], numberOfRecyclableImageSprites) - 1;
    
    // Animate old front card to the back
    
    CCSprite *iframe = [self.imageFrameSprites objectAtIndex:0];
    [self reorderChild:iframe z:(N-order-1)];


    CCAction *actionForIframe = [CCSpawn actions:
                                 [CCMoveTo actionWithDuration:duration position:ccp(w + last_count_index*dX, h2)],
                                 [CCRotateTo actionWithDuration:duration angle:(last_count_index*dAngle)],
                                 nil];
    [iframe runAction:actionForIframe];
    
    CCSprite *img = [self.imageSprites objectAtIndex:0];
    [self replaceSpriteTextureForSprite:img withImageNamed:[self.images objectAtIndex:(k % N)]];
        
    [self reorderChild:img z:(N-order-1)];
    
    CCAction *actionForImg = [CCSpawn actions:
                              [CCMoveTo actionWithDuration:duration position:ccp(w + last_count_index*dX, h + imgHeightAdjustment)],
                              nil];
    
    [img runAction:actionForImg];
    
    // Reorder the self.imageSprites to 0, 1, ..., N-1
    for (int j = 1; j < last_count_index+1; j++) {
        [self.imageSprites exchangeObjectAtIndex:j-1 withObjectAtIndex:j];
        [self.imageFrameSprites exchangeObjectAtIndex:j-1 withObjectAtIndex:j];
    }
    
    // bring up the new titlelabel string for the top card
    NSString *title = [self.imageTitles objectAtIndex:imageIndexOnTop];
    NSString *attribution = [NSString stringWithFormat:@"-%@", [self.imageAttributions objectAtIndex:imageIndexOnTop]];
    
    titleLabel.string = title;    
    titleLabel.position = ccp(w + textLeftMargin, titleLabelHeight);
    CCAction *actionForTitle2 = [CCFadeIn actionWithDuration:0.5];
    [titleLabel runAction:actionForTitle2];
    
    attributionLabel.string = attribution;
    attributionLabel.position = ccp(w + textLeftMargin, attributionLabelHeight);
    CCAction *actionForAttribution2 = [CCFadeIn actionWithDuration:0.5];
    [attributionLabel runAction:actionForAttribution2];
    
}

-(void)setAndAnimateBackImageToTop {

    imageIndexOnTop = (imageIndexOnTop+N-1) % N;
    imageIndexAtBack = (imageIndexAtBack+N-1) % N;

    float duration = 0.5f;
    
    CCAction *actionForTitle = [CCEaseOut actionWithDuration:0.5];
    CCAction *actionForAttribution = [CCEaseOut actionWithDuration:0.5];
    [titleLabel runAction:actionForTitle];
    [attributionLabel runAction:actionForAttribution];
    
    int last_count_index = MIN([self.images count], numberOfRecyclableImageSprites) - 1;
    int order = 0;
    int i;
    int k;
    for (k = imageIndexOnTop;; k++) {
        if (order == N-1) break;
        
        i = k % N;
        
        if (order < numberOfRecyclableImageSprites-1) {
            
            CCSprite *iframe = [self.imageFrameSprites objectAtIndex:((order + last_count_index) % (last_count_index+1))];
            [self reorderChild:iframe z:(N-order-1)];

            
            CCAction *actionForIframe = [CCSpawn actions:
                                         [CCMoveTo actionWithDuration:duration position:ccp(w + order*dX, h2)],
                                         [CCRotateTo actionWithDuration:duration angle:(order*dAngle)],
                                         nil];
            [iframe runAction:actionForIframe];
            
            CCSprite *img = [self.imageSprites objectAtIndex:((order+last_count_index) % (last_count_index+1))];

            [self replaceSpriteTextureForSprite:img withImageNamed:[self.images objectAtIndex:i]];
            
            [self reorderChild:img z:(N-order-1)];

            
            CCAction *actionForImg = [CCSpawn actions:
                                      [CCMoveTo actionWithDuration:duration position:ccp(w + order*dX, h + imgHeightAdjustment)],
                                      [CCRotateTo actionWithDuration:duration angle:(order*dAngle)],
                                      nil];
            
            [img runAction:actionForImg];
        }
        order++;
    }

    // Animate old b
    CCSprite *iframe = [self.imageFrameSprites objectAtIndex:last_count_index-1];
    
    [self reorderChild:iframe z:(N-order-1)];
    
    CCAction *actionForIframe = [CCSpawn actions:
                                 [CCMoveTo actionWithDuration:duration position:ccp(w + last_count_index*dX, h2)],
                                 [CCRotateTo actionWithDuration:duration angle:(last_count_index*dAngle)],
                                 nil];

    [iframe runAction:actionForIframe];

    CCSprite *img = [self.imageSprites objectAtIndex:last_count_index-1];

    [self replaceSpriteTextureForSprite:img withImageNamed:[self.images objectAtIndex:(k % N)]];

    [self reorderChild:img z:(N-order-1)];

    CCAction *actionForImg = [CCSpawn actions:
                              [CCMoveTo actionWithDuration:duration position:ccp(w + last_count_index*dX, h + imgHeightAdjustment)],
                              // [CCRotateTo actionWithDuration:duration angle:((order+1)*dAngle)],
                              nil];
    [img runAction:actionForImg];
    
    // Reorder the self.imageSprites to 0, 1, N-1
    for (int j = last_count_index-1; j >= 0; j--) {

        [self.imageSprites exchangeObjectAtIndex:j withObjectAtIndex:j+1];
        [self.imageFrameSprites exchangeObjectAtIndex:j withObjectAtIndex:j+1];

    }
    
    // bring up the new titlelabel string for the top card
    NSString *title = [self.imageTitles objectAtIndex:imageIndexOnTop];
    NSString *attribution = [NSString stringWithFormat:@"-%@", [self.imageAttributions objectAtIndex:imageIndexOnTop]];
    
    titleLabel.string = title;    
    titleLabel.position = ccp(w + textLeftMargin, titleLabelHeight);
    CCAction *actionForTitle2 = [CCFadeIn actionWithDuration:2.0];
    [titleLabel runAction:actionForTitle2];
    
    attributionLabel.string = attribution;
    attributionLabel.position = ccp(w + textLeftMargin, attributionLabelHeight);
    CCAction *actionForAttribution2 = [CCFadeIn actionWithDuration:2.0];
    [attributionLabel runAction:actionForAttribution2];

}

-(void) animateTopImageToOriginal {

    CCSprite *iframe = [self.imageFrameSprites objectAtIndex:0];

    CCAction *actionForIframe = [CCMoveTo actionWithDuration:0.5 position:ccp(w, h2)];
    [iframe runAction:actionForIframe];

    CCSprite *img = [self.imageSprites objectAtIndex:0];
    
    CCAction *actionForImg = [CCMoveTo actionWithDuration:0.5 position:ccp(w, h + imgHeightAdjustment)];
    [img runAction:actionForImg];
    
    CCAction *actionForTitle = [CCMoveTo actionWithDuration:0.5 position:ccp(w + textLeftMargin, titleLabelHeight)];
    [titleLabel runAction:actionForTitle];
    
    CCAction *actionForAttribution = [CCMoveTo actionWithDuration:0.5 position:ccp(w + textLeftMargin, attributionLabelHeight)];
    [attributionLabel runAction:actionForAttribution];
    
}

-(void) animateBackImageToOriginal {
    
    int last_count_index = MIN([self.images count], numberOfRecyclableImageSprites) - 1;

    CCSprite *iframe = [self.imageFrameSprites objectAtIndex:last_count_index];

    CCAction *actionForIframe = [CCSpawn actions:
                                 [CCMoveTo actionWithDuration:0.5 position:ccp(w + last_count_index*dX, h2)],
                                 [CCRotateTo actionWithDuration:0.5 angle:originalIframeOrientation],
                                 nil];
    
    [iframe runAction:actionForIframe];
    
    CCSprite *img = [self.imageSprites objectAtIndex:last_count_index];
    CCAction *actionForImg = [CCMoveTo actionWithDuration:0.5 position:ccp(w + last_count_index*dX, h + imgHeightAdjustment)];
    
    [img runAction:actionForImg];
    
}

#pragma mark - Touch

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
    
    CGRect bound = CGRectMake([self boundingBox].origin.x, [self boundingBox].origin.y, [self boundingBox].size.width+100, [self boundingBox].size.height);
    CGRect boundImageFrameOntop = ((CCSprite*)[self.imageFrameSprites objectAtIndex:0]).boundingBox;

    CGRect boundOnTop = CGRectMake(self.boundingBox.origin.x, self.boundingBox.origin.y,
                              boundImageFrameOntop.size.width-50, boundImageFrameOntop.size.height);
    
    if (CGRectContainsPoint(bound, loc)) {
        if (!CGRectContainsPoint(boundOnTop, loc)) {
            CCSprite *iframe = [self.imageFrameSprites lastObject];
            
            originalIframeOrientation = iframe.rotation;
            
            // temporarily set rotation to zero.
            CCAction *rotAction = [CCRotateTo actionWithDuration:0.5 angle:0.0];
            [iframe runAction:rotAction];
            // iframe.rotation = 0.0f;     
        }
        startTouchPt = loc;
        lastTouchPt = loc;
        // CCLOG(@"start touch = %f, %f", loc.x, loc.y);
        return YES;
    }
    
    return NO;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
    
    // CCLOG(@"delta x = %f", loc.x - startTouchPt.x);
    
    CGRect boundImageFrameOntop = ((CCSprite*)[self.imageFrameSprites objectAtIndex:0]).boundingBox;

    CGRect bound = CGRectMake(self.boundingBox.origin.x, self.boundingBox.origin.y,
                              boundImageFrameOntop.size.width-50, boundImageFrameOntop.size.height);
    
    if (CGRectContainsPoint(bound, loc)) {
        
        // Touch-move the image on top
    
        CGPoint dpt = ccp(loc.x - lastTouchPt.x, loc.y - lastTouchPt.y);
        lastTouchPt = ccp(loc.x, loc.y);
        
        // drag the photo on the top of the stack
        CCSprite *iframe = [self.imageFrameSprites objectAtIndex:0];

        CCSprite *img = [self.imageSprites objectAtIndex:0];
        
        iframe.position = ccp(iframe.position.x + dpt.x, iframe.position.y);
        img.position = ccp(img.position.x + dpt.x, img.position.y);
        titleLabel.position = ccp(titleLabel.position.x + dpt.x, titleLabel.position.y);
        attributionLabel.position = ccp(attributionLabel.position.x + dpt.x, attributionLabel.position.y);
    }
    else {
        
        // Touch-move the image at bottom
        
        CGPoint dpt = ccp(loc.x - lastTouchPt.x, loc.y - lastTouchPt.y);
        lastTouchPt = ccp(loc.x, loc.y);
        
        // drag the photo at the back of the stack
        CCSprite *iframe = [self.imageFrameSprites lastObject];

        CCSprite *img = [self.imageSprites lastObject];
        
        iframe.position = ccp(iframe.position.x + dpt.x, iframe.position.y);

        img.position = ccp(img.position.x + dpt.x, img.position.y);
        
        // titleLabel.position = ccp(titleLabel.position.x + dpt.x, titleLabel.position.y);
        // attributionLabel.position = ccp(attributionLabel.position.x + dpt.x, attributionLabel.position.y);
    }
}


-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
    
    // CCLOG(@"delta x = %f", loc.x - startTouchPt.x);
    
    CGRect boundImageFrameOntop = ((CCSprite*)[self.imageFrameSprites objectAtIndex:0]).boundingBox;

    CGRect bound = CGRectMake(self.boundingBox.origin.x-20, 
                              self.boundingBox.origin.y,
                              boundImageFrameOntop.size.width-50+20, 
                              boundImageFrameOntop.size.height);
    
    // CCLOG(@"bound=(%f,%f,%f,%f)", bound.origin.x, bound.origin.y, bound.size.width, bound.size.height);
    
    if (CGRectContainsPoint(bound, loc)) {
        if (loc.x - lastTouchPt.x < 0 && abs(loc.x - startTouchPt.x) > 25.0f ) {
            CCAction *action = [CCCallFuncN actionWithTarget:self selector:@selector(setAndAnimateTopImageToBack)];
            [self runAction:action];
        }
        else {
            CCAction *frontAction = [CCCallFuncN actionWithTarget:self selector:@selector(animateTopImageToOriginal)];
            [self runAction:frontAction];
            CCAction *backAction = [CCCallFuncN actionWithTarget:self selector:@selector(animateBackImageToOriginal)];
            [self runAction:backAction];
        }
    }
    else {
        if (loc.x - lastTouchPt.x > 0 && abs(loc.x - startTouchPt.x) > 25.0f ) {
            CCAction *action = [CCCallFuncN actionWithTarget:self selector:@selector(setAndAnimateBackImageToTop)];
            [self runAction:action];
        }
        else {
            CCAction *backAction = [CCCallFuncN actionWithTarget:self selector:@selector(animateBackImageToOriginal)];
            [self runAction:backAction];
            CCAction *frontAction = [CCCallFuncN actionWithTarget:self selector:@selector(animateTopImageToOriginal)];
            [self runAction:frontAction];
        }

    }
        
}

@end

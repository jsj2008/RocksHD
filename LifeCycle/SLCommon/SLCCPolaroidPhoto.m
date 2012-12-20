//
//  SLCCPolaroidPhoto.m
//  LifeCycle
//
//  Created by Kelvin Chan on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLCCPolaroidPhoto.h"

@interface SLCCPolaroidPhoto (Private)
-(CCSprite *) makeNewSpriteWithImageNamed:(NSString *)imageName;
-(void) replaceSpriteTextureForSprite:(CCSprite *) sprite withImageNamed:(NSString *)imageName;
@end

@implementation SLCCPolaroidPhoto 

@synthesize image;
@synthesize frame;
@synthesize titleLabel;
@synthesize attributionLabel;

-(void) dealloc {
    
    CCLOG(@"Deallocating SLCCPolaroidPhoto");
    
    [image release];
    [frame release];
    [titleLabel release];
    [attributionLabel release];
    
    [super dealloc];
}

+(id) slCCPolaroidPhotoWithImageName:(NSString *)imageName withTitle:(NSString*)title withAttribution:(NSString*)attribution {
    return [[[self alloc] initWithImageName:imageName withTitle:title withAttribution:attribution] autorelease];
}

-(id) initWithImageName:(NSString *)imageName withTitle:(NSString*)title withAttribution:(NSString*)attribution {
    
    self = [super init];
    if (self) {

        titleBottomMargin = 100.0f;
        attributionBottomMargin = 40.0f;
        
        self.frame = [self makeNewSpriteWithImageNamed:@"ImageFrameLite.png"];
        [self addChild:self.frame];
         
        self.image = [self makeNewSpriteWithImageNamed:imageName];
        [self addChild:self.image];
        
        // calculate image top margin
        imgTopMargin = ([self.frame boundingBox].size.width - [self.image boundingBox].size.width)*0.5;
        [self.image setPosition:ccp(0.0, [self.frame boundingBox].size.height * 0.5 - [self.image boundingBox].size.height * 0.5 - imgTopMargin)];     
         
        CGSize dimension = CGSizeMake([self.image boundingBox].size.width, 50);

        self.titleLabel = [CCLabelTTF labelWithString:title dimensions:dimension alignment:UITextAlignmentLeft fontName:@"ArialMT" fontSize:16.0];
        self.titleLabel.color = ccc3(0, 0, 0);
        self.titleLabel.anchorPoint = ccp(0.5, 0.5);
        self.titleLabel.position = ccp(0, -[self.frame boundingBox].size.height * 0.5f + titleBottomMargin);
        [self addChild:self.titleLabel z:20];
        
        self.attributionLabel = [CCLabelTTF labelWithString:attribution dimensions:dimension alignment:UITextAlignmentRight fontName:@"ArialMT" fontSize:11.0];
        self.attributionLabel.color = ccc3(0, 0, 0);
        self.attributionLabel.anchorPoint = ccp(0.5, 0.5);
        self.attributionLabel.position = ccp(0, -[self.frame boundingBox].size.height * 0.5f + attributionBottomMargin);
        [self addChild:self.attributionLabel z:20];
        
        self.contentSize = self.frame.boundingBox.size;

    }
    
    return self;
}


-(void) replaceWithImageName:(NSString *)imageName withTitle:(NSString*)title withAttribution:(NSString*)attribution {
    
    [self replaceSpriteTextureForSprite:self.image withImageNamed:imageName];
    self.titleLabel.string = title;
    self.attributionLabel.string = attribution;
}

-(void) setOpacity:(GLubyte) anOpacity {
    [self.image setOpacity:anOpacity];
    [self.frame setOpacity:anOpacity];
    [self.titleLabel setOpacity:anOpacity];
    [self.attributionLabel setOpacity:anOpacity];
}


#pragma mark - Sprite Creating and Texture replacement Logic
-(CCSprite *) makeNewSpriteWithImageNamed:(NSString *)imageName {
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
        UIImage *uiimage = [UIImage imageNamed:imageName];
        [[CCTextureCache sharedTextureCache] addImage:imageName];
        
        [sprite setTexture:[[CCTextureCache sharedTextureCache] textureForKey:imageName]];
        [sprite setTextureRect:CGRectMake(0, 0, uiimage.size.width, uiimage.size.height)];
    }
}
@end

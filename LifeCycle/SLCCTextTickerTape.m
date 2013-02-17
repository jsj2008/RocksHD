//
//  SLCCTextTickerTape.m
//  SLPOC
//
//  Created by Kelvin Chan on 11/2/12.
//
//

#import "SLCCTextTickerTape.h"
#import "CCAnimationCatalog.h"

typedef enum SLCCTextTickerTapeTags : NSInteger {
    kRightMenuTag = 1000,
    kLeftMenuTag = 1001,
    kTitleTag = 1002,
    kTextLabelTag = 1003
} SLCCTextTickerTapeTags;

@interface SLCCTextTickerTape () <CCTargetedTouchDelegate>

@end

@implementation SLCCTextTickerTape {
    int currentTextIndex;
    CGSize adjustedContentSize;
}

-(void) dealloc {
    
    CCLOG(@"Deallocating SLCCTextTickerTape");
    
    [_titleImageName release];
    [_goRightImageName release];
    [_goLeftImageName release];
    [_texts release];
        
    [super dealloc];
}

+(id)slCCTextTickerTapeWithParentNode:(CCNode *)parentNode withTitleImage:(NSString *)titleImageName withGoRightImage:(NSString *)goRightImageName withGoLeftImage:(NSString *)goLeftImageName {
    return [[[self alloc] initWithParentNode:parentNode withTitleImage:titleImageName withGoRightImage:goRightImageName withGoLeftImage:goLeftImageName] autorelease];
}

-(id)initWithParentNode:(CCNode *)parentNode withTitleImage:(NSString *)titleImageName withGoRightImage:(NSString *)goRightImageName withGoLeftImage:(NSString *)goLeftImageName {
    self = [super init];
    if (self) {
        
        [parentNode addChild:self];
        
        _titleImageName = [titleImageName copy];
        _goRightImageName = [goRightImageName copy];
        _goLeftImageName = [goLeftImageName copy];
        
        CCSprite *didYouKnowHeadTitle;
        if (titleImageName != nil && ![titleImageName isEqualToString:@""]) {
            didYouKnowHeadTitle = [CCSprite spriteWithFile:titleImageName];
            didYouKnowHeadTitle.tag = kTitleTag;
            didYouKnowHeadTitle.position = ccp(screenSize.width*0.0195, screenSize.height*0.1969);
            didYouKnowHeadTitle.anchorPoint = ccp(0, 0);
            didYouKnowHeadTitle.rotation = -5.0f;
            [self addChild:didYouKnowHeadTitle z:20];
        }

        CCMenuItemImage *right = [CCMenuItemImage itemWithNormalImage:_goRightImageName
                                                        selectedImage:_goRightImageName
                                                        disabledImage:_goRightImageName
                                                               target:self
                                                             selector:@selector(goRight)];
        
        CCMenu *rightMenu = [CCMenu menuWithItems:right, nil];
        rightMenu.tag = kRightMenuTag;
        rightMenu.position = ccp(screenSize.width*0.9440, screenSize.height*0.1020);
        [self addChild:rightMenu z:10];
        
        
        CCMenuItemImage *left = [CCMenuItemImage itemWithNormalImage:_goLeftImageName
                                                       selectedImage:_goLeftImageName
                                                       disabledImage:_goLeftImageName
                                                              target:self
                                                            selector:@selector(goLeft)];
        CCMenu *leftMenu = [CCMenu menuWithItems:left, nil];
        leftMenu.tag = kLeftMenuTag;
        leftMenu.anchorPoint = ccp(0, 0);
        leftMenu.position = ccp(screenSize.width*0.0664, screenSize.height*0.0938);
        [self addChild:leftMenu z:10];   // z = 10 to make sure it covers the text
        
        CGRect unionBound;
        if (titleImageName != nil && ![titleImageName isEqualToString:@""])
            unionBound = CGRectUnion(didYouKnowHeadTitle.boundingBox, CGRectUnion(left.boundingBox, right.boundingBox));
        else
            unionBound = CGRectUnion(left.boundingBox, right.boundingBox);
                
        self.contentSize = unionBound.size;
        
        CCLabelTTF *didYouKnowTxtLabel = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(screenSize.width*0.8, 80) hAlignment:UITextAlignmentCenter fontName:@"Arial" fontSize:30.0];
        didYouKnowTxtLabel.tag = kTextLabelTag;
        
        didYouKnowTxtLabel.color = ccc3(0, 0, 0);
        didYouKnowTxtLabel.anchorPoint = ccp(0, 0.5);
        
        didYouKnowTxtLabel.position = ccp(screenSize.width*0.1000, screenSize.height*0.1106);
        
        [self addChild:didYouKnowTxtLabel z:0];
        
        currentTextIndex = 0;
        
        adjustedContentSize = unionBound.size;
        
    }
    return self;
}

-(void)onEnter {
    [super onEnter];

//    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
}

-(void)onExit {
//    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    [super onExit];
}

#pragma mark - Override
-(CGSize)adjustedContentSize {
    return adjustedContentSize;
}

-(CGRect)adjustedBoundingBox {
    CGPoint o = ccp(position_.x - adjustedContentSize.width * self.anchorPoint.x,
                    position_.y - adjustedContentSize.height * self.anchorPoint.y);
    
    return CGRectMake(o.x, o.y, adjustedContentSize.width, adjustedContentSize.height);
}


#pragma mark - Getters & Setters
-(CGRect)boundingBox {
    return CGRectMake(self.position.x - self.contentSize.width*self.anchorPoint.x, self.position.y - self.contentSize.height*self.anchorPoint.y, self.contentSize.width, self.contentSize.height);
}

#pragma mark - Show and Text UX
-(void)show {
    if (self.texts.count > 0) {
        CCLabelTTF *label = (CCLabelTTF *)[self getChildByTag:kTextLabelTag];
        label.string = self.texts[currentTextIndex];
    }
}

-(void)goRight {
   
    if (currentTextIndex < self.texts.count - 1) {
         currentTextIndex++;
    }
    
    CCLabelTTF *label = (CCLabelTTF *)[self getChildByTag:kTextLabelTag];
    label.string = self.texts[currentTextIndex];
    label.opacity = 0;
    id action = [CCAnimationCatalog scaleUpToOneFadein];
    [label runAction:action];

}

-(void)goLeft {
    
    if (currentTextIndex > 0) {
        currentTextIndex--;
    }
    
    CCLabelTTF *label = (CCLabelTTF *)[self getChildByTag:kTextLabelTag];
    label.string = self.texts[currentTextIndex];
    label.opacity = 0;
    id action = [CCAnimationCatalog scaleUpToOneFadein];
    [label runAction:action];
}

#pragma mark - Touches & Gestures
-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CCLOG(@"SLCCTextTickerTape ccTouchBegan");
    return YES;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    
}

@end

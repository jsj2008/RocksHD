//
//  SLCCTextTickerTape.h
//  SLPOC
//
//  Created by Kelvin Chan on 11/2/12.
//
//

#import "cocos2d.h"
#import "SLCCCompositeNode.h"

@interface SLCCTextTickerTape : SLCCCompositeNode

+(id)slCCTextTickerTapeWithParentNode:(CCNode *)parentNode withTitleImage:(NSString *)titleImageName withGoRightImage:(NSString *)goRightImageName withGoLeftImage:(NSString *)goLeftImageName;

-(id)initWithParentNode:(CCNode *)parentNode withTitleImage:(NSString *)titleImageNam withGoRightImage:(NSString *)goRightImageName withGoLeftImage:(NSString *)goLeftImageName;

-(void)show;

@property (nonatomic, copy) NSString *titleImageName;
@property (nonatomic, copy) NSString *goRightImageName;
@property (nonatomic, copy) NSString *goLeftImageName;

@property (nonatomic, copy) NSArray *texts;

@end

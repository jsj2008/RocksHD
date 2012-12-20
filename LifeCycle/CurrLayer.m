//
//  CurrLayer.m
//  ButterflyPOC
//
//  Created by Kelvin Chan on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CurrLayer.h"
#import "ConfigManager.h"
#import "PlistManager.h"
#import "ScrollableCCLabelTTF.h"

@implementation CurrLayer

-(void)dealloc {    
    [super dealloc];
}

-(void) addCurriculum {
    
    [self unschedule:_cmd];
    
    CCSprite *currPane = [CCSprite spriteWithFile:@"InfoTextPane.png"];
    
    NSString *path = [NSString stringWithFormat:@"%@/CCSprite", NSStringFromClass([self class])];
    CGPoint pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kCurrPaneTag];
    currPane.position = pos;
//    [self addChild:currPane z:0 tag:kCurrPaneTag];
    
    NSString *txt = [(NSString *)[[[PlistManager sharedPlistManager] appDictionary] objectForKey:@"curriculum_text"] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    
    NSString *text = [txt stringByReplacingOccurrencesOfString:@"\\t" withString:@"     "];
    
//    NSString *text = @"Butterfly Life Cycle App\n\nCorrelation to California State Science Standards\n\nGrade K\n*******\nLife Sciences:\n\t2a – The student will describe similarities and differences in the appearance and behavior of insects.\n\t2c – The student will identify major structures of common animals.\n\nGrade 1\n*******\nLife Sciences:\n\t2a – The student knows plants and animals inhabit different kinds of environments and have external features that help them thrive in different kinds of places.\n\t2b – The student knows that animals need food.\n\t2c – The student knows animals use plants for food.\n\t2d – The student knows how to infer what animals eat from the shape of their teeth.\n\nGrade 2\n*******\nLife Sciences:\n\t2a – The student knows organisms reproduce offspring of their own kind and that the offspring resemble the parents and each other.\n\t2b – The student knows the sequential stages of life cycle of animals.\n\t2c – The student knows many characteristics of organisms are inherited from parents.\n\nGrade 3\n*******\nLife Sciences:\n\t2a – The student knows animals have structures that serve different functions in growth, survival, and reproduction.\n\t2d – The student knows when the environment changes, some animals survive while others die or move to new locations.\n\n_______\n\nButterfly Life Cycle Common Core Correlations\n\nReading Standards for Informational Text K-5\n\nKey Ideas and Details\n*********************\n\nGrade K – Standards 1, 2, and 3\n\nGrade 1 – Standards 1, 2, and 3\n\nGrade 2 – Standards 1, 2, and 3\n\nGrade 3 – Standards 1, 2, and 3\n\nGrade 4 – Standards 1, 2, and 3\n\nGrade 5 – Standards 1, 2, and 3\n\n*Life Cycle app meets all standards in this area for grades K-5\n\nCraft and Structure\n\n*****************\n\nGrade K – Standard 4\n\nGrade 1 – Standards 4, 5, and 6\n\nGrade 2 – Standards 4, 5, and 6\n\nGrade 3 – Standard 4\n\nGrade 4 – no correlation\n\nGrade 5 – no correlation\n\nIntegration of Knowledge and Ideas\n\n******************************\n\nGrade K – Standards 7 and 8\n\nGrade 1 – Standards 7 and 8\n\nGrade 2 – Standards 7 and 8\n\nGrade 3 – Standards 7 and 8\n\nGrade 4 – Standards 7 and 8\n\nGrade 5 – Standard 8\n\nRange of Reading and Level of Text Complexity\n\n***********************************\n\nGrade K – Standard 10\n\nGrade 1 – Standard 10\n\nGrade 2 – Standard 10\n\nGrade 3 – Standard 10\n\nGrade 4 – no correlation\n\nGrade 5 – no correlation\n\n";
    
    ScrollableCCLabelTTF *currLabel = [[ScrollableCCLabelTTF alloc] 
                                       initWithString:text dimensions:CGSizeMake(screenSize.width/2, screenSize.height*2) 
                                       alignment:UITextAlignmentLeft 
                                       fontName:@"AmericanTypewriter" 
                                       fontSize:20];
    
    currLabel.color = ccc3(1.0, 1.0, 1.0);
    currLabel.anchorPoint = ccp(0.0, 1.0);
    
    NSString *path2 = [NSString stringWithFormat:@"%@/ScrollableCCLabelTTF", NSStringFromClass([self class])];
    CGPoint pos2 = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path2 andTag:kCurrTextTag];
    currLabel.position = pos2;
    currLabel.viewPortHeight = [[ConfigManager sharedConfigManager] absoluteValueFromDefaultsWithKey:@"INFO_TEXT_VIEWPORT_HEIGHT"];
    
//    [self addChild:currLabel z:1 tag:kCurrTextTag];
    
    currLabelBound = currLabel.boundingBox;
    
    [currLabel release];
    
    currTextView = [CCUITextView ccUITextViewWithParentNode:self];
    currTextView.text = text;
    
}

-(void)addMenu {
    CCMenuItemImage *home = [CCMenuItemImage itemFromNormalImage:@"home.png" 
                                                   selectedImage:@"home_bigger.png"
                                                   disabledImage:@"home.png"
                                                          target:self selector:@selector(goHome)];
    home.position = ccp(0.0f, 0.0f);
    home.tag = kCurrHomeButtonTag;
    
    //    CCMenuItemImage *email = [CCMenuItemImage itemFromNormalImage:@"Email.png"
    //                                                    selectedImage:@"Email_bigger.png"
    //                                                    disabledImage:@"Email.png"
    //                                                           target:self
    //                                                         selector:@selector(email)];
    //    
    //                              
    //    email.scale = 0.93;
    //    email.tag = kCurrEmailButtonTag;
    
    //    CCMenu *menu = [CCMenu menuWithItems:home, email, nil];
    CCMenu *menu = [CCMenu menuWithItems:home, nil];
    
    NSString *path = [NSString stringWithFormat:@"%@/CCMenu", NSStringFromClass([self class])];
    CGPoint pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kCurrMenuTag]; 
    menu.position = pos;

    [menu alignItemsHorizontallyWithPadding:20.0f];
    
    [self addChild:menu z:0 tag:kCurrMenuTag];
    
    //    CCLOG(@"menu boundingbox = %f, %f, %f, %f", menu.boundingBox.origin.x, menu.boundingBox.origin.y, 
    //          menu.boundingBox.size.width, menu.boundingBox.size.height);
    //    CCLOG(@"menu anchorpoint = %f, %f", menu.anchorPoint.x, menu.anchorPoint.y);
    //    CCLOG(@"menu position = %f, %f", menu.position.x, menu.position.y);
}

-(void)goHome {
    // remoev the CCUItextview first.
    [currTextView removeFromParentAndCleanup:YES];
    
    PLAYSOUNDEFFECT(CURR_CLICK_1);
    [[FlowAndStateManager sharedFlowAndStateManager] runSceneWithID:kHomeScene withTranstion:kCCTransitionPageFlip];
}

-(void)email {
    NSString *emailStr = [NSString stringWithFormat:@"mailto:?to=%@&subject=%@", @"support@sproutlabs.net", @"Plants HD Feedback"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[emailStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}


- (id)init
{
    self = [super init];
    if (self) {
        screenSize = [CCDirector sharedDirector].winSize;
        [self addMenu];
//        [self addCurriculum];
        [self schedule:@selector(addCurriculum) interval:0.4];

    }
    
    return self;
}

-(void)onEnter {
    [super onEnter];
    
    editModeAbler = [EditModeAbler node];
    [editModeAbler retain];
    editModeAbler.delegateLayer = self;
    
    [editModeAbler activate];
}

-(void)onExit {
    [editModeAbler release];
    [super onExit];
}


@end

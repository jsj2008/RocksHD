//
//  InfoLayer.m
//  PlantHD
//
//  Created by Kelvin Chan on 11/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "InfoLayer.h"
#import "ConfigManager.h"
#import "PlistManager.h"
#import "ScrollableCCLabelTTF.h"
#import "CCImageReflector.h"
#import "AppInfo.h"
#import "ModelManager.h"
@implementation InfoLayer

// i m a small change

-(void)dealloc {    
    [super dealloc];
}

-(void) addInfo {
    
    CCSprite *infoPane = [CCSprite spriteWithFile:@"InfoTextPane.png"];
    
    NSString *path = [NSString stringWithFormat:@"%@/CCSprite", NSStringFromClass([self class])];
    CGPoint pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kInfoPaneTag];
    infoPane.position = pos;
//    infoPane.position = INFO_TEXT_PANE_POSITON;
    // mainTextPane.anchorPoint = ccp(0.0, 1.0);
    [self addChild:infoPane z:0 tag:kInfoPaneTag];
    
    AppInfo *appInfo = [ModelManager sharedModelManger].appInfo;
    NSString *txt = appInfo.info;

    txt = [txt stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    
    NSString *text = [txt stringByReplacingOccurrencesOfString:@"\\t" withString:@"\t"];
    
//    NSString *text = @"Sprout Labs - Learning reimagined!\n\n\nPlants HD delivers high-quality interactive content about plants and their lifecycle. The app provides an audio visual exploration of topics such as seeds, dispersal, germination, pollination, flowers, trees, and fruits.\n\nAt Sprout Labs, we are a group of engineers and designers, developing interactive learning apps for everyone.\n\n\nHow to use the app\n***************\n\nGame:\nPress the play button from the main page to start the game. Arrange the lifecycle by moving the various stages into their respective slots to get the right sequence.\n\nTopics:\nPress one of the topics from the main page to begin learning.\n\nPictures:\nFlip through the pictures in the topic page by swiping from right to left. To go back to a picture, touch the bottom picture of the stack and pull it up.\n\nRead Along:\nPress the read to me button to have the text read to you.\n\nDid You Know:\nPress the left or right arrows to scroll through the different facts about that topic.\n\nQuiz:\nPress the Pop Quiz button to begin taking the Easy level of the quiz. Select the right answer and earn a coin. Unlock the Intermediate level by answering questions in the Easy level. Proceed from the Intermediate to the Advanced level.\n\n\n*****\n\nFor more information on news and updates, like us on Facebook and follow us on Twitter @SproutLabs.\n\nFor feature requests, feedback or support, send email to support@sproutlabs.net or use the email button.\n\n*****";
    
    
    
    // TODO:FIX
    
    
    debugLog(@"create the scroll lable");
    
    ScrollableCCLabelTTF *infoLabel = [[ScrollableCCLabelTTF alloc] initWithString:text fontName:@"AmericanTypewriter"  fontSize:20 dimensions:CGSizeMake(screenSize.width*0.5,
                                                                                                                                                          screenSize.height*2.0) hAlignment:kCCTextAlignmentLeft];
    

    debugLog(@"After label created");    
    infoLabel.color = ccc3(1.0, 1.0, 1.0);
    infoLabel.anchorPoint = ccp(0.0, 1.0);
    
    NSString *path2 = [NSString stringWithFormat:@"%@/ScrollableCCLabelTTF", NSStringFromClass([self class])];
    CGPoint pos2 = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path2 andTag:kInfoTextTag];
    infoLabel.position = pos2;
//    infoLabel.position = INFO_TEXT_POSITION;
//    infoLabel.viewPortHeight = INFO_TEXT_VIEWPORT_HEIGHT;
    infoLabel.viewPortHeight = [[ConfigManager sharedConfigManager] absoluteValueFromDefaultsWithKey:@"INFO_TEXT_VIEWPORT_HEIGHT"];
    
    [self addChild:infoLabel z:1 tag:kInfoTextTag];
    
    infoLabelBound = infoLabel.boundingBox;
    
    [infoLabel release];

}

-(void)addMenu {
    CCMenuItemImage *home = [CCMenuItemImage itemFromNormalImage:@"home-button.png"
                                                   selectedImage:@"home-button.png"
                                                   disabledImage:@"home-button.png"
                                                          target:self selector:@selector(goHome)];
    home.position = ccp(0.0f, 0.0f);
    home.tag = kInfoHomeButtonTag;
    
//    CCMenuItemImage *email = [CCMenuItemImage itemFromNormalImage:@"Email.png"
//                                                    selectedImage:@"Email_bigger.png"
//                                                    disabledImage:@"Email.png"
//                                                           target:self
//                                                         selector:@selector(email)];
//    
//                              
//    email.scale = 0.93;
//    email.tag = kInfoEmailButtonTag;
    
//    CCMenu *menu = [CCMenu menuWithItems:home, email, nil];
    CCMenu *menu = [CCMenu menuWithItems:home, nil];
    
    NSString *path = [NSString stringWithFormat:@"%@/CCMenu", NSStringFromClass([self class])];
    CGPoint pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:path andTag:kInfoMenuTag]; 
    menu.position = pos;
//    menu.position = INFO_MENU_POSITION;
    [menu alignItemsHorizontallyWithPadding:20.0f];
    
    [self addChild:menu z:0 tag:kInfoMenuTag];
    
//    CCImageReflector *reflector = [[CCImageReflector alloc] init];
//    CCSprite *homeSprite = [CCSprite spriteWithFile:@"home.png"];    
//    CCSprite *reflectedHomeSprite = [reflector drawSpriteReflection:homeSprite withHeight:25];
//    reflectedHomeSprite.position = ccp(50, 100);
//    [self addChild:reflectedHomeSprite];
//    
//    [reflector release];
    
    
//    CCLOG(@"menu boundingbox = %f, %f, %f, %f", menu.boundingBox.origin.x, menu.boundingBox.origin.y, 
//          menu.boundingBox.size.width, menu.boundingBox.size.height);
//    CCLOG(@"menu anchorpoint = %f, %f", menu.anchorPoint.x, menu.anchorPoint.y);
//    CCLOG(@"menu position = %f, %f", menu.position.x, menu.position.y);
}

-(void)goHome {
    PLAYSOUNDEFFECT(INFO_CLICK_1);
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
        [self addInfo];
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

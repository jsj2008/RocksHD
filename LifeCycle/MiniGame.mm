//
//  MiniGame.m
//  PlantHD
//
//  Created by Kelvin Chan on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MiniGame.h"
#import "Constants.h"
#import "MiniGamePlaceholder.h"
#import "FlowAndStateManager.h"
#import "ConfigManager.h"
#import "PlistManager.h"
#import "IntroLayer.h"

@implementation MiniGame

@synthesize parentLayer;

+(id)gameWithParentLayer:(CCLayer*)parentLayer {
    MiniGame *miniGame = [[[self alloc] init] autorelease];
    miniGame.parentLayer = parentLayer;
    return miniGame;
}

-(void)dealloc {
    
    for (CCSprite *s in placeHolders) 
        [s removeFromParentAndCleanup:YES];
    
    for (CCSprite *s in miniGameSprites) 
        [s removeFromParentAndCleanup:YES];
        
    [placeHolders release];
    [miniGameSprites release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHECKCORRECTNESSNOTIFICATIONNAME object:nil];
    
    [super dealloc];
}

-(void)setupDraggableSprites {

    if ([miniGameSprites count] == 0) {
        // Setup a draggable sprite for each of the life stages
        NSDictionary *basicInfoAboutCycles = [[PlistManager sharedPlistManager] allTopicsPlistDictionary];
        
        CGPoint menu_pos = [[ConfigManager sharedConfigManager] 
                    positionFromDefaultsForNodeHierPath:[NSString stringWithFormat:@"IntroLayer/CCMenu"] 
                    andTag:kIntroMainMenuTag];
        
        
        int topicCursor = 0;

        for (NSString *topic in [[basicInfoAboutCycles allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {
            
            MiniGameSprite *topicSprite = [MiniGameSprite miniGameSpriteWithTopic:topicCursor+1];
            int tag = kIntroTopic1ButtonTag + topicCursor;
            NSString *hierPath = [NSString stringWithFormat:@"IntroLayer/CCMenu:%d/CCMenuItemImage", kIntroMainMenuTag];
            CGPoint pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:hierPath andTag:tag];
            topicSprite.position = ccp(menu_pos.x + pos.x, menu_pos.y + pos.y);
            topicSprite.placeholders = placeHolders;
            
            [self.parentLayer addChild:topicSprite z:1];
            [miniGameSprites addObject:topicSprite];
            
            if (topicCursor == numOfTopics - 1)
                break;
            
            topicCursor++;
        }
    }
    

}

-(void) addPlaceHolders {
    
    if ([placeHolders count] == 0) {
        
        // Setup a placeholder for each of the life stages
        NSDictionary *basicInfoAboutCycles = [[PlistManager sharedPlistManager] allTopicsPlistDictionary];
        CGPoint menu_pos = [[ConfigManager sharedConfigManager] 
                            positionFromDefaultsForNodeHierPath:[NSString stringWithFormat:@"IntroLayer/CCMenu"] 
                            andTag:kIntroMainMenuTag];
        
        int topicCursor = 0;

        for (NSString *topic in [[basicInfoAboutCycles allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {
            
            MiniGamePlaceholder *placeholderForTopic = [MiniGamePlaceholder miniGamePlaceholder];
            
            int tag = kIntroTopic1ButtonTag + topicCursor;
            NSString *hierPath = [NSString stringWithFormat:@"IntroLayer/CCMenu:%d/CCMenuItemImage", kIntroMainMenuTag];
            CGPoint pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:hierPath andTag:tag];
            
            placeholderForTopic.position = ccp(menu_pos.x + pos.x, menu_pos.y + pos.y);
            
            [self.parentLayer addChild:placeholderForTopic];   // hold a reference for cleanup when the game ends
            
            [placeHolders addObject:placeholderForTopic];
            
            if (topicCursor == numOfTopics - 1)
                break;
            
            topicCursor++;
        }
    
    }
}

- (void) dropDraggableSpriteToBottom {
    float x = 0.0;
    CGPoint destPoint;
    id action;
    float jump_x;
    
    bool slotTaken[numOfTopics];
    for (int x = 0; x < numOfTopics; x++)
        slotTaken[x] = false;
    
    for (MiniGameSprite *s in miniGameSprites) {

        int k = (int) floor((float) numOfTopics * ((float) random()) / RAND_MAX);
        while (slotTaken[k])
            k = (int) floor((float) numOfTopics * ((float) random()) / RAND_MAX);
        slotTaken[k] = true;
        
        x = (k+0.5)*1024.0f/numOfTopics;
        
        destPoint = ccp(x, s.boundingBox.size.height*0.65/2.0);
        
        jump_x = 10.0f * ((float) random()) / RAND_MAX - 5.0f;
    
        action = [CCSequence actions:
                  [CCSpawn actions:
                   [CCEaseIn actionWithAction:[CCMoveTo actionWithDuration:1.2f position:destPoint] rate:3.0f],
                   [CCScaleTo actionWithDuration:1.2f scale:0.65f],
                   nil],
                  [CCJumpBy actionWithDuration:1.0f position:ccp(jump_x, 0) height:20 jumps:1],
                  [CCJumpBy actionWithDuration:1.0f position:ccp(-jump_x/2, 0) height:10 jumps:1],
                  nil];

        [s runAction:action];
    }
    
}


-(void) animateSpritesBacktoOriginPositions {
    
    float duration = 1.0f;
    
    NSDictionary *basicInfoAboutCycles = [[PlistManager sharedPlistManager] allTopicsPlistDictionary];
    CGPoint menu_pos = [[ConfigManager sharedConfigManager] 
                        positionFromDefaultsForNodeHierPath:[NSString stringWithFormat:@"IntroLayer/CCMenu"] 
                        andTag:kIntroMainMenuTag];
    
    int topicCursor = 0;
    for (NSString *topic in [[basicInfoAboutCycles allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {
        
        MiniGameSprite *s = [miniGameSprites objectAtIndex:topicCursor];
        
        int tag = kIntroTopic1ButtonTag + topicCursor;
        NSString *hierPath = [NSString stringWithFormat:@"IntroLayer/CCMenu:%d/CCMenuItemImage", kIntroMainMenuTag];
        CGPoint pos = [[ConfigManager sharedConfigManager] positionFromDefaultsForNodeHierPath:hierPath andTag:tag];

        id action = [CCSpawn actions:
                     [CCScaleTo actionWithDuration:duration scale:1.0f],
                     [CCMoveTo actionWithDuration:duration position:ccp(menu_pos.x + pos.x, menu_pos.y + pos.y)],
                     nil];
        
        [s runAction:action];

        if (topicCursor == numOfTopics - 1)
            break;
        
        topicCursor++;
    }

}

-(void)start {
    [self addPlaceHolders];

    [self setupDraggableSprites];
    
    [self dropDraggableSpriteToBottom];
}

-(void)installHomeButton {
    // Install home icon 
    CCMenuItemImage *home = [CCMenuItemImage itemFromNormalImage:@"home.png" 
                                                   selectedImage:@"home_bigger.png" 
                                                   disabledImage:@"home.png" 
                                                          target:self
                                                        selector:@selector(forceEndGame)];
    home.position = [[ConfigManager sharedConfigManager] 
                     positionFromDefaultsForNodeHierPath:[NSString stringWithFormat:@"IntroLayer/CCMenu:%d/CCMenuItemImage", kIntroPlayButtonTag] 
                     andTag:kIntroPlayButtonTag];
    home.scale = 1.4;
    home.tag = kMiniGameButtonTag;
    
    CCMenu *homeMenu = [CCMenu menuWithItems:home, nil];
    homeMenu.position = [[ConfigManager sharedConfigManager] 
                         positionFromDefaultsForNodeHierPath:[NSString stringWithFormat:@"IntroLayer/CCMenu"] 
                         andTag:kIntroMainMenuTag];
    [self.parentLayer addChild:homeMenu z:0 tag:kMiniGameHomeMenuTag];
    

}

-(void)removeHomeButton {
    // Remove home menu
    CCMenu *menu = (CCMenu*) [self.parentLayer getChildByTag:kMiniGameHomeMenuTag];
    [menu removeFromParentAndCleanup:YES];
}

-(void)checkCorrectness:(NSNotification*) notification {
    // NSDictionary *userInfo = [notification userInfo];
    // CCLOG(@"abc = %@", [userInfo objectForKey:@"abc"]);
    /*int k = 0;
    for (MiniGameSprite *s in miniGameSprites) {
        CCLOG(@"%d, %d", k, s.inPlaceHolderIndex);
        k++;
    }*/
    
    BOOL correct = YES;
    for (int k=1; k < [miniGameSprites count]; k++) {
        MiniGameSprite *s = [miniGameSprites objectAtIndex:k];
        MiniGameSprite *last_s = [miniGameSprites objectAtIndex:k-1];
                                  
        if (((last_s.inPlaceHolderIndex + 1) % numOfTopics) != s.inPlaceHolderIndex) {
            correct = NO;   // wrong
            break;
        }
        
    }
        
    if (correct) {
        CCLOG(@"Great Job!");
        PLAYSOUNDEFFECT(INTRO_GREAT_JOB);
        
        [self animateSpritesBacktoOriginPositions];
        id action = [CCSequence actions:
                     [CCMoveBy actionWithDuration:1.8 position:CGPointZero],
                     [CCCallFuncN actionWithTarget:self selector:@selector(endGame)],
                     nil];
        
        CCSprite *dummy = [CCSprite node];
        [self.parentLayer addChild:dummy];
        [dummy runAction:action];
    }
    else {
        CCLOG(@"Oops! Would you like to try again?");
        PLAYSOUNDEFFECT(INTRO_TRYAGAIN);
        
        // Shake everything
        for (CCSprite *s in miniGameSprites) {
            id action = [CCSequence actions:
                         [CCMoveBy actionWithDuration:0.1 position:ccp(10, 0)],
                         [CCMoveBy actionWithDuration:0.1 position:ccp(-20, 0)],
                         [CCMoveBy actionWithDuration:0.1 position:ccp(20, 0)], 
                         [CCMoveBy actionWithDuration:0.1 position:ccp(-20, 0)],
                         [CCMoveBy actionWithDuration:0.1 position:ccp(10, 0)],
                         nil];
            [s runAction:action];
        }
        
    }
    
}

-(void) forceEndGame {
    
    PLAYSOUNDEFFECT(INTRO_CLICK_1);
    
    for (CCSprite *s in miniGameSprites) {
        [s stopAllActions];
    }
    
    id action = [CCSequence actions:
                 [CCCallBlock actionWithBlock:^{
        [self animateSpritesBacktoOriginPositions];
    }],
                 [CCMoveBy actionWithDuration:1.5 position:CGPointZero],
                 [CCCallFuncN actionWithTarget:self selector:@selector(endGame)],
                 nil];
    
    CCSprite *dummy = [CCSprite node];
    [self.parentLayer addChild:dummy];
    [dummy runAction:action];
     
}

-(void) endGame {
    [self removeHomeButton];
    
    if ([self.parentLayer respondsToSelector:@selector(miniGameDidFinish:)]) 
        [(id<MiniGameDelegate>)self.parentLayer miniGameDidFinish:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        screenSize = [CCDirector sharedDirector].winSize;
        placeHolders = [[CCArray alloc] initWithCapacity:numOfTopics];
        miniGameSprites = [[CCArray alloc] initWithCapacity:numOfTopics];
        numOfTopics = [FlowAndStateManager sharedFlowAndStateManager].numOfTopics;
        srandom(time(NULL));
        
        // observe "check correctness" event
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkCorrectness:)
                                                     name:CHECKCORRECTNESSNOTIFICATIONNAME
                                                   object:nil];
    }
    
    return self;
}



@end

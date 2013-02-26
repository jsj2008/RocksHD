//
//  SLCCMenu.m
//  SLPOC
//
//  Created by Kelvin Chan on 9/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLCCMenu.h"

@interface SLCCMenu () <CCTouchOneByOneDelegate>

@end

@implementation SLCCMenu {
    CGSize screenSize;
    CCSprite *pulloutIndicatorSprite;
    
    CGPoint startTouchPoint;
    CGPoint endTouchPoint;
    BOOL touchInProgress;
    
    BOOL menuShown;
}

@synthesize menuLocation;
@synthesize type;
@synthesize menuItemPadding;
@synthesize menu = _menu;

-(void) dealloc {
    [super dealloc];
}

+(id)slCCMenuWithParentNode:(CCNode *)parentNode atLocation:(SLCCMenuLocation)location withType:(SLCCMenuType)type {
    return [[[self alloc] initWithParentNode:parentNode atLocation:location withType:type] autorelease];
}

-(id) initWithParentNode:(CCNode *)parentNode atLocation:(SLCCMenuLocation)aLocation withType:(SLCCMenuType)aType {
    self = [super init];
    if (self) {
        [parentNode addChild:self];
        screenSize = [CCDirector sharedDirector].winSize;
        
        menuLocation = aLocation;
        type = aType;

        switch (menuLocation) {
            case SLCCMenuTopLeft:
                pulloutIndicatorSprite = [CCSprite spriteWithFile:@"pullout-tab-rightarrow.png"];
                self.position = ccp(pulloutIndicatorSprite.boundingBox.size.width*0.5, screenSize.height - pulloutIndicatorSprite.boundingBox.size.height*0.5);
                break;
            case SLCCMenuTopRight:
                pulloutIndicatorSprite = [CCSprite spriteWithFile:@"pullout-tab-leftarrow.png"];
                self.position = ccp(screenSize.width - pulloutIndicatorSprite.contentSize.width*0.5, screenSize.height - pulloutIndicatorSprite.contentSize.height*0.5);
                break;
            case SLCCMenuBottomLeft:
                pulloutIndicatorSprite = [CCSprite spriteWithFile:@"pullout-tab-rightarrow.png"];
                self.position = ccp(pulloutIndicatorSprite.boundingBox.size.width*0.5, pulloutIndicatorSprite.boundingBox.size.height*0.5);
                break;
            case SLCCMenuBottomRight:
                pulloutIndicatorSprite = [CCSprite spriteWithFile:@"pullout-tab-leftarrow.png"];
                self.position = ccp(screenSize.width - pulloutIndicatorSprite.boundingBox.size.width*0.5, pulloutIndicatorSprite.boundingBox.size.height*0.5);
                break;
            default:
                break;
        }
        
        [self addChild:pulloutIndicatorSprite];
    }
    return self;
}

-(void) menuWithItems: (CCMenuItem*) item, ...
{
	va_list args;
	va_start(args,item);
    
    NSMutableArray *ccitems = [[[NSMutableArray alloc] init] autorelease];
    for (CCMenuItem *arg = item; arg != nil; arg = va_arg(args, CCMenuItem*))
    {
        [ccitems addObject:arg];
    }
    va_end(args);
    
    if (_menu == nil) {        
      //  _menu = [[[CCMenu alloc] initWithItems:item vaList:args] autorelease];

        _menu = [[CCMenu alloc] initWithArray: ccitems];
        if (menuItemPadding == 0.0)
            menuItemPadding = 10.0;

        // Fix up the boundingBox, it has zero size initially if you don't 
        _contentSize = pulloutIndicatorSprite.contentSize;
        
        // Assign the approx contentSize for _menu
        float menu_width = 0.0;
        float menu_height = 0.0;
        
        switch (type) {
            case SLCCMenuTypePullOrTabOutHorizontal:
                [_menu alignItemsHorizontallyWithPadding:menuItemPadding];
                
                for (CCMenuItem *item in _menu.children)
                    menu_width += item.contentSize.width;
            
                menu_width += ([_menu.children count] + 1) * menuItemPadding;
                
                menu_height = ((CCMenuItem *) [_menu.children objectAtIndex:0]).contentSize.height;
                
                break;
            case SLCCMenuTypePullOrTabOutVertical:
                [_menu alignItemsVerticallyWithPadding:menuItemPadding];
                
                for (CCMenuItem *item in _menu.children)
                    menu_height += item.contentSize.height;
            
                menu_height += ([_menu.children count] + 1) * menuItemPadding;
                
                menu_width = ((CCMenuItem *) [_menu.children objectAtIndex:0]).contentSize.width;
                
                break;
            default:
                break;
        }
    
        _menu.contentSize = CGSizeMake(menu_width, menu_height);
        
        switch (menuLocation) {
            case SLCCMenuTopLeft:
                _menu.position = ccp(-0.5*_menu.contentSize.width, screenSize.height - 0.5*_menu.contentSize.height);
                menuShown = NO;
                break;
            case SLCCMenuTopRight:
                _menu.position = ccp(screenSize.width+0.5*_menu.contentSize.width, screenSize.height-0.5*_menu.contentSize.height);
                menuShown = NO;
                break;
            case SLCCMenuBottomLeft:
                _menu.position = ccp(-0.5*_menu.contentSize.width, 0.5*_menu.contentSize.height);
                menuShown = NO;
                break;
            case SLCCMenuBottomRight:
                _menu.position = ccp(screenSize.width+0.5*_menu.contentSize.width, 0.5*_menu.contentSize.height);
                menuShown = NO;
                break;
            default:
                break;
        }
        
        [self.parent addChild:_menu z:20];
    }
    
	va_end(args);
}

-(void)onEnter {
    [super onEnter];
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
}

-(void)onExit {
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    [super onExit];
}

#pragma mark - Getters & Setters

-(void) setMenuItemPadding:(float)aMenuItemPadding {
    if (menuItemPadding != aMenuItemPadding) {
        menuItemPadding = aMenuItemPadding;
        [_menu alignItemsHorizontallyWithPadding:menuItemPadding];
        
        // recompute the approx contentSize for _menu
        float menu_width = 0.0;
        float menu_height = 0.0;
        
        switch (type) {
            case SLCCMenuTypePullOrTabOutHorizontal:
                [_menu alignItemsHorizontallyWithPadding:menuItemPadding];
                
                for (CCMenuItem *item in _menu.children)
                    menu_width += item.contentSize.width;
                
                menu_width += ([_menu.children count] + 1) * menuItemPadding;
                
                menu_height = ((CCMenuItem *) [_menu.children objectAtIndex:0]).contentSize.height;
                
                break;
            case SLCCMenuTypePullOrTabOutVertical:
                [_menu alignItemsVerticallyWithPadding:menuItemPadding];
                
                for (CCMenuItem *item in _menu.children)
                    menu_height += item.contentSize.height;
                
                menu_height += ([_menu.children count] + 1) * menuItemPadding;
                
                menu_width = ((CCMenuItem *) [_menu.children objectAtIndex:0]).contentSize.width;
                
                break;
            default:
                break;
        }
        
        _menu.contentSize = CGSizeMake(menu_width, menu_height);
    }
}

#pragma mark - Touches & Gestures
-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    // Only respond if the touch is on the GLView
    if (![touch.view isMemberOfClass:[CCGLView class]])
        return NO;
    
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
    
    CGPoint o = self.boundingBox.origin;
    CGSize bsize = self.boundingBox.size;
          
    CGRect bound;
    CGPoint expandedMenuPosition;
    CGPoint hiddenMenuPosition;
    CGPoint expandedPulloutSpritePosition;
    NSString *expandedStatePng;
    NSString *hiddenStatePng;
    
    // setup various points, and strings depending on menu location
    switch (menuLocation) {
        case SLCCMenuTopLeft:
            if (!menuShown)
                bound = CGRectMake(o.x - bsize.width*0.5, o.y - bsize.height*0.5, bsize.width, bsize.height);
            else 
                bound = CGRectMake(o.x - bsize.width*0.5 + _menu.contentSize.width, o.y - bsize.height*0.5, bsize.width, bsize.height);
            
            expandedMenuPosition = ccp(0.5*_menu.contentSize.width, screenSize.height - 0.5*_menu.contentSize.height);
            hiddenMenuPosition = ccp(-0.5*_menu.contentSize.width, screenSize.height - 0.5*_menu.contentSize.height);
            expandedPulloutSpritePosition = ccp(_menu.contentSize.width, 0);
            
            expandedStatePng = @"pullout-tab-leftarrow.png";
            hiddenStatePng = @"pullout-tab-rightarrow.png";
            
            break;
        case SLCCMenuTopRight:
            if (!menuShown) 
                bound = CGRectMake(o.x - bsize.width*0.5, o.y - bsize.height*0.5, bsize.width, bsize.height);
            else
                bound = CGRectMake(o.x - bsize.width*0.5 - _menu.contentSize.width, o.y - bsize.height*0.5, bsize.width, bsize.height);
            
            expandedMenuPosition = ccp(screenSize.width - 0.5*_menu.contentSize.width, screenSize.height - 0.5*_menu.contentSize.height);
            hiddenMenuPosition = ccp(screenSize.width + 0.5*_menu.contentSize.width, screenSize.height - 0.5*_menu.contentSize.height);
            expandedPulloutSpritePosition = ccp(-_menu.contentSize.width, 0);
            
            expandedStatePng = @"pullout-tab-rightarrow.png";
            hiddenStatePng = @"pullout-tab-leftarrow.png";
            
            break;
        case SLCCMenuBottomLeft:
            if (!menuShown) 
                bound = CGRectMake(o.x - bsize.width*0.5, o.y - bsize.height*0.5, bsize.width, bsize.height);
            else 
                bound = CGRectMake(o.x - bsize.width*0.5 + _menu.contentSize.width, o.y - bsize.height*0.5, bsize.width, bsize.height);
                
            expandedMenuPosition = ccp(0.5*_menu.contentSize.width, 0.5*_menu.contentSize.height);
            hiddenMenuPosition = ccp(-0.5*_menu.contentSize.width, 0.5*_menu.contentSize.height);
            expandedPulloutSpritePosition = ccp(_menu.contentSize.width, 0);
            
            expandedStatePng = @"pullout-tab-leftarrow.png";
            hiddenStatePng = @"pullout-tab-rightarrow.png";
            
            break;
        case SLCCMenuBottomRight:
            if (!menuShown) 
                bound = CGRectMake(o.x - bsize.width*0.5, o.y - bsize.height*0.5, bsize.width, bsize.height);
            else 
                bound = CGRectMake(o.x - bsize.width*0.5 - _menu.contentSize.width, o.y - bsize.height*0.5, bsize.width, bsize.height);
            
            expandedMenuPosition = ccp(screenSize.width - 0.5*_menu.contentSize.width, 0.5*_menu.contentSize.height);
            hiddenMenuPosition = ccp(screenSize.width + 0.5*_menu.contentSize.width, 0.5*_menu.contentSize.height);
            expandedPulloutSpritePosition = ccp(-_menu.contentSize.width, 0);
            
            expandedStatePng = @"pullout-tab-rightarrow.png";
            hiddenStatePng = @"pullout-tab-leftarrow.png";
            
            break;
        default:
            break;
    }

//    CCLOG(@"menu contentsize = %.2f, %.2f", _menu.contentSize.width, _menu.contentSize.height);
    
    if (CGRectContainsPoint(bound, loc)) {
        
        float duration = 0.5*_menu.contentSize.width / 200.0;

        if (!menuShown) {
            [_menu runAction:[CCMoveTo actionWithDuration:duration position:expandedMenuPosition]];
            [pulloutIndicatorSprite runAction:[CCMoveTo actionWithDuration:duration position:expandedPulloutSpritePosition]];
            
            // swap image for expandHintSprite
            CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:expandedStatePng];
            [pulloutIndicatorSprite setTexture:texture];
                                                                                      
            menuShown = YES;
        }
        else {
            [_menu runAction:[CCMoveTo actionWithDuration:duration position:hiddenMenuPosition]];
            [pulloutIndicatorSprite runAction:[CCMoveTo actionWithDuration:duration position:ccp(0, 0)]];
            
            // swap image for expandHintSprite

            CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:hiddenStatePng];
            [pulloutIndicatorSprite setTexture:texture];

            menuShown = NO;
        }
    }
    
    return YES;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
}

@end

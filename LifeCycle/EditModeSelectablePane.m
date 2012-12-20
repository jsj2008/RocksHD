//
//  EditModeCCRenderTexture.m
//  PlantHD
//
//  Created by Kelvin Chan on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EditModeSelectablePane.h"

@implementation EditModeSelectablePane

@synthesize selected;
@synthesize delegate;
@synthesize note;
@synthesize partnerNode;
@synthesize partnerNodeFullPath;

-(void) dealloc {
    CCLOG(@"EditModeSelectablePane dealloc");
    [note release];
    [partnerNodeFullPath release];
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

-(id)initWithWidth:(int)w height:(int)h pixelFormat:(CCTexture2DPixelFormat) format {
    size = CGSizeMake(w, h);
    return [super initWithWidth:w height:h pixelFormat:format];
}

-(void)choose {
    self.selected = YES;
    [self.delegate editModeSelectablePaneSelected:self];
}
     

-(void)onEnter {
    [super onEnter];
    
    NSString *str = [NSString stringWithFormat:@"%@", note];
    
    //[self begin];
    
    CCLabelTTF *t = [CCLabelTTF labelWithString:str fontName:@"Arial-BoldItalicMT" fontSize:20];
    t.color = ccc3(255, 0, 0);
    t.position = ccp(0, size.height*0.25);
    [self addChild:t];
    
//    CCMenuItemLabel *l = [CCMenuItemLabel itemWithLabel:t target:self selector:@selector(tap)];
//    CCMenu *m = [CCMenu menuWithItems:l, nil];
//    // m.position = ccp(size.width*0.5, size.height*0.85);
//    m.position = ccp(0, size.height*0.25);
//    [self addChild:m];
    //[m visit];
    
    //[self end];
    self.selected = NO;
    
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
}

-(void)onExit {
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super onExit];
}

#pragma mark - Touch
-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint loc = [[CCDirector sharedDirector] convertToGL:location];
    
    CGRect bound = CGRectMake(self.position.x - size.width*0.5, self.position.y - size.height*0.5, size.width, size.height);

    if (CGRectContainsPoint(bound, loc) && self.visible == YES) {
        [self choose];
        return YES;
    }
    return NO;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {

}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {

}

@end

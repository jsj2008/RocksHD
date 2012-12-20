//
//  MiniGamePlaceholder.h
//  PlantHD
//
//  Created by Kelvin Chan on 11/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CCSprite.h"
#import "MiniGameSprite.h"

@interface MiniGamePlaceholder : CCSprite {
    int occupation_count;
}

@property (nonatomic, assign) BOOL isOccupied;

+(MiniGamePlaceholder *) miniGamePlaceholder;

@end

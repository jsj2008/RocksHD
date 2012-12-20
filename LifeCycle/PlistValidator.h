//
//  PlistValidator.h
//  ButterflyPOC
//
//  Created by Kelvin Chan on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlistValidator : NSObject

+(PlistValidator*) sharedPlistValidator;

-(void)validateQuizDictionary;

-(void)validateTopic1SpecificsDictionary;
-(void)validateTopic2SpecificsDictionary;
-(void)validateTopic3SpecificsDictionary;
-(void)validateTopic4SpecificsDictionary;
-(void)validateTopic5SpecificsDictionary;
-(void)validateTopic6SpecificsDictionary;
-(void)validateTopic7SpecificsDictionary;

@end

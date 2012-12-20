//
//  PlistValidator.m
//  ButterflyPOC
//
//  Created by Kelvin Chan on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlistValidator.h"
#import "PlistManager.h"

@implementation PlistValidator

static PlistValidator* _sharedPlistValidator = nil;

+(PlistValidator*) sharedPlistValidator {
    @synchronized([PlistValidator class]) {
        if (!_sharedPlistValidator) 
            [[self alloc] init];
        return _sharedPlistValidator;
    }
    return nil;
}

+(id)alloc {
    @synchronized([PlistValidator class]) {
        NSAssert(_sharedPlistValidator == nil, @"Attempted to allocate a 2nd instance of the PlistValidator singleton");
        _sharedPlistValidator = [super alloc];
        return _sharedPlistValidator;
    }
    return nil;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

#pragma mark - validation methods

-(void)validateQuizDictionary {
    NSDictionary *dict = [[PlistManager sharedPlistManager] quizDictionary];
    
    for (NSString *topic in dict) {
        NSDictionary *d = [dict objectForKey:topic];
        NSArray *questions = [d objectForKey:@"questions"];
        for (NSDictionary *question in questions) {
            NSArray *anses = [question objectForKey:@"answers"];
            NSString *q = [question objectForKey:@"question"];
            NSString *level = [question objectForKey:@"level"];
            
            if (!([level isEqualToString:@"Easy"] || [level isEqualToString:@"Medium"] || [level isEqualToString:@"Hard"])) {
                NSString *format = @"%@, question=\"%@\" has unrecgonized level";
                [NSException raise:@"QuizPlistException" format:format, topic, q];
            }
            
            int num_of_correct_ans = 0;
            int num_of_wrong_ans = 0;
            
            for (NSString *ans in anses) {
                
                NSString *trim_ans = [ans stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                NSArray *ans_part = [trim_ans componentsSeparatedByString:@"|"];
                if ([ans_part count] != 2) {
                    NSString *format = @"%@, question=\"%@\", ans=\"%@\" is not valid";
                    [NSException raise:@"QuizPlistException" format:format, topic, q, ans];
                }
                NSString *a = [ans_part objectAtIndex:1];
                if ([a isEqualToString:@"Y"]) 
                    num_of_correct_ans++;
                else if ([a isEqualToString:@"N"])
                    num_of_wrong_ans++;
            }
            
            if ([anses count] == 4) {
                if (!(num_of_correct_ans == 1 && num_of_wrong_ans == 3)) {
                    NSString *format = @"%@, question=\"%@\" has wrong number of ans key";
                    [NSException raise:@"QuizPlistException" format:format, topic, q];
                }
            }
            else if ([anses count] == 2) {
                if (!(num_of_correct_ans == 1 && num_of_wrong_ans == 1)) {
                    NSString *format = @"%@, question=\"%@\" has wrong number of ans key";
                    [NSException raise:@"QuizPlistException" format:format, topic, q];
                }
            }
            else {
                NSString *format = @"%@, question=\"%@\" has unrecgonized # of available answers";
                [NSException raise:@"QuizPlistException" format:format, topic, q];
            }
        }
    }
    
}

@end



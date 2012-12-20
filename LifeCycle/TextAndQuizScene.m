//
//  TextAndQuizScene.m
//  PlantHD
//
//  Created by Kelvin Chan on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TextAndQuizScene.h"
#import "PlistManager.h"
#import "MainTextImagesLayer.h"
#import "QuizLayer.h"
#import "FlowAndStateManager.h"
#import "NSMutableArrayShuffle.h"

@interface TextAndQuizScene ()
@property (nonatomic, copy) NSDictionary *specificTopicInfo;
@end

@implementation TextAndQuizScene

@synthesize questions;
@synthesize topicInfo;
@synthesize specificTopicInfo;

-(void) dealloc {
    CCLOG(@"Deallocating Scene");
    [questions release];
    [topicInfo release];
    [specificTopicInfo release];
    
    MainTextImagesLayer *mainTextImagesLayer = (MainTextImagesLayer*)[self getChildByTag:1];
    for (NSString *f in mainTextImagesLayer.imgFileNames) {
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrameByName:f];
    }
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    
    [CCSpriteFrameCache purgeSharedSpriteFrameCache];
    [CCTextureCache purgeSharedTextureCache];

    [super dealloc];
}

-(void)loadQuiz {
    // First unload the main text and the "Do you know?" section
    MainTextImagesLayer *mainTextImagesLayer = (MainTextImagesLayer*)[self getChildByTag:1];
    self.specificTopicInfo = mainTextImagesLayer.topicInfo;

    [mainTextImagesLayer removeFromParentAndCleanup:YES]; mainTextImagesLayer = nil;
    
    // Then load the quiz layer and its background
    TextAndQuizBackgroundLayer *bgLayer = [TextAndQuizBackgroundLayer node];
    [self addChild:bgLayer z:0 tag:0];
    
//    QuizLayer *quizLayer = [QuizLayer node];
//    quizLayer.topicInfo = specificTopicInfo;
    
    currentQuestion = -1;
    [self progressReportEasy];
//    NSDictionary *q = [self.questions objectAtIndex:currentQuestion];
//    quizLayer.questionDict = q;
//    
//    [quizLayer addMenu];
//    [quizLayer prepareLayerForQuestion];
//    [self addChild:quizLayer z:1 tag:3];

//    [specificTopicInfo release];
    
}

-(void)loadNextQuiz:(BOOL)must {
    QuizLayer *quizLayer = (QuizLayer*)[self getChildByTag:3];
//    NSDictionary *specificTopicInfo = [quizLayer.topicInfo retain];

    [quizLayer removeFromParentAndCleanup:YES]; quizLayer = nil;
    
    if (!must && currentQuestion == numberOfEasy - 1) {
        CCLOG(@"Beginning of medium, display score and ask the question");
        [self progressReportMedium];
        return;
    }
    else if (!must && currentQuestion == numberOfEasy + numberOfMedium - 1) {
        CCLOG(@"Beginning of hard, display score and ask the question");
        [self progressReportHard];
        return;
    }
    else 
        currentQuestion++;
    
    if (currentQuestion < [self.questions count]) {
        
        NSDictionary *q = [self.questions objectAtIndex:currentQuestion];
        
        QuizLayer *qL = [QuizLayer node];
        qL.topicInfo = self.specificTopicInfo;
        qL.questionDict = q;
        
        [qL addMenu];
        [qL prepareLayerForQuestion];
        [qL showScoreRepresentation:correctCount];
        [self addChild:qL z:1 tag:3];
    }
    else {
        [self loadResult];
    }
    
//    [specificTopicInfo release];
         
}

-(void)progressReportEasy {
    QuizLayer *qL = [QuizLayer node];
    qL.topicInfo = self.specificTopicInfo;
    [qL addMenu];
    [qL showResult:correctCount outOfTotal:numberOfEasy withText:@"Let's begin with easy questions to see how well you remember what you learnt!\n\n (Bloom’s Taxonomy Level – Remembering)"];
    
    [self addChild:qL z:1 tag:3];
}

-(void)progressReportMedium {
    QuizLayer *qL = [QuizLayer node];
    qL.topicInfo = self.specificTopicInfo;
    [qL addMenu];
    [qL showScoreRepresentation:correctCount];
    [qL showResult:correctCount outOfTotal:numberOfEasy withText:@"You have unlocked harder questions, which will test your understanding!\n\n(Bloom’s Taxonomy Level – Understanding)"];
    
    [self addChild:qL z:1 tag:3];
}

-(void)progressReportHard {
    QuizLayer *qL = [QuizLayer node];
    qL.topicInfo = self.specificTopicInfo;
    [qL addMenu];
    [qL showScoreRepresentation:correctCount];
    [qL showResult:correctCount outOfTotal:(numberOfEasy+numberOfMedium) withText:@"You have unlocked the hardest questions, which will test your analysis and application skills!\n\n(Bloom’s Taxonomy Level - Applying, Analyzing, Evaluating)"];
    
    [self addChild:qL z:1 tag:3];
}


-(void)loadResult {
    
    QuizLayer *qL = [QuizLayer node];
    [qL addMenu];
    [qL showResult:correctCount outOfTotal:[self.questions count]];
    
    [self addChild:qL z:1 tag:3];
}

-(NSArray *)shuffleQuestionsAccordingToLevel:(NSArray *)qs {
    NSMutableArray *questionsToReturn = [[[NSMutableArray alloc] initWithCapacity:[qs count]] autorelease];
    
    NSMutableArray *easyQuestions = [[NSMutableArray alloc] init];
    for (NSDictionary *q in qs) {
        if ([[q objectForKey:@"level"] isEqualToString:@"Easy"]) {
            [easyQuestions addObject:q];
        }
    }
    [easyQuestions shuffle];
    numberOfEasy = [easyQuestions count];
    
    NSMutableArray *mediumQuestions = [[NSMutableArray alloc] init];
    for (NSDictionary *q in qs) {
        if ([[q objectForKey:@"level"] isEqualToString:@"Medium"]) {
            [mediumQuestions addObject:q];
        }
    }
    [mediumQuestions shuffle];
    numberOfMedium = [mediumQuestions count];
    
    NSMutableArray *hardQuestions = [[NSMutableArray alloc] init];
    for (NSDictionary *q in qs) {
        if ([[q objectForKey:@"level"] isEqualToString:@"Hard"]) {
            [hardQuestions addObject:q];
        }
    }
    [hardQuestions shuffle];
    numberOfHard = [hardQuestions count];
    
    NSMutableArray *unrankedQuestions = [[NSMutableArray alloc] init];
    for (NSDictionary *q in qs) {
        if ([q objectForKey:@"level"] == nil || [[q objectForKey:@"level"] isEqualToString:@""]) {
            [unrankedQuestions addObject:q];
        }
    }
    [unrankedQuestions shuffle];
    
    [questionsToReturn addObjectsFromArray:easyQuestions];
    [questionsToReturn addObjectsFromArray:mediumQuestions];
    [questionsToReturn addObjectsFromArray:hardQuestions];
    [questionsToReturn addObjectsFromArray:unrankedQuestions];
    
    [easyQuestions release];
    [mediumQuestions release];
    [hardQuestions release];
    [unrankedQuestions release];
    
    return questionsToReturn;
}

-(void)loadQuestionsForScene:(SceneTypes)sceneType {
//    NSString *fileName = @"Quiz";
//    
//    NSString *fullFileName = [NSString stringWithFormat:@"%@.plist", fileName];
//    NSString *plistPath;
//    
//    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
//        plistPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
//    }
//    
//    NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
//    if (plistDict == nil) {
//        CCLOG(@"Error reading plist: %@.plist", fileName);
//    }
    
    NSDictionary *plistDict = [[PlistManager sharedPlistManager] quizDictionary];
    
    NSDictionary *dict;
    switch (sceneType) {
        case kTopic1Scene:
            dict = (NSDictionary *) [plistDict objectForKey:@"topic1"];
            break;
        case kTopic2Scene:
            dict = (NSDictionary *) [plistDict objectForKey:@"topic2"];
            break;
        case kTopic3Scene:
            dict = (NSDictionary*) [plistDict objectForKey:@"topic3"];
            break;
        case kTopic4Scene:
            dict = (NSDictionary*) [plistDict objectForKey:@"topic4"];
            break;
        case kTopic5Scene:
            dict = (NSDictionary*) [plistDict objectForKey:@"topic5"];
            break;
        case kTopic6Scene: 
            dict = (NSDictionary*) [plistDict objectForKey:@"topic6"];
            break;
        case kTopic7Scene:
            dict = (NSDictionary*) [plistDict objectForKey:@"topic7"];
            break;
        default:
            break;
    }
    
    NSArray *qs = [self shuffleQuestionsAccordingToLevel:[dict objectForKey:@"questions"]];
    
    self.questions = qs;
    
}

- (id)init
{
    CCLOG(@"Enter [TextAndQuizScene init]");
    self = [super init];
    if (self) {
        // [self loadQuestionsForScene:[FlowAndStateManager sharedFlowAndStateManager].currentScene];
        
        // score keeping
        correctCount = 0;
    }
    CCLOG(@"Exit [TextAndQuizScene init]");
    return self;
}

-(void)incrementCorrectCount {
    correctCount++;
}

-(void) play_great_job {
    // override this
}

-(void) play_oops {
    // override this
}

-(void) play_kaching {
    // override this
}

-(void) play_funny {
    // override this
}

-(void) play_dyk_scroll_left {
    // override this
}

-(void) play_dyk_scroll_right {
    // override this
}


@end

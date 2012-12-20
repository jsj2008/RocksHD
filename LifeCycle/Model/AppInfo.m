//
//  AppInfo.m
//  SLPOC
//
//  Created by Kelvin Chan on 10/12/12.
//
//

#import "AppInfo.h"
#import "IntroTexts.h"
#import "TopicInfo.h"

@implementation AppInfo

@dynamic version;
@dynamic uid;
@dynamic name;
@dynamic numberOfTopics;
@dynamic backgroundImage;
@dynamic info;
@dynamic curriculum;
@dynamic topics;
@dynamic navigation;

-(void) dealloc {
    
    [_introTexts release];
    
    [super dealloc];
}


#pragma mark - the Meat (but most is now meta)

-(void) parseAndBuildObject:(GDataXMLElement *)root {
    
    GDataXMLElement *introTextsElem = [root elementsForName:@"introTexts"][0];
    self.introTexts = [IntroTexts loadContentsFromGDataXMLElement:introTextsElem];

}

@end

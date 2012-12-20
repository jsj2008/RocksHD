//
//  ModelManager.m
//  SLPOC
//
//  Created by Kelvin Chan on 10/21/12.
//
//

#import "ModelManager.h"

@implementation ModelManager

static ModelManager* sSharedModelManager = nil;

-(void)dealloc {
    
    NSLog(@"No..... deallocating ModelManager!!");
    
    [_sourceName release];
    [_appInfo release];
    
    [super dealloc];
}

+(void)initialize {
    NSAssert(self == [ModelManager class], @"ModelManager is not designed to be subclassed");
    sSharedModelManager = [ModelManager new];
}

+(ModelManager *)sharedModelManger {
    return sSharedModelManager;
}

-(void) setDataSrcName:(NSString *)sourceName {
    // ignore if this is already set. (this can be set only once)

    if (_sourceName == nil) {
        _sourceName = [sourceName retain];
    }
    
    if (_appInfo == nil) {
        _appInfo = [AppInfo loadContentsFromXMLFile:_sourceName];
        [_appInfo retain];
    }
    
}


@end

//
//  AppConfig.m
//  JustSikh
//
//  Created by admin on 9/17/09.
//  Copyright 2009 Livrona.com. All rights reserved.
//


#import "AppConfigManager.h"
#import "Constants.h"
static NSString *DEVICE_TOKEN = @"device.token";

@implementation AppConfigManager

@synthesize isLoaded;@synthesize currentTopic;
static AppConfigManager *instance = NULL;



-(id) init
{
	if (( self=[super init] )) {
		
		props = [[Properties alloc] init];
	}
	return self;
}


-(NSString*) getLocalProperty: (NSString*)key
{
	defaults = [NSUserDefaults standardUserDefaults];
	NSString *value = [defaults stringForKey:key];
	debugLog(@"Get Property : %@ = %@",key,value);
	return value;
}



-(void) setLocalProperty : (NSString*) prop withValue :(NSString*) value
{
	debugLog(@"Set Property : %@ = %@",prop,value);
	defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:value forKey:prop];
	[defaults synchronize];
}




-(NSString*) getDeviceToken
{	
	return [self getLocalProperty:DEVICE_TOKEN];
}


-(void) setDeviceToken :(NSString*) token
{
	[self setLocalProperty:DEVICE_TOKEN withValue:token];
}



+(AppConfigManager *) getInstance
{
    @synchronized(self)
    {
        if (instance == NULL)
		{
			instance = [[AppConfigManager alloc]init];
		}
		
    }
    return(instance);
	
}

-(void) load
{
	NSString *configFileUrl = [[[NSString alloc] initWithFormat: @"%@/%@",WEB_SERVICE_URL,APP_CONFIG_FILE_NAME] autorelease];
	[props loadFromUrl:configFileUrl];
    if ([props.getDictionary count] > 0)
    {
        isLoaded = true;
    }
    else {
        isLoaded = false;
    }
    
}


-(NSString*) getProperty: (NSString*)key
{
	return [props getProperty:key];
}




-(void) dealloc
{
	[props release];
	[super dealloc];
}



@end

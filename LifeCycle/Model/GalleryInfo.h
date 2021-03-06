//
//  GalleryInfo.h
//  SLPOC
//
//  Created by Kelvin Chan on 10/15/12.
//
//

#import "SLInfo.h"

@interface GalleryInfo : SLInfo

{
    NSMutableDictionary *itemMap;
}
@property (nonatomic, retain) NSString *uid;        
@property (nonatomic, retain) NSNumber *version;  
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSMutableArray *items;  // no meta, rule exception
@property (nonatomic, retain) NSMutableDictionary *itemMap;  // no meta, rule exception

@end

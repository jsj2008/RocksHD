//
//  TopicInfo.h
//  SLPOC
//
//  Created by Kelvin Chan on 10/14/12.
//
//

#import "SLInfo.h"
#import "ImagesInfo.h"
#import "DidYouKnowsInfo.h"
#import "VoiceoverPacingsInfo.h"
#import "YoutubeVideosInfo.h"
#import "FlickrPhotosInfo.h"
#import "StarterImagesInfo.h"
#import "GalleryInfo.h"
#import "QuestionsInfo.h"
#import "HotspotsOnBackgroundInfo.h"

@interface TopicInfo : SLInfo

// primitive elements (@dynamic)
@property (nonatomic, retain) NSNumber *version;
@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSNumber *number;
@property (nonatomic, retain) NSString *name;

@property (nonatomic, retain) NSString *backgroundImage;
@property (nonatomic, retain) NSString *topicImageName;
@property (nonatomic, retain) NSString *topicBiggerImageName;
@property (nonatomic, retain) NSString *mainText;
@property (nonatomic, retain) NSString *mainTextTitleImageName;
@property (nonatomic, retain) NSString *backgroundTrackName;
@property (nonatomic, retain) NSString *voiceoverTrackName;
@property (nonatomic, retain) NSString *optionalText;

@property (nonatomic, retain) ImagesInfo *images;
@property (nonatomic, retain) DidYouKnowsInfo *didYouKnows;
@property (nonatomic, retain) VoiceoverPacingsInfo *voiceoverPacings;
@property (nonatomic, retain) YoutubeVideosInfo *youtubeVideos;
@property (nonatomic, retain) FlickrPhotosInfo *flickrPhotos;
@property (nonatomic, retain) StarterImagesInfo *starterImages;
@property (nonatomic, retain) GalleryInfo *gallery;
@property (nonatomic, retain) QuestionsInfo *questions;

@property (nonatomic, retain) NSMutableArray *hotspotsOnBackgrounds;

@end

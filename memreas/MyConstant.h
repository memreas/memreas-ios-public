#import <Foundation/Foundation.h>

#define VERSION @"version: YOUR_VERSION_ID"
#define APPID @"YOUR_APP_ID"

#ifdef DEBUG
#   define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define ALog(...)
#endif

#define SYSTEM_VERSION_EQUAL_TO(v)                                       \
([[[UIDevice currentDevice] systemVersion] compare:v                   \
options:NSNumericSearch] == \
NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)                                   \
([[[UIDevice currentDevice] systemVersion] compare:v                   \
options:NSNumericSearch] == \
NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)                       \
([[[UIDevice currentDevice] systemVersion] compare:v                   \
options:NSNumericSearch] != \
NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                                      \
([[[UIDevice currentDevice] systemVersion] compare:v                   \
options:NSNumericSearch] == \
NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)                          \
([[[UIDevice currentDevice] systemVersion] compare:v                   \
options:NSNumericSearch] != \
NSOrderedDescending)

//Prefix remnants
#ifndef __IPHONE_8_0
#warning "This project uses features only available in iOS SDK 8.0 and later."
#endif

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define kAppDelegate ((AppDelegate*)[[UIApplication sharedApplication] delegate])
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)
/* Release a Foundation object and set it to nil */
#define SAFE_RELEASE(__POINTER) {[__POINTER release]; __POINTER = nil;}

#ifndef __has_feature      // Optional.
#define __has_feature(x) 0 // Compatibility with non-clang compilers.
#endif

#ifndef NS_RETURNS_RETAINED
#if __has_feature(attribute_ns_returns_retained)
#define NS_RETURNS_RETAINED __attribute__((ns_returns_retained))
#else
#define NS_RETURNS_RETAINED
#endif
#endif

#ifndef CF_RETURNS_RETAINED
#if __has_feature(attribute_cf_returns_retained)
#define CF_RETURNS_RETAINED __attribute__((cf_returns_retained))
#else
#define CF_RETURNS_RETAINED
#endif
#endif

#define DegreesToRadians(x) ((x) * M_PI / 180.0)
#define CC_DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) * 0.01745329252f) // PI / 180
#define CC_RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) * 57.29577951f) // PI * 180

//
// Session vars
//
#define USERID [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"]
#define SID [[NSUserDefaults standardUserDefaults] valueForKey:@"SID"]
#define TVM [[NSUserDefaults standardUserDefaults] valueForKey:@"TVM"]

//
// Copyright font, size,
//
#define COPYRIGHT_FONT "Segoe Script"
#define COPYRIGHT_FONT_SIZE 12
extern NSString* const NSCOPYRIGHT_FONT;
extern NSString* const NSCOPYRIGHT_FONT_SIZE;
extern NSString* const NSCOPYRIGHT_FONT_COLOR;

//
// AWS related
//
extern NSString* const DEVICE_TYPE;
extern NSString* const hostName;
extern NSString* const HOSTNAMECHECK;
extern int MAX_SELECTION;
extern NSString* const MAX_MESSAGE;
extern NSString* const S3_ENCRYPTION_TYPE;


// App Secret
#define SecretRegistration @"freedom tower"

// Upload and download Limit
#define MAX_CONCURRENT_TRANSFERS 3

// Gallery Observers
#define GALLERY_REFRESH_VIEW @"GALLERY_REFRESH_VIEW"
#define GALLERY_UPDATE_PROGRESS @"GALLERY_UPDATE_PROGRESS"
#define GALLERY_CLOSE_SPINNER @"GALLERY_CLOSE_SPINNER"


// Queue Observers
#define TRANSFER_QUEUE_VIEW_RELOAD @"TransferQueueViewReload"
#define TRANSFER_QUEUE_DELETECOMPLETED @"TransferQueueDeleteCompleted"
#define COMPLETED_VIEW_LOAD @"CompleteViewLoad"
#define TRANSFER_QUEUE_PROGRESS @"TRANSFER_QUEUE_PROGRESS"


// Web Service action names
#define FULLSCREENVIEWACTION @"fullscreenviewAction"
#define CHECKUSERNAME @"checkusername"
#define CHECKUSERNAME_RESULT_NOTIFICATION @"checkusernameMWSHandlerComplete"
#define REGISTRATION @"registration"
#define REGISTRATION_RESULT_NOTIFICATION @"registrationMWSHandlerComplete"
#define LOGIN @"login"
#define LOGIN_RESULT_NOTIFICATION @"LOGIN_RESULT_NOTIFICATION"
#define GETUSERDETAILS @"getuserdetails"
#define GETUSERDETAILS_RESULT_NOTIFICATION @"GETUSERDETAILS_RESULT_NOTIFICATION"
#define LISTALLMEDIA @"listallmedia"
#define ADDMEDIAEVENT @"addmediaevent"
#define ADDMEDIAEVENT_RESULT_NOTIFICATION @"addMediaEventMWSHandlerComplete"
#define ADDMEDIAEVENT_REGISTRATION_RESULT_NOTIFICATION \
@"addMediaEventRegistionMWSHandlerComplete"
#define GENERATEMEDIAID @"generatemediaid"
#define GENERATEMEDIAID_RESULT_NOTIFICATION \
@"generatemediaidRegistrationMWSHandlerComplete"
#define GENERATEMEDIAID_REGISTRATION_RESULT_NOTIFICATION \
@"generatemediaidRegistrationMWSHandlerComplete"
#define FETCHCOPYRIGHTBATCH @"fetchcopyrightbatch"
#define FETCHCOPYRIGHTBATCH_RESULT_NOTIFICATION \
@"fetchcopyrightbatchMWSHandlerComplete"
#define MEDIADEVICETRACKER @"mediadevicetracker"
#define MEDIADEVICETRACKER_RESULT_NOTIFICATION \
@"mediadevicetrackerMWSHandlerComplete"
#define UPDATEMEDIA @"updatemedia"
#define UPDATEMEDIA_RESULT_NOTIFICATION \
@"updateMediaMWSHandlerComplete"
#define REPORTMEDIAINAPPROPRIATE @"mediainappropriate"
#define REPORTMEDIAINAPPROPRIATE_RESULT_NOTIFICATION \
@"mediainappropriateMWSHandlerComplete"
#define ADDMEDIAEVENTCOMMENT @"addmediaevent"
#define ADDMEDIAEVENTCOMMENT_RESULT_NOTIFICATION @"addMediaEventMWSHandlerComplete"
#define ADDCOMMENTS @"addcomments"
#define ADDCOMMENT_RESULT_NOTIFICATION \
@"addcommentMWSHandlerComplete"


//
// Share Page notifications - 3 pages (share, media, friends)
//
#define ADDEVENT @"addevent"
#define ADDEVENT_RESULT_NOTIFICATION \
@"ADDEVENT_RESULT_NOTIFICATION"
#define ADDEVENT_SHARE_RESULT_NOTIFICATION \
@"ADDEVENT_SHARE_RESULT_NOTIFICATION"
//
// Share Media Page (add event then media)
//
#define ADDEVENT_MEDIA_EVENT_RESULT_NOTIFICATION \
@"ADDEVENT_MEDIA_EVENT_RESULT_NOTIFICATION"
#define ADDEVENT_MEDIA_MEDIA_RESULT_NOTIFICATION \
@"ADDEVENT_MEDIA_MEDIA_RESULT_NOTIFICATION"
//
// Share Friends Page (add event then media then friends)
//
#define ADDFRIENDTOEVENT @"addfriendtoevent"
#define ADDEVENT_FRIENDS_EVENT_RESULT_NOTIFICATION \
@"ADDEVENT_FRIENDS_EVENT_RESULT_NOTIFICATION"
#define ADDEVENT_FRIENDS_MEDIA_RESULT_NOTIFICATION \
@"ADDEVENT_FRIENDS_MEDIA_RESULT_NOTIFICATION"
#define ADDEVENT_FRIENDS_FRIENDS_RESULT_NOTIFICATION \
@"ADDEVENT_FRIENDS_FRIENDS_RESULT_NOTIFICATION"
#define ADDEXISTMEDIATOEVENT @"addexistmediatoevent"

//
// Add Media to Share Selector Popup
//
#define MEMREAS_ADDMEDIA_RESULT_NOTIFICATION \
@"MEMREAS_ADDMEDIA_RESULT_NOTIFICATION"
#define MEMREAS_ADDFRIENDS_RESULT_NOTIFICATION \
@"MEMREAS_ADDFRIENDS_RESULT_NOTIFICATION"
#define MEMREAS_SELECT_RESULT_REFRESH_NOTIFICATION \
@"MEMREAS_SELECT_RESULT_REFRESH_NOTIFICATION"
#define MEMREAS_ADDMEDIA_DETAIL_RESULT_NOTIFICATION \
@"MEMREAS_ADDMEDIA_DETAIL_RESULT_NOTIFICATION"
#define MEMREAS_ADDFRIENDS_SELECT_RESULT_NOTIFICATION \
@"MEMREAS_ADDFRIENDS_SELECT_RESULT_NOTIFICATION"
#define MEMREAS_ADDFRIENDS_HANDLER_NOTIFICATION \
@"MEMREAS_ADDFRIENDS_HANDLER_NOTIFICATION"


//
// Add Audio Comment
//
#define ADDMEDIAEVENT_AUDIOCOMMENT @"ADDMEDIAEVENT_AUDIOCOMMENT"
#define ADDMEDIAEVENT_AUDIOCOMMENT_RESULT_NOTIFICATION @"ADDMEDIAEVENT_AUDIOCOMMENT_RESULT_NOTIFICATION"

#define ADDCOMMENTS_AUDIOCOMMENT @"ADDCOMMENTS_AUDIOCOMMENT"
#define ADDCOMMENTS_AUDIOCOMMENT_RESULT_NOTIFICATION @"ADDCOMMENTS_AUDIOCOMMENT_RESULT_NOTIFICATION"

//
// Memreas calls - replace delegate
//
#define LIKEMEDIA @"likemedia"
#define MEMREAS_MEDIA_DETAIL_LIKE_MEDIA_RESPONSE @"MEMREAS_MEDIA_DETAIL_LIKE_MEDIA_RESPONSE"
#define MEMREAS_DETAIL_GALLERY_LIKE_MEDIA_RESPONSE @"MEMREAS_DETAIL_GALLERY_LIKE_MEDIA_RESPONSE"
#define MEMREAS_DETAIL_LIKE_MEDIA_RESPONSE @"MEMREAS_DETAIL_LIKE_MEDIA_RESPONSE"

#define VIEWEVENTS @"viewevents"
#define MEMREAS_MAIN_VIEW_EVENTS_ME_RESPONSE @"MEMREAS_MAIN_VIEW_EVENTS_ME_RESPONSE"
#define MEMREAS_MAIN_VIEW_EVENTS_FRIENDS_RESPONSE @"MEMREAS_MAIN_VIEW_EVENTS_FRIENDS_RESPONSE"
#define MEMREAS_MAIN_VIEW_EVENTS_PUBLIC_RESPONSE @"MEMREAS_MAIN_VIEW_EVENTS_PUBLIC_RESPONSE"

#define VIEWALLFRIENDS @"viewallfriends"

//Search related
//#define SEARCH_ADD_FRIEND_TO_EVENT @"SEARCH_ADD_FRIEND_TO_EVENT"
#define ADDFRIEND @"addfriend"
#define SEARCH_ADD_FRIEND_RESPONSE @"SEARCH_ADD_FRIEND_RESPONSE"
#define SEARCH_ADD_FRIEND_TO_EVENT_RESPONSE @"SEARCH_ADD_FRIEND_TO_EVENT_RESPONSE"
#define FINDTAG @"findtag"
#define SEARCH_FINDTAG_RESPONSE @"SEARCH_FINDTAG_RESPONSE"


//
// Notifications
//
#define LISTNOTIFICATION @"listnotification"
#define LISTNOTIFICATION_RESULT_NOTIFICATION @"notificationMWSHandlerComplete"
#define UPDATENOTIFICATION @"updatenotification"
#define UPDATENOTIFICATION_RESULT_NOTIFICATION @"UPDATENOTIFICATION_RESULT_NOTIFICATION"

//
// Notification Response Statuses
//
#define ACCEPT @"ACCEPT"
#define DECLINE @"DECLINE"
#define IGNORE @"IGNORE"



#define FETCHCOPYRIGHTBATCH_RUNNING_LOW 5
#define FETCHMEDIAIDBATCH_RUNNING_LOW 5

//Constants for MCameraViewController
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

//Cell sizes based on device...
extern NSInteger const CELLSIZE_IPAD;
extern NSInteger const CELLSIZE_IPHONE;
extern NSInteger const MEMREAS_MAIN_CELLSIZE_IPAD_HEIGHT;
extern NSInteger const MEMREAS_MAIN_CELLSIZE_IPAD_WIDTH;
extern NSInteger const MEMREAS_MAIN_CELLSIZE_IPHONE_HEIGHT;
extern NSInteger const MEMREAS_MAIN_CELLSIZE_IPHONE_WIDTH;
extern NSInteger const MEMREAS_GALLERY_CELLSIZE_IPAD;
extern NSInteger const MEMREAS_GALLERY_CELLSIZE_IPHONE;


// Constant for after login where to land
/*
 Gallery =0
 Queue =1
 Share =2
 Memreas =3
 More =4
 */
#define SelectedLandingToTab 0
extern NSInteger const SELECTEDLANDINGTAB;
// * Note: Do not add another value rather than mentioned above.

// Constant for after login Memreas tab selected segment of me/friend/public
/*
 Me =0
 Friend =1
 Public =2
 */
#define SelectedSegmentForMemreas 0

// * Note: Do not add another value rather than mentioned above.

// Maximum allowed file size in Free plan is 200 MB
#define MAX_FILE_SIZE_MB_S3 300  // MB - *not used yet...


//XCommon removed ... remnant
#define CommonGalleryImage [UIImage imageNamed:@"gallery_img.png"]
#define CommonGalleryImageLoading [UIImage imageNamed:@"TranscodingDisc"]
#define headerButtonRect CGRectMake(12, 10, 296, 24)
#define SelectedValue @"SelectedValue"
#define valueT @"value"


// Google map Detail
// Search location Typo Ahead API Key
extern NSString* const PLACES_API_BASE;
extern NSString* const GMSSERVICESKEY;
extern NSString* const GOOGLECASTKEY;

// Google Maps zoom constants
extern const float GOOGLEMAPZOOMWORLD;
extern const float GOOGLEMAPZOOMLOCAL;

// Google Maps zoom constants
extern NSString* const GOOGLEADUNITID;
extern NSString* const GOOGLETESTADUNITID;

//Google Cast related
extern NSString *const kPrefPreloadTime;


@interface MyConstant : NSObject
    //+(NSString*) fetchConstantByName:(NSString*)pListKey;
    +(NSString*) getVERSION;
    +(BOOL) isDEVENV;
    +(NSString*) getSMS_URL;
    +(NSString*) getUPLOAD_URL;
    +(NSString*) getWEB_SERVICE_URL;
    +(NSString*) getPOLICY_URL;
    +(NSString*) getBUCKET_NAME;
    +(NSString*) getCOGNITO_POOL_ID;
    +(NSString*) getCOGNITO_ROLE_UNAUTH;
    +(NSString*) getCOGNITO_ROLE_AUTH;
    +(NSString*) fetchGoogleConstantByName:(NSString*)pListKey;
@end


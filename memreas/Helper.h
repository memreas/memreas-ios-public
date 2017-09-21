#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface Helper : NSObject

//
// Location
//
+ (void)setLattitue:(float)lattitue;
+ (float)getLattitue;
+ (void)setLongtitue:(float)longtitue;
+ (float)getLongtitue;


//
// User Defaults
//
+ (NSString*) fetchUserId;
+ (NSString*) fetchUserName;
+ (NSString*) fetchProfilePic;
+ (NSString*) fetchDeviceId;
+ (NSString*) fetchDeviceToken;
+ (NSString*) fetchSID;
+ (void) clearSession;

//
// Show message and Fade
//
+ (MBProgressHUD*) showMessageFade:(UIView*) view withMessage:(NSString*) msg andWithHideAfterDelay:(int) delay;


//
// Fetch content type
//
+ (NSString*)getContentType:(NSString*)fileName;

//
// Convert string to hex string for device token
//
+ (NSString *) hexadecimalString:(NSData*) data;

//
// Misc file utils - refactor
//
+ (NSString*)getFileNameWithExtensionFromPath:(NSString*)path;
+ (NSString*)getIdFromPath:(NSString*)path;


//
// Add top, leading, trailing, and bottom constraints for a child view
//
+(void) setNSLayoutConstraintsParentMargins:(UIView*) parentView withChildView:(UIView*) childView andWithSpacing:(NSInteger) spacing;



@end

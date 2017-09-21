#import "Helper.h"
#import "JSONUtil.h"
#import "MyConstant.h"

@implementation Helper
+ (void)setLattitue:(float)lattitue
{
    [[NSUserDefaults standardUserDefaults]setFloat:lattitue forKey:@"lat"];
}
+ (float)getLattitue
{
    return [[NSUserDefaults standardUserDefaults]floatForKey:@"lat"];
}
+ (void)setLongtitue:(float)longtitue
{
    [[NSUserDefaults standardUserDefaults]setFloat:longtitue forKey:@"long"];
}
+ (float)getLongtitue
{
    return [[NSUserDefaults standardUserDefaults]floatForKey:@"long"];
}

+ (MBProgressHUD*) showMessageFade:(UIView*) view withMessage:(NSString*) msg andWithHideAfterDelay:(int) delay{
    
    //Create the hud with a weak reference
    __weak __block MBProgressHUD *hud;
    
    //Alway on main thread via queue...
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //
        //Create an overlay view to avoid crash related to viewController lifecycle
        //
        UIView* displayOverlayView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        displayOverlayView.backgroundColor = [UIColor clearColor];
        displayOverlayView.opaque = NO;
        [[[UIApplication sharedApplication] keyWindow] addSubview:displayOverlayView];
        
        //
        // MBProgressHUD - viewController shouldn't crash app
        //
        hud = [MBProgressHUD showHUDAddedTo:displayOverlayView animated:YES];
        
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeText;
        hud.labelText = msg;
        hud.margin = 10.f;
        hud.yOffset = 150.f;
        //hud.removeFromSuperViewOnHide = YES;
        
        //[hud hide:YES afterDelay:delay];
        
        //
        //Remove view after hud is removed
        //
        double delayInSeconds = delay;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after delay
            [displayOverlayView removeFromSuperview];
        });
        
    });
    return hud;
}



+ (NSString*) fetchUserId {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
}

+ (NSString*) fetchUserName {
    NSDictionary* dictUserDetail = [[NSUserDefaults standardUserDefaults] objectForKey:@"userDetail"];
    NSString* username = [dictUserDetail objectForKey:@"ownerName"];
    return username;
}

+ (NSString*) fetchProfilePic {
    NSDictionary* dictUserDetail = [[NSUserDefaults standardUserDefaults] objectForKey:@"userDetail"];
    NSString* profile_pic = [JSONUtil convertToID:[dictUserDetail objectForKey:@"ownerImage"]][0];
    
    return profile_pic;
}


+ (NSString*) fetchDeviceId {
    NSString* device_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"device_id"];
    if (device_id == nil) {
        device_id = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [[NSUserDefaults standardUserDefaults] setObject:device_id forKey:@"device_id"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return device_id;
}

+ (NSString*) fetchDeviceToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"];
}

+ (NSString*) fetchSID {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"SID"];
}


+ (void)clearSession {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}


//
// File Utils
//
+ (NSString*)getContentType:(NSString*)fileName {
    @try {
        NSString* contentType = @"";
        fileName = [fileName lowercaseString];
        if ([fileName rangeOfString:@".mp4"].length != 0) {
            contentType = @"video/mp4";
        } else if ([fileName rangeOfString:@".mov"].length != 0) {
            contentType = @"video/quicktime";
        } else if ([fileName rangeOfString:@".flv"].length != 0) {
            contentType = @"video/x-flv";
        } else if ([fileName rangeOfString:@".m3u8"].length != 0) {
            contentType = @"application/x-mpegURL";
        } else if ([fileName rangeOfString:@".ts"].length != 0) {
            contentType = @"video/MP2T";
        } else if ([fileName rangeOfString:@".3gp"].length != 0) {
            contentType = @"video/3gpp";
        } else if ([fileName rangeOfString:@".avi"].length != 0) {
            contentType = @"video/x-msvideo";
        } else if ([fileName rangeOfString:@".wmv"].length != 0) {
            contentType = @"video/x-ms-wmv";
        } else if ([fileName rangeOfString:@".jpg"].length != 0) {
            contentType = @"image/jpeg";
        } else if ([fileName rangeOfString:@".png"].length != 0) {
            contentType = @"image/png";
        } else if ([fileName rangeOfString:@".caf"].length != 0) {
            contentType = @"audio/caf";
        }
        return contentType;
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

//
// Custom method to convert bytes to hex string for device_token
//
+ (NSString *)hexadecimalString:(NSData*) data {
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */
    
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
    
    if (!dataBuffer) {
        return [NSString string];
    }
    
    NSUInteger          dataLength  = [data length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i) {
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    
    return [NSString stringWithString:hexString];
}


//
// Get Filename from Path
//
+ (NSString*)getFileNameWithExtensionFromPath:(NSString*)path {
    NSString* strFileName = @"";
    NSString* str = [NSString stringWithFormat:@"%@", path];
    NSArray* arr = [str componentsSeparatedByString:@"?"];
    NSArray* arr2 = [[NSString stringWithFormat:@"%@", [arr objectAtIndex:1]]
                     componentsSeparatedByString:@"&"];
    NSArray* arr3 = [[NSString stringWithFormat:@"%@", [arr2 objectAtIndex:0]]
                     componentsSeparatedByString:@"="];
    
    NSArray* arr4 = [[NSString stringWithFormat:@"%@", [arr2 objectAtIndex:1]]
                     componentsSeparatedByString:@"="];
    strFileName = [NSString stringWithFormat:@"%@.%@", [arr3 objectAtIndex:1],
                   [arr4 objectAtIndex:1]];
    //    ALog(@"%@",strFileName);
    arr3 = nil;
    arr2 = nil;
    arr = nil;
    return strFileName;
}
+ (NSString*)getIdFromPath:(NSString*)path {
    NSString* strFileName = @"";
    NSString* str = [NSString stringWithFormat:@"%@", path];
    NSArray* arr = [str componentsSeparatedByString:@"?"];
    NSArray* arr2 = [[NSString stringWithFormat:@"%@", [arr objectAtIndex:1]]
                     componentsSeparatedByString:@"&"];
    NSArray* arr3 = [[NSString stringWithFormat:@"%@", [arr2 objectAtIndex:0]]
                     componentsSeparatedByString:@"="];
    strFileName = [NSString stringWithFormat:@"%@", [arr3 objectAtIndex:1]];
    //    ALog(@"%@",strFileName);
    arr3 = nil;
    arr2 = nil;
    arr = nil;
    return strFileName;
}

//
// Add top, leading, trailing, and bottom constraints for a child view
//

+(void) setNSLayoutConstraintsParentMargins:(UIView*) parentView withChildView:(UIView*) childView andWithSpacing:(NSInteger) spacing {
    
    // Creating the same constraints using Layout Anchors
    // - note set childView auto resize to no...
    UILayoutGuide *margin = parentView.layoutMarginsGuide;
    childView.translatesAutoresizingMaskIntoConstraints = NO;
    [childView.topAnchor constraintEqualToAnchor:margin.topAnchor].active = YES;
    [childView.leadingAnchor constraintEqualToAnchor:margin.leadingAnchor].active = YES;
    [childView.trailingAnchor constraintEqualToAnchor:margin.trailingAnchor].active = YES;
    [childView.bottomAnchor constraintEqualToAnchor:margin.bottomAnchor].active = YES;
}




@end

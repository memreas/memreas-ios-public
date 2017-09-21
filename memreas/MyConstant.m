#import "MyConstant.h"
#import "NSString+SrtingUrlValidation.h"

// Landing Tab
NSInteger const SELECTEDLANDINGTAB = 0;

//Cell Sizes for iPhone / iPad
NSInteger const CELLSIZE_IPAD = 120;
NSInteger const CELLSIZE_IPHONE = 80;

//memreas section sizing
NSInteger const MEMREAS_MAIN_CELLSIZE_IPAD_HEIGHT = 120;
NSInteger const MEMREAS_MAIN_CELLSIZE_IPAD_WIDTH = 90;
NSInteger const MEMREAS_MAIN_CELLSIZE_IPHONE_HEIGHT = 80;
NSInteger const MEMREAS_MAIN_CELLSIZE_IPHONE_WIDTH = 60;

NSInteger const MEMREAS_GALLERY_CELLSIZE_IPAD = 120;
NSInteger const MEMREAS_GALLERY_CELLSIZE_IPHONE = 60;

// long fileMaxSize = 10485760; // 10 MB (1 MB = 1024 KB = 1048576 Bytes a)
NSString* const HOSTNAMECHECK = @"www.google.com";
NSString* const DEVICE_TYPE = @"IOS";
NSString* const S3_ENCRYPTION_TYPE = @"AES256";

// int MAX_SELECTION = 10;
NSString* const MAX_MESSAGE = @"You can not select files more than 10";

// Copyright related
NSString* const NSCOPYRIGHT_FONT = @"Segoe Script";
NSString* const NSCOPYRIGHT_FONT_SIZE = @"12";
NSString* const NSCOPYRIGHT_FONT_COLOR = @"blueColor";

// Google Maps related
NSString* const PLACES_API_BASE = @"https://maps.googleapis.com/maps/api/place";
NSString* const GMSSERVICESKEY = @"YOUR_GMSSERVICESKEY";
NSString* const GOOGLECASTKEY = @"YOUR_GOOGLECASTKEY";
NSString* const GOOGLEADUNITID = @"YOUR_GOOGLEADUNITID";
NSString* const GOOGLETESTADUNITID = @"YOUR_GOOGLETESTADUNITID";

const float GOOGLEMAPZOOMWORLD=0.0f;
const float GOOGLEMAPZOOMLOCAL=16.0f;

//Google Cast related
NSString *const kPrefPreloadTime = @"preload_time_sec";

@implementation MyConstant : NSObject

static NSDictionary* envDict = nil;

+(NSString*) fetchConstantByName:(NSString*)pListKey
{
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    //ALog(@"%@", infoDict);
    
    //NSURL* pListUrl = [infoDict objectForKey:@"CFBundleInfoPlistURL"];
    //NSString *pListUrlString = [pListUrl absoluteString];
    
    NSString* pListUrlString = [infoDict objectForKey:@"CFBundleExecutable"];
    
    if (envDict == nil) {
        NSString *file;
        if ([pListUrlString rangeOfString:@"memreasdev" options:NSCaseInsensitiveSearch].location == NSNotFound) {
            //handle prod here
            file = [[NSBundle mainBundle] pathForResource:@"memreas" ofType:@"plist"];
        } else {
            //handle dev here
            file = [[NSBundle mainBundle] pathForResource:@"memreasdev" ofType:@"plist"];
        }
        envDict = [NSDictionary dictionaryWithContentsOfFile:file];
    }
    NSString* pListValue = [envDict objectForKey:pListKey];
    
    return pListValue;
}

+(NSString*) getVERSION {
    NSString* version = [NSString stringWithFormat:@"%@%@", VERSION,[MyConstant fetchConstantByName:@"VERSION"]];
    return version;
};


+(BOOL) isDEVENV {
    NSString *env = [[MyConstant getVERSION] substringFromIndex:[[MyConstant getVERSION] length] - 1];
    if ([env isEqualToString:@"d"]) {
        return YES;
    }
    return NO;
};

+(NSString*) getSMS_URL {
    return [MyConstant fetchConstantByName:@"SMS_URL"];
};

+(NSString*) getUPLOAD_URL {
    return [MyConstant fetchConstantByName:@"UPLOAD_URL"];
};

+(NSString*) getPOLICY_URL {
    return [MyConstant fetchConstantByName:@"POLICY_URL"];
};

+(NSString*) getWEB_SERVICE_URL {
    return [MyConstant fetchConstantByName:@"WEB_SERVICE_URL"];
};

+(NSString*) getBUCKET_NAME {
    return [MyConstant fetchConstantByName:@"BUCKET_NAME"];
}

+(NSString*) getCOGNITO_POOL_ID {
    return [MyConstant fetchConstantByName:@"COGNITO_IDENTITY_POOL_ID"];
}

+(NSString*) getCOGNITO_ROLE_UNAUTH {
    return [MyConstant fetchConstantByName:@"COGNITO_ROLE_UNAUTH"];
}

+(NSString*) getCOGNITO_ROLE_AUTH {
    return [MyConstant fetchConstantByName:@"COGNITO_ROLE_AUTH"];
}

+(NSString*) fetchGoogleConstantByName:(NSString*)pListKey
{
    NSString *file = [[NSBundle mainBundle] pathForResource:@"GoogleService-Info" ofType:@"plist"];
    NSDictionary* googleDict = [NSDictionary dictionaryWithContentsOfFile:file];
    NSString* pListValue = [googleDict objectForKey:pListKey];
    
    return pListValue;
}

//+(NSString*) getCOGNITO_ROLE_AUTH {
//    return [MyConstant fetchGoogleConstantByName:@"COGNITO_ROLE_AUTH"];
//}

@end


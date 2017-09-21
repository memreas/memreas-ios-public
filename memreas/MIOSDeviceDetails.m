#import "MIOSDeviceDetails.h"
#import "MyConstant.h"

@implementation MIOSDeviceDetails

static dispatch_once_t pred;
static MIOSDeviceDetails *sharedInstance = nil;

#pragma mark
#pragma mark Init Methods
- (id)init {
    if (self = [super init]) {
        self.screenHeight = [self getWindowHeight];
        self.screenWidth = [self getWindowWidth];

        ALog(@"Physical Width::%@", @([self getPhysicalWidth]));
        ALog(@"Physical Height::%@", @([self getPhysicalHeight]));
        ALog(@"getWindowHeight::%@", @([self getWindowHeight]));
        ALog(@"getWindowWidth::%@", @([self getWindowWidth]));
        ALog(@"getWindowNativeScale::%@", @([self getWindowNativeScale]));
        ALog(@"getPhysicalWidth::%@", @([self getPhysicalWidth]));
        ALog(@"getPhysicalHeight::%@", @([self getPhysicalHeight]));
        
        //
        // Check by hw method
        //
        //NSString *platform = [UIDevice currentDevice].model;
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
        free(machine);
        
        if ([platform isEqualToString:@"iPhone5,1"]) self.iosDeviceType = IPHONE_5;
        if ([platform isEqualToString:@"iPhone5,2"]) self.iosDeviceType = IPHONE_5;
        if ([platform isEqualToString:@"iPhone5,3"]) self.iosDeviceType = IPHONE_5;
        if ([platform isEqualToString:@"iPhone5,4"]) self.iosDeviceType = IPHONE_5;
        if ([platform isEqualToString:@"iPhone6,1"]) self.iosDeviceType = IPHONE_6;
        if ([platform isEqualToString:@"iPhone6,2"]) self.iosDeviceType = IPHONE_5;
        if ([platform isEqualToString:@"iPhone7,1"]) self.iosDeviceType = IPHONE_6_PLUS;
        if ([platform isEqualToString:@"iPhone7,2"]) self.iosDeviceType = IPHONE_6;
        if ([platform isEqualToString:@"iPhone8,1"]) self.iosDeviceType = IPHONE_6_PLUS;
        if ([platform isEqualToString:@"iPhone8,2"]) self.iosDeviceType = IPHONE_6;
        if ([platform isEqualToString:@"iPad1,1"]) self.iosDeviceType = IPAD;
        if ([platform isEqualToString:@"iPad2,1"]) self.iosDeviceType = IPAD;
        if ([platform isEqualToString:@"iPad2,2"]) self.iosDeviceType = IPAD;
        if ([platform isEqualToString:@"iPad2,3"]) self.iosDeviceType = IPAD;
        if ([platform isEqualToString:@"iPad2,4"]) self.iosDeviceType = IPAD;
        if ([platform isEqualToString:@"iPad2,5"]) self.iosDeviceType = IPAD;
        if ([platform isEqualToString:@"iPad2,6"]) self.iosDeviceType = IPAD;
        if ([platform isEqualToString:@"iPad2,7"]) self.iosDeviceType = IPAD;
        if ([platform isEqualToString:@"iPad3,1"]) self.iosDeviceType = IPAD;
        if ([platform isEqualToString:@"iPad3,2"]) self.iosDeviceType = IPAD;
        if ([platform isEqualToString:@"iPad3,3"]) self.iosDeviceType = IPAD;
        if ([platform isEqualToString:@"iPad3,4"]) self.iosDeviceType = IPAD;
        if ([platform isEqualToString:@"iPad3,5"]) self.iosDeviceType = IPAD;
        if ([platform isEqualToString:@"iPad3,6"]) self.iosDeviceType = IPAD;
        if ([platform isEqualToString:@"iPad4,1"]) self.iosDeviceType = IPAD;
        if ([platform isEqualToString:@"iPad4,2"]) self.iosDeviceType = IPAD;
        if ([platform isEqualToString:@"iPad4,4"]) self.iosDeviceType = IPAD;
        if ([platform isEqualToString:@"iPad4,5"]) self.iosDeviceType = IPAD;
        
        
        /*
         
         
         if([deviceType isEqualToString:@"iPhone"]) {
         //if (
         //        ((self.screenHeight == 2732) && (self.screenWidth == 2048)) ||
         //        ((self.screenWidth == 2732) && (self.screenHeight == 2048))
         //    ) {
         
         //
         // IPAD_PRO
         //
         self.iosDeviceType == IPAD_PRO;
         } else if ( ((self.screenHeight == 2048) && (self.screenWidth == 1536)) ||
         ((self.screenWidth == 2048) && (self.screenHeight == 1536)) ) {
         //
         // IPAD_AIR, IPAD_AIR_2, IPAD_MINI_2, IPAD_MINI_4
         //
         self.iosDeviceType == IPAD_AIR;
         
         } else if ( ((self.screenHeight == 2208) && (self.screenWidth == 1242)) ||
         ((self.screenWidth == 2208) && (self.screenHeight == 1242)) ) {
         //
         // IPHONE_6_PLUS, IPHONE_6S_PLUS
         //
         self.iosDeviceType == IPHONE_6_PLUS;
         
         */
        
    }
    return self;
}

// Get the shared instance and create it if necessary.
+ (MIOSDeviceDetails *)sharedInstance {
    dispatch_once(&pred, ^{
        sharedInstance = [[MIOSDeviceDetails alloc] init];
    });
    return sharedInstance;
}

+ (void)resetSharedInstance {
    sharedInstance = nil;
}

#pragma mark
#pragma mark Window Size Methods
- (CGFloat) getWindowHeight   {
    return [UIScreen mainScreen].bounds.size.height;
}

- (CGFloat) getWindowWidth   {
    return [UIScreen mainScreen].bounds.size.width;
}

- (CGRect) getWindowRect   {
    return [[UIScreen mainScreen] bounds];
}

- (CGFloat) getWindowNativeScale   {
    return [UIScreen mainScreen].nativeScale;
}

- (CGFloat) getPhysicalWidth   {
    return [self getWindowWidth] * [self getWindowNativeScale];
}

- (CGFloat) getPhysicalHeight   {
    return [self getWindowHeight] * [self getWindowNativeScale];
}

- (IOSDeviceType) getIOSDeviceType {
    return self.iosDeviceType;
}

//- (NSString*) getAdUnitId:(GADBannerView*) bannerView {
- (NSString*) getAdUnitId {
    
    //
    // Create adMob ad View (note the use of various macros to detect device)
    //
    /*
    if (self.iosDeviceType == IPHONE_5) {
        bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    }
    else if (self.iosDeviceType == IPHONE_6) {
        bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    }
    else if (self.iosDeviceType == IPHONE_6_PLUS) {
        bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    }
    else {
        // boring old iPhones and iPod touches
        bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    }
    */
    
    //GADRequest *request = [GADRequest request];
    // Requests test ads on devices you specify. Your test device ID is printed to the console when
    // an ad request is made. GADBannerView automatically returns test ads when running on a
    // simulator.
    NSString *env = [[MyConstant getVERSION] substringFromIndex:[[MyConstant getVERSION] length] - 1];
    ALog(@"%@", [MyConstant getVERSION]);
    ALog(@"env: %@", env);
    NSString* adUnitId;
    if ([env isEqualToString:@"d"]) {
        //request.testDevices = @[[Helper fetchDeviceId]];
        adUnitId = GOOGLETESTADUNITID;
        //request.testDevices = @[ @"b648b4b7573dd55b6554c594a55491dd" ];
    } else {
        adUnitId = GOOGLEADUNITID;
    }
    
    return adUnitId;
    
    //bannerView.rootViewController = viewController;
    //[bannerView loadRequest:request];
    //return bannerView;
}

@end

#import <Foundation/Foundation.h>
#import <sys/sysctl.h>
@import GoogleMobileAds;

typedef NS_ENUM(NSInteger, IOSDeviceType) {
    IPHONE_6S_PLUS,
    IPHONE_6S,
    IPHONE_6_PLUS,
    IPHONE_6,
    IPHONE_5S,
    IPHONE_5,
    IPAD_PRO,
    IPAD,
    IPAD_AIR_2,
    IPAD_AIR,
    IPAD_MINI_4,
    IPAD_MINI_2
};

@interface MIOSDeviceDetails : NSObject

//
// properties
//
@property (nonatomic) IOSDeviceType iosDeviceType;
@property (nonatomic) CGFloat screenHeight;
@property (nonatomic) CGFloat screenWidth;

//
//Methods
//
+ (MIOSDeviceDetails*)sharedInstance;
+ (void)resetSharedInstance;
- (IOSDeviceType) getIOSDeviceType;
//- (NSString*) getBannerView:(GADBannerView*) bannerView;
- (NSString*) getAdUnitId;

@end


#import <UIKit/UIKit.h>
#import "CommonButton.h"
#import "MyConstant.h"
#import "MIOSDeviceDetails.h"
@import GoogleMobileAds;

@class MoreTabViewController;

@interface MoreTabViewController : UIViewController<GADBannerViewDelegate>

//Account vars
@property (nonatomic) IBOutlet UIImageView *profileImageView;
@property (nonatomic) IBOutlet UILabel *usernameLabel;
@property (nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;

@end

#import <UIKit/UIKit.h>
#import "MIOSDeviceDetails.h"
@import GoogleMobileAds;

@interface PrivacyPolicyViewController : UIViewController

//Web Views
@property (nonatomic) IBOutlet UIWebView *webview;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;

@end

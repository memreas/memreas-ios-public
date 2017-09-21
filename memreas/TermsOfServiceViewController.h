#import <UIKit/UIKit.h>
@import GoogleMobileAds;
@class MyConstant;
@class MIOSDeviceDetails;

@interface TermsOfServiceViewController : UIViewController

//Web Views
@property (nonatomic) IBOutlet UIWebView *webview;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;

@end

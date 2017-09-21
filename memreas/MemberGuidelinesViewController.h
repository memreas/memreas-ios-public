#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
@import GoogleMobileAds;
@class MIOSDeviceDetails;
@class MyConstant;


@interface MemberGuidelinesViewController : UIViewController

//Web Views
@property (nonatomic) IBOutlet WKWebView *webView;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;

@end

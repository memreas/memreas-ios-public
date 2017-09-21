#import "PrivacyPolicyViewController.h"
#import "MyConstant.h"
@implementation PrivacyPolicyViewController

#pragma mark
#pragma mark View Controller Methods

- (void)viewDidLoad {
    @try {
        [super viewDidLoad];

        //
        // Google Banner View
        //
        self.bannerView.adUnitID = [[MIOSDeviceDetails sharedInstance] getAdUnitId];
        self.bannerView.rootViewController = self;
        [self.bannerView loadRequest:[GADRequest request]];
        
        //
        // load web view
        //
        NSString* strMemberGuidelinesPolicy = [NSString stringWithFormat:@"%@privacy", [MyConstant getPOLICY_URL]];
        NSURL *url = [NSURL URLWithString:strMemberGuidelinesPolicy];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        [self.webview loadRequest:urlRequest];
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    @try {
        [super viewWillAppear:animated];
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    @try {
        [super viewWillAppear:animated];
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

- (void)dealloc {
}


- (void)viewWillDisappear:(BOOL)animated {
}

#pragma mark
#pragma mark Instance Methods

- (IBAction) segueBack:(UIButton*)sender {
    //
    // pop back to more...
    //
    [self dismissViewControllerAnimated:NO completion:nil];
    
}

#pragma mark
#pragma mark GAdBannerViewDelegate Method

- (void)adViewDidReceiveAd:(GADBannerView *) bannerView {
    //ALog(@"ad was received...");
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    //ALog(@"didFailToReceiveAdWithError: %@...", error.localizedFailureReason);
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView {
    //ALog(@"adViewWillPresentScreen...");
}
- (void)adViewDidDismissScreen:(GADBannerView *)bannerView {
    //ALog(@"adViewDidDismissScreen...");
}
- (void)adViewWillDismissScreen:(GADBannerView *)bannerView {
    //ALog(@"adViewWillDismissScreen...");
}

@end

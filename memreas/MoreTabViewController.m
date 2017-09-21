#import "MoreTabViewController.h"
#import "Helper.h"
#import "UIImageView+AFNetworking.h"

@implementation MoreTabViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //
    // Google Banner View
    //
    self.bannerView.adUnitID = [[MIOSDeviceDetails sharedInstance] getAdUnitId];
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
    
    NSURL* profilePic = [NSURL URLWithString:[Helper fetchProfilePic]];
    self.profileImageView.layer.borderWidth =2;
    self.profileImageView.layer.cornerRadius =5;
    self.profileImageView.layer.masksToBounds =YES;
    self.profileImageView.clipsToBounds =YES;
    self.profileImageView.layer.borderColor = [UIColor clearColor].CGColor;

    [self.profileImageView setImageWithURL:profilePic placeholderImage:[UIImage imageNamed:@"profile_img"]];
    self.usernameLabel.text = [Helper fetchUserName];
    self.versionLabel.text = [MyConstant getVERSION];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    if (IS_IPAD) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"more"] forBarMetrics:UIBarMetricsDefault];
    }else{
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"MoreTitle.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
}

- (IBAction)btnHeaderPressed:(UIButton*)sender {
    
    //
    // need one of these for each header
    //
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark
#pragma mark accordion actions
- (IBAction) segueMemberGuidelines:(UIButton*)sender {
    //
    // Handle tabs and layout
    //
    [self performSegueWithIdentifier:@"segueMemberGuidelines" sender:self];
}

- (IBAction) seguePrivacyPolicy:(UIButton*)sender {
    //
    // Handle tabs and layout
    //
    [self performSegueWithIdentifier:@"seguePrivacyPolicy" sender:self];
    
}

- (IBAction) segueDmcaPolicy:(UIButton*)sender {
    //
    // Handle tabs and layout
    //
    [self performSegueWithIdentifier:@"segueDmcaPolicy" sender:self];
    
}


- (IBAction) segueTermsOfService:(UIButton*)sender {
    //
    // Handle tabs and layout
    //
    [self performSegueWithIdentifier:@"segueTermsOfService" sender:self];
    
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



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end


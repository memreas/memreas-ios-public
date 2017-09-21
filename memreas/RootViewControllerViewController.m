#import "RootViewControllerViewController.h"
@import Photos;
#import "MyConstant.h"

@implementation RootViewControllerViewController {
}


- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (NSArray*)bannerArray {
    return @[
             [UIImage imageNamed:@"slider1"],
             [UIImage imageNamed:@"slider2"],
             [UIImage imageNamed:@"slider3"],
             [UIImage imageNamed:@"slider4"],
             [UIImage imageNamed:@"slider5"],
             [UIImage imageNamed:@"slider6"],
             [UIImage imageNamed:@"slider7"]
             ];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
//    ALog(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    
    self.sliderImage.animationImages = self.bannerArray;
    self.sliderImage.animationDuration = 20;
    [self.sliderImage startAnimating];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //
    // Check access to photos
    //
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    __block bool accessAllowed = NO;
    if (status == PHAuthorizationStatusAuthorized) {
        // Access has been granted.
        ALog(@"status == PHAuthorizationStatusAuthorized");
        accessAllowed = YES;
    } else if (status == PHAuthorizationStatusDenied) {
        // Access has been denied.
        ALog(@"status == PHAuthorizationStatusDenied");
    } else if (status == PHAuthorizationStatusNotDetermined) {
        ALog(@"status == PHAuthorizationStatusNotDetermined");
        // Access has not been determined.
    } else if (status == PHAuthorizationStatusRestricted) {
        // Restricted access - normally won't happen.
        ALog(@"status == PHAuthorizationStatusRestricted");
    }
    
    if (!accessAllowed) {
        //
        // Request Access
        //
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if (status == PHAuthorizationStatusAuthorized) {
                // Access has been granted.
                accessAllowed = YES;
            } else {
                // Access has been denied.
                ALog(@"status == Access has been denied.");
                // - disable access to app - photos access is a prerequisite
                
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.btnLogin.enabled = NO;
                    weakSelf.btnSignUp.enabled = NO;
                    [Helper showMessageFade:self.view withMessage:@"please enable photo gallery access" andWithHideAfterDelay:60];
                });

            }
        }];

    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (UIImage*)placeHolderImageOfZeroBannerView {
    return [[UIImage alloc] init];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


@end

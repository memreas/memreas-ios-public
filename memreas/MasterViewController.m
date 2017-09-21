#import "MasterViewController.h"
#import "SettingButton.h"
#import "MyConstant.h"

@implementation MasterViewController {
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SettingButton addRightBarButtonAsNotificationInViewController:self];
    [SettingButton addLeftSearchInViewController:self];
    
    appDelegate =
    (AppDelegate*)[UIApplication sharedApplication]
    .delegate;
    
    [self prefersStatusBarHidden];
    
    //
    // show bottom menu bar and back button
    //
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = NO;
    
    //
    // Search and Notifications
    //
    [SettingButton addRightBarButtonAsNotificationInViewController:self];
    [SettingButton addLeftSearchInViewController:self];
    
}
- (void)viewDidAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning {
    ALog(@"%s", __PRETTY_FUNCTION__);
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

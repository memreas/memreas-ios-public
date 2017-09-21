#import "MyTabBarController.h"

@interface MyTabBarController ()

@end

@implementation MyTabBarController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self setSelectedIndex:int(SelectedLandingToTab)];
    //[self setSelectedIndex:SELECTEDLANDINGTAB];
}

- (void)didReceiveMemoryWarning
{
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


@end

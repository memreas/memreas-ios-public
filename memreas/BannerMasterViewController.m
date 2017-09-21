//
//  BannerMasterViewController.m
//  Eventmanagement
//
//  Created by sarfaraj on 06/06/13.
//
//

#import "BannerMasterViewController.h"

@interface BannerMasterViewController ()

@end

@implementation BannerMasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView{
    [super loadView];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect rect = self.view.frame;
    _adView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    _adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    _adView.delegate = self;
    
    [self.view addSubview:_adView];
    
    _adView.center= CGPointMake((rect.size.width/2), (rect.size.height-25));
    
    [self.view bringSubviewToFront:_adView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload{
    _adView = nil;
}

#pragma mark
#pragma mark AdBannerViewDelegate Method

-(BOOL) bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{

    NSLog(@"Banner view is beginning ad action");
    return YES;
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"banner error : %@",error.description);
}

@end

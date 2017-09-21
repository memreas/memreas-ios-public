#import "EventViewController.h"
#import "MyConstant.h"

@implementation EventViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    ALog(@"%s", __PRETTY_FUNCTION__);
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    ALog(@"%s", __PRETTY_FUNCTION__);
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (void)viewDidLoad
{
    ALog(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden=NO;
    self.navigationItem.hidesBackButton=NO;
    
}

-(void)viewWillAppear:(BOOL)animated{
    ALog(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
    
    //set navigation bar custom image    
    if ([[[UIDevice currentDevice] systemVersion] intValue] >= 5.0)
    {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"event_hdr.png"] forBarMetrics:UIBarMetricsDefault];
    }
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    ALog(@"%s", __PRETTY_FUNCTION__);
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
-(void)logoutButtonWasPressed:(id)sender

{    
    ALog(@"%s", __PRETTY_FUNCTION__);
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end

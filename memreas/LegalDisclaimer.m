#import "LegalDisclaimer.h"
#import "MyConstant.h"

@interface LegalDisclaimer ()
@property (weak, nonatomic) IBOutlet UIImageView *imgHeader;

@end

@implementation LegalDisclaimer

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)backPressed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES
     ];
    
}
-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    if (IS_IPAD) {
        [self.imgHeader setImage:[UIImage imageNamed:@"terms of services"] ];
    }else{
        [self.imgHeader setImage:[UIImage imageNamed:@"iphone -  terms of services"] ];
        
    }
    
    
    if (IS_IPAD) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"terms of services"] forBarMetrics:UIBarMetricsDefault];
    }else{
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"iphone -  terms of services"] forBarMetrics:UIBarMetricsDefault];
    }



}

- (void)viewDidLoad
{
    ALog(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#import "PrivecyPolicy.h"
#import "MyConstant.h"

@interface PrivecyPolicy ()

@end

@implementation PrivecyPolicy

- (void)viewDidLoad {
    ALog(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    if (IS_IPAD) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"privacy policy"] forBarMetrics:UIBarMetricsDefault];

    }else{
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"Iphone-privacy-policy"] forBarMetrics:UIBarMetricsDefault];

    }

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)backTap:(id)sender {
    
    [self.navigationController popViewControllerAnimated:1];
}

@end

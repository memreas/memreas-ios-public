#import <UIKit/UIKit.h>
#import "Helper.h"


@interface RootViewControllerViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *sliderImage;
@property (strong, nonatomic) IBOutlet UIButton *btnLogin;
@property (strong, nonatomic) IBOutlet UIButton *btnSignUp;

@property (nonatomic,readonly) NSArray * bannerArray;
@end

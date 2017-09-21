#import "UIViewController+Logout.h"
#import "MyConstant.h"

@implementation UIViewController (Logout)

-(void)checkForLogOut:(NSString*)respose{
    @try {
        if ([respose rangeOfString:@"Please Login"].length) {
            [[[UIAlertView alloc] initWithTitle:@"Your session has expired,Please Login again" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            [self dismissViewControllerAnimated:1 completion:nil];
        }
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
}

@end

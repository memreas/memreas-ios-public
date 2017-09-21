#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@class AWSCore;
@class AWSManager;
@class CopyrightManager;
@class GalleryManager;
@class MyConstant;
@class MWebServiceHandler;
@class MWebServiceHandler;
@class RootViewControllerViewController;
@class MyConstant;
@class NotificationsViewController;
@class Helper;
@class Util;
@class XMLParser;
@class MediaIdManager;


@interface LoginViewController : UIViewController<UITextFieldDelegate> {
  CGFloat animatedDistance;
  __weak IBOutlet UINavigationBar* myNav;
  __weak IBOutlet UIBarButtonItem* backButton;
  __weak IBOutlet UILabel* lblUsername;
  __weak IBOutlet UILabel* lblPassword;
  XMLParser* parser;
  AppDelegate* appDelegate;

}

@property(strong, nonatomic) IBOutlet UILabel* lblVersion;
@property(strong, nonatomic) IBOutlet UITextField* txtUsername;
@property(strong, nonatomic) IBOutlet UITextField* txtPassword;
@property(strong, nonatomic) IBOutlet UIView* loadingView;

- (IBAction)doLogin:(id)sender;
- (IBAction)goForgotPassword:(id)sender;
- (void)dismissInputControls;
- (IBAction)btnCancelClicked:(id)sender;

@property(weak, nonatomic) IBOutlet UIImageView* imgheaderTitle;

@end

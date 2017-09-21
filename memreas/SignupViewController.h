#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
@class MyConstant;
@class RootViewControllerViewController;
@class MyConstant;
@class XMLParser;
@class MemreasGallery;
@class Helper;
@class AWSManager;
@class MWebServiceHandler;
@class WebServiceParser;
@class WebServices;
@class XMLGenerator;
@class Util;
@class GalleryManager;


@interface SignupViewController
    : UIViewController <UITextFieldDelegate, UINavigationControllerDelegate,
                            UIImagePickerControllerDelegate,
                            UIAlertViewDelegate> {
  __weak IBOutlet UINavigationBar *myNav;
  CGFloat animatedDistance;
  UIImagePickerController *imgPicker;
  BOOL isTermsAccepted, needToValidate;
  //    IBOutlet UILabel *label2;
  __weak IBOutlet UILabel *lblProgress;
  __weak IBOutlet UIActivityIndicatorView *actRegister;
  XMLParser *parser;
  NSData *imgData;

  __weak IBOutlet UILabel *lblEmail;
  __weak IBOutlet UILabel *lblUsername;
  __weak IBOutlet UILabel *lblPassword;
  __weak IBOutlet UILabel *lblVerifyPassword;
  __weak IBOutlet UIButton *btnLegalDisclaimer;
}




@property(strong, nonatomic) IBOutlet UITextField *textEmail;
@property(strong, nonatomic) IBOutlet UITextField *textUsername;
@property(strong, nonatomic) IBOutlet UITextField *textPassword;
@property(strong, nonatomic) IBOutlet UITextField *textCPassword;
@property(strong, nonatomic) IBOutlet UITextField *textInvitedBy;
@property(strong, nonatomic) IBOutlet UIView *loadingView;
@property(strong, nonatomic) IBOutlet UIImageView *uiProfileImage;
@property(strong, nonatomic) IBOutlet UIButton *btn_checked;
@property(weak, nonatomic) IBOutlet UILabel *label2;
@property(weak, nonatomic) IBOutlet UILabel *lableUsernameMsg;
@property(weak, nonatomic) IBOutlet UILabel *lblEmailCheck;
@property NSString *s3Path;
@property NSString *s3file_name;
@property NSString *content_type;
@property NSData *profileImage;
@property NSURLSessionUploadTask *uploadProfileImageTask;
@property NSURL *mediaCopyURL;
@property NSString *isProfileSelected;
@property NSString *profileImageURL;
@property NSString *userId;
@property NSString *sid;
@property NSString *device_id;
@property NSString *mediaId;

- (IBAction)doSignup:(id)sender;
- (void)dismissInputControls;
- (IBAction)grabImage:(id)sender;
- (IBAction)btnCancelClicked:(id)sender;
@end

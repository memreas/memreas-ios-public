#import "LoginViewController.h"
#import "AWSCore.h"
#import "AWSManager.h"
#import "CopyrightManager.h"
#import "GalleryManager.h"
#import "MyConstant.h"
#import "MWebServiceHandler.h"
#import "MWebServiceHandler.h"
#import "RootViewControllerViewController.h"
#import "MyConstant.h"
#import "NotificationsViewController.h"
#import "Helper.h"
#import "Util.h"
#import "XMLParser.h"
#import "MediaIdManager.h"


@implementation LoginViewController {
    WebServiceParser* webServiceParserLogin;
    NSString* device_id;
}


- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"uploadImages"]) {
    } else if ([segue.identifier isEqualToString:@"segueTabbarLogin"]) {
        RootViewControllerViewController* root = [segue destinationViewController];
        if (!root.isBeingPresented) {
            [self performSelector:@selector(btnCancelClicked:)
                       withObject:nil
                       afterDelay:0.5];
        }
    }
}

- (void)didReceiveMemoryWarning {
    ALog(@"%s", __PRETTY_FUNCTION__);
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     * fetch appDelegate for view messages
     */
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    /**
     * Set Observer for login web services...
     */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLoginMWS:)
                                                 name:LOGIN_RESULT_NOTIFICATION
                                               object:nil];
    
    
    [lblUsername setFont:[UIFont fontWithName:@"TRCenturyGothic" size:15]];
    [lblPassword setFont:[UIFont fontWithName:@"TRCenturyGothic" size:15]];
    
    self.txtPassword.delegate = self;
    self.txtUsername.delegate = self;
    
    
    self.txtUsername.text = @"";
    self.txtPassword.text = @"";
    //
    // Set default for dev version for now...
    //
    //ALog(@"%@", [MyConstant getVERSION]);
    if ([MyConstant isDEVENV]) {
        self.txtUsername.text = @"jmeah1";
        self.txtPassword.text = @"a123456";
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.lblVersion.text = [NSString stringWithFormat:@"%@", [MyConstant getVERSION]];
    
    // set navigation bar custom image
    //
    
    if (IS_IPAD) {
        [self.imgheaderTitle setImage:[UIImage imageNamed:@"LoginHeader"]];
    } else {
        [self.imgheaderTitle setImage:[UIImage imageNamed:@"login_hdr"]];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -
#pragma mark - Text Field Delegate  Methods
#pragma mark -

- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField*)textField {
    textField.text = @"";
    static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
    static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
    static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
    static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
    static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
    
    CGRect textFieldRect;
    CGRect viewRect;
    
    textFieldRect =
    [self.view.window convertRect:textField.bounds fromView:textField];
    viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y -
    MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) *
    viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0) {
        heightFraction = 0.0;
    } else if (heightFraction > 1.0) {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown) {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    } else {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame;
    
    viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldEndEditing:(UITextField*)textField {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField*)textField {
    [textField resignFirstResponder];
    if (textField.tag == 0) {
        static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
        CGRect viewFrame;
        
        viewFrame = self.view.frame;
        viewFrame.origin.y += animatedDistance;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
        
        [self.view setFrame:viewFrame];
        [UIView commitAnimations];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return TRUE;
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    [super touchesBegan:touches withEvent:event];  // may be not required
    [self dismissInputControls];
}

#pragma mark -
#pragma mark---------------               RESIGN KEYBOARD on touch Method                ---------------
#pragma mark -
- (void)dismissInputControls {
    [self.txtPassword resignFirstResponder];
    [self.txtUsername resignFirstResponder];
}

#pragma mark LoginWebservices
- (void)clearForm {
    self.txtPassword.text = @"";
    self.txtUsername.text = @"";
}
- (BOOL)validateLogin {
    BOOL isValid = true;
    
    if (([self.txtUsername.text length] == 0) || ([self.txtPassword.text length] == 0)) {
        // Show Error Message
        [Helper showMessageFade:[appDelegate topViewController].view withMessage:@"Please enter your username and password" andWithHideAfterDelay:2];
        isValid = false;
    }
    
    return isValid;
}

- (void)doLogins:(UIButton*)sender {
    sender.enabled = YES;
}

- (IBAction)doLogin:(UIButton*)sender {
    sender.enabled = NO;
    
    [self performSelector:@selector(doLogins:) withObject:sender afterDelay:5];
    
    if ([self validateLogin]) {
        [self dismissInputControls];
        
        //
        // Exec in background - avoid main thread
        //
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            /*
             * Use new XMLGenerator...
             */
            NSString* requestXML = [XMLGenerator generateLoginXML:self.txtUsername.text
                                                         password:self.txtPassword.text
                                                        device_id:[Helper fetchDeviceId]
                                                       devicetype:DEVICE_TYPE
                                                      devicetoken:[Helper fetchDeviceToken]];
            if ([Util checkInternetConnection]) {
                if (webServiceParserLogin) {
                    webServiceParserLogin = nil;
                }
                
                if (!webServiceParserLogin) {
                    
                    __weak typeof(self) weakSelf = self;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.loadingView.hidden = YES;
                    });
                    //self.loadingView.hidden = NO;
                    
                    webServiceParserLogin.isFriendList = NO;
                    
                    /**
                     * Use WebServices Request Generator
                     */
                    
                    NSMutableURLRequest* request =
                    [WebServices generateWebServiceRequest:requestXML action:LOGIN];
                    //ALog(@"NSMutableRequest request ----> %@", request);
                    
                    /**
                     * Send Request and Parse Response...
                     *  Note: wsHandler calls objectParsed_ListAllMedia
                     */
                    MWebServiceHandler* wsHandler = [[MWebServiceHandler alloc] init];
                    [wsHandler fetchServerResponse:request action:LOGIN key:LOGIN_RESULT_NOTIFICATION];
                }
            }
        });
    }
}

/**
 * Web Service Response Result methods
 */
- (void)handleLoginMWS:(NSNotification*)notification {
    NSDictionary* resultTags = [notification userInfo];
    
    NSString* status = @"";
    status = [resultTags objectForKey:@"status"];
    if ([status isEqualToString:@"success"]) {
        [[NSUserDefaults standardUserDefaults] setObject:resultTags[@"user_id"]
                                                  forKey:@"UserId"];
        [[NSUserDefaults standardUserDefaults] setObject:resultTags[@"sid"]
                                                  forKey:@"SID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // hide loading view...
        self.loadingView.hidden = YES;
        
        //
        // Fetch MediaIdManager for batch use
        //
        [MediaIdManager sharedInstance];
        
        //
        // Fetch CopyrightManager for batch use
        //
        [CopyrightManager sharedInstance];

        //
        // fire load notifications - background fetch in method
        //
        [[NotificationsViewController sharedInstance] getNotifications];
        
        
        //
        // Fetch AWS Handle
        //
        [AWSManager sharedInstance];
        
        /**
         * Segue
         */
        [self performSegueWithIdentifier:@"segueTabbarLogin" sender:nil];
        
    } else {
        // message too long for Helper view
        //NSString* message =
        //[NSString stringWithFormat:@"%@", [resultTags valueForKey:@"message"]];
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.loadingView.hidden = YES;
            [Helper showMessageFade:weakSelf.view withMessage:@"login failed - check credentials" andWithHideAfterDelay:3];
        });
        
        
    }
}

- (IBAction)goForgotPassword:(id)sender {
    [self performSegueWithIdentifier:@"segueForgotPassword" sender:nil];
}

- (IBAction)btnCancelClicked:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)goBack {  // Go Back
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


@end

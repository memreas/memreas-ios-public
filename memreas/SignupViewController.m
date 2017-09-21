#import "SignupViewController.h"
#import "MyConstant.h"
#import "RootViewControllerViewController.h"
#import "MyConstant.h"
#import "XMLParser.h"
#import "MemreasGallery.h"
#import "Helper.h"
#import "AWSManager.h"
#import "MWebServiceHandler.h"
#import "WebServiceParser.h"
#import "WebServices.h"
#import "XMLGenerator.h"
#import "Util.h"
#import "GalleryManager.h"
#import "AWSCore.h"
#import "AWSS3.h"

@implementation SignupViewController {
    __weak IBOutlet UIImageView *imgHeader;
    AppDelegate *appDelegate;
}
@synthesize textEmail;
@synthesize textUsername;
@synthesize textPassword;
@synthesize textCPassword;
@synthesize textInvitedBy;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueTabbarLogin"]) {
        RootViewControllerViewController *root = [segue destinationViewController];
        if (!root.isBeingPresented) {
            [self performSelector:@selector(btnCancelClicked:)
                       withObject:nil
                       afterDelay:0.5];
        }
    }
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view,
// typically from a nib.
- (void)viewDidLoad {
    ALog(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    
    [textCPassword setDelegate:self];
    [textUsername setDelegate:self];
    [textPassword setDelegate:self];
    [textEmail setDelegate:self];
    [textInvitedBy setDelegate:self];
    parser = [[XMLParser alloc] init];
    
    [lblEmail setFont:[UIFont fontWithName:@"TRCenturyGothic" size:15]];
    [lblUsername setFont:[UIFont fontWithName:@"TRCenturyGothic" size:15]];
    [btnLegalDisclaimer.titleLabel
     setFont:[UIFont fontWithName:@"TRCenturyGothic" size:15]];
    appDelegate =
    (AppDelegate *)[UIApplication sharedApplication]
    .delegate;
    
    /**
     * Set Observer for Registration web service...
     */
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(checkusernameMWSHandlerComplete:)
     name:CHECKUSERNAME_RESULT_NOTIFICATION
     object:nil];
    
    /**
     * Set Observer for Registration web service...
     */
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleRegistrationMWS:)
     name:REGISTRATION_RESULT_NOTIFICATION
     object:nil];
    
    /**
     * Set Observer for GenerateMediaId web service...
     */
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleGenerateMediaIdMWS:)
     name:@"REGISTRATION"
     object:nil];
    
    /**
     * Set Observer for addmediaevent web service...
     */
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleAddMediaEventMWS:)
     name:ADDMEDIAEVENT_REGISTRATION_RESULT_NOTIFICATION
     object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //
    // Set Page Title
    //
    if (IS_IPAD) {
        [imgHeader setImage:[UIImage imageNamed:@"sign up"]];
    } else {
        [imgHeader setImage:[UIImage imageNamed:@"singup_hdr"]];
    }
    
    // set navigation bar custom image
    needToValidate = true;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    if (parser == nil) {
        parser = [[XMLParser alloc] init];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void)viewDidUnload {
    [super viewDidUnload];
    
    [self setTextEmail:nil];
    [self setTextUsername:nil];
    [self setTextPassword:nil];
    [self setTextCPassword:nil];
    [self setTextInvitedBy:nil];
    [self setLoadingView:nil];
    [self setUiProfileImage:nil];
    [self setBtn_checked:nil];
    myNav = nil;
    [self setLblEmailCheck:nil];
    actRegister = nil;
    lblEmail = nil;
    lblUsername = nil;
    lblPassword = nil;
    lblVerifyPassword = nil;
    btnLegalDisclaimer = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark------------------------------ Text Field Delegate  Methods --------------------------------
#pragma mark -

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
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



-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event]; // may be not required
    [self.view endEditing:YES];
    //	[self     dismissInputControls];
}

#pragma mark -
#pragma mark ---------------               RESIGN KEYBOARD on touch Method                ---------------
#pragma mark -
- (void)dismissInputControls {
    [textCPassword resignFirstResponder];
    [textUsername resignFirstResponder];
    [textPassword resignFirstResponder];
    [textEmail resignFirstResponder];
    [textInvitedBy resignFirstResponder];
}

#pragma mark LoginWebservices

- (BOOL)validateEmail:(NSString *)candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest =
    [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}
- (BOOL)validateSignup {
    [self dismissInputControls];
    
    if (([textUsername.text length] == 0) || ([textPassword.text length] == 0) ||
        ([textCPassword.text length] == 0) || ([textEmail.text length] == 0))
        
    {
        // label.text=@"Please fill the Fields!!!";
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"error"
                                   message:@"please fill all the fields."
                                  delegate:self
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil, nil];
        
        [alert show];
        
        return false;
    }
    if ([[textPassword.text
          stringByTrimmingCharactersInSet:
          [NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        
        [Helper showMessageFade:self.view withMessage:@"please check your password" andWithHideAfterDelay:3];
        
        return false;
    }
    if (!isTermsAccepted) {
        [Helper showMessageFade:self.view withMessage:@"please check our terms of service" andWithHideAfterDelay:3];
        return false;
    }
    if (![self validateEmail:textEmail.text]) {
        self.lblEmailCheck.text = @"invalid email address";
        return false;
    }
    if ([textUsername.text length] < 4 || [textUsername.text length] > 32) {
        self.lableUsernameMsg.text = @"username min 4 and max 32 character allowed";
        
        return false;
    }
    if ([textPassword.text length] < 8 || [textPassword.text length] > 32) {
        self.label2.text = @"password min 8 and max 32 character allowed";
        self.label2.textColor = [UIColor redColor];
        return false;
    }
    
    NSString *password = [NSString stringWithFormat:@"%@", textPassword.text];
    NSString *verifyPassword =
    [NSString stringWithFormat:@"%@", textCPassword.text];
    
    if (![password isEqualToString:verifyPassword]) {
        [Helper showMessageFade:self.view withMessage:@"passwords must match" andWithHideAfterDelay:3];
        return false;
    }
    return true;
}

- (void)clearForm {
    textEmail.text = @"";
    textUsername.text = @"";
    textPassword.text = @"";
    textCPassword.text = @"";
    textInvitedBy.text = @"";
    self.lableUsernameMsg.text = @"";
    self.label2.text = @"";
    isTermsAccepted = false;
    [self.btn_checked setImage:[UIImage imageNamed:@"unchecked"]
                      forState:UIControlStateNormal];
}

- (IBAction)grabImage:(id)sender {
    UINavigationController *picker = [self.storyboard instantiateViewControllerWithIdentifier:@"MemreasGallery"];
    MemreasGallery *gallery = picker.viewControllers[0];
    gallery.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark
#pragma mark UIImagepicker Delegate method

- (void)imagePickerController:(MemreasGallery *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)editInfo {
    ALog(@"ImageDetail:- %@", editInfo);
    self.profileImageURL = [NSString
                            stringWithFormat:
                            @"%@",
                            [editInfo objectForKey:@"UIImagePickerControllerReferenceURL"]];
    imgData = nil;
    
    UIImage *img =
    [editInfo objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    if (!imgData) {
        imgData = UIImageJPEGRepresentation(img, 1);
    }
    self.uiProfileImage.image = img;
    // create a copy for upload
    
    // GetNSData
    NSURL *profileImageNSURL = [NSURL URLWithString:self.profileImageURL];
    self.s3file_name = [profileImageNSURL lastPathComponent];
    self.mediaCopyURL = [NSURL
                         fileURLWithPath:[NSTemporaryDirectory()
                                          stringByAppendingPathComponent:self.s3file_name]];
    [imgData writeToFile:self.mediaCopyURL.path atomically:YES];
    
    self.isProfileSelected = @"1";
    [picker dismissViewControllerAnimated:YES completion:nil];
    //
    // Fetch a media_id
    //
    [self fetchGenerateMediaIdMWS];
}

- (void)imagePickerControllerDidCancel:(MemreasGallery *)picker {
    if (imgData == nil)
        self.isProfileSelected = @"0";
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)btnLegalDisclaimerClicked:(id)sender {
    if (isTermsAccepted) {
        isTermsAccepted = false;
        [self.btn_checked setImage:[UIImage imageNamed:@"unchecked"]
                          forState:UIControlStateNormal];
    } else {
        isTermsAccepted = true;
        [self.btn_checked setImage:[UIImage imageNamed:@"checked"]
                          forState:UIControlStateNormal];
    }
}

#pragma mark Password Strength

- (IBAction)textPasswordStart:(id)sender {
    self.label2.text = @"";
    self.label2.hidden = NO;
}

- (IBAction)textPassword:(id)sender {
    NSString *passwordWeakCharacterOnly = self.textPassword.text;
    NSString *passwordWeakRegexCharacterOnly = @"^[a-zA-Z_-]{8,32}$";
    NSPredicate *testWeakpasswordCharacterOnly = [NSPredicate
                                                  predicateWithFormat:@"SELF MATCHES %@", passwordWeakRegexCharacterOnly];
    
    NSString *passwordWeakDigitOnly = self.textPassword.text;
    NSString *passwordWeakRegexDigitOnly = @"^[0-9_-]{8,32}$";
    NSPredicate *testWeakpasswordDigitOnly = [NSPredicate
                                              predicateWithFormat:@"SELF MATCHES %@", passwordWeakRegexDigitOnly];
    
    NSString *passwordMedium = self.textPassword.text;
    NSString *passwordMediumRegex = @"^[a-zA-Z0-9_-]{8,32}$";
    NSPredicate *testMediumpassword =
    [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordMediumRegex];
    
    NSString *passwordStrong = self.textPassword.text;
    NSString *passwordStrongRegex = @"^[a-zA-Z0-9._@#!$%&]{8,32}$";
    NSPredicate *testStrongpassword =
    [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordStrongRegex];
    
    if ([testWeakpasswordCharacterOnly
         evaluateWithObject:passwordWeakCharacterOnly] ||
        [testWeakpasswordDigitOnly evaluateWithObject:passwordWeakDigitOnly]) {
        self.label2.text = @"weak";
        self.label2.textColor = [UIColor redColor];
        
    } else if ([testMediumpassword evaluateWithObject:passwordMedium]) {
        self.label2.text = @"medium";
        self.label2.textColor = [UIColor greenColor];
        
    } else if ([testStrongpassword evaluateWithObject:passwordStrong]) {
        self.label2.text = @"strong";
        self.label2.textColor = [UIColor blueColor];
    }
}

- (IBAction)textPasswordEnd:(id)sender {
    NSString *password = textPassword.text;
    if (needToValidate) {
        if (needToValidate) {
            if (password.length < 6) {
                self.label2.text = @"password length : 8 min";
                self.label2.textColor = [UIColor redColor];
            } else if (password.length > 32) {
                self.label2.text = @"password length : 32 max";
                self.label2.textColor = [UIColor redColor];
            }
        }
    }
}

- (IBAction)verifyPassword:(id)sender {
    __weak NSString *password =
    [NSString stringWithFormat:@"%@", textPassword.text];
    __weak NSString *verifyPassword =
    [NSString stringWithFormat:@"%@", textCPassword.text];
    
    if (![password isEqualToString:verifyPassword]) {
        [Helper showMessageFade:self.view withMessage:@"passwords must match" andWithHideAfterDelay:3];
    }
}

#pragma mark Webservice UsernameVerification
- (IBAction)verifyUsername:(id)sender {
    if (needToValidate) {
        if (textUsername.text.length < 4) {
            self.lableUsernameMsg.text = @"username length : 4 min";
            self.lableUsernameMsg.textColor = [UIColor redColor];
        } else if (textUsername.text.length > 32) {
            self.lableUsernameMsg.text = @"username length : 32 max";
            self.lableUsernameMsg.textColor = [UIColor redColor];
        } else {
            self.lableUsernameMsg.text = @"";
            [self checkUserName];
        }
    }
}

- (IBAction)verifyEmailID:(id)sender {
    if ([self validateEmail:self.textEmail.text] ||
        self.textEmail.text.length == 0) {
        self.lblEmailCheck.text = @"";
    } else {
        self.lblEmailCheck.text = @"invalid email address";
    }
}
#pragma mark ValidateUserName

- (void)checkUserName {
    if ([Util checkInternetConnection]) {
        NSString *requestXML =
        [XMLGenerator generateCheckUserNameXML:textUsername.text];
        ALog(@"Request:- %@", requestXML);
        
        //
        // Use WebServices Request Generator
        //
        
        NSMutableURLRequest *request =
        [WebServices generateWebServiceRequest:requestXML action:CHECKUSERNAME];
        ALog(@"NSMutableRequest request ----> %@", request);
        
        /**
         * Send Request and Parse Response...
         *  Note: wsHandler calls objectParsed_ListAllMedia
         */
        MWebServiceHandler *wsHandler = [[MWebServiceHandler alloc] init];
        [wsHandler fetchServerResponse:request
                                action:CHECKUSERNAME
                                   key:CHECKUSERNAME_RESULT_NOTIFICATION];
    }
}

- (void)checkusernameMWSHandlerComplete:(NSNotification *)notification {
    NSDictionary *resultTags = [notification userInfo];
    ALog(@"checkusername response : %@", resultTags);
    
    if ([[[resultTags objectForKey:@"status"] lowercaseString]
         isEqualToString:@"failure"]) {
        [appDelegate runOnMainWithoutDeadlocking:^{
            self.lableUsernameMsg.text = [resultTags valueForKey:@"message"];
            self.lableUsernameMsg.textColor = [UIColor greenColor];
        }];
    } else {
        [appDelegate runOnMainWithoutDeadlocking:^{
            self.lableUsernameMsg.text = [resultTags valueForKey:@"message"];
            self.lableUsernameMsg.textColor = [UIColor redColor];
        }];
        textUsername.text = @"";
    }
    
    //    self.loadingView.hidden = YES;
}
- (IBAction)btnCancelClicked:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
    //    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark
#pragma mark Upload Image

- (IBAction)doSignup:(id)sender {
    @try {
        if ([Util checkInternetConnection]) {
            if ([self validateSignup]) {
                [self dismissInputControls];
                
                NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
                self.device_id = [pref objectForKey:@"device_id"];
                if (self.device_id == nil) {
                    self.device_id =
                    [[[UIDevice currentDevice] identifierForVendor] UUIDString];
                    [pref setObject:self.device_id forKey:@"device_id"];
                }
                
                if (self.device_id == nil)
                    self.device_id = @"";
                
                if ([Util checkInternetConnection]) {
                    NSString *requestXML =
                    [XMLGenerator generateRegistrationXML:textEmail.text
                                                 username:textUsername.text
                                                 password:textPassword.text
                                                device_id:self.device_id
                                              device_type:DEVICE_TYPE
                                            profile_photo:self.isProfileSelected
                                               invited_by:@""
                                                  secret:SecretRegistration];
                    ALog(@"Request:- %@", requestXML);
                    
                    //
                    // Use WebServices Request Generator
                    //
                    
                    NSMutableURLRequest *request =
                    [WebServices generateWebServiceRequest:requestXML
                                                    action:@"registration"];
                    ALog(@"NSMutableRequest request ----> %@", request);
                    
                    /**
                     * Send Request and Parse Response...
                     *  Note: wsHandler calls objectParsed_ListAllMedia
                     */
                    MWebServiceHandler *wsHandler = [[MWebServiceHandler alloc] init];
                    [wsHandler fetchServerResponse:request
                                            action:REGISTRATION
                                               key:REGISTRATION_RESULT_NOTIFICATION];
                }
                
                self.loadingView.hidden = NO;
            }
        }
    } @catch (NSException *exception) {
        ALog(@"object type = %@", [[GalleryManager class] debugDescription]);
        ALog(@"%@", exception);
    }
}

- (void)handleRegistrationMWS:(NSNotification *)notification {
    NSDictionary *resultTags = [notification userInfo];
    
    if ([[[resultTags objectForKey:@"status"] lowercaseString]
         isEqualToString:@"success"]) {
        NSUserDefaults *defaultUser = [NSUserDefaults standardUserDefaults];
        self.userId = [resultTags objectForKey:@"userid"];
        [defaultUser setObject:self.userId forKey:@"UserId"];
        
        [defaultUser setObject:[resultTags objectForKey:@"sid"] forKey:@"SID"];
        
        if (self.profileImageURL != nil) {
            //
            // On completion of fetch media_id -> uploadMedia
            // - media_id generated after profile pic selection
            //
            [self uploadMedia];
        } else {
            [appDelegate runOnMainWithoutDeadlocking:^{
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Success"
                                      message:@"please check your email and verify to login."
                                      delegate:nil
                                      cancelButtonTitle:@"Ok"
                                      otherButtonTitles:nil, nil];
                [alert show];
                
                [self.navigationController popToRootViewControllerAnimated:1];
                self.loadingView.hidden = YES;
            }];
        }
        //[self performSegueWithIdentifier:@"segueRegisterTabbar" sender:nil];
        
    } else {
        NSString *message = [resultTags objectForKey:@"message"];
        [Helper showMessageFade:self.view withMessage:message andWithHideAfterDelay:3];
    }
}

//
// fetch media_id for profile pic
//
- (void)fetchGenerateMediaIdMWS {
    @try {
        NSUserDefaults* defaultUser = [NSUserDefaults standardUserDefaults];
        NSString* sid = [defaultUser stringForKey:@"SID"];
        
        if ([Util checkInternetConnection]) {
            /**
             * Use XMLGenerator...
             */
            
            NSString* requestXML = [XMLGenerator generateMediaIdXML:sid];
            ALog(@"Request:- %@", requestXML);
            
            /**
             * Use WebServices Request Generator
             */
            
            NSMutableURLRequest* request =
            [WebServices generateWebServiceRequest:requestXML
                                            action:@"generatemediaid"];
            //ALog(@"NSMutableRequest request ----> %@", request);
            
            /**
             * Send Request and Parse Response...
             *  Note: wsHandler calls objectParsed_ListAllMedia
             */
            MWebServiceHandler* wsHandler = [[MWebServiceHandler alloc] init];
            [wsHandler fetchServerResponse:request
                                    action:@"generatemediaid"
                                       key:@"REGISTRATION"];
        }
    } @catch (NSException* exception) {
        ALog(@"object type = %@", [[GalleryManager class] debugDescription]);
        ALog(@"%@", exception);
    }
}

/**
 * Web Service Response via notification here...
 */
- (void)handleGenerateMediaIdMWS:(NSNotification*)notification {
    @try {
        NSDictionary* resultTags = [notification userInfo];
        // NSString* action = [resultTags objectForKey:@"action"];
        //
        // Handle result here...
        //
        NSString* status = @"";
        status = [resultTags objectForKey:@"status"];
        self.mediaId = [resultTags objectForKey:@"media_id"];
        
        ALog(@"%@ mediaId:: %@", @"REGISTRATION", self.mediaId);
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}


//
// Transfer upload start
//
- (void)uploadMedia {
    //
    // Get fileName and mimeType from profileImageURL
    //
    NSURL *profileImageNSURL = [NSURL URLWithString:self.profileImageURL];
    self.s3file_name = [profileImageNSURL lastPathComponent];
    NSString *fileExtension = [profileImageNSURL pathExtension];
    NSString *UTI =
    (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(
                                                                        kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension,
                                                                        NULL);
    self.content_type =
    (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(
                                                                  (__bridge CFStringRef)UTI, kUTTagClassMIMEType);
    ALog(@"starting uploadMedia for filename:%@", self.s3file_name);
    ALog(@"content_type:%@", self.content_type);
    
    //
    // Fetch signed URL
    //
    [AWSManager sharedInstance];
    AWSS3GetPreSignedURLRequest *getPreSignedURLRequest =
    [AWSS3GetPreSignedURLRequest new];
    getPreSignedURLRequest.bucket = [MyConstant getBUCKET_NAME];
    NSString *s3Key =
    [NSString stringWithFormat:@"%@/%@/%@", self.userId, self.mediaId, self.s3file_name];
    getPreSignedURLRequest.key = s3Key;
    getPreSignedURLRequest.HTTPMethod = AWSHTTPMethodPUT;
    getPreSignedURLRequest.expires = [NSDate dateWithTimeIntervalSinceNow:3600];
    
    // Important: must set contentType for PUT request
    ALog(@"headers: %@", getPreSignedURLRequest);
    getPreSignedURLRequest.contentType = self.content_type;
    
    if ([[NSFileManager defaultManager]
         fileExistsAtPath:self.mediaCopyURL.path]) {
        //
        // Show uploading... msg
        //
        [appDelegate runOnMainWithoutDeadlocking:^{
            self.loadingView.hidden = NO;
            [lblProgress setText:@"uploading..."];
        }];
        
        //
        // Upload the file
        //
        [[[AWSS3PreSignedURLBuilder defaultS3PreSignedURLBuilder]
          getPreSignedURL:getPreSignedURLRequest]
         continueWithBlock:^id(AWSTask *task) {
             if (task.error) {
                 ALog(@"Error: %@", task.error);
             } else {
                 NSURL *presignedURL = task.result;
                 // ALog(@"upload presignedURL is: \n%@", presignedURL);
                 
                 NSMutableURLRequest *request =
                 [NSMutableURLRequest requestWithURL:presignedURL];
                 request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
                 [request setHTTPMethod:@"PUT"];
                 [request setValue:self.content_type
                forHTTPHeaderField:@"Content-Type"];
                 [request setValue:@"AES256"
                forHTTPHeaderField:@"x-amz-server-side-encryption"];
                 
                 NSDictionary *headers = [request allHTTPHeaderFields];
                 ALog(@"headers: %@", headers);
                 @try {
                     self.uploadProfileImageTask = [[NSURLSession sharedSession]
                                                    uploadTaskWithRequest:request
                                                    fromFile:self.mediaCopyURL
                                                    completionHandler:^(NSData *data, NSURLResponse *response,
                                                                        NSError *error) {
                                                        if (!error) {
                                                            ALog(@"upload completed for filename:%@",
                                                                  self.s3file_name);
                                                            //
                                                            // Call web service to store entry in db
                                                            //
                                                            [self addMediaEventMWS];
                                                        } else {
                                                            NSDictionary *userInfo = [error userInfo];
                                                            ALog(@"(void)URLSession:session "
                                                                  @"task:(NSURLSessionTask*)task "
                                                                  @"didCompleteWithError:error called...%@\n "
                                                                  @"userInfo: " @"%@",
                                                                  error, userInfo);
                                                        }
                                                        
                                                    }];
                     [self.uploadProfileImageTask resume];
                 } @catch (NSException *exception) {
                     ALog(@"exception creating upload task: %@", exception);
                 }
             }
             return nil;
         }];
    } // end if copy file exists
}

//
// Web Service to finalize upload
//
- (void)addMediaEventMWS {
    @try {
        NSUserDefaults *defaultUser = [NSUserDefaults standardUserDefaults];
        self.userId = [defaultUser stringForKey:@"UserId"];
        NSString *sid = [defaultUser stringForKey:@"SID"];
        NSString *device_id = [defaultUser stringForKey:@"device_id"];
        
        if ([Util checkInternetConnection]) {
            // Update text to show finalizing...
            [appDelegate runOnMainWithoutDeadlocking:^{
                [lblProgress setText:@"finalizing..."];
            }];
            
            /**
             * Use XMLGenerator...
             */
            NSString* s3Url = [NSString stringWithFormat:@"%@/%@/%@", self.userId, self.mediaId, self.s3file_name];
            NSString *requestXML =
            [XMLGenerator generateAddMediaEventXML:sid
                                        withUserId:self.userId
                                   andWithDeviceId:device_id
                                 andWithDeviceTYPE:DEVICE_TYPE
                                    andWithEventId:@""
                                    andWithMediaId:self.mediaId
                                      andWithS3Url:s3Url
                                andWithContentType:self.content_type
                                 andWithS3FileName:self.s3file_name
                              andWithIsServerImage:NO
                               andWithIsProfilePic:self.isProfileSelected
                                   andWithLocation:@""
                                  andWithCopyRight:@"" isRegistration:YES];
            
            ALog(@"Request:- %@", requestXML);
            
            /**
             * Use WebServices Request Generator
             */
            
            NSMutableURLRequest *request =
            [WebServices generateWebServiceRequest:requestXML
                                            action:ADDMEDIAEVENT];
            ALog(@"NSMutableRequest request ----> %@", request);
            
            /**
             * Send Request and Parse Response...
             *  Note: wsHandler notifies handleAddMediaEventMWS
             */
            MWebServiceHandler *wsHandler = [[MWebServiceHandler alloc] init];
            [wsHandler
             fetchServerResponse:request
             action:ADDMEDIAEVENT
             key:ADDMEDIAEVENT_REGISTRATION_RESULT_NOTIFICATION];
        }
    } @catch (NSException *exception) {
        ALog(@"%@", exception);
    }
}

/**
 * Web Service Response via notification here...
 */
- (void)handleAddMediaEventMWS:(NSNotification *)notification {
    @try {
        //
        // Hide loading view
        //
        self.loadingView.hidden = NO;
        
        NSDictionary *resultTags = [notification userInfo];
        ALog(@"result tags: %@", resultTags);
        //
        // Handle result here...
        //
        NSString *status = @"";
        status = [resultTags objectForKey:@"status"];
        
        if ([[status lowercaseString] isEqualToString:@"success"]) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Success"
                                  message:@"please check your email and verify to login"
                                  delegate:nil
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil, nil];
            [alert show];
            
            [self.navigationController popToRootViewControllerAnimated:1];
        } else {
            [Helper showMessageFade:self.view withMessage:@"an error occurred" andWithHideAfterDelay:3];
        }
        
    } @catch (NSException *exception) {
        ALog(@"%@", exception);
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


@end

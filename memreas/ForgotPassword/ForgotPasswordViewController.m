#import "ForgotPasswordViewController.h"
#import "WebServiceParser.h"
#import "WebServices.h"
#import "XMLGenerator.h"
#import "Util.h"

#import "MBProgressHUD.h"

@interface ForgotPasswordViewController ()
{
    MBProgressHUD *progressView;
    
    WebServiceParser *wspLogin;
    WebServiceParser *wspChnagePassword;
}

@property (nonatomic, assign) IBOutlet UIScrollView *svMain;

@property (nonatomic, assign) IBOutlet UITextField * txtEmail;

@property (nonatomic, assign) IBOutlet UITextField * txtNewPassword;
@property (nonatomic, assign) IBOutlet UITextField * txtVerifyPassword;
@property (nonatomic, assign) IBOutlet UITextField * txtCode;
@property (strong, nonatomic) IBOutlet UIImageView *img;

@property (nonatomic, assign) IBOutlet UILabel *lblPassword;
@property (nonatomic, assign) IBOutlet UILabel *lblVerify;

- (IBAction)btnBack:(id)sender;

- (IBAction)btnGetCode:(id)sender;
- (IBAction)btnSubmitNewPassword:(id)sender;

@end

@implementation ForgotPasswordViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    ALog(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    
    self.lblPassword.hidden = YES;
    self.lblVerify.hidden = YES;
    
    
    
    if (IS_IPAD) {
        [self.img  setImage:[UIImage imageNamed:@"forgot password"]];
    }else{
        [self.img  setImage:[UIImage imageNamed:@"forgot_pass"]];
    }
    
    self.svMain.contentSize = CGSizeMake(self.svMain.frame.size.width, self.svMain.frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)btnBack:(id)sender
{
    //    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

////////  Forgot Password
//-(void)getForgotPassword:(NSString*)sm_msg;
//{
//    NSString *postLength = [NSString stringWithFormat:@"%d", [sm_msg length]];
//    //    ALog(@"postLength:: %@",postLength);
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://memreasint.elasticbeanstalk.com/app/?action=forgetpassword&sid=%@",SID]]];
//    [request setHTTPMethod:@"POST"];
//    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    [request setHTTPBody:[sm_msg dataUsingEncoding:NSUTF8StringEncoding]];
//    //    ALog(@"Request for Update Location::: %@",request);
//
//    NSURLResponse *response;
//    NSData *POSTReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
//    NSString *theReply = [[NSString alloc] initWithBytes:[POSTReply bytes] length:[POSTReply length] encoding: NSASCIIStringEncoding];
//    //return request;
//    //	ALog(@"theReply %@ %d", theReply, POSTReply.length);
//}
//
- (IBAction)btnGetCode:(id)sender
{
    if(![self validateEmail:self.txtEmail.text])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"please enter a valid email address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    
    if([Util checkInternetConnection])
    {
        /**
         * Use XMLGenerator...
         */
        NSString *requestXML = [XMLGenerator generateForgotPasswordXML:self.txtEmail.text];
        ALog(@"Request:- %@",requestXML);
        
        /**
         * Use WebServices Request Generator
         */
        
        NSMutableURLRequest *request = [WebServices generateWebServiceRequest:requestXML action:@"forgotpassword"];
        ALog(@"NSMutableRequest request ----> %@", request);
        
        /**
         * Send Request and Parse Response...
         */
        WebServiceParser *wsParserGetUserDetails = [[WebServiceParser alloc] init];
        wsParserGetUserDetails = [[WebServiceParser alloc] initWithRequest:request arrayRootObjectTags:[NSArray arrayWithObjects:@"xml",@"forgotpasswordresponse", nil] sel:@selector(objectParesedForForgotPassword:) andHandler:self];
    }
    
    
    
    //    NSString *request = @"<xml>";
    //    request = [request stringByAppendingFormat:@"<forgotpassword><email>%@</email></forgotpassword>", self.txtEmail.text];
    //    request = [request stringByAppendingString:@"</xml>"];
    //    ALog(@"Request:- %@",request);
    //
    //    if([Util checkInternetConnection])
    //    {
    //        if(wspLogin){
    //            wspLogin = nil;
    //        }
    //
    //        if(!wspLogin)
    //        {
    //            [self performSelectorInBackground:@selector(startActivity) withObject:nil];
    //
    //            wspLogin.isFriendList = NO;
    //            wspLogin = [[WebServiceParser alloc] initWithRequest:[WebServices getURqWebservicesMessage:[WebServices getSM_WebservicesParameters:request] action:@"forgotpassword"] arrayRootObjectTags:[NSArray arrayWithObjects:@"xml",@"forgotpasswordresponse", nil] sel:@selector(objectParesedForForgotPassword:) andHandler:self];
    //        }
    //    }
}

- (BOOL) validateEmail: (NSString *) candidate
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    //    ALog(@"Validate email :- %d ", [emailTest evaluateWithObject:candidate]);
    return [emailTest evaluateWithObject:candidate];
}

-(void)objectParesedForForgotPassword:(NSDictionary *)dictionary
{
    [self stopActivity];
    wspLogin = nil;
    //    NSArray *response1 = [[NSArray alloc] initWithArray:[dictionary objectForKey:@"objects"]];
    //    ALog(@"Forgot Password response : %@",dictionary);
    
    UIAlertView *successMessage = [[UIAlertView alloc] initWithTitle:nil message:@"We have generate an activation code and emailed it. Use the code here to change your password." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [successMessage show];
    
    //            [successMessage show];
    
    //    if([response1 count] > 0 & response1 != nil)
    //    {
    //        NSString *status = [NSString stringWithFormat:@"%@",[[response1 objectAtIndex:0] valueForKey:@"status"]];
    //        NSString *message = [NSString stringWithFormat:@"%@",[[response1 objectAtIndex:0] valueForKey:@"message"]];
    //
    //        if([status isEqualToString:@"success"])
    //        {
    //            UIAlertView *successMessage = [[UIAlertView alloc] initWithTitle:@"Success" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    //            [successMessage show];
    //        }
    //        else
    //        {
    //            UIAlertView *failureMessage = [[UIAlertView alloc] initWithTitle:@"Fail" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    //            [failureMessage show];
    //        }
    //    }
    //    else
    //    {
    //        UIAlertView *failureMessage = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Failer" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    //        [failureMessage show];
    //    }
}

- (IBAction)btnSubmitNewPassword:(id)sender
{
    NSString *password = self.txtNewPassword.text;
    NSString *verify = self.txtVerifyPassword.text;
    NSString *code = self.txtCode.text;
    
    if(password.length < 6 || password.length > 32)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"please enter a valid password." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    else if(![password isEqualToString:verify])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"password does not match." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    else if(code.length == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Your code does not match our records. Please check and re-enter your code." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    //ADDTOXMLGENERATOR
    
    
    if([Util checkInternetConnection])
    {
        /**
         * Use XMLGenerator...
         */
        NSString *requestXML = [XMLGenerator generateChangePasswordXML:password verify:verify code:code];
        ALog(@"Request:- %@",requestXML);
        
        /**
         * Use WebServices Request Generator
         */
        
        NSMutableURLRequest *request = [WebServices generateWebServiceRequest:requestXML action:@"changepassword"];
        ALog(@"NSMutableRequest request ----> %@", request);
        
        /**
         * Send Request and Parse Response...
         */
        WebServiceParser *wsParserGetUserDetails = [[WebServiceParser alloc] init];
        wsParserGetUserDetails = [[WebServiceParser alloc] initWithRequest:request arrayRootObjectTags:[NSArray arrayWithObjects:@"xml",@"changepasswordresponse", nil] sel:@selector(objectParesedForChangePassword:) andHandler:self];
        
    }
    
    //    NSString *request = @"<xml>";
    //    request = [request stringByAppendingFormat:@"<changepassword><username></username><password></password><new>%@</new><retype>%@</retype><token>%@</token></changepassword>", password, verify, code];
    //    request = [request stringByAppendingString:@"</xml>"];
    //    ALog(@"Request:- %@",request);
    //
    //    if([Util checkInternetConnection])
    //    {
    //        if(wspChnagePassword){
    //            wspChnagePassword = nil;
    //        }
    //
    //        if(!wspChnagePassword)
    //        {
    //            [self performSelectorInBackground:@selector(startActivity) withObject:nil];
    //
    //            wspChnagePassword.isFriendList = NO;
    //            wspChnagePassword = [[WebServiceParser alloc] initWithRequest:[WebServices getURqWebservicesMessage:[WebServices getSM_WebservicesParameters:request] action:@"changepassword"] arrayRootObjectTags:[NSArray arrayWithObjects:@"xml",@"changepassword", nil] sel:@selector(objectParesedForChangePassword:) andHandler:self];
    //        }
    //    }
}

-(void)objectParesedForChangePassword:(NSDictionary *)dictionary
{
    [self stopActivity];
    
    wspChnagePassword = nil;
    NSArray *response1 = [[NSArray alloc] initWithArray:[dictionary objectForKey:@"objects"]];
    ALog(@"Change Password response : %@",dictionary);
    
    if([response1 count] > 0 & response1 != nil)
    {
        NSString *status = [NSString stringWithFormat:@"%@",[[response1 objectAtIndex:0] valueForKey:@"status"]];
        NSString *message = [NSString stringWithFormat:@"%@",[[response1 objectAtIndex:0] valueForKey:@"message"]];
        
        if([status isEqualToString:@"success"])
        {
            UIAlertView *successMessage = [[UIAlertView alloc] initWithTitle:@"Success" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [successMessage show];
        }
        else
        {
            UIAlertView *failureMessage = [[UIAlertView alloc] initWithTitle:@"Fail" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [failureMessage show];
        }
    }
    else
    {
        UIAlertView *failureMessage = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"failed to change password - please try again later" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [failureMessage show];
    }
}

- (void) checkPassword
{
    NSString *passwordWeakCharacterOnly=self.txtNewPassword.text;
    NSString *passwordWeakRegexCharacterOnly=@"^[a-zA-Z_-]{6,32}$";
    NSPredicate *testWeakpasswordCharacterOnly=[NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordWeakRegexCharacterOnly];
    
    NSString *passwordWeakDigitOnly=self.txtNewPassword.text;
    NSString *passwordWeakRegexDigitOnly=@"^[0-9_-]{6,32}$";
    NSPredicate *testWeakpasswordDigitOnly=[NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordWeakRegexDigitOnly];
    
    NSString *passwordMedium=self.txtNewPassword.text;
    NSString *passwordMediumRegex=@"^[a-zA-Z0-9_-]{6,32}$";
    NSPredicate *testMediumpassword=[NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordMediumRegex];
    
    NSString *passwordStrong=self.txtNewPassword.text;
    NSString *passwordStrongRegex=@"^[a-zA-Z0-9._@#!$%&]{6,32}$";
    NSPredicate *testStrongpassword=[NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordStrongRegex];
    
    if([testWeakpasswordCharacterOnly evaluateWithObject:passwordWeakCharacterOnly] || [testWeakpasswordDigitOnly evaluateWithObject:passwordWeakDigitOnly])
    {
        self.lblPassword.text=@"Weak";
        self.lblPassword.textColor=[UIColor redColor];
        
    }
    else if ([testMediumpassword evaluateWithObject:passwordMedium]) {
        
        self.lblPassword.text=@"Medium";
        self.lblPassword.textColor=[UIColor greenColor];
        
    }
    else if ([testStrongpassword evaluateWithObject:passwordStrong]) {
        self.lblPassword.text=@"Strong";
        self.lblPassword.textColor=[UIColor blueColor];
    }
}

- (void) startActivity
{
    [self startActivity:@""];
}

- (void) startActivity:(NSString *)message
{
    progressView = [[MBProgressHUD alloc] initWithView:self.view];
    
    [self.view addSubview:progressView];
    progressView.detailsLabelText = message;
    
    [progressView show:YES];
}

-(void)stopActivity
{
    [progressView removeFromSuperview];
    [progressView hide:YES];
    progressView = nil;
}

#pragma mark UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    self.svMain.frame = CGRectMake(self.svMain.frame.origin.x, self.svMain.frame.origin.y, self.svMain.frame.size.width, self.view.frame.size.height - 44);
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.svMain.frame = CGRectMake(self.svMain.frame.origin.x, self.svMain.frame.origin.y, self.svMain.frame.size.width, self.view.frame.size.height - 44 - 216);
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField == self.txtNewPassword)
    {
        self.lblPassword.hidden = NO;
        
        NSString *newpassword = self.txtNewPassword.text;
        
        if(newpassword.length < 6 || newpassword.length > 32)
        {
            self.lblPassword.text = @"6 and 32 characters";
            self.lblPassword.textColor = [UIColor redColor];
        }
        else
        {
            [self checkPassword];
        }
    }
    else if(textField == self.txtVerifyPassword)
    {
        NSString *password = self.txtNewPassword.text;
        NSString *verify = self.txtVerifyPassword.text;
        
        self.lblVerify.hidden = [password isEqualToString:verify];
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

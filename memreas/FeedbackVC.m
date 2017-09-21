#import "FeedbackVC.h"
#import "XMLParser.h"
#import "MBProgressHUD.h"
#import "MyConstant.h"

@interface FeedbackVC ()
{
    
    MBProgressHUD *progressView;
    
}

@property (weak, nonatomic) IBOutlet UITextField *txtusername;
@property (weak, nonatomic) IBOutlet UITextField *txtemail;
@property (weak, nonatomic) IBOutlet UITextView *txtmessage;

@end

@implementation FeedbackVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //    NSDictionary*dic =[[NSUserDefaults standardUserDefaults]valueForKey:@"userDetail"];
    //    self.txtemail.text = [dic valueForKeyPath:@"email.text"];
    //    self.txtusername.text = [dic valueForKeyPath:@"username.text"];
    
    if (!IS_IPAD) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"Iphone-feedback"] forBarMetrics:UIBarMetricsDefault];
    }else{
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"feedback"] forBarMetrics:UIBarMetricsDefault];
    }
    
    self.txtmessage.layer.cornerRadius = 10;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backTap:(id)sender {
    
    [self.navigationController popViewControllerAnimated:1];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    //    [self.txtmessage becomeFirstResponder];
}

- (IBAction)oktapped:(id)sender {
    
    
    
    if (![self.txtusername.text length]) {
        
        UIAlertController *cont = [UIAlertController alertControllerWithTitle:@"Please enter name." message:nil preferredStyle:UIAlertControllerStyleAlert];
        [cont addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:cont animated:YES completion:nil];
        return;
    }
    
    if (![self validateEmail:self.txtemail.text] ) {
        
        UIAlertController *cont = [UIAlertController alertControllerWithTitle:@"Please enter valid email id." message:nil preferredStyle:UIAlertControllerStyleAlert];
        [cont addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:cont animated:YES completion:nil];
        
        return;
        
    }
    
    
    
    
    if (![self.txtmessage.text length]) {
        UIAlertController *cont = [UIAlertController alertControllerWithTitle:@"Please enter message." message:nil preferredStyle:UIAlertControllerStyleAlert];
        [cont addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:cont animated:YES completion:nil];
        return;
        
    }else{
        
        [self.view endEditing:1];
        [self startActivity:@"sending feedback..."];
        //ADDTOXMLGENERATOR
        NSMutableString *xml = [[NSMutableString alloc] init];
        NSString *urlString = [NSString stringWithFormat:@"%@?action=feedback&sid=%@",[MyConstant getWEB_SERVICE_URL],SID];
        
        [xml appendFormat:@"xml=<xml><feedback>"];
        [xml appendFormat:@"<user_id>%@</user_id>",[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"]];
        [xml appendFormat:@"<email>%@</email>",self.txtemail.text];
        [xml appendFormat:@"<name>%@</name>",self.txtemail.text];
        [xml appendFormat:@"<message>%@</message>",self.txtemail.text];
        [xml appendFormat:@"</feedback></xml>"];
        
        XMLParser* parser = [[XMLParser alloc] init];
        [parser parseWithURL:urlString typeParse:1 soapMessage:xml startTag:@"event" completedSelector:@selector(objectParsed_feedback:) handler:self];
        return;
        
    }
    
}


-(void)objectParsed_feedback:(NSMutableDictionary *)dictionary{
    
    ALog(@"%@",dictionary);
    [self stopActivity];
    [self canceltapped:nil];
    
    UIAlertView *alert  =[[UIAlertView alloc]initWithTitle:nil message:@"Feedback send successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    
}


- (BOOL) validateEmail: (NSString *) candidate
{
    
    
    @try {
        
        BOOL final=0;
        
        for ( NSString *str in [candidate componentsSeparatedByString:@","]  ) {
            
            NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
            NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
            //    ALog(@"Validate email :- %d ", [emailTest evaluateWithObject:candidate]);
            final = [emailTest evaluateWithObject:str];
            
            if (! final) {
                break;
            }
            
        }
        
        return final;
        
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
    
}


- (void) startActivity:(NSString *)message
{
    progressView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:progressView];
    if (message) {
        progressView.detailsLabelText = message;
    }
    [progressView show:YES];
}

-(void)stopActivity
{
    [progressView removeFromSuperview];
    [progressView hide:YES];
    progressView = nil;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    // For any other character return TRUE so that the text gets added to the view
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
    
}


- (IBAction)canceltapped:(id)sender {
    
    [self.navigationController popViewControllerAnimated:1];
}

@end

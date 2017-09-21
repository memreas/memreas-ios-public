#import "AddMemreasShareViewController.h"

#define METERS_PER_MILE 10000
#define METERS_PER_MILE_DETAIL 15000

@implementation AddMemreasShareViewController{
    //
    // local vars here
    //
    GalleryManager* sharedGalleryInstance;
    MBProgressHUD* progressView;
    UITextField * tempTxt;
    UITextField * activeField;
    GMSPlacesClient* gmsPlacesClient;
    ShareCreator* shareCreatorInstance;
}

//
// Methods
//
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //
    // Google Banner View
    //
    self.bannerView.adUnitID = [[MIOSDeviceDetails sharedInstance] getAdUnitId];
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
    
    //
    // Set Page Title
    //
    if (IS_IPAD) {
        [self.navigationController.navigationBar
         setBackgroundImage:[UIImage imageNamed:@"memreas"]
         forBarMetrics:UIBarMetricsDefault];
    } else {
        [self.navigationController.navigationBar
         setBackgroundImage:[UIImage imageNamed:@"nav_Memreas"]
         forBarMetrics:UIBarMetricsDefault];
    }
    
    
    //
    // Gallery Manager (singleton)
    //
    sharedGalleryInstance = [GalleryManager sharedGalleryInstance];
    
    //
    // Set current controller
    //
    //appDelegate.currentView = @"AddMemreasShareViewController";
    
    //
    // Fetch ShareCreator
    //
    shareCreatorInstance = [ShareCreator sharedInstance];
    
    //
    // Date picker settings
    //
    self.viewDatepicker.hidden = YES;
    
    NSDate *now = [NSDate date];
    self.pckrDate.date = now;
    [self.pckrDate addTarget:self action:@selector(fetchDateValue) forControlEvents:UIControlEventValueChanged];
    
    //
    // Add notifications
    //
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAddEvent:)
                                                 name:ADDEVENT_SHARE_RESULT_NOTIFICATION
                                               object:nil];
    
    
    //
    // set first responder for date fields
    //
    [self.txtLocation resignFirstResponder];
    [self.txtDate resignFirstResponder];
    [self.txtFrom resignFirstResponder];
    [self.txtGhost resignFirstResponder];
    
    //
    // Set methods for date img
    //
    UITapGestureRecognizer *tapImgDate = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDateField:)];
    [self.imgDate setUserInteractionEnabled:YES];
    [self.imgDate addGestureRecognizer:tapImgDate];
    //[self.txtDate setUserInteractionEnabled:YES];
    //[self.txtDate addGestureRecognizer:tapImgDate];
    
    UITapGestureRecognizer *tapImgFromDate = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFromDateField:)];
    [self.imgFromDate setUserInteractionEnabled:YES];
    [self.imgFromDate addGestureRecognizer:tapImgFromDate];
    
    UITapGestureRecognizer *tapImgToDate = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleToDateField:)];
    [self.imgToDate setUserInteractionEnabled:YES];
    [self.imgToDate addGestureRecognizer:tapImgToDate];
    
    UITapGestureRecognizer *tapImgGhostDate = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGhostDateField:)];
    [self.imgGhostDate setUserInteractionEnabled:YES];
    [self.imgGhostDate addGestureRecognizer:tapImgGhostDate];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self becomeFirstResponder];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [self setCheckBox:self.btnFriendsCanAdd withValue:YES];
    [self setCheckBox:self.btnFriendsCanPost withValue:YES];
    [self setCheckBox:self.btnPublic withValue:NO];
    
    if ([shareCreatorInstance.name  isEqual: @""]) {
        [self clearall];
    }
    
}

- (void) setCheckBox:(UIButton*)btnCheckBox withValue:(BOOL)turnOn {
    //
    // Set check box image
    //
    if (turnOn) {
        [btnCheckBox setImage:[UIImage imageNamed:@"checked_white"] forState:UIControlStateNormal];
    } else {
        [btnCheckBox setImage:[UIImage imageNamed:@"unchecked_white"] forState:UIControlStateNormal];
    }
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark
#pragma mark Keyboard handlers
// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.detailsScrollView.contentInset = contentInsets;
    self.detailsScrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        [self.detailsScrollView scrollRectToVisible:activeField.frame animated:YES];
    }
}
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.detailsScrollView.contentInset = contentInsets;
    self.detailsScrollView.scrollIndicatorInsets = contentInsets;
}



#pragma mark
#pragma mark UITextfield Delegate methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == self.txtName) {
        return YES;
    }
    return NO;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    shareCreatorInstance.name = textField.text;
    return YES;
}


// This method is called once we click inside the textField
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
}


#pragma mark
#pragma mark methods for checkbox, date, and location fields

- (IBAction)btnCheckboxClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSString* btnLabel = btn.accessibilityIdentifier;
    bool checkBoxOn = NO;
    bool handlePublic = NO;
    bool handleViewable = NO;
    bool handleGhost = NO;
    
    
    //
    // Switch the button
    //
    checkBoxOn = [self checkBoxSwitch:btn];
    
    
    //
    // switch for checkbox
    //
    if ([btnLabel isEqualToString:@"fcp_checkbox"]) {
        self.btnFriendsCanPost = btn;
    } else if ([btnLabel isEqualToString:@"faf_checkbox"]) {
        self.btnFriendsCanAdd = btn;
    } else if ([btnLabel isEqualToString:@"public_checkbox"]) {
        self.btnPublic = btn;
        handlePublic = YES;
    } else if ([btnLabel isEqualToString:@"viewable_checkbox"]) {
        self.btnViewable = btn;
        handleViewable = YES;
    } else if ([btnLabel isEqualToString:@"ghost_checkbox"]) {
        self.btnGhost = btn;
        handleGhost = YES;
    }
    
    //
    // Handle Public ON
    //
    if (handlePublic) {
        if (self.btnPublic.selected) {
            self.btnFriendsCanAdd.selected = NO;
            self.btnFriendsCanPost.selected = NO;
            [self checkBoxSwitch:self.btnFriendsCanPost];
            [self checkBoxSwitch:self.btnFriendsCanAdd];
            self.btnFriendsCanAdd.enabled = NO;
            self.btnFriendsCanPost.enabled = NO;
        } else {
            self.btnFriendsCanAdd.enabled = YES;
            self.btnFriendsCanPost.enabled = YES;
        }
    }
    
    //
    // Handle Ghost On
    //
    if (handleGhost) {
        if (self.btnGhost.selected) {
            //switch off viewable
            self.btnViewable.selected = YES;
            [self checkBoxSwitch:self.btnViewable];
            
            //disable viewable fields
            self.txtTo.text = @"";
            self.txtFrom.text = @"";
            self.txtTo.enabled = NO;
            self.txtFrom.enabled = NO;
            self.btnViewable.enabled = NO;
            self.imgFromDate.userInteractionEnabled = NO;
            self.imgToDate.userInteractionEnabled = NO;
            
        } else {
            //reset viewable fields
            self.txtGhost.text = @"";
            self.btnViewable.enabled = YES;
            self.txtTo.enabled = YES;
            self.txtFrom.enabled = YES;
            self.imgFromDate.userInteractionEnabled = YES;
            self.imgToDate.userInteractionEnabled = YES;

        }
    }
    
    
    //
    // Handle Viewable On
    //
    if (handleViewable) {
        if (self.btnViewable.selected) {
            self.btnGhost.selected = YES;
            [self checkBoxSwitch:self.btnGhost];
            self.txtGhost.text = @"";
            self.btnGhost.enabled = NO;
            self.txtGhost.enabled = NO;
            self.imgGhostDate.userInteractionEnabled = NO;
        } else {
            self.txtTo.text = @"";
            self.txtFrom.text = @"";
            self.btnGhost.enabled = YES;
            self.txtGhost.enabled = YES;
            self.imgGhostDate.userInteractionEnabled = YES;
        }
    }
}

-(bool) checkBoxSwitch:(UIButton*) btn {
    UIImage *img;
    bool checkBoxOn = NO;
    if (btn.selected) {
        img = [UIImage imageNamed:@"unchecked_white"];
        btn.selected = NO;
        checkBoxOn = NO;
    } else{
        img = [UIImage imageNamed:@"checked_white"];
        btn.selected = YES;
        checkBoxOn = YES;
    }
    [btn setImage:img forState:UIControlStateNormal];
    img = nil;
    
    return checkBoxOn;
    
}

//
// disable next, done, cancel while date picker is open
//
- (void) controlNavButtonsForDatePicker {
    if (!self.viewDatepicker.hidden) {
        self.btnNext.enabled = NO;
        self.btnDone.enabled = NO;
        self.btnCancel.enabled = NO;
    } else {
        self.btnNext.enabled = YES;
        self.btnDone.enabled = YES;
        self.btnCancel.enabled = YES;
    }
}


-(IBAction) handleDateField:(id) sender{
    //User touched field so open Date Picker
    [self controlNavButtonsForDatePicker];
    self.viewDatepicker.hidden = NO;
    activeField = self.txtDate;
}
-(IBAction) handleFromDateField:(id) sender{
    //User touched field so open Date Picker
    [self controlNavButtonsForDatePicker];
    self.viewDatepicker.hidden = NO;
    activeField = self.txtFrom;
}
-(IBAction) handleToDateField:(id) sender{
    //User touched field so open Date Picker
    [self controlNavButtonsForDatePicker];
    self.viewDatepicker.hidden = NO;
    activeField = self.txtTo;
}
-(IBAction) handleGhostDateField:(id) sender{
    //User touched field so open Date Picker
    [self controlNavButtonsForDatePicker];
    self.viewDatepicker.hidden = NO;
    activeField = self.txtGhost;
}

-(IBAction) handleLocationField:(id) sender{
    //launch location
    activeField = self.txtLocation;
    
    [self performSegueWithIdentifier:@"segueShareLocationViewController"
                              sender:self];
}

- (void) okPassBackAddress:(NSString*) address withLocation:(CLLocation*) location {
    //
    // ShareLocationViewControllerDelegate implementation
    //
    NSDictionary* addressDict = [[NSDictionary alloc] initWithObjectsAndKeys:address,@"address",location,@"location", nil];
    self.addressDict = addressDict;
    self.txtLocation.text = address;
}



#pragma mark
#pragma mark Custom methods

-(NSString *)convertBoolToString:(BOOL)convert{
    if(convert)
        return @"YES";
    else
        return @"NO";
}

-(int)convertBoolToInt:(BOOL)convert{
    if(convert)
        return 1;
    else
        return 0;
}



#pragma mark
#pragma mark Picker  methods

-(void) fetchDateValue
{
    NSDate *now = [NSDate date];
    if(activeField == self.txtTo) {
        if (!self.btnViewable.selected) {
            [self btnCheckboxClicked:self.btnViewable];
        }
        self.pckrDate.minimumDate = now;
        
        NSDate *from = [self getDateFromString:self.txtFrom.text];
        NSDate *to = self.pckrDate.date;
        
        if([from compare:to] == NSOrderedDescending)
        {
            [Helper showMessageFade:self.view withMessage:@"please check from/to dates" andWithHideAfterDelay:3];
            activeField.text = [self getDateStringFromDate:from];
            self.pckrDate.date = from;
            shareCreatorInstance.fromDate = self.txtFrom.text;
            shareCreatorInstance.isViewable = YES;
            shareCreatorInstance.isGhost = NO;
            //self.btnViewable.selected = YES;
            //self.btnGhost.selected = NO;
        }
        else
        {
            activeField.text = [self getDateStringFromDate:to];
            shareCreatorInstance.toDate = self.txtTo.text;
            shareCreatorInstance.isViewable = YES;
            shareCreatorInstance.isGhost = NO;
            //self.btnViewable.selected = YES;
            //self.btnGhost.selected = NO;
        }
    } else if(activeField == self.txtFrom) {
        if (!self.btnViewable.selected) {
            [self btnCheckboxClicked:self.btnViewable];
        }
        self.pckrDate.minimumDate = now;
        NSDate *from = self.pckrDate.date;
        NSDate *to = [self getDateFromString:self.txtTo.text];
        
        if([from compare:to] == NSOrderedDescending)
        {
            [Helper showMessageFade:self.view withMessage:@"please check the from and to dates set." andWithHideAfterDelay:3];
            activeField.text = [self getDateStringFromDate:to];
            self.pckrDate.date = to;
            shareCreatorInstance.toDate = self.txtTo.text;
            shareCreatorInstance.isViewable = YES;
            shareCreatorInstance.isGhost = NO;
        }
        else
        {
            activeField.text = [self getDateStringFromDate:from];
            shareCreatorInstance.fromDate = self.txtFrom.text;
            shareCreatorInstance.isViewable = YES;
            shareCreatorInstance.isGhost = NO;
        }
    } else if(activeField == self.txtGhost) {
        if (!self.btnGhost.selected) {
            [self btnCheckboxClicked:self.btnGhost];
        }
        self.pckrDate.minimumDate = now;
        NSDate *ghost = self.pckrDate.date;
        activeField.text = [self getDateStringFromDate:ghost];
        shareCreatorInstance.ghostDate = self.txtGhost.text;
        shareCreatorInstance.isGhost = YES;
        shareCreatorInstance.isViewable = NO;
    } else {
        activeField.text = [self getDateStringFromDate:self.pckrDate.date];
        // must be date field
        shareCreatorInstance.date = self.txtDate.text;
    }
    
}

- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

//-(BOOL)canBecomeFirstResponder {
//    return YES;
//}

- (NSDate *) getDateFromString:(NSString *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd-MM-yyyy";
    
    return [dateFormatter dateFromString:date];
}

- (NSString *) getDateStringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd-MM-yyyy";
    
    return [dateFormatter stringFromDate:date];
}

#pragma mark
#pragma mark Button Handling methods

- (IBAction)btnDonePopupClicked:(id)sender
{
    //
    // handle
    //
    self.viewDatepicker.hidden = YES;
    [self controlNavButtonsForDatePicker];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    //    [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, 0)];
    [UIView commitAnimations];
    [self fetchDateValue];
}

- (BOOL) checkShareNameSet {
    if ([[_txtName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        [Helper showMessageFade:self.view withMessage:@"please name your share" andWithHideAfterDelay:3];
        return NO;
    }
    else {
    }
    return YES;
}

-(void)clearall{
    
    
    self.txtName.text = @"";
    self.txtDate.text = @"";
    self.txtLocation.text = @"";
    self.txtFrom.text = @"";
    self.txtTo.text = @"";
    self.txtGhost.text = @"";
    
    self.btnFriendsCanAdd.selected= YES;
    self.btnFriendsCanPost.selected = YES;
    self.btnPublic.selected = NO;
    
}

- (IBAction)btnCancelClicked:(id)sender {
    //
    // clear the form and reset shareCreatorInstance
    //
    [self clearall];
    [shareCreatorInstance resetSharedInstance];
    
    [self.tabBarController setSelectedIndex:3];
}

- (void) addMemreasDetail {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //
    // Generate XML
    //
    
    //
    // Call Web Service
    //
    
    //
    // Parse response
    //
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark
#pragma mark - Show dialogs

- (void)startActivity:(NSString*)message {
    progressView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:progressView];
    if (message) {
        progressView.detailsLabelText = message;
    }
    
    [progressView show:YES];
}

#pragma mark - Remove loading dialog
- (void)stopActivity {
    //[self.gridGalleryCollectionView reloadData];
    [progressView removeFromSuperview];
    [progressView hide:YES];
    progressView = nil;
}



#pragma mark
#pragma mark handle buttons for segue methods
- (IBAction)handleMediaSegue:(id)sender {
    if ([self checkShareNameSet]) {
        if ([self storeShareDetails]) {
            [self performSegueWithIdentifier:@"segueShareAddMedia" sender:self];
        }
    }
}

- (IBAction)handleFriendsSegue:(id)sender {
    if ([self checkShareNameSet]) {
        if ([self storeShareDetails]) {
            [self performSegueWithIdentifier:@"segueShareAddFriends" sender:self];
        }
    }
}

- (bool) storeShareDetails {
    //
    // Store the share data
    //
    NSString* msgStoreShare = [shareCreatorInstance storeShareDetailsCompositeData:self.txtName.text
                                                                          withDate:self.txtDate.text
                                                                   andWithLocation:self.addressDict
                                                             andWithFriendsCanPost:self.btnFriendsCanPost.selected
                                                       andWithFriendsCanAddFriends:self.btnFriendsCanPost.selected
                                                                   andWithIsPublic:self.btnPublic.selected
                                                                 andWithIsViewable:self.btnViewable.selected
                                                                   andWithFromDate:self.txtFrom.text
                                                                     andWithToDate:self.txtTo.text
                                                                    andWithIsGhost:self.btnGhost.selected
                                                                  andWithGhostDate:self.txtGhost.text];
    
    //
    // Show message if failure else Create the share
    //
    if (![msgStoreShare isEqualToString:@""]) {
        [Helper showMessageFade:self.view withMessage:msgStoreShare andWithHideAfterDelay:3];
        return NO;
    }
    
    return YES;
}

//
// Call Web Service
//
- (IBAction)handleDoneAction:(id)sender {
    
    if ([self checkShareNameSet]) {
        //
        // Store the share data
        //
        if ([self storeShareDetails]) {
            //
            // Call web service
            //
            [shareCreatorInstance addeventWSCall:ADDEVENT_SHARE_RESULT_NOTIFICATION];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showHUDAddedTo:self.view animated:YES ];
            });
        } else {
            // do nothing - message displayed above
        }
    }
    
}

/**
 * Web Service Response via notification here...
 */
- (void)handleAddEvent:(NSNotification*)notification {
    NSDictionary* resultTags = [notification userInfo];
    NSString* status = [resultTags objectForKey:@"status"];
    NSString* message = [resultTags objectForKey:@"message"];
    if ([status isEqualToString:@"Success"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //
            // Event created and media added to move to memreas
            //
            [self clearall];
            [shareCreatorInstance resetSharedInstance];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self performSelector:@selector(moveToMemreas) withObject:nil afterDelay:1.0];
            [self.tabBarController setSelectedIndex:3];
        });
    } else {
        // show error message
        [Helper showMessageFade:self.view withMessage:message andWithHideAfterDelay:3];
    }
}

-(void) moveToMemreas{
    [self.navigationController popToRootViewControllerAnimated:true];
}

#pragma mark
#pragma mark Segue method

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //
    // Check Sender
    //
    if([segue.identifier isEqualToString:@"Setting"])
    {
        UIViewController *destViewController = segue.destinationViewController;
        destViewController.hidesBottomBarWhenPushed = YES;
        ALog(@"%@", [destViewController class]);
    } else if ([segue.identifier isEqualToString:@"segueShareLocationViewController"]) {
        ShareLocationViewController *shareLocationViewController = segue.destinationViewController;
        shareLocationViewController.delegate = self;
        return;
    }
}

#pragma mark
#pragma mark GAdBannerViewDelegate Method

- (void)adViewDidReceiveAd:(GADBannerView *) bannerView {
    //ALog(@"ad was received...");
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    //ALog(@"didFailToReceiveAdWithError: %@...", error.localizedFailureReason);
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView {
    //ALog(@"adViewWillPresentScreen...");
}
- (void)adViewDidDismissScreen:(GADBannerView *)bannerView {
    //ALog(@"adViewDidDismissScreen...");
}
- (void)adViewWillDismissScreen:(GADBannerView *)bannerView {
    //ALog(@"adViewWillDismissScreen...");
}

@end

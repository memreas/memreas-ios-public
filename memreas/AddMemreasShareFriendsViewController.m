#import "AddMemreasShareFriendsViewController.h"
#import "MediaItem.h"
#import "MyConstant.h"
#import "ShareCreator.h"
#import "FriendsContactEntry.h"
#import "FriendsCell.h"
#import "MIOSDeviceDetails.h"
#import "Helper.h"
#import "UIImageView+AFNetworking.h"
#import "NSString+SrtingUrlValidation.h"
#import "NSDictionary+valueAdd.h"
#import "QueueController.h"

@implementation AddMemreasShareFriendsViewController{
    //
    // local vars here
    //
    ShareCreator* shareCreatorInstance;
    
}


#pragma mark
#pragma mark View Life cycle
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
    // Share Creator Instance
    //
    shareCreatorInstance = [ShareCreator sharedInstance];
    
    //
    // Show Select Friends if none selected
    //
    if (shareCreatorInstance.selectedFriends.count == 0) {
        [self performSegueWithIdentifier:@"segueShareAddFriendsSelect" sender:self];
    }
    
    //
    // Add observer for event
    //
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAddEvent:)
                                                 name:ADDEVENT_FRIENDS_EVENT_RESULT_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAddMediaToEvent:)
                                                 name:ADDEVENT_FRIENDS_MEDIA_RESULT_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAddFriendsToEvent:)
                                                 name:ADDEVENT_FRIENDS_FRIENDS_RESULT_NOTIFICATION
                                               object:nil];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark
#pragma mark Navigation Methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"segueShareAddFriendsSelect"]){
        AddMemreasShareFriendsSelectViewController *frndVC = segue.destinationViewController;
        frndVC.delegate = self;
    }
    
}

#pragma mark
#pragma mark IB Actions

- (IBAction)btnFriendTap:(id)sender {
    
    @try {
        [self performSegueWithIdentifier:@"segueShareAddFriendsSelect" sender:self];
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
}

- (IBAction)btnCancelPressed:(id)sender {
    
    @try {
        
        
        if (self.eventID) {
            [self.navigationController popViewControllerAnimated:true];
        }else{
            [self.tabBarController setSelectedIndex:3];
            [ShareCreator resetSharedInstance];
            [self.navigationController popToRootViewControllerAnimated:true];
            
        }
        
        
        
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
    
}

- (IBAction)btnDonePressed:(id)sender {
    
    @try {
        
        [shareCreatorInstance addeventWSCall:ADDEVENT_FRIENDS_EVENT_RESULT_NOTIFICATION];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES ];
            
        });
        
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
}

#pragma mark
#pragma mark Web Service Relates methods


- (void) handleAddEvent:(NSNotification*)notification {
    NSDictionary* resultTags = [notification userInfo];
    NSString* status = [resultTags objectForKey:@"status"];
    if ([status isEqualToString:@"Success"]) {
        shareCreatorInstance.eventId = [resultTags objectForKey:@"event_id"];
        if (shareCreatorInstance.selectedMedia.count > 0) {
            //
            // event is created and media added next add friends...
            //
            [shareCreatorInstance addMediaToEvent:shareCreatorInstance.eventId withNotificationKey:ADDEVENT_FRIENDS_MEDIA_RESULT_NOTIFICATION];
        } else if (shareCreatorInstance.selectedFriends.count > 0) {
                //
                // no media but friends so send out msgs
                //
                [self handleFriendsMessaging];
            
                //
                // Hide the processing view
                //
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.eventID) {
                    [shareCreatorInstance resetSharedInstance];
                    [self.navigationController popViewControllerAnimated:true];
                }else{
                    [self performSelector:@selector(moveToMemreas) withObject:nil afterDelay:1.0];
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [self.tabBarController setSelectedIndex:3];
                }
            });
        }
    }
}

- (void) handleAddMediaToEvent:(NSNotification*)notification {
    NSDictionary* resultTags = [notification userInfo];
    NSString* status = [resultTags objectForKey:@"status"];
    if ([status isEqualToString:@"Success"]) {
        
        //
        // event is created and media added next add friends...
        //
        if (shareCreatorInstance.selectedFriends.count > 0) {
            
            //
            // handleFriendsMessaging
            //
            [self handleFriendsMessaging];
            
            
            //
            // Hide the processing view
            //
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            });
            
            
        } else {
            //
            // event created and media added but no friends so move
            //
            
            [shareCreatorInstance resetSharedInstance];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(moveToMemreas) withObject:nil afterDelay:1.0];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [self.tabBarController setSelectedIndex:3];
            });
        }
    }
}

- (void) handleFriendsMessaging {
    //
    // determine the counts for sms and memreas
    //
    [shareCreatorInstance determineMemreasFriendsCount];
    
    //
    // SMS
    //
    if (shareCreatorInstance.countSelectedFriendsSMS > 0) {
        
        NSMutableArray* recipients = [shareCreatorInstance fetchSMSRecipients:shareCreatorInstance.eventId];
        if(![MFMessageComposeViewController canSendText]) {
            [Helper showMessageFade:self.view withMessage:@"sms not supported by device" andWithHideAfterDelay:3];
            
        } else {
            if (recipients.count > 0) {
                MFMessageComposeViewController *messageComposerVC = [[MFMessageComposeViewController alloc] init];
                NSString *struserName =   [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"userDetail.ownerName"];
                NSString *message =[NSString stringWithFormat: @"@%@ invites you to !%@! %@%@",struserName, shareCreatorInstance.name, [MyConstant getSMS_URL], shareCreatorInstance.eventId];
                ALog(@"recipients :: %@", recipients);
                messageComposerVC.recipients = recipients;
                [messageComposerVC setBody:message];
                
                messageComposerVC.messageComposeDelegate = self;
                [self presentViewController:messageComposerVC animated:NO completion:^(void) {
                    [shareCreatorInstance addfriendtoeventWSCall:shareCreatorInstance.eventId withNotificationKey:ADDEVENT_FRIENDS_FRIENDS_RESULT_NOTIFICATION];
                }];
            }
            
        }
    }
    
    //
    // memreas
    //
    if (shareCreatorInstance.countSelectedFriendsMemreasOrEmails > 0) {
        [shareCreatorInstance addfriendtoeventWSCall:shareCreatorInstance.eventId withNotificationKey:ADDEVENT_FRIENDS_FRIENDS_RESULT_NOTIFICATION];
    }
}

- (void) handleAddFriendsToEvent:(NSNotification*)notification {
    NSDictionary* resultTags = [notification userInfo];
    NSString* status = [resultTags objectForKey:@"status"];
    NSString* message = [resultTags objectForKey:@"message"];
    if ([status isEqualToString:@"Success"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //
            // event created, media and friends added so move to memreas
            //
            [shareCreatorInstance resetSharedInstance];
            [self performSelector:@selector(moveToMemreas) withObject:nil afterDelay:1.0];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self.tabBarController setSelectedIndex:3];
            
        });
    } else {
        //
        // event created, media and friends added so move to memreas
        //
        [Helper showMessageFade:self.view withMessage:message andWithHideAfterDelay:3];
        [shareCreatorInstance resetSharedInstance];
        [self performSelector:@selector(moveToMemreas) withObject:nil afterDelay:3.0];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self.tabBarController setSelectedIndex:3];
    }
}


-(void)moveToMemreas{
    [self.navigationController popToRootViewControllerAnimated:true];
}

- (void)sendMediaToQueueForSync:(NSArray*)selectedForSync {
    @try {
        // add transfer
        QueueController* queueController = [QueueController sharedInstance];
        for (MediaItem* mediaItem in selectedForSync) {
            [queueController addToPendingTransferArray:mediaItem
                                      withTransferType:UPLOAD];
        }
        queueController = nil;
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}


- (void)messageComposeViewController: (MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result)
    {
        case MessageComposeResultCancelled:
            ALog(@"Cancelled");
            break;
        case MessageComposeResultFailed:
            ALog(@"Failed");
            break;
        case MessageComposeResultSent:
            ALog(@"Sent");
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark
#pragma mark Delegates

-(void)shareFriendsSelect:(AddMemreasShareFriendsSelectViewController *)sender{
    
    @try {
        [self.tblSelectedFriend reloadData];
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
}


#pragma mark
#pragma mark Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  shareCreatorInstance.selectedFriends.count ;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    @try {
        
        FriendsContactEntry *frndContact =[shareCreatorInstance.selectedFriends objectAtIndex:section];
        if (frndContact.friendType == MemreasNetwork) {
            return 0;
        }else{
            
            NSDictionary *contact = frndContact.objectOfFriend;
            return [contact[@"EmailArray"] count]  + [contact[@"PhoneArray"] count];
        }
        
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    @try {
        
        static NSString * CellIdentifier = @"DetailCell";
        DetailCell*  cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        FriendsContactEntry *frndContact =[shareCreatorInstance.selectedFriends objectAtIndex:indexPath.section];
        
        NSDictionary *contact = frndContact.objectOfFriend;
        // Check Box Selected un selected
        cell.btnCheckBox.indexPath = indexPath;
        
        [cell.btnCheckBox setBackgroundImage:[UIImage imageNamed:@"checked_white.png"] forState:UIControlStateNormal];
        
        if ([contact[@"EmailArray"] count] >indexPath.row) {
            NSString *str =  contact[@"EmailArray"] [indexPath.row];
            cell.lblDetail.text = [NSString stringWithFormat:@"Email: %@",str];
        }else{
            NSString *str = contact[@"PhoneArray"][indexPath.row - [contact[@"EmailArray"] count]];
            cell.lblDetail.text =[NSString stringWithFormat:@"SMS: %@", str];
        }
        
        return cell;
        
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
    
    
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    @try {
        
        FriendsCell *headerView = [tableView dequeueReusableCellWithIdentifier:@"HeaderView"];
        
        headerView.userName.layer.cornerRadius = 20.0;
        headerView.lblDetail.layer.cornerRadius = 17.0;
        
        headerView.userName.clipsToBounds = true;
        headerView.lblDetail.clipsToBounds = true;
        
        headerView.userName.layer.borderWidth = 2.0;
        headerView.userName.layer.borderColor = [UIColor whiteColor].CGColor;
        
        headerView.lblDetail.layer.borderWidth = 2.0;
        headerView.lblDetail.layer.borderColor = [UIColor whiteColor].CGColor;
        headerView.imageSelectedNetwork.hidden = true;
        CheckBoxButton *btnCheckBox = (CheckBoxButton*) headerView.btnSelected;
        btnCheckBox.indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        
        FriendsContactEntry *frndContact =[shareCreatorInstance.selectedFriends objectAtIndex:section];
        
        if (frndContact.friendType == MemreasNetwork) {
            
            NSDictionary *dicDetail = frndContact.objectOfFriend;
            
            headerView.userName.text = [dicDetail valueForKeyPath:@"social_username.text"];
            headerView.lblDetail.text = @"Memreas";
            [headerView.profilePic setImageWithURL:[NSURL URLWithString:[[[dicDetail valueForKeyPath:@"url.text"] convertToJsonWithFirstObject] urlEnocodeString]]  placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
            
            //            ALog(@"%@",[dicDetail valueForKeyPath:@"url.text"] );
            //            ALog(@"%@",[[dicDetail valueForKeyPath:@"url.text"]  class]);
            
            // Button selected or not selected
            [headerView.btnSelected setBackgroundImage:[UIImage imageNamed:@"Overlay"] forState:UIControlStateNormal];
            headerView.btnSelected.userInteractionEnabled = false;
            
        }else{
            
            NSDictionary *contact = frndContact.objectOfFriend;
            
            NSString* fullName = [contact valueForKeyPath:@"FullName"];;
            headerView.userName.text = fullName;
            headerView.lblDetail.text = @"Contact";
            
            headerView.profilePic.image = [contact valueForKey:@"Image"];
            
            // Button selected or not selected
            
            headerView.btnSelected.userInteractionEnabled = false;
            [headerView.btnSelected setBackgroundImage:[UIImage imageNamed:@"Overlay"] forState:UIControlStateNormal];
            
            
        }
        
        return headerView;
        
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
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

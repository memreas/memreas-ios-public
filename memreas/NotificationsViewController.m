#import "NotificationsViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "CommentVC.h"
#import "MemreasDetailSelf.h"
#import "MWebServiceHandler.h"
#import "MyConstant.h"
#import "SetSeachCellResults.h"
#import "WebServiceParser.h"
#import "WebServices.h"
#import "Util.h"
#import "XMLReader.h"
#import "XMLParser.h"
#import "XMLGenerator.h"
#import "JSONUtil.h"
#import "GalleryManager.h"
#import "QueueController.h"

#import "UIImageView+AFNetworking.h"
#import "NSString+SrtingUrlValidation.h"
#import "NSDictionary+valueAdd.h"


@implementation NotificationsViewController

+ (NotificationsViewController*)sharedInstance {
    ALog(@"%s", __PRETTY_FUNCTION__);
    static NotificationsViewController* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        
        /**
         * Set Observer for notification web services...
         */
        
        [[NSNotificationCenter defaultCenter] addObserver:instance
                                                 selector:@selector(notificationMWSHandlerComplete:)
                                                     name:LISTNOTIFICATION_RESULT_NOTIFICATION
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:instance
                                                 selector:@selector(responseReceivedForUpdateNotification:)
                                                     name:UPDATENOTIFICATION_RESULT_NOTIFICATION
                                                   object:nil];
        
    });
    return instance;
}

- (void)viewDidLoad {
    ALog(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tblNotification.tableFooterView = [[UIView alloc] init];
    [self.txtKeyword addTarget:self
                        action:@selector(searchValueChanged:)
              forControlEvents:UIControlEventEditingChanged];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        [[NotificationsViewController sharedInstance] getNotifications];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark
#pragma mark Table View

+ (NSMutableArray*) fetchNoticationsArray {
    return starrNotifications;
}


- (NSInteger)tableView:(UITableView*)tableView  numberOfRowsInSection:(NSInteger)section {
    ALog(@"starrNotifications.count-->%@",@(starrNotifications.count));
    return starrNotifications.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    
    static NSString* identi;
    
    NSDictionary* notification = starrNotifications[indexPath.row];
    //NSDictionary* notification = [notificationHolder objectForKey:@"notification"];
    NSString* notificationType = [notification valueForKeyPath:@"notification_type.text"];
    NSString *strNotification = @"";
    switch ([self filterNotificationType: notificationType]) {
        case ADD_COMMENT: {
            identi = @"Comment";
            strNotification = @"comment add";
            break;
        }
            
        case ADD_FRIEND: {
            identi = @"AddFrnd";
            strNotification = @"friend request received";
            break;
        }
            
        case ADD_FRIEND_TO_EVENT: {
            identi = @"EventAdd";
            strNotification = @"add friend to event";
            break;
        }
            
        case ADD_FRIEND_TO_EVENT_RESPONSE: {
            identi = @"EventAdd";
            strNotification = @"add friend to event";
            break;
        }
            
        case ADD_MEDIA: {
            identi = @"MediaAdd";
            strNotification = @"media added to event";
            break;
        }
            
        case ADD_EVENT: {
            // ADD_EVENT
            identi = @"Notification";  // Same just provide OK button.
            strNotification = @"add event request";
            break;
        }
            
        default: {
            identi = @"Notification";
            strNotification = @"friend request response";
            break;
        }
    }
    
    SetSeachCellResults* cell =
    [tableView dequeueReusableCellWithIdentifier:identi
                                    forIndexPath:indexPath];
    cell.tag = indexPath.row;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.lblProfileName.text = [NSString stringWithFormat:@"@%@",[notification valueForKeyPath:@"profile_username.text"]];
    
    [cell assignTags:indexPath];
    [cell.lblNotification setText:strNotification];
    cell.lblComment.text = [notification valueForKeyPath:@"comment.text"];
    cell.lblNotificationTime.text = [notification valueForKeyPath:@"updated_about.text"];
    
    NSString* profile_pic_98x78 = [notification valueForKeyPath:@"profile_pic_98x78.text"];
    NSURL* profileUrl = nil;
    if (profile_pic_98x78 != nil) {
        profile_pic_98x78 = [JSONUtil convertToID:profile_pic_98x78][0];
        profileUrl = [NSURL URLWithString:profile_pic_98x78];
    }
    [cell.profileImage setImageWithURL: profileUrl placeholderImage:[UIImage imageNamed:@"gallery_img"]];
    
    NSString* event_media_url = [notification valueForKeyPath:@"event_media_url.text"];
    NSURL* eventMediaUrl = nil;
    if (event_media_url != nil) {
        event_media_url = [JSONUtil convertToID:event_media_url][0];
        eventMediaUrl = [NSURL URLWithString:event_media_url];
    }
    [cell.profileImage setImageWithURL: eventMediaUrl placeholderImage:[UIImage imageNamed:@"gallery_img"]];
    
    cell.imageEvent.layer.cornerRadius = 5;
    cell.profileImage.layer.cornerRadius = 5;
    cell.profileImage.layer.masksToBounds = 1;
    cell.imageEvent.layer.masksToBounds = 1;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    cell.btnAddFriend.cell = cell;
    cell.btnDeclineRequest.cell = cell;
    cell.btnReply.cell = cell;
    cell.btnAcceptRequest.cell = cell;
    cell.btnIgnoreRequest.cell = cell;
    
    [cell.txtComments setReturnKeyType:UIReturnKeyDone];
    cell.txtComments.delegate = self;
    cell.txtComments.text = [notification valueForKeyPath:@"comment.text"];
    cell.lblComment.text = [notification valueForKeyPath:@"message.text"];
    cell.lblNotification.layer.cornerRadius = 10;
    cell.lblNotification.layer.masksToBounds = true;
    cell.lblNotification.layer.borderWidth = 1.0;
    cell.lblNotification.layer.borderColor = [UIColor whiteColor].CGColor;
    
    return cell;
}

- (void)tableView:(UITableView*)tableView
didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    //        [self onSelectNotification:indexPath.row];
    //        [tableView deselectRowAtIndexPath:indexPath animated:1];
}

//
// UITableView editing mode
//
- (void) removeRowFromTable:(CellButton*)sender {
    
    SetSeachCellResults* cell = sender.cell;
    NSIndexPath *indexPath = [self.tblNotification indexPathForCell:cell];
    [starrNotifications removeObjectAtIndex:indexPath.row];
    [self.tblNotification reloadData];
    if (starrNotifications.count == 0) {
        [self getNotifications];
    }
}

-(NSInteger) filterNotificationType:(NSString*)notificationType{
    
    if ([notificationType isEqualToUpperCase:@"ADD_FRIEND"]) {
        return ADD_FRIEND;
    } else   if ([notificationType isEqualToUpperCase:@"ADD_COMMENT"]) {
        return ADD_COMMENT;
    }else   if ([notificationType isEqualToUpperCase:@"ADD_FRIEND_TO_EVENT"]) {
        return ADD_FRIEND_TO_EVENT;
    }else   if ([notificationType isEqualToUpperCase:@"ADD_MEDIA"]) {
        return ADD_MEDIA;
    }else   if ([notificationType isEqualToUpperCase:@"ADD_EVENT"]) {
        return ADD_EVENT;
    }
    return 0;
}

#pragma mark--
#pragma mark IBActions

- (IBAction)cellButtonPressed:(UIButton*)sender {
}

- (void)searchValueChanged:(UITextField*)sender {
    if ([sender.text length]) {
    }
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    [self.view endEditing:YES];
}

- (IBAction)onClear:(id)sender {
    //    [self clearAllNotifications];
}

- (IBAction)onLogout:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    });
    [self logout];
}

//    Pleae Note The convention followed for notifcation data
//
//    notification_type:
//    1 : ADD_FRIEND notification
//    2 : ADD_FRIEND_TO_EVENT notification
//    3 : ADD_COMMENT notification
//    4 : ADD_MEDIA notification
//    5 : ADD_EVENT notification
//
//    //Server Side const
//    //  const ADD_FRIEND = '1';
//    //	const EMAIL = '0';
//    //	const MEMERAS = '1';
//    //	const NONMEMERAS = '2';
//    //	const ADD_FRIEND_TO_EVENT = '2';
//    //	const ADD_COMMENT = '3';
//    //	const ADD_MEDIA = '4';
//    //	const ADD_EVENT = '5';
//    //	const ADD_FRIEND_RESPONSE = '6';
//    //	const ADD_FRIEND_TO_EVENT_RESPONSE = '7';
//    //
//    //        is_read:
//    //        0 : not read
//    //        1:Cleared
//
////        is_read:
////        0 : not read
////        1:Cleared
//
////        status:
////        0-request,
////        1-accepted,
////        2-ignore
////        3-reject
//
////        notification_method:
////        0-email,
////        1-memares,
////        2-nonmemerars
//
//

-(void)callForFeedBackNotificationStatus:(NSString*) status
                              andMessage:(NSString*) message
                   andWithNotificationId:(NSString*) notification_id
{
    
    @try {
        
        //
        // Exec in background
        //
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            
            /**
             * Use WebServices Request Generator
             */
            NSString* requestXML = [XMLGenerator generateUpdateNotificationXML:notification_id
                                                                    withStatus:status
                                                                andWithMessage:message];
            
            /**
             * Use WebServices Request Generator
             */
            
            NSMutableURLRequest* request =
            [WebServices generateWebServiceRequest:requestXML action:UPDATENOTIFICATION];
            //ALog(@"NSMutableRequest request ----> %@", request);
            
            /**
             * Send Request and Parse Response...
             *  Note: wsHandler calls objectParsed_ListAllMedia
             */
            MWebServiceHandler* wsHandler = [[MWebServiceHandler alloc] init];
            [wsHandler fetchServerResponse:request action:UPDATENOTIFICATION key:UPDATENOTIFICATION_RESULT_NOTIFICATION];
        });
        
        
    } @catch (NSException* exception) {
        ALog(@"object type = %@", [[GalleryManager class] debugDescription]);
        ALog(@"%@", exception);
    }
}

-(void)responseReceivedForUpdateNotification:(NSNotification *)notification
{
    //
    // show message
    //
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [Helper showMessageFade:weakSelf.view withMessage:@"notification sent" andWithHideAfterDelay:1];
    });
    
}

- (IBAction)refreshNotificationList:(id)sender {
    // background fetch
    [self getNotifications];
}

#pragma mark - Web Service Methods

- (id)keyFor:(NSDictionary*)dic {
    if ([dic isKindOfClass:[NSDictionary class]]) {
        return dic[@"text"] ? dic[@"text"] : @"";
    } else {
        return dic;
    }
}

- (void)getNotifications {
    
    @try {
        
        //
        // Exec in background
        //
        if (self.isViewLoaded && self.view.window) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            
            /**
             * Use XMLGenerator
             */
            NSString* requestXML = [XMLGenerator generateXMLForListNotification];
            
            /**
             * Use WebServices Request Generator
             */
            NSMutableURLRequest* request = [WebServices generateWebServiceRequest:requestXML action:LISTNOTIFICATION];
            
            /**
             * Send Request and Parse Response...
             *  Note: wsHandler calls objectParsed_ListAllMedia
             */
            MWebServiceHandler* wsHandler = [[MWebServiceHandler alloc] init];
            [wsHandler fetchServerResponse:request action:LISTNOTIFICATION key:LISTNOTIFICATION_RESULT_NOTIFICATION];

            //
            // Hide HUD
            //
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });

            
        });
        
        
    } @catch (NSException* exception) {
        ALog(@"object type = %@", [[GalleryManager class] debugDescription]);
        ALog(@"%@", exception);
    }
}

/**
 * Web Service Response via notification here...
 */
- (void)notificationMWSHandlerComplete:(NSNotification*)notification {
    
    NSDictionary* dictResponse = [notification userInfo];
    
    @try {
        
        
        //
        // Create the array to start fresh
        //
        @synchronized (starrNotifications) {
            starrNotifications = [NSMutableArray array];
            
            //
            // Fetch notification subset
            //
            NSString* noNotificationsMsg = @"no notifications at this time";
            self.lblNorecord.text =@"";
            
            
            //ALog(@"dictResponse-->%@",dictResponse);
            starrNotifications = [dictResponse valueForKeyPath:@"xml.listnotificationresponse.notifications.notification"];
            
            if(starrNotifications != nil) {
                
                if (![starrNotifications isKindOfClass:[NSArray class]]) {
                    starrNotifications = [NSMutableArray
                                          arrayWithObject:starrNotifications];
                }
                
                if (starrNotifications.count > 0) {
                    //starrNotifications = [[NSMutableArray alloc] initWithArray:arrNotifications copyItems:YES];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"badge"
                                                                           object:[NSString stringWithFormat:@"%lu",(unsigned long)starrNotifications.count]];
                    });
                    [UIApplication sharedApplication].applicationIconBadgeNumber = starrNotifications.count;
                    //[self.tblNotification reloadData];
                } else {
                    self.lblNorecord.text = noNotificationsMsg;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"badge"
                                                                           object:@"0"];
                    });
                    starrNotifications = nil;
                    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                }
                
            } else {
                self.lblNorecord.text = noNotificationsMsg;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"badge"
                                                                       object:@"0"];
                });
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                starrNotifications = nil;
            }
            
        } // end @synchronized (starrNotifications)
        
        //
        // Update finished so remove HUD - if showing
        //
        /*
        if (self.isViewLoaded && self.view.window) {
            // viewController is visible
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }
         */
        
    } @catch(NSException *exception) {
        ALog(@"%@",exception);
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
    return YES;
}

#pragma mark Cell Button pressed

- (IBAction)acceptRequest:(CellButton*)sender {
    
    
    //
    // Fetch WS Data, remove row, then call WS
    //
    NSDictionary* notification = starrNotifications[sender.tag];
    [sender.cell.txtComments resignFirstResponder];
    NSString* notification_id = [notification valueForKeyPath:@"notification_id.text"];
    [self callForFeedBackNotificationStatus:ACCEPT
                                 andMessage:sender.cell.txtComments.text
                      andWithNotificationId:notification_id];
    [self removeRowFromTable:sender];
    
}

- (IBAction)declineRequest:(CellButton*)sender {
    
    //
    // Fetch WS Data, remove row, then call WS
    //
    NSDictionary* notification = starrNotifications[sender.tag];
    [sender.cell.txtComments resignFirstResponder];
    NSString* notification_id = [notification valueForKeyPath:@"notification_id.text"];
    [self callForFeedBackNotificationStatus:DECLINE
                                 andMessage:sender.cell.txtComments.text
                      andWithNotificationId:notification_id];
    [self removeRowFromTable:sender];
    
}

- (IBAction)ignoreRequest:(CellButton*)sender {
    
    //
    // Call web service with text if any
    //
    NSDictionary* notification = starrNotifications[sender.tag];
    [sender.cell.txtComments resignFirstResponder];
    NSString* notification_id = [notification valueForKeyPath:@"notification_id.text"];
    [self callForFeedBackNotificationStatus:IGNORE
                                 andMessage:sender.cell.txtComments.text
                      andWithNotificationId:notification_id];
    [self removeRowFromTable:sender];
    
}

- (IBAction)replyComment:(CellButton*)sender {
    
    //
    // Call web service with text if any
    //
    NSDictionary* notification = starrNotifications[sender.tag];
    [sender.cell.txtComments resignFirstResponder];
    NSString* notification_id = [notification valueForKeyPath:@"notification_id.text"];
    [self callForFeedBackNotificationStatus:ACCEPT
                                 andMessage:sender.cell.txtComments.text
                      andWithNotificationId:notification_id];
    [self removeRowFromTable:sender];
    
}

#pragma mark - logout
- (void)logout {
    /**
     * Use XMLGenerator...
     */
    NSString* requestXML =
    [XMLGenerator generateLogoutXML:[Helper fetchSID]
                            user_id:[Helper fetchUserId]];
    //  ALog(@"Request:- %@", requestXML);
    
    /**
     * Use WebServices Request Generator
     */
    
    NSMutableURLRequest* request =
    [WebServices generateWebServiceRequest:requestXML
                                    action:@"logout"];
    //  ALog(@"NSMutableRequest request ----> %@", request);
    
    /**
     * Send Request and Parse Response...
     */
    WebServiceParser* wsParserListNotifications = [[WebServiceParser alloc] init];
    wsParserListNotifications = [[WebServiceParser alloc]
                                 initWithRequest:request
                                 arrayRootObjectTags:[NSArray
                                                      arrayWithObjects:@"xml", @"logoutresponse", nil]
                                 sel:@selector(objectParsedForLogout:)
                                 andHandler:self];
}

- (void)objectParsedForLogout:(NSDictionary*)dic {
    [self processLogout];
}

- (void)processLogout {
    //
    // Migrate to Queue Controller
    //
    ALog(@"NotificationsViewController - - (void)processLogout - migrate to QueueController and Gallery Manager");
    if ([[QueueController sharedInstance] hasPendingTransfers]) {
        [[QueueController sharedInstance] cancelTransferTasks];
    }
    
    //
    // Clear NSUserDefaults
    //
    [Helper clearSession];

    //
    // Hide HUD
    //
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    });

    //
    // Pop to main view controller
    //
    //[self dismissViewControllerAnimated:YES completion:nil];
    UIViewController* initController = [[UIStoryboard storyboardWithName:@"Universal" bundle:nil] instantiateViewControllerWithIdentifier:@"PortraitNavigationController"];
    appDelegate.window.rootViewController = initController;
    [self presentViewController:initController animated:YES completion:nil];
    
}

@end

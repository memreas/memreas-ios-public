#import "SearchVC.h"
#import "MyConstant.h"
#import "WebServiceParser.h"
#import "WebServices.h"
#import "Util.h"
#import "MBProgressHUD.h"
#import "LoginViewController.h"
#import "XMLReader.h"
#import "SetSeachCellResults.h"
#import "XMLParser.h"
#import "MemreasDetailSelf.h"
#import "AFNetworking.h"
#import "XMLGenerator.h"
#import "WebServices.h"
#import "MWebServiceHandler.h"
#import "GalleryManager.h"
#import "NSDictionary+valueAdd.h"

@interface SearchVC ()
{
    MBProgressHUD *progressView;
    enum SearchModes searchMode;
}

- (IBAction)onFind:(id)sender;

@end

@implementation SearchVC

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
    [super viewDidLoad];
    
    
    /**
     * Set Observers for notifications...
     */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseAddFriendToEventNotification:)
                                                 name:SEARCH_ADD_FRIEND_TO_EVENT_RESPONSE
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseAddFriendNotification:)
                                                 name:SEARCH_ADD_FRIEND_RESPONSE
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseFindTagSearchNotification:)
                                                 name:SEARCH_FINDTAG_RESPONSE
                                               object:nil];
    
    
    
    
    // Do any additional setup after loading the view.
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.txtKeyword addTarget:self action:@selector(searchValueChanged:) forControlEvents:UIControlEventEditingChanged];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super  viewWillAppear:animated];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(NSMutableArray *)operations{
    if (!self.search_operations) {
        self.search_operations = [NSMutableArray array];
    }
    return self.search_operations;
}



-(void)setArrSearchList:(NSMutableArray *)arrSearchList{
    _arrSearchList = arrSearchList;
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [self cancelAllOperation];
    
}

-(void)cancelAllOperation{
    /*
     for (AFHTTPSessionManager * manager_ops in self.search_operations) {
     [manager_ops ca cancel];
     }
     */
}

- (IBAction)onFind:(id)sender
{
    if ([self isSearchValid]) {
        
        if (self.txtKeyword.text.length>1) {
            [self searchInformation];
        }
    }
}



-(SearchModes)presentSearch{
    if ([self.txtKeyword.text hasPrefix:@"@"]) {
        return Person;
    }else if ([self.txtKeyword.text hasPrefix:@"#"]) {
        return Discover;
    }else if ([self.txtKeyword.text hasPrefix:@"!"]) {
        return Memreas;
    }else {
        return searchMode;
    }
}


-(BOOL)isSearchValid{
    
    if ([self.txtKeyword.text hasPrefix:@"@"]) {
        searchMode = Person;
        return YES;
    }else if ([self.txtKeyword.text hasPrefix:@"#"]) {
        searchMode = Discover;
        return YES;
    }else if ([self.txtKeyword.text hasPrefix:@"!"]) {
        searchMode = Memreas;
        return YES;
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Helper showMessageFade:self.view withMessage:@"use search prefix @, !, or #" andWithHideAfterDelay:3];
        });
        self.txtKeyword.text =@"";
        searchMode = None;
        if (![self.txtKeyword isFirstResponder]) [self.txtKeyword becomeFirstResponder];
        return NO;
    }
}



#pragma mark - WS delegates

- (void)addFriendToEventWSCall:(NSDictionary*)dic {
    @try {
        
        ALog(@"addFriendToEventWSCall:(NSDictionary*)dic-->%@", dic);
        NSUserDefaults* defaultUser = [NSUserDefaults standardUserDefaults];
        NSString *webMethod = ADDFRIENDTOEVENT;
        
        NSString* requestXML = @"<xml>";
        requestXML = [requestXML stringByAppendingFormat:@"<sid>%@</sid>", [Helper fetchSID]];
        requestXML = [requestXML stringByAppendingFormat:@"<%@>",webMethod];
        requestXML = [requestXML stringByAppendingFormat:@"<user_id>%@</user_id>",[Helper fetchUserId]];
        requestXML = [requestXML stringByAppendingFormat:@"<event_id>%@</event_id>",[dic valueForKey:@"event_id"]];
        // Friends
        requestXML = [requestXML stringByAppendingFormat:@"<friends>"];
        requestXML = [requestXML stringByAppendingFormat:@"<friend>"];
        requestXML = [requestXML stringByAppendingFormat:@"<friend_name>%@</friend_name>", [defaultUser valueForKeyPath:@"userDetail.ownerName"]];
        requestXML = [requestXML stringByAppendingFormat:@"<friend_id>%@</friend_id>",[Helper fetchUserId]];
        requestXML = [requestXML stringByAppendingFormat:@"<network_name>memreas</network_name>"];
        requestXML = [requestXML stringByAppendingFormat:@"</friend>"];
        requestXML = [requestXML stringByAppendingFormat:@"</friends>"];
        
        // Request
        requestXML = [requestXML stringByAppendingFormat:@"</%@>",webMethod];
        requestXML = [requestXML stringByAppendingFormat:@"</xml>"];
        
        /**
         * Send Request and Parse Response...
         *  Note: wsHandler calls
         */
        if ([Util checkInternetConnection]) {
            /**
             * Use WebServices Request Generator
             */
            NSMutableURLRequest* request =
            [WebServices generateWebServiceRequest:requestXML
                                            action:webMethod];
            // ALog(@"NSMutableRequest request ----> %@", request);
            
            /**
             * Send Request and handle Resonse via Notification
             */
            MWebServiceHandler* wsHandler = [[MWebServiceHandler alloc] init];
            [wsHandler fetchServerResponse:request action:webMethod key:SEARCH_ADD_FRIEND_TO_EVENT_RESPONSE];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        });
        
        /**
         *  Send Request and Parse Response.
         *  Note: wsHandler calls
         */
        /*
         MWebServiceHandler* wsHandler = [[MWebServiceHandler alloc] init];
         [wsHandler fetchServerResponseWithwebMethodName:webMethod andInput:nil andDelegate:self andCallBackSelector:@selector(responseAddFriendToEventNotification:) andRequestXML:requestXML];
         */
        
    } @catch (NSException* exception) {
        ALog(@"object type = %@", [[GalleryManager class] debugDescription]);
        ALog(@"%@", exception);
    }
}


-(void)responseAddFriendToEventNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [Helper showMessageFade:self.view withMessage:@"request sent" andWithHideAfterDelay:3];
    });
}



- (void)addNotification:(NSDictionary*)dic {
    
    @try {
        NSMutableDictionary *input  = [NSMutableDictionary dictionary];
        
        NSString *webMethod = ADDFRIEND;
        [input addValueToDictionary:dic[@"user_id"] andKeyIs:@"friend_id"];
        
        /**
         * Send Request and Parse Response...
         *  Note: wsHandler calls
         */
        if ([Util checkInternetConnection]) {
            
            /**
             * Generate xml
             */
            NSString* requestXML = [XMLGenerator generateXMLForInputDictionary:input andSID:[Helper fetchSID] andWebMethod:webMethod];
            /**
             * Use WebServices Request Generator
             */
            NSMutableURLRequest* request =
            [WebServices generateWebServiceRequest:requestXML
                                            action:webMethod];
            // ALog(@"NSMutableRequest request ----> %@", request);
            
            /**
             * Send Request and handle Resonse via Notification
             */
            MWebServiceHandler* wsHandler = [[MWebServiceHandler alloc] init];
            [wsHandler fetchServerResponse:request action:webMethod key:SEARCH_ADD_FRIEND_RESPONSE];
        }
        
        
        /**
         * Send Request and Parse Response...
         *  Note: wsHandler calls
         */
        /*
         MWebServiceHandler* wsHandler = [[MWebServiceHandler alloc] init];
         [wsHandler fetchServerResponseWithwebMethodName:webMethod andAction:webMethod andInput:input andDelegate:self andCallBackSelector:@selector(responseAddFriendNotification:) andRequestXML:nil];
         */
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        });
        
        
    } @catch (NSException* exception) {
        ALog(@"object type = %@", [[GalleryManager class] debugDescription]);
        ALog(@"%@", exception);
    }
}
-(void)responseAddFriendNotification:(NSNotification *)notification
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [Helper showMessageFade:self.view withMessage:@"request sent" andWithHideAfterDelay:3];
    });
    
}





- (void)searchInformation {
    
    @try {
        NSMutableDictionary *input  = [NSMutableDictionary dictionary];
        
        NSString *webMethod = FINDTAG;
        
        [input addValueToDictionary:self.txtKeyword.text andKeyIs:@"tag"];
        
        /**
         * Send Request and Parse Response...
         *  Note: wsHandler calls
         */
        if ([Util checkInternetConnection]) {
            
            /**
             * Generate xml
             */
            NSString* requestXML = [XMLGenerator generateXMLForInputDictionary:input andSID:[Helper fetchSID] andWebMethod:webMethod];
            /**
             * Use WebServices Request Generator
             */
            NSMutableURLRequest* request =
            [WebServices generateWebServiceRequest:requestXML
                                            action:webMethod];
            ALog(@"NSMutableRequest request ----> %@", request);
            
            /**
             * Send Request and handle Resonse via Notification
             */
            MWebServiceHandler* wsHandler = [[MWebServiceHandler alloc] init];
            wsHandler.isJsonParsing = true;
            [wsHandler fetchServerResponse:request action:webMethod key:SEARCH_FINDTAG_RESPONSE];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        });
        
        
        /**
         * Send Request and Parse Response...
         *  Note: wsHandler calls
         */
        
        //MWebServiceHandler* wsHandler = [[MWebServiceHandler alloc] init];
        //wsHandler.isJsonParsing = true;
        //[wsHandler fetchServerResponseWithwebMethodName:webMethod andAction:webMethod andInput:input andDelegate:(UIViewController*)self andCallBackSelector:@selector(responseFindTagSearchNotification:) andRequestXML:nil];
        
    } @catch (NSException* exception) {
        ALog(@"object type = %@", [[GalleryManager class] debugDescription]);
        ALog(@"%@", exception);
    }
}

-(void)responseFindTagSearchNotification:(NSNotification *)notification
{
    
    @try {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        });
        
        NSDictionary *dictionary = notification.userInfo;
        
        NSMutableArray *aryNotifications = [dictionary objectForKey:@"search"];
        
        if(aryNotifications != nil)
        {
            self.arrSearchList = aryNotifications;
        }
        
        
        
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
}




#pragma mark
#pragma mark  Table View


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.arrSearchList count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identi ;
    
    switch (searchMode) {
        case Person:{
            
            identi = @"Cell";
            break;
        }
        case Discover:{
            
            identi = @"Discover";
            break;
        }
        case Memreas:{
            
            identi = @"Event";
            break;
        }
        default:
            break;
    }
    
    
    SetSeachCellResults * cell = [tableView dequeueReusableCellWithIdentifier:identi forIndexPath:indexPath];
    cell.tag = indexPath.row;
    cell.profileImage.layer.masksToBounds =1;
    cell.profileImage.layer.cornerRadius =5;
    cell.profileImage.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.profileImage.layer.borderWidth =1;
    
    cell.imageEvent.layer.masksToBounds =1;
    cell.imageEvent.layer.cornerRadius =5;
    cell.imageEvent.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.imageEvent.layer.borderWidth =1;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (searchMode) {
        case Person:{
            [cell configureFriendsdetail:self.arrSearchList[indexPath.row]];
            break;
        }
        case Discover:{
            [cell configureDiscoverdetail:self.arrSearchList[indexPath.row]];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            break;
        }
        case Memreas:{
            [cell configureMemreasdetail:self.arrSearchList[indexPath.row]];
            break;
        }
        default:
            break;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:1];
    
    switch (searchMode) {
        case Person:{
            // TODO - route to memreas page...
            break;
        }
        case Memreas:{
            // TODO - route to memreas page...
            break;
        }
        case Discover:{
            // TODO - route to memreas page...
            //            MemreasDetailSelf *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"MemreasDetail"];
            //            NSDictionary*dic= self.arrSearchList[indexPath.row];
            //            detail.dicPassedEventDetail = dic;
            //            detail.selectedSegmentIndex = 3;
            //            [self.navigationController pushViewController:detail animated:1];
            
            break;
        }
        default:
            break;
    }
}


#pragma mark --
#pragma mark  IBActions

-(IBAction)cellButtonPressed:(UIButton *)sender{
    
    NSDictionary * dic = self.arrSearchList[sender.tag];
    
    switch (searchMode) {
            
        case Person:{
            ALog(@"memreas Person dictionary ---> %@", dic);
            [self addNotification:dic];
            [sender setTitle:@"friend request sent." forState:UIControlStateDisabled];
            [sender setEnabled:NO];
            break;
        }
        case Discover:{
            //TODO
            ALog(@"memreas Discover dictionary ---> %@", dic);
            break;
        }
        case Memreas:{
            [self addFriendToEventWSCall:dic];
            ALog(@"memreas Memreas dictionary ---> %@", dic);
            [sender setTitle:@"add to memreas sent." forState:UIControlStateDisabled];
            
            break;
        }
        default:
            break;
    }
}


-(void)actionResponsereceived:(NSDictionary *)dic{
    
    [self stopActivity];
    
    if (dic!=nil) {
        
        switch (self.presentSearch) {
            case Person:{
                NSString * str = dic[@"xml"][@"addfriendtoeventresponse"][@"message"][@"text"];
                if ([str length]) {
                    __weak typeof(self) weakSelf = self;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [Helper showMessageFade:self.view withMessage:@"add friend success" andWithHideAfterDelay:3];
                    });
                }
                break;
            }
            case Discover:
                break;
            case Memreas:{
                NSString * str = dic[@"xml"][@"addfriendtoeventresponse"][@"message"][@"text"];
                if ([str length]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [Helper showMessageFade:self.view withMessage:@"added you to event" andWithHideAfterDelay:3];
                    });
                }
                break;
            }
            default:
                break;
        }
        
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [Helper showMessageFade:self.view withMessage:@"success" andWithHideAfterDelay:3];
        });
    }
}

-(void)searchValueChanged:(UITextField *)sender {
    if ([sender.text length]) {
        [self onFind:nil];
    }
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}



-(NSString*)keyFor:(NSDictionary*)dic{
    return dic [@"text"]?dic[@"text"]:@"";
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

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

@end

#import "AddMemreasShareFriendsSelectViewController.h"
#import "MyConstant.h"
#import "GalleryManager.h"
#import "ShareCreator.h"
#import "FriendsCell.h"
#import "FriendsContactEntry.h"
#import "UIKit+AFNetworking.h"
#import "NSDictionary+valueAdd.h"
#import "NSString+SrtingUrlValidation.h"

#pragma mark
#pragma mark Detail Cell

@implementation CheckBoxButton
@end

@implementation DetailCell
@end


@interface AddMemreasShareFriendsSelectViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) CNContactStore *contactStore;
@property (nonatomic,strong) NSMutableArray *arrContactList;
@property (nonatomic,strong) NSMutableArray *arrMemreasFriends;
@property (nonatomic,strong) NSMutableArray *arrFriendArray;
@property (nonatomic,strong)  ShareCreator* shareCreatorInstance;
@property (nonatomic,strong ) NSMutableArray*arrTempDatasaveForCancel;

@end

@implementation AddMemreasShareFriendsSelectViewController
#pragma mark
#pragma mark View Life Cycle
//
// Methods
//
- (void)viewDidLoad {
    [super viewDidLoad];
    
    @try {
        //
        // Fetch ShareCreator
        //
        self.shareCreatorInstance = [ShareCreator sharedInstance];
        
        //
        // Set Page Title
        //
        if (IS_IPAD) {
            self.headerImageView.image = [UIImage imageNamed:@"select friends"];
        }
        
        //
        // Add a gray border to the view
        //
        self.popupView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        
        //
        // Contact Access Authorization
        //
        if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {
            
            [self.contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                
                if (granted) {
                    
                    // Start fetching contact List
                    
                    [self retrieveContactsWithStore:self.contactStore];
                    
                }else{
                    
                    // Show Error
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Not Authorized" message:@"Please allow contacts access to this application. Check setting > Privacy for detail." preferredStyle:UIAlertControllerStyleAlert];
                    
                    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
                    
                    [self presentViewController:alert animated:true completion:nil];
                    
                }
                
            }];
        }else if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized){
            
            // Start fetching contact List
            [self retrieveContactsWithStore:self.contactStore];
            
        }else{
            
            // Show Error
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Not Authorized" message:@"Please allow contacts access to this application. Check setting > Privacy for detail." preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
            
            [self presentViewController:alert animated:true completion:nil];
            
        }
        
        // Data save for cancel
        self.arrTempDatasaveForCancel =self. shareCreatorInstance.selectedFriends;
        
        //
        // Add observers
        //
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleViewAllFriends:)
                                                     name:VIEWALLFRIENDS
                                                   object:nil];

        
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark
#pragma mark Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    //    return  self.arrMemreasFriends.count + self.arrContactList.count ;
    return  self.arrFriendArray.count ;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    @try {
        
        FriendsContactEntry *frndContact =[self.arrFriendArray objectAtIndex:section];
        if (frndContact.friendType == MemreasNetwork) {
            return 0;
        }else{
            
            CNContact *contact = frndContact.objectOfFriend;
            return contact.emailAddresses.count + contact.phoneNumbers.count;
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
        
        FriendsContactEntry *frndContact =[self.arrFriendArray objectAtIndex:indexPath.section];
        
        CNContact *contact = frndContact.objectOfFriend;
        
        // Check Box Selected un selected
        cell.btnCheckBox.indexPath = indexPath;
        
        
        NSPredicate *predicateTemplate = [NSPredicate predicateWithFormat:@"self.friendType == %d AND self.objectOfFriend.Identifier == %@",PhoneBookContact,contact.identifier];
        NSArray *arySelectedTemp = [self.shareCreatorInstance.selectedFriends filteredArrayUsingPredicate:predicateTemplate];
        NSMutableDictionary *dicSelectedTemplate = ((FriendsContactEntry*)[arySelectedTemp firstObject]).objectOfFriend;
        
        if (arySelectedTemp.count) {
            // Do nothing
        }else{
            [cell.btnCheckBox setBackgroundImage:[UIImage imageNamed:@"unselected_check.png"] forState:UIControlStateNormal];
        }
        
        if (contact.emailAddresses.count >indexPath.row) {
            
            CNLabeledValue *cnLblEmail = contact.emailAddresses[indexPath.row];
            //                        ALog(@"Email: %@", cnLblEmail);
            cell.lblDetail.text = [NSString stringWithFormat:@"Email :%@",cnLblEmail.value];
            
            
            if (arySelectedTemp.count && [dicSelectedTemplate[@"EmailArray"] count] && [dicSelectedTemplate[@"EmailArray"] containsObject:cnLblEmail.value]) {
                [cell.btnCheckBox setBackgroundImage:[UIImage imageNamed:@"checked_white.png"] forState:UIControlStateNormal];
            }else{
                [cell.btnCheckBox setBackgroundImage:[UIImage imageNamed:@"unselected_check.png"] forState:UIControlStateNormal];
            }
            
            
        }else{
            CNLabeledValue *cnLblPhone = contact.phoneNumbers[indexPath.row - contact.emailAddresses.count];
            //                        ALog(@"Phone: %@", cnLblPhone);
            CNPhoneNumber *phNumber = cnLblPhone.value;
            cell.lblDetail.text =[NSString stringWithFormat:@"SMS: %@", phNumber.stringValue];
            
            if (arySelectedTemp.count && [dicSelectedTemplate[@"PhoneArray"] count] && [dicSelectedTemplate[@"PhoneArray"] containsObject:phNumber.stringValue]) {
                [cell.btnCheckBox setBackgroundImage:[UIImage imageNamed:@"checked_white.png"] forState:UIControlStateNormal];
            }else{
                [cell.btnCheckBox setBackgroundImage:[UIImage imageNamed:@"unselected_check.png"] forState:UIControlStateNormal];
            }
            
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
        
        FriendsContactEntry *frndContact =[self.arrFriendArray objectAtIndex:section];
        
        if (frndContact.friendType == MemreasNetwork) {
            
            NSDictionary *dicDetail = frndContact.objectOfFriend;
            
            headerView.userName.text = [dicDetail valueForKeyPath:@"social_username.text"];
            headerView.lblDetail.text = @"Memreas";
            [headerView.profilePic setImageWithURL:[NSURL URLWithString:[[[dicDetail valueForKeyPath:@"url.text"] convertToJsonWithFirstObject] urlEnocodeString]]  placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
            
            
            //            ALog(@"%@",[dicDetail valueForKeyPath:@"url.text"] );
            //            ALog(@"%@",[[dicDetail valueForKeyPath:@"url.text"]  class]);
            
            // Button selected or not selected
            NSPredicate *predicateTemplate = [NSPredicate predicateWithFormat:@"self.friendType == %d AND self.objectOfFriend.friend_id.text == %@",MemreasNetwork,[dicDetail valueForKeyPath:@"friend_id.text"]];
            NSArray *arySelectedTemp = [self.shareCreatorInstance.selectedFriends filteredArrayUsingPredicate:predicateTemplate];
            if (arySelectedTemp.count) {
                [headerView.btnSelected setBackgroundImage:[UIImage imageNamed:@"Overlay"] forState:UIControlStateNormal];
            }else{
                [headerView.btnSelected setBackgroundImage:nil forState:UIControlStateNormal];
            }
            
            headerView.btnSelected.userInteractionEnabled = true;
            
        }else{
            
            
            CNContact *contact = frndContact.objectOfFriend;
            
            NSString* fullName = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
            headerView.userName.text = fullName;//[NSString stringWithFormat:@"%@ %@", contact.givenName, contact.familyName?contact.familyName:@""];
            headerView.lblDetail.text = @"Contact";
            
            if (contact.thumbnailImageData) {
                headerView.profilePic.image = [UIImage imageWithData:contact.thumbnailImageData];
            }else{
                headerView.profilePic.image = [UIImage imageNamed:@"placeholder.png"];
            }
            
            
            // Button selected or not selected
            NSPredicate *predicateTemplate = [NSPredicate predicateWithFormat:@"self.friendType == %d AND self.objectOfFriend.Identifier == %@",PhoneBookContact,contact.identifier];
            NSArray *arySelectedTemp = [self.shareCreatorInstance.selectedFriends filteredArrayUsingPredicate:predicateTemplate];
            
            headerView.btnSelected.userInteractionEnabled = false;
            if (arySelectedTemp.count) {
                NSMutableDictionary *dicSelectedTemplate = ((FriendsContactEntry*)[arySelectedTemp firstObject]).objectOfFriend;
                
                if ([dicSelectedTemplate[@"EmailArray"] count] || [dicSelectedTemplate[@"PhoneArray"] count]  ) {
                    [headerView.btnSelected setBackgroundImage:[UIImage imageNamed:@"Overlay"] forState:UIControlStateNormal];
                }else{
                    [headerView.btnSelected setBackgroundImage:nil forState:UIControlStateNormal];
                }
                
            }else{
                [headerView.btnSelected setBackgroundImage:nil forState:UIControlStateNormal];
            }
            
        }
        
        return headerView;
        
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
    
}

#pragma mark
#pragma mark IB Actions methods


- (IBAction)btnCheckboxPressed:(CheckBoxButton *)sender {
    
    @try {
        
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.shareCreatorInstance.selectedFriends]; // == Sharecreate Selected Friends
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        
        NSIndexPath*indexPath = sender.indexPath;
        
        FriendsContactEntry *frndContact =[self.arrFriendArray objectAtIndex:indexPath.section];
        
        if (frndContact.friendType == MemreasNetwork) {
            
            NSDictionary *dicContact = frndContact.objectOfFriend;
            
            // Button selected or not selected
            NSPredicate *predicateTemplate = [NSPredicate predicateWithFormat:@"self.friendType == %d AND self.objectOfFriend.friend_id.text == %@",MemreasNetwork,[dicContact valueForKeyPath:@"friend_id.text"]];
            NSArray *arySelectedTemp = [self.shareCreatorInstance.selectedFriends filteredArrayUsingPredicate:predicateTemplate];
            
            if (arySelectedTemp.count) {
                
                [tempArray removeObject:[arySelectedTemp firstObject]];
                
            }else{
                
                FriendsContactEntry *obj = [FriendsContactEntry friendInstance];
                obj.friendType = frndContact.friendType;
                obj.objectOfFriend = frndContact.objectOfFriend;
                
                [tempArray addObject:obj];
                
            }
            
            
        }else{
            
            
            CNContact *contact = frndContact.objectOfFriend;
            
            BOOL isRecordFound = false;
            int x = 0;
            for (x=0; x<tempArray.count; x++) {
                
                FriendsContactEntry *ObjOfFrnd = tempArray[x];
                NSMutableDictionary *dic = ObjOfFrnd.objectOfFriend;
                if( ObjOfFrnd.friendType == PhoneBookContact &&[dic[@"Identifier"] isEqualToString:contact.identifier]){
                    tempDic = dic;
                    isRecordFound = true;
                    break;
                }
            }
            
            [tempDic  setObject:contact.identifier forKey:@"Identifier"];
            NSString* fullName = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
            [tempDic  setObject:fullName forKey:@"FullName"];
            
            if (contact.thumbnailImageData) {
                [tempDic  setObject: [UIImage imageWithData:contact.thumbnailImageData] forKey:@"Image"];
            }else{
                [tempDic  setObject: [UIImage imageNamed:@"placeholder.png"] forKey:@"Image"];
            }
            
            if (contact.emailAddresses.count >indexPath.row) {
                
                
                CNLabeledValue *cnLblEmail = contact.emailAddresses[indexPath.row];
                
                if ([tempDic[@"EmailArray"] count] && [tempDic[@"EmailArray"] containsObject:cnLblEmail.value]) {
                    [tempDic[@"EmailArray"] removeObject:cnLblEmail.value];
                }else{
                    
                    NSMutableArray *emailArray = [NSMutableArray array];
                    
                    if ([tempDic[@"EmailArray"] count] ) {
                        [emailArray addObjectsFromArray:tempDic[@"EmailArray"] ];
                    }
                    
                    [emailArray addObject:cnLblEmail.value];
                    [tempDic setObject:emailArray forKey:@"EmailArray"];
                    
                }
                
                
                
            }else{
                
                CNLabeledValue *cnLblPhone = contact.phoneNumbers[indexPath.row - contact.emailAddresses.count];
                
                CNPhoneNumber *phNumber = cnLblPhone.value;
                
                if ([tempDic[@"PhoneArray"] count] && [tempDic[@"PhoneArray"] containsObject:phNumber.stringValue]) {
                    [tempDic[@"PhoneArray"] removeObject:phNumber.stringValue];
                }else{
                    
                    NSMutableArray *phoneArray = [NSMutableArray array];
                    
                    if ([tempDic[@"PhoneArray"] count] ) {
                        [phoneArray addObjectsFromArray:tempDic[@"PhoneArray"] ];
                    }
                    
                    [phoneArray addObject:phNumber.stringValue];
                    [tempDic setObject:phoneArray forKey:@"PhoneArray"];
                    
                }
                
            }
            
            
            FriendsContactEntry *obj = [FriendsContactEntry friendInstance];
            obj.friendType = frndContact.friendType;
            obj.objectOfFriend = tempDic;
            
            if ([tempDic[@"EmailArray"] count] || [tempDic[@"PhoneArray"] count]  ) {
                
                if (isRecordFound) {
                    [tempArray replaceObjectAtIndex:x withObject:obj];
                }else{
                    [tempArray addObject:obj];
                }
                
            }else{
                
                if (isRecordFound) {
                    [tempArray removeObjectAtIndex:x];
                }else{
                    //                [tempArray addObject:tempDic]; // Do nothing
                }
                
            }
            
            
        }
        
        self.shareCreatorInstance.selectedFriends = tempArray;
        [self.contactTableView reloadData];
        
        //        ALog(@"%@", [[self.shareCreatorInstance.selectedFriends firstObject] valueForKeyPath:@"self.objectOfFriend.Identifier"]);
        
        
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
}


- (IBAction)okAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        //
        // Return to parent with updates
        //
        [self.delegate shareFriendsSelect:self];
        
    }];
    
}

- (IBAction)cancelAction:(id)sender {
    
    // Data save for cancel
    
    self. shareCreatorInstance.selectedFriends =  self.arrTempDatasaveForCancel;
    
    [self dismissViewControllerAnimated:YES completion:^{
        //
        // clear selections updates here
        //
        
        [self.delegate shareFriendsSelect:self];
        
    }];
}

#pragma mark
#pragma mark Setter Getters

-(CNContactStore *)contactStore{
    
    if (!_contactStore) {
        _contactStore = [[CNContactStore alloc]init];
    }return _contactStore;
    
}


-(NSMutableArray *)arrFriendArray{
    
    if (!_arrFriendArray) {
        _arrFriendArray = [NSMutableArray array];
    }return _arrFriendArray;
    
}

#pragma mark
#pragma mark Contact Pick Related methods

-(void)retrieveContactsWithStore:(CNContactStore*)store {
    
    @try {
        
        NSArray *keys = @[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],CNContactFamilyNameKey, CNContactGivenNameKey,CNContactEmailAddressesKey, CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey];
        NSString *containerId = store.defaultContainerIdentifier;
        NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
        NSError *error;
        self.arrContactList = (NSMutableArray*)[store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];
        
        [self listAllFriends];
        
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
}



#pragma mark
#pragma mark Web service related methods

- (void)listAllFriends {
    @try {
        NSUserDefaults* defaultUser = [NSUserDefaults standardUserDefaults];
        NSString* userId = [defaultUser stringForKey:@"UserId"];
        NSString* sid = [defaultUser stringForKey:@"SID"];
        
        if ([Util checkInternetConnection]) {
            //
            // Use XMLGenerator...
            //
            
            NSMutableDictionary *input  = [NSMutableDictionary dictionary];
            [input addValueToDictionary:userId andKeyIs:@"user_id"];
            NSString* requestXML = [XMLGenerator generateXMLForInputDictionary:input andSID:sid andWebMethod:VIEWALLFRIENDS];
            ALog(@"Request:- %@", requestXML);
            
            /**
             * Use WebServices Request Generator
             */
            
            NSMutableURLRequest* request =
            [WebServices generateWebServiceRequest:requestXML
                                            action:VIEWALLFRIENDS];
            ALog(@"NSMutableRequest request ----> %@", request);
            
            /**
             * Send Request and Parse Response...
             *  Note: wsHandler calls objectParsed_ListAllMedia
             */
            MWebServiceHandler* wsHandler = [[MWebServiceHandler alloc] init];
            [wsHandler fetchServerResponse:request action:VIEWALLFRIENDS key:VIEWALLFRIENDS];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showHUDAddedTo:self.view animated:YES ];
            });
            
            
        }
        
    } @catch (NSException* exception) {
        ALog(@"object type = %@", [[GalleryManager class] debugDescription]);
        ALog(@"%@", exception);
    }
}

- (void)handleViewAllFriends:(NSNotification*)dictionary {
    
    NSDictionary *dicReceived = dictionary.userInfo;
    if ([[dicReceived valueForKeyPath:@"friends.friend"] isKindOfClass:[NSArray class]]) {
        self.arrMemreasFriends = [NSMutableArray arrayWithArray:[dicReceived valueForKeyPath: @"friends.friend"]];
        
    }else if([dicReceived valueForKeyPath:@"friends.friend"]){
        self.arrMemreasFriends = [NSMutableArray arrayWithArray:@[[dicReceived valueForKeyPath: @"friends.friend"]]];
    }
    
    for (int x = 0; x< [self.arrMemreasFriends count]; x++) {
        
        id objectFrnd =self.arrMemreasFriends [x];
        
        FriendsContactEntry *obj = [FriendsContactEntry friendInstance];
        obj.friendType = MemreasNetwork;
        obj.objectOfFriend = objectFrnd;
        [self.arrFriendArray addObject:obj];
        
    }
    
    for (int x = 0; x< [self.arrContactList count]; x++) {
        
        id objectFrnd =self.arrContactList [x];
        
        FriendsContactEntry *obj = [FriendsContactEntry friendInstance];
        obj.friendType = PhoneBookContact;
        obj.objectOfFriend = objectFrnd;
        [self.arrFriendArray addObject:obj];
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    [self.contactTableView reloadData];
    
}


//
// Memreaas Add Media button Handlers
//
- (IBAction)okMemreasAction:(id)sender {
    
    //
    // At this point the event is created so the media needs to be added
    //
    self.shareCreatorInstance.eventId = self.eventId;
    if (self.shareCreatorInstance.selectedFriends.count > 0) {
        
        //
        // Initiate refresh of events...
        //
        NSMutableDictionary* resultInfo = [NSMutableDictionary dictionary];
        [resultInfo addValueToDictionary:@"Success" andKeyIs:@"status"];
        [resultInfo addValueToDictionary:@"updates submitted..." andKeyIs:@"message"];

        [[NSNotificationCenter defaultCenter] postNotificationName:MEMREAS_ADDFRIENDS_HANDLER_NOTIFICATION
                                                            object:self
                                                          userInfo:resultInfo];

        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        // show error message
        [Helper showMessageFade:self.view withMessage:@"please select friends or cancel" andWithHideAfterDelay:3];
    }
    
    
}

- (IBAction)cancelMemreasAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        //
        // Dismiss modal here
        //
        [self.shareCreatorInstance resetSharedInstance];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
}




@end


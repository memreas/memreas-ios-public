#import "ContactPicker.h"
#import "THContact.h"
#import "MyConstant.h"
#import "FriendsContactEntry.h"

@implementation ContactCell



@end

@interface ContactPicker ()<ABPersonViewControllerDelegate>
@property (nonatomic, assign) ABAddressBookRef addressBookRef;
@property (weak, nonatomic) IBOutlet UIButton *btnTop;

@end

@implementation ContactPicker




/*
 typedef enum FriendType{
 
 Local ,
 FaceBook,
 email,
 SMS,
 Twitter,
 
 }FriendType;
 */

- (void)viewDidLoad
{
    ALog(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    
    
    
    if (IS_IPAD) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"contact-ipad"] forBarMetrics:UIBarMetricsDefault];
    }else{
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"contact-iphone"] forBarMetrics:UIBarMetricsDefault];
    }
    
    self.navigationItem.hidesBackButton = 1;
    
    
    
    
    
    switch (self.network) {
        case MemreasNetwork:{
            [self.btnTop setTitle:@"  memreas" forState:UIControlStateNormal];
            
            break;
        }
        case Email:{
            [self.btnTop setTitle:@"  email" forState:UIControlStateNormal];
            
            CFErrorRef error;
            _addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
            
            ABAddressBookRequestAccessWithCompletion(self.addressBookRef, ^(bool granted, CFErrorRef error) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self getContactsFromAddressBook];
                    });
                } else {
                    // TODO: Show alert
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Privacy Warning", @"Privacy Warning")
                                                                    message:NSLocalizedString(@"Permission was not granted for Contacts.", @"Permission was not granted for Contacts.")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                          otherButtonTitles:nil];
                    [alert show];
                    
                }
            });
            
            break;
        }
        case SMS:{
            [self.btnTop setTitle:@"  sms" forState:UIControlStateNormal];
            
            
            CFErrorRef error;
            _addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
            
            ABAddressBookRequestAccessWithCompletion(self.addressBookRef, ^(bool granted, CFErrorRef error) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self getContactsFromAddressBook];
                    });
                } else {
                    // TODO: Show alert
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Privacy Warning", @"Privacy Warning")
                                                                    message:NSLocalizedString(@"Permission was not granted for Contacts.", @"Permission was not granted for Contacts.")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                          otherButtonTitles:nil];
                    [alert show];
                    
                }
            });
            
            break;
        }
    }
    
    
    
    
    // Fill the rest of the view with the table view
}


-(void)getContactsFromAddressBook
{
    CFErrorRef error = NULL;
    self.contacts = [[NSMutableArray alloc]init];
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (addressBook) {
        NSArray *allContacts = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
        NSMutableArray *mutableContacts = [NSMutableArray arrayWithCapacity:allContacts.count];
        
        NSUInteger i = 0;
        for (i = 0; i<[allContacts count]; i++)
        {
            THContact *contact = [[THContact alloc] init];
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            contact.recordId = ABRecordGetRecordID(contactPerson);
            
            // Get first and last names
            NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
            NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            
            // Set Contact properties
            contact.firstName = firstName;
            contact.lastName = lastName;
            
            // Get mobile number
            ABMultiValueRef phonesRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
            contact.phone = [self getMobilePhoneProperty:phonesRef];
            if(phonesRef) {
                CFRelease(phonesRef);
            }
            
            
            // Get email
            ABMultiValueRef emailRef = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
            NSArray *emailAddresses = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailRef) ;
            contact.email = [emailAddresses firstObject];
            if(emailRef) {
                CFRelease(emailRef);
            }
            
            
            
            // Get image if it exists
            NSData  *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(contactPerson);
            contact.image = [UIImage imageWithData:imgData];
            if (!contact.image) {
                contact.image = [UIImage imageNamed:@"profile_img.png"];
            }
            
            [mutableContacts addObject:contact];
        }
        
        if(addressBook) {
            CFRelease(addressBook);
        }
        
        self.contacts = [NSArray arrayWithArray:mutableContacts];
        
        switch (self.network) {
                
            case Email:{
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.email.length > 0"];
                self.contacts = [self.contacts filteredArrayUsingPredicate:predicate];
                
                
                break;
            }
            case SMS:{
                
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.phone.length > 0"];
                self.contacts = [self.contacts filteredArrayUsingPredicate:predicate];
                
                break;
            }
                
                
        }
        
        
        
        
        [self.tableView reloadData];
    }
    else
    {
        ALog(@"Error");
        
    }
}

- (void) refreshContacts
{
    for (THContact* contact in self.contacts)
    {
        [self refreshContact: contact];
    }
    [self.tableView reloadData];
}

- (void) refreshContact:(THContact*)contact
{
    
    ABRecordRef contactPerson = ABAddressBookGetPersonWithRecordID(self.addressBookRef, (ABRecordID)contact.recordId);
    contact.recordId = ABRecordGetRecordID(contactPerson);
    
    // Get first and last names
    NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
    
    // Set Contact properties
    contact.firstName = firstName;
    contact.lastName = lastName;
    
    // Get mobile number
    ABMultiValueRef phonesRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
    contact.phone = [self getMobilePhoneProperty:phonesRef];
    if(phonesRef) {
        CFRelease(phonesRef);
    }
    
    // Get image if it exists
    NSData  *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(contactPerson);
    contact.image = [UIImage imageWithData:imgData];
    
    if (!contact.image) {
        contact.image = [UIImage imageNamed:@"profile_img.png"];
    }
}

- (NSString *)getMobilePhoneProperty:(ABMultiValueRef)phonesRef
{
    for (int i=0; i < ABMultiValueGetCount(phonesRef); i++) {
        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
        
        if(currentPhoneLabel) {
            if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
                return (__bridge NSString *)currentPhoneValue;
            }
            
            if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
                return (__bridge NSString *)currentPhoneValue;
            }
        }
        if(currentPhoneLabel) {
            CFRelease(currentPhoneLabel);
        }
        if(currentPhoneValue) {
            CFRelease(currentPhoneValue);
        }
    }
    
    return nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshContacts];
    });
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - UITableView Delegate and Datasource functions


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (self.network) {
            
        case MemreasNetwork:{
            return self.arrlocalmemreasFriend.count;
            break;
        }
            
        case Email:{
            return self.contacts.count;
            break;
        }
        case SMS:{
            return self.contacts.count;
            break;
        }
        default:{
            return 0;
            break;
        }
    }
    
    
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    NSString *cellIdentifier = @"ContactCell";
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView.backgroundColor = [UIColor clearColor];
    
    cell.imgProfilePics.layer.masksToBounds = YES;
    cell.imgProfilePics.layer.cornerRadius = 10;
    
    
    
    
    
    switch (self.network) {
            
        case MemreasNetwork:
        {
            
            
            cell.imageNetworkIndication.image = [UIImage imageNamed:@"Memreas-icon"];
            
            cell.lblSubtitle.text = @"";
            
            if (self.arrlocalmemreasFriend[indexPath.row][@"friend"] != nil) {
                
                cell.lblTitle.text = self.arrlocalmemreasFriend[indexPath.row][@"friend"][@"social_username"];
                
                NSString*  profileUrl = [self.arrlocalmemreasFriend[indexPath.row][@"friend"][@"url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                //[cell.imgProfilePics setImageWithURL:[NSURL URLWithString:profileUrl] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
                [cell.imgProfilePics setImage:[UIImage imageNamed:@"placeholder.png"]];
                
                
                
                
                NSDictionary *contact = self.arrlocalmemreasFriend[indexPath.row];
                
                BOOL selected = 0;
                NSPredicate *predicate ;
                
                predicate = [NSPredicate predicateWithFormat:@"self.friend.friend_id == %@",contact[@"friend"][@"friend_id"]];
                
                selected = [[self.selectedLocalFrnd filteredArrayUsingPredicate:predicate] count];
                
                UIImage *image;
                if (selected){
                    image = [UIImage imageNamed:@"checked_white.png"];
                } else {
                    image = nil;
                }
                cell.imgSelected.image = image;
                
                
            } else{
                
                
                if (self.arrlocalmemreasFriend[indexPath.row][@"group"]!= nil) {
                    
                    cell.lblTitle.text = self.arrlocalmemreasFriend[indexPath.row][@"group"][@"group_name"];
                    
                    NSString*  profileUrl = [self.arrlocalmemreasFriend[indexPath.row][@"friend"][@"url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    //[cell.imgProfilePics setImageWithURL:[NSURL URLWithString:profileUrl] placeholderImage:[UIImage imageNamed:@"group_icon"]];
                    [cell.imgProfilePics setImage:[UIImage imageNamed:@"group_icon"]];
                    
                    
                    NSDictionary *contact =  self.arrlocalmemreasFriend[indexPath.row];
                    
                    BOOL selected = 0;
                    NSPredicate *predicate;
                    
                    predicate = [NSPredicate predicateWithFormat:@"self.group.group_id == %@",contact[@"group"][@"group_id"]];
                    
                    selected = [[self.selectedLocalFrnd filteredArrayUsingPredicate:predicate] count];
                    
                    
                    
                    UIImage *image;
                    if (selected){
                        image = [UIImage imageNamed:@"checked_white.png"];
                    } else {
                        image = nil;
                    }
                    cell.imgSelected.image = image;
                    
                    
                }
            }
            
            
            break;
        }
            
            
        case Email:
        {
            cell.imageNetworkIndication.image = [UIImage imageNamed:@"Email-iconl"];
            
            
            THContact *contact = [self.contacts objectAtIndex:indexPath.row];
            
            cell.lblTitle.text = [contact fullName];
            cell.lblSubtitle.text = contact.email;
            
            if(contact.image) {
                cell.imgProfilePics.image = contact.image;
            }
            
            
            // Set the checked state for the contact selection checkbox
            
            BOOL selected = 0;
            
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.email == %@",contact.email];
            selected = [[self.selectedContacts filteredArrayUsingPredicate:predicate] count];
            
            
            UIImage *image;
            if (selected){
                image = [UIImage imageNamed:@"checked_white.png"];
            } else {
                
                image = nil;
            }
            cell.imgSelected.image = image;
            
            
            break;
        }
            
            
        case SMS:
        {
            
            cell.imageNetworkIndication.image = [UIImage imageNamed:@"Sms-icon"];
            
            THContact *contact = [self.contacts objectAtIndex:indexPath.row];
            
            cell.lblTitle.text = [contact fullName];
            
            
            cell.lblSubtitle.text = contact.phone;
            
            
            if(contact.image) {
                cell.imgProfilePics.image = contact.image;
            }
            
            
            // Set the checked state for the contact selection checkbox
            UIImage *image;
            BOOL selected = 0;
            
            
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.phone == %@",contact.phone];
            selected = [[self.selectedContacts filteredArrayUsingPredicate:predicate] count];
            
            
            
            
            if (selected){
                image = [UIImage imageNamed:@"checked_white.png"];
            } else {
                
                image = nil;
            }
            cell.imgSelected.image = image;
            
            break;
        }
            
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    @try {
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        
        switch (self.network) {
                
            case MemreasNetwork:{
                
                
                if (self.arrlocalmemreasFriend[indexPath.row][@"friend"] != nil) {
                    
                    NSDictionary *contact = self.arrlocalmemreasFriend[indexPath.row];
                    
                    BOOL selected = 0;
                    NSPredicate *predicate ;
                    
                    predicate = [NSPredicate predicateWithFormat:@"self.friend.friend_id == %@",contact[@"friend"][@"friend_id"]];
                    
                    selected = [[self.selectedLocalFrnd filteredArrayUsingPredicate:predicate] count];
                    NSDictionary* con = [[self.selectedLocalFrnd filteredArrayUsingPredicate:predicate] firstObject] ;
                    
                    if (selected){
                        [self.selectedLocalFrnd removeObject:con];
                    } else {
                        [self.selectedLocalFrnd addObject:contact];
                    }
                    
                    
                } else{
                    
                    
                    if (self.arrlocalmemreasFriend[indexPath.row][@"group"]!= nil) {
                        
                        NSDictionary *contact =  self.arrlocalmemreasFriend[indexPath.row];
                        
                        BOOL selected = 0;
                        NSPredicate *predicate;
                        
                        predicate = [NSPredicate predicateWithFormat:@"self.group.group_id == %@",contact[@"group"][@"group_id"]];
                        
                        selected = [[self.selectedLocalFrnd filteredArrayUsingPredicate:predicate] count];
                        NSDictionary* con = [[self.selectedLocalFrnd filteredArrayUsingPredicate:predicate] firstObject] ;
                        
                        if (selected){
                            [self.selectedLocalFrnd removeObject:con];
                        } else {
                            [self.selectedLocalFrnd addObject:contact];
                        }
                        
                    }
                }
                
                
                break;
            }
                
            case Email:{
                
                THContact *contact = [self.contacts objectAtIndex:indexPath.row];
                THContact *con;
                
                BOOL selected = 0;
                NSPredicate *predicate ;
                
                predicate = [NSPredicate predicateWithFormat:@"self.email == %@",contact.email];
                
                
                selected = [[self.selectedContacts filteredArrayUsingPredicate:predicate] count];
                con = [[self.selectedContacts filteredArrayUsingPredicate:predicate] firstObject] ;
                
                if (selected){ // contact is already selected so remove it from ContactPickerView
                    
                    [self.selectedContacts removeObject:con];
                } else {
                    [self.selectedContacts addObject:contact];
                }
                
                break;
            }
                
            case SMS:{
                
                THContact *contact = [self.contacts objectAtIndex:indexPath.row];
                THContact *con;
                
                BOOL selected = 0;
                NSPredicate *predicate ;
                
                predicate = [NSPredicate predicateWithFormat:@"self.phone == %@",contact.phone];
                
                selected = [[self.selectedContacts filteredArrayUsingPredicate:predicate] count];
                con = [[self.selectedContacts filteredArrayUsingPredicate:predicate] firstObject] ;
                
                if (selected){ // contact is already selected so remove it from ContactPickerView
                    
                    [self.selectedContacts removeObject:con];
                } else {
                    [self.selectedContacts addObject:contact];
                }
                
                break;
            }
        }
        
        // Refresh the tableview
        [self.tableView reloadData];
        
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
}



#pragma mark ABPersonViewControllerDelegate

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return YES;
}


// This opens the apple contact details view: ABPersonViewController
//TODO: make a THContactPickerDetailViewController
- (IBAction)viewContactDetail:(UIButton*)sender {
    ABRecordID personId = (ABRecordID)sender.tag;
    ABPersonViewController *view = [[ABPersonViewController alloc] init];
    view.addressBook = self.addressBookRef;
    view.personViewDelegate = self;
    view.displayedPerson = ABAddressBookGetPersonWithRecordID(self.addressBookRef, personId);
    
    
    [self.navigationController pushViewController:view animated:YES];
}




- (IBAction)closePicker:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(contactpickerDidCancelPickerController:)]) {
        [self.delegate contactpickerDidCancelPickerController:self];
    }
    
}



// TODO: send contact object
- (IBAction)done:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(contactpicker:didSelectContact:)]) {
        
        
        switch (self.network) {
            case SMS:{ // Allegro Mic sys. ACS 712 20 A, 9537399698 - Bhavya. Nirma.
                [self.delegate contactpicker:self didSelectContact:self.selectedContacts];
                break;
            }
            case Email:{
                [self.delegate contactpicker:self didSelectContact:self.selectedContacts];
                break;
            }
            case MemreasNetwork:{
                [self.delegate contactpicker:self didSelectContact:self.selectedLocalFrnd];
                break;
            }
        }
        
    }
    
}

@end

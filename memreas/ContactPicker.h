#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
@class THContact;
@class MyConstant;
@class FriendsContactEntry;


@class ContactPicker;
@protocol ContactPicking <NSObject>


@optional
-(void)contactpicker:(ContactPicker*)contactPicker didSelectContact:(NSMutableArray*)selectedContacts;

-(void)contactpickerDidCancelPickerController:(ContactPicker*)contactPicker ;


@end


@class ContactCell;
@interface ContactPicker : UIViewController

@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSMutableArray *selectedContacts;
//@property (nonatomic,assign) BOOL email;


@property (nonatomic, strong) NSMutableArray *arrlocalmemreasFriend;
@property (nonatomic, strong) NSMutableArray *arrFBFriend;
@property (nonatomic, strong) NSMutableArray *selectedFBFrind;
@property (nonatomic, strong) NSMutableArray *selectedLocalFrnd;



@property (nonatomic,assign) NSInteger network;

@property (nonatomic,assign) id <ContactPicking> delegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end



@interface ContactCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgProfilePics;
@property (weak, nonatomic) IBOutlet UIImageView *imgSelected;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSubtitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageNetworkIndication;

@end











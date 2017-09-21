#import <Foundation/Foundation.h>
@import UIKit;
#import "MasterViewController.h"
@class MyConstant;
@class GalleryManager;
@class ShareCreator;
@class FriendsCell;
@class FriendsContactEntry;
@import Contacts;


@class AddMemreasShareFriendsSelectViewController;
@interface CheckBoxButton : UIButton
@property (nonatomic,strong) NSIndexPath *indexPath;
@end


@class AddMemreasShareFriendsSelectViewController;
@interface DetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblDetail;
@property (weak, nonatomic) IBOutlet CheckBoxButton *btnCheckBox;

@end
@class AddMemreasShareFriendsSelectViewController;
@protocol SelectFriendListDelegate <NSObject>
-(void)shareFriendsSelect:(AddMemreasShareFriendsSelectViewController*)sender;
@end

@interface AddMemreasShareFriendsSelectViewController : MasterViewController

//
// properties
//
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIView *contactsView;
@property (weak, nonatomic) IBOutlet UITableView *contactTableView;
@property (weak, nonatomic) IBOutlet UILabel *lblFriendName;
@property (weak, nonatomic) IBOutlet UILabel *lblDetail;
@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (nonatomic) id <SelectFriendListDelegate> delegate;
@property (nonatomic) NSString* eventId;

//
// methods
//
- (IBAction)okAction:(id)sender;
- (IBAction)cancelAction:(id)sender;


//
// Memreas page actions
//
- (IBAction)okMemreasAction:(id)sender;
- (IBAction)cancelMemreasAction:(id)sender;

@end

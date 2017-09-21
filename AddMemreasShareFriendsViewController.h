@import Foundation;
@import MessageUI;
@import GoogleMobileAds;
@import Contacts;
@import MessageUI;
#import "MasterViewController.h"
#import "AddMemreasShareFriendsSelectViewController.h"
@class MediaItem;
@class MyConstant;
@class ShareCreator;
@class FriendsContactEntry;
@class FriendsCell;
@class MIOSDeviceDetails;
@class Helper;
    

@interface AddMemreasShareFriendsViewController : MasterViewController <SelectFriendListDelegate,MFMessageComposeViewControllerDelegate,UINavigationControllerDelegate> {
}

//
// properties
//
@property (weak, nonatomic) IBOutlet UITableView *tblSelectedFriend;
@property (nonatomic) NSString *eventID;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;

//
// methods
//


@end

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
@import GoogleMobileAds;
#import "MasterViewController.h"
@class XMLParser;
@class MyConstant;
@class MyView;
@class MemreasDetailViewController;
@class WebServiceParser;
@class WebServices;
@class MasterViewController;
@class FriendUITableViewController;
@class MyConstant;
@class Util;
@class CellComment;
@class XMLReader;
@class MIOSDeviceDetails;
@class SettingButton;
@class Helper;
@class XMLGenerator;
@class WebServices;
@class MWebServiceHandler;
@class GalleryManager;
@class GridCell;
@class TableCollectionCell;
#import "MeUICollectionViewController.h"
#import "FriendUITableViewController.h"
#import "PublicTableUIViewController.h"

static NSString* lastViewEventsRequestXML = @"";
static int me_f = 0, friends_f = 0, public_f = 0;

@interface MemreasMainViewController : MasterViewController

@property (nonatomic) IBOutlet UIView *meView;
@property (nonatomic) MeUICollectionViewController *meUICollectionViewController;

@property (nonatomic) IBOutlet UIView *friendsView;
@property (nonatomic) FriendUITableViewController *friendUITableViewController;
@property (nonatomic) IBOutlet UIView *publicView;
@property (nonatomic) PublicTableUIViewController *publicUITableViewController;

@property (nonatomic) IBOutlet UIActivityIndicatorView *actMemreas;
@property (nonatomic) IBOutlet UIView *viewLoading;
@property (nonatomic) IBOutlet UISegmentedControl *segMeFriendPublic;

@property (nonatomic)  NSMutableArray *arrEvents;
@property (nonatomic)  NSMutableArray *arrFriendEvents;
@property (nonatomic)  NSMutableArray *arrPublicEvents;
@property (nonatomic)  NSMutableArray *operations;

@property (nonatomic) BOOL isFriend;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;

- (void)CellTap:(NSIndexPath*)indexPath andDictionary:(NSDictionary*)dic;
+ (bool) fetchIsPublic;


@end

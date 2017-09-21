#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "NotificationsViewController.h"

@class AFNetworking;
@class MBProgressHUD;
@class CommentVC;
@class MemreasDetailSelf;
@class MWebServiceHandler;
@class MyConstant;
@class SetSeachCellResults;
@class WebServiceParser;
@class WebServices;
@class Util;
@class XMLReader;
@class XMLParser;
@class XMLGenerator;
@class JSONUtil;
@class GalleryManager;
@class QueueController;

static const int ADD_FRIEND = 1;
static const int ADD_FRIEND_TO_EVENT = '2';
static const int ADD_COMMENT = '3';
static const int ADD_MEDIA = '4';
static const int ADD_EVENT = '5';
static const int ADD_FRIEND_RESPONSE = '6';
static const int ADD_FRIEND_TO_EVENT_RESPONSE = '7';
static NSMutableArray *starrNotifications;

@interface NotificationsViewController : UIViewController<UITextFieldDelegate,
UIAlertViewDelegate,
UITableViewDataSource,
UITableViewDelegate> {
    AppDelegate *appDelegate;
}

@property (nonatomic) BOOL didGetNotifications;
@property (nonatomic) BOOL isSearch;
@property (nonatomic) BOOL open;
@property (nonatomic) IBOutlet UILabel *lblNorecord;
@property (nonatomic) IBOutlet UITextField* txtKeyword;
@property (nonatomic) IBOutlet UITableView* tblNotification;


+ (NotificationsViewController *) sharedInstance;
- (void) getNotifications;
- (IBAction)onLogout:(id)sender;
+ (NSMutableArray*) fetchNoticationsArray;
@end

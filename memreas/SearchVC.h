#import <UIKit/UIKit.h>
@class MyConstant;
@class WebServiceParser;
@class WebServices;
@class Util;
@class MBProgressHUD;
@class LoginViewController;
@class XMLReader;
@class SetSeachCellResults;
@class XMLParser;
@class MemreasDetailSelf;
@class AFNetworking;
@class QueueController;
@class XMLGenerator;
@class WebServices;
@class MWebServiceHandler;
@class GalleryManager;

typedef NS_ENUM( NSInteger, SearchModes ){
    None,
    Person,
    Discover,
    Memreas
};



@interface SearchVC : UIViewController <UITextFieldDelegate,UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>


@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (nonatomic) BOOL isSearch;
@property (nonatomic, weak) IBOutlet UITextField *txtKeyword;
@property (nonatomic) NSMutableArray *search_operations;
@property (nonatomic) NSMutableArray *arrSearchList;
@property (nonatomic,readonly) SearchModes presentSearch;




@end

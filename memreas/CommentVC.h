#import <UIKit/UIKit.h>
@class Helper;
@class MemreasDetailViewController;
#import "NSString+SrtingUrlValidation.h"

@interface CommentVC : UIViewController

@property (nonatomic, strong) IBOutlet UITableView *tableComment;
@property (nonatomic, strong) IBOutlet UITextField *txtMemreasComment;
@property (nonatomic, strong) IBOutlet UIButton *btnSound;

@property (nonatomic,strong) NSArray *arrComment;
@property (nonatomic,strong) NSDictionary *dicEventNSDictionary;
@property (nonatomic,strong) NSString* strParentController;



@end

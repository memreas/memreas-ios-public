#import <UIKit/UIKit.h>
@class MyConstant;

@class NetworkSelectionVC;

@protocol NetworkSelection <NSObject>

-(void)didselectNetwork:(NetworkSelectionVC*)networkSelectionVC selectedIndex:(NSInteger)index;

@end

@interface NetworkCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblNetworkName;

@property (weak, nonatomic) IBOutlet UIButton *btnRadio;
@end




@class NetworkCell;

@interface NetworkSelectionVC : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *arrayName;
@property (nonatomic,assign) id <NetworkSelection> delegate;
@property (nonatomic) NSInteger selectedNetwork;

@end





































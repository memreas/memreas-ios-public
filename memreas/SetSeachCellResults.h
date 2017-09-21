#import <UIKit/UIKit.h>
@class Helper;
@class MyConstant;
@class SetSeachCellResults;

@interface CellButton : UIButton
    @property (nonatomic,assign) SetSeachCellResults *cell;
@end

@interface SetSeachCellResults : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView * profileImage;
@property (nonatomic, weak) IBOutlet UILabel * lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblComment;

-(void)configureFriendsdetail:(NSDictionary *)dic;
-(void)configureDiscoverdetail:(NSDictionary *)dic;
-(void)configureMemreasdetail:(NSDictionary *)dic;
-(void)assignTags :(NSIndexPath*)indexPath;

+(NSString*)convertIntegerToTime:(NSString*)timeStamp;

@property (weak, nonatomic) IBOutlet UITextField *txtComments;
@property (weak, nonatomic) IBOutlet CellButton *btnAcceptRequest;
@property (weak, nonatomic) IBOutlet CellButton *btnDeclineRequest;
@property (weak, nonatomic) IBOutlet CellButton *btnIgnoreRequest;
@property (weak, nonatomic) IBOutlet CellButton *btnReply;
@property (nonatomic, weak) IBOutlet CellButton * btnAddFriend;
@property (weak, nonatomic) IBOutlet UILabel *lblProfileName;
@property (weak, nonatomic) IBOutlet UILabel *lblNotification;
@property (weak, nonatomic) IBOutlet UILabel *lblNotificationTime;
@property (weak, nonatomic) IBOutlet UIImageView *imageEvent;

@end

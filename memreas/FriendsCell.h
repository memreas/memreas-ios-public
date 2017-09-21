#import <UIKit/UIKit.h>

@interface FriendsCell : UITableViewCell


@property (nonatomic,weak) IBOutlet UIImageView * profilePic;
@property (nonatomic,weak) IBOutlet UILabel * userName;
@property (nonatomic,weak) IBOutlet UIButton * btnSelected;
@property (nonatomic,weak) IBOutlet UIButton * btnGroup;
@property (nonatomic,weak) IBOutlet UITextField * txtGroupName;
-(void)displayUserInfo:(NSString *)userName andProfileUrl:(NSString * )profileUrl andSelected:(BOOL)selected;
-(void)displayUserInfo:(NSString *)userName andProfileUrl:(NSString * )profileUrl andSelected:(BOOL)selected andIsGroup:(BOOL)isGroup;
@property (nonatomic,assign) id delegate;
@property (weak, nonatomic) IBOutlet UIImageView *imageSelectedNetwork;
@property (weak, nonatomic) IBOutlet UILabel *lblDetail;

@end

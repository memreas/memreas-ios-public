#import <UIKit/UIKit.h>

@interface MemreasDetailCell : UITableViewCell



@property (nonatomic,weak) IBOutlet UITextField * txtTitle;
@property (nonatomic,weak) IBOutlet UITextField * txtDate;
@property (nonatomic,weak) IBOutlet UITextField * txtLocation;
@property (nonatomic,weak) IBOutlet UITextField * txtViewableFrom;
@property (nonatomic,weak) IBOutlet UITextField * txtViewableTo;
@property (nonatomic,weak) IBOutlet UITextField * txtSelfDestruct;
@property (nonatomic,weak) IBOutlet UIButton * btnFriendsCanPost;
@property (nonatomic,weak) IBOutlet UIButton * btnFriendsCanAdd;
@property (nonatomic,weak) IBOutlet UIButton * btnIsPublic;
@property (nonatomic,assign) id delegate;



@end

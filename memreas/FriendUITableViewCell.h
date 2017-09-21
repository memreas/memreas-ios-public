#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "FriendUITableViewController.h"
#import "GridCell.h"

@interface FriendUITableViewCell : UITableViewCell
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout
>

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *imgProfilePics;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
//@property (weak, nonatomic) IBOutlet UIImageView *imgEventPics;
//@property (weak, nonatomic) IBOutlet UIButton *btnCommentCount;
//@property (weak, nonatomic) IBOutlet UIButton *btnLikeCount;

@property NSIndexPath*indexpath;
@property FriendUITableViewController *tableVC;
@property (nonatomic,strong) NSArray *dicDetail;

@end

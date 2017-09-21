#import <UIKit/UIKit.h>
#import "FriendCollectionView.h"
@class Helper;


@interface HeaderView : UIView
// User header
@property (weak, nonatomic) IBOutlet UILabel *lblEventName;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UIImageView *imgUserImage;
@property (weak, nonatomic) IBOutlet UIButton *btnLikeUserHeader;
@property (weak, nonatomic) IBOutlet UIButton *btnCommentUserHeader;
@property (weak, nonatomic) IBOutlet FriendCollectionView *friendCollectionView;


@property (nonatomic) NSInteger selectedSegmentIndex;
@property (nonatomic) NSInteger selectedEventIndex;
@property (nonatomic,strong) NSDictionary *dicPassedEventDetail;
@end

#import <UIKit/UIKit.h>
#import "GridCell.h"

@interface FriendCollectionView : UICollectionView<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic,strong) NSArray *arrFriends;
@property (nonatomic) NSInteger selectedSegmentIndex;

@end

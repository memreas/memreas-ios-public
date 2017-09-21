#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface MemreasEventViewCell : UICollectionViewCell
@property(weak, nonatomic) IBOutlet UILabel* lblEventName;
@property(weak, nonatomic) IBOutlet UIImageView* imgEventPhoto;
@property(weak, nonatomic) IBOutlet UIImageView* imgVideo;
@property(weak, nonatomic) IBOutlet UIButton* btnPhoto;
@end

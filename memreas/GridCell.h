#import <UIKit/UIKit.h>
#import "MyView.h"
#import "ELCAsset.h"

@interface GridCell : UICollectionViewCell
@property(weak, nonatomic) IBOutlet MyView* myView;
@property(weak, nonatomic) IBOutlet ELCAsset* elcAsset;
@property(weak, nonatomic) IBOutlet UILabel* lblEventName;
@property(weak, nonatomic) IBOutlet UIImageView* imgPhoto;
@property(weak, nonatomic) IBOutlet UIImageView* imgVideo;

// MyView
@property(weak, nonatomic) IBOutlet UIButton* btnPhoto;

// Cell Specific
@property CGSize size;

@end

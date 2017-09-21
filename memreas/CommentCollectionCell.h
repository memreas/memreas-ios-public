#import <UIKit/UIKit.h>
#import "PlayerAudioButton.h"

@interface CommentCollectionCell : UICollectionViewCell


@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
@property (weak, nonatomic) IBOutlet UITextView *tfComment;
@property (weak, nonatomic) IBOutlet PlayerAudioButton *btnPlay;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *active;
@property (weak, nonatomic) IBOutlet UIView *viewAudioPlayer;


@end

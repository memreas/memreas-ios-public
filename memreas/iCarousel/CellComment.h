#import <UIKit/UIKit.h>
#import "PlayerAudioButton.h"

@interface CellComment : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *textCommentView;
@property (weak, nonatomic) IBOutlet UIView *audioCommentView;
@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
@property (weak, nonatomic) IBOutlet UIImageView *playBG;
@property (weak, nonatomic) IBOutlet UITextView *tfComment;
@property (weak, nonatomic) IBOutlet PlayerAudioButton *btnPlay;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *active;

@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UIButton *btnHideShow;

@end

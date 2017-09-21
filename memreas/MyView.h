#import <UIKit/UIKit.h>
#import "MyConstant.h"

@interface MyView : UIView<UIScrollViewDelegate>
{
//    IBOutlet UIImageView *imgPhoto;
    NSString *_imageURL;
}
@property (retain, nonatomic) IBOutlet UIView *viewBack;

@property (weak, nonatomic) IBOutlet UIButton *btnPhoto;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actLoading;
@property (nonatomic,retain) IBOutlet UIImageView *imgPhoto;
@property (nonatomic,retain) IBOutlet UIImageView *imgVideo;
@property (nonatomic, retain) NSString *imageURL;
@property (nonatomic, retain) NSString *eventID,*eventName;
@property (nonatomic, retain) NSString *profileImageURL;
@property (nonatomic, retain) NSString *createName;
@property (nonatomic, assign) int  userComment;
@property (nonatomic, assign) int  userLike;
@property (nonatomic, strong) NSMutableArray *strUserImages;
@property (assign) int friend_can_post;
@property (assign) int friend_can_share;
@property (assign) BOOL isLoading;

@property (weak, nonatomic) IBOutlet UIScrollView *scroll;
@property(nonatomic,strong) NSMutableArray *ary;

@end

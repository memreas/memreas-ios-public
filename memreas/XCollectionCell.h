#import <UIKit/UIKit.h>
@class MyConstant;
@class XCollectionCell;
@interface PlayerVideoBtn : UIButton

@property (weak, nonatomic) IBOutlet XCollectionCell *cell;

@end




@interface XCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView * image;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView * indicator;
@property (weak, nonatomic) IBOutlet PlayerVideoBtn * playButton;

-(void)loadImageWithURLString:(NSDictionary *)dic andImageKey:(NSString *)key;



@property (weak, nonatomic) IBOutlet UIView *viewVideo;


@property(nonatomic,strong) NSMutableArray *aryImages;


@end

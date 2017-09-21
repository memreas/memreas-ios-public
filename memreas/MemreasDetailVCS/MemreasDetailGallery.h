#import <UIKit/UIKit.h>
@class Util;
@class MWebServiceHandler;
@class HeaderView;
@import AVFoundation;
@import AVKit;

@class MemreasDetailGallery;
@interface CommentCollection:UICollectionView<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic,strong)NSArray *arrComments;
@property (nonatomic,strong) NSDictionary *dicPassedEventDetail;
@property (nonatomic, strong) AVPlayer *playAu;
@property (nonatomic,strong) NSString *media_id;


@end

@interface MemreasDetailGallery : UIViewController

// Outlets
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (nonatomic,strong) NSDictionary *dicPassedEventDetail;
@property (nonatomic,assign) NSInteger selectedSegmentIndex;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionGallery;
@property (weak, nonatomic) IBOutlet CommentCollection *collectionComment;

- (void)responseForLikeMedia:(NSNotification *)notification;

@end

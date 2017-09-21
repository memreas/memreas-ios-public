@import UIKit;
@import Foundation;
#import "CommentCollectionCell.h"
#import "MemreasDetailGallery.h"
#import "MemreasMainViewController.h"
#import "HeaderView.h"
@class XCollectionCell;
@class CommentCollectionCell;
@class FullScreenMode;
@class XMLGenerator;
@class GalleryManager;
@class QueueController;


@interface MemreasMediaDetail : UIViewController

@property (nonatomic,strong)NSArray *arrGalleryMedia;
@property (weak, nonatomic) IBOutlet UIButton *btnCommentCount;
@property (weak, nonatomic) IBOutlet UIButton *btnLikeCount;
@property (nonatomic,strong) NSString *strEventID;
@property (nonatomic,strong) NSString *strMediaID;
@property (nonatomic, strong) FullScreenMode* fullScreenView;
@property (nonatomic, strong) AVPlayerViewController *playerViewController;

// Outlets
@property (nonatomic) IBOutlet HeaderView *headerView;
@property (nonatomic) IBOutlet UIStackView* detailStackView;
@property (nonatomic) IBOutlet UIView *actionView;
@property (nonatomic) IBOutlet UIView *menubarView;
@property (nonatomic) IBOutlet UIView *menubarPublicView;
@property (nonatomic) NSDictionary *dicPassedEventDetail;
@property (nonatomic) NSInteger selectedSegmentIndex;
@property (nonatomic) IBOutlet UICollectionView *collectionGallery;
@property (nonatomic) IBOutlet CommentCollection *collectionComment;
@property (nonatomic) NSIndexPath* selectedIndexPath;

@property (nonatomic) IBOutlet UIView *reportInappropriateMediaView;
@property (nonatomic) IBOutlet UILabel *lblReportHeader;
// explicit sexual content
@property (nonatomic) IBOutlet UIButton *btnESC;
@property (nonatomic) IBOutlet UILabel *lblESC;
// explicit violent content
@property (nonatomic) IBOutlet UIButton *btnEVC;
@property (nonatomic) IBOutlet UILabel *lblEVC;
// explicit hate speech content
@property (nonatomic) IBOutlet UIButton *btnEHS;
@property (nonatomic) IBOutlet UILabel *lblEHS;
// explicit inappropriate other content
@property (nonatomic) IBOutlet UIButton *btnIOC;
@property (nonatomic) IBOutlet UILabel *lblIOC;

@end

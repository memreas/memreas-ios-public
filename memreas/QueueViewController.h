#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MasterViewController.h"
@class MyConstant;
@class GridCell;
@class MyView;
@class UploadCustomCell;
@class WebServiceParser;
@class WebServices;
@class MIOSDeviceDetails;
@import GoogleMobileAds;
#import "QueueController.h"
#import "QueueUploadController.h"
#import "QueueDownloadController.h"
@class AMGProgressView;



@interface QueueViewController : MasterViewController
<
    // Delegates
    UITableViewDataSource,
    UITableViewDelegate,
    UIScrollViewDelegate,
    UIAlertViewDelegate,
    GADBannerViewDelegate,
    QueueUploadControllerDelegate,
    QueueDownloadControllerDelegate,
    QueueControllerDelegate
>
{
    int counter;
    int uploadedfileCounter;
    int uploadLimit, currentUploadedCounter;
    
    BOOL isCompleteFirstTime, isInBack;
    
    int x, y;
    int noOfObjectInColumn, current_no_of_object_in_row;
    int scrollView_Height;
    int height, width;
    int currentIndex, succedIndex, endPoint;
    
    BOOL isPaused;
    NSTimer* timer;
}

@property(nonatomic) IBOutlet UIView* viewTransfer;
@property(nonatomic) IBOutlet UITableView* tableViewTransfers;
@property(nonatomic) IBOutlet UIView* viewComplete;
@property(weak, nonatomic) IBOutlet GADBannerView *bannerView;
@property(weak, nonatomic) IBOutlet UICollectionView* gridViewTransfersCompleted;
@property(nonatomic) IBOutlet UIButton* btnResume;
@property(nonatomic) IBOutlet UIButton* btnClear;
@property(nonatomic) IBOutlet UIButton* btnPause;
@property(nonatomic, assign) IBOutlet UISegmentedControl* sgmTransferOrCompleteTab;
@property(nonatomic, strong) NSMutableDictionary* progress;


@end

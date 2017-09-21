#import <GoogleMaps/GoogleMaps.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "MasterViewController.h"
#import "MediaItem.h"
#import "GalleryManager.h"
#import "QueueController.h"
@class ELCAsset;
@class GridCell;
@class MyConstant;
@class MyView;
@class MyMovieViewController;
@class FullScreenView;
@class GridCell;
@class Util;
@class MediaIdManager;
@class CopyrightManager;
@class MIOSDeviceDetails;
@class SettingButton;
@import GoogleMobileAds;
@import Photos;
@class EventMapPopView;
@class GMSMarker;

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

@interface GalleryViewController : MasterViewController<
GADBannerViewDelegate,
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
PHPhotoLibraryChangeObserver,
GalleryManagerDelegate>

{
    BOOL _bIsEditing;
}

@property(weak, nonatomic) IBOutlet UIView* galleryView;
@property(weak, nonatomic) IBOutlet UIView* spinnerView;
@property(weak, nonatomic) IBOutlet UIActivityIndicatorView* viewLoading;
@property(weak, nonatomic) IBOutlet UIView* fullScreenView;
@property(weak, nonatomic) IBOutlet UIView* syncView;
@property(weak, nonatomic) IBOutlet UIImageView* fullScreenImageView;
@property(weak, nonatomic) IBOutlet UISegmentedControl* segViewSync;
@property(weak, nonatomic) IBOutlet GADBannerView *bannerView;
@property(weak, nonatomic) IBOutlet UICollectionView* gridCollectionView;
@property(weak, nonatomic) IBOutlet UIButton* btnClear;
@property(weak, nonatomic) IBOutlet UIButton* btnDone;
@property(weak, nonatomic) IBOutlet UIButton* btnRed;
@property(weak, nonatomic) IBOutlet UIButton* btnYellow;
@property(weak, nonatomic) IBOutlet UIButton* btnGreen;
@property(weak, nonatomic) IBOutlet UIButton* btnOrange;
@property(weak, nonatomic) IBOutlet UIButton* btnBack;
@property(weak, nonatomic) IBOutlet UILabel* lblProgress;
@property(weak, nonatomic) IBOutlet UIButton* fullScreenPlayButton;
@property(nonatomic) NSMutableArray* selectedForSync;
@property PHCachingImageManager* cachingImageManager;
@property(nonatomic) CGFloat lastContentOffset;
@property(nonatomic) BOOL isPhotoChangeObserverOn;

- (IBAction)backPressed:(id)sender;
- (void)enterFullScreenMode:(NSInteger)index
              withMediaItem:(MediaItem*)mediaItem;
- (void)refreshGalleryView;

@end

#import <Foundation/Foundation.h>
#import "MasterViewController.h"
@import Photos;
@class MyConstant;
@class GalleryManager;
@class MediaItem;
@class GridCell;
@class ShareCreator;
@class MIOSDeviceDetails;
@import GoogleMobileAds;



@interface AddMemreasShareMediaViewController : MasterViewController {
}

//
// properties
//
@property (weak, nonatomic) IBOutlet UIView *viewLoading;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *snifferLoading;
@property (weak, nonatomic) IBOutlet UIButton *btnDetails;
@property (weak, nonatomic) IBOutlet UIButton *btnMedia;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextField *txtComment;
@property (weak, nonatomic) IBOutlet UIButton *btnAudioComment;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

@property (nonatomic,strong) NSString *eventID;

- (IBAction)handleAudioComment:(id)sender;
- (IBAction)handleNextAction:(id)sender;
- (IBAction)handleDoneAction:(id)sender;
- (IBAction)handleCancelAction:(id)sender;
- (IBAction)handleAddMediaPopup:(id)sender;


@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;
//
// methods
//

@end

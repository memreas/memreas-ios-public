#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
@import AVKit;
@import AVFoundation;
#import "MasterViewController.h"
#import "MemreasDetailViewController.h"
@class MemreasLocationViewController;
@class AddMemreasShareMediaSelectViewController;
@class AddMemreasShareFriendsSelectViewController;
@class MemreasLocationViewController;
@class MemreasDetailGallery;
@class MemreasMediaDetail;
@class ShareCreator;
@class XMLParser;
@class MyConstant;
@class MyView;
@class AudioRecording;
@class Helper;
@class MIOSDeviceDetails;
@class AddMediaFromPhotoDetai;
@class AddMemreasShareFriendsViewController;
@class AudioRecording;
@class XCollectionCell;
@class RecordingProgress;
@class CellComment;
@class AddMemreasShareMediaViewController;
@class Util;
@class XMLReader;
@class CommentCollectionCell;
@class FullScreenView;
@class RecordingVC;
@class CommentVC;
@import MessageUI;
@import GoogleMaps;
@import GoogleMobileAds;


@interface MemreasDetailViewController : MasterViewController
<
MFMessageComposeViewControllerDelegate,
GMSMapViewDelegate,
UITextFieldDelegate,
CLLocationManagerDelegate,
GADBannerViewDelegate
>
{
    AVPlayer* playerStream;
    GMSMapView* googleMap;
}
// IB Outlets
@property(strong, nonatomic) IBOutlet UITextField* txtComment;
// Internal Property
@property (nonatomic, strong) FullScreenView* fullScreenView;
@property (nonatomic, strong) RecordingVC* recordingVC;
@property (nonatomic, strong) CommentVC* commentVC;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;



// Passed objects
@property (nonatomic) NSInteger selectedSegmentIndex;
@property (nonatomic) NSNumber* index;
@property (nonatomic) NSMutableArray *arrEventsForSegment;
@property (nonatomic) NSDictionary* dicPassedEventDetail;
@property (nonatomic) ShareCreator* shareCreatorInstance;
@property(nonatomic, strong) MemreasLocationViewController* vcLocation;
@property(nonatomic, strong) MemreasDetailGallery* vcGallery;
@property(nonatomic, strong) MemreasMediaDetail* vcDetail;

// IB Outlets
- (void) galleryMediaSelect:(id)gallery selectedMedia:(NSDictionary*)selectedDic andSelectedIndexPath:(NSIndexPath*)indexPath;
- (void)loadRecording:(BOOL)load;
- (void) loadRecording:(BOOL)load anddicEventMediaDetail:(NSDictionary*)dicPassed ;
- (void) showComments:(BOOL)display withComments:(NSArray*) arrComments andWithEventDetail:(NSDictionary*) dictEvent;
- (void) loadLocation:(BOOL)load;

// Segement indicator
+ (bool) fetchIsGallery;

// Commons
@property (weak, nonatomic) IBOutlet UISegmentedControl *segGalleryDetail;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@end

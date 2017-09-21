#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "MasterViewController.h"
@import GoogleMobileAds;

@class MyConstant;
@class WebServiceParser;
@class WebServices;
@class Util;
@class GridCell;
@class XMLParser;
@class ELCAsset;
@class MyConstant;
@class MyView;
@class AudioRecording;
@class RecordingVC;


@interface AddMediaViewController : UIViewController<GADBannerViewDelegate>{
    
    __weak IBOutlet UIView *mainView;
    __weak IBOutlet UIButton *btnCancel;
    __weak IBOutlet UIButton *btnNext;
    __weak IBOutlet GADBannerView *adView;
    __weak IBOutlet UIScrollView *scrForm;
    __weak IBOutlet UITextField *txtAddComment;
    __weak IBOutlet UIButton *btnSound;
    
    XMLParser *parser;
    ALAssetsLibrary *library;
    int firstMediaId;
    AudioRecording *audioRecording;
    BOOL recording;

    BOOL isAudioCommentAdded;
    BOOL isFirstTimeMedia;
    BOOL isGalleryLoading;
    CGPoint previouseContentOffSet;
}


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *snifferLoading;
@property (weak, nonatomic) IBOutlet UIView *viewLoading;
@property (nonatomic, strong) NSString *eventId;

@property (nonatomic,strong) NSMutableDictionary *selectedLocationDic;
@property (nonatomic,strong) NSMutableDictionary *dicPassed;





@end

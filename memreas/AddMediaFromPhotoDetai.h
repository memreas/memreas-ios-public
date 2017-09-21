#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MediaPlayer/MediaPlayer.h>
@import GoogleMobileAds;
#import "MasterViewController.h"

@class MyConstant;
@class WebServiceParser;
@class WebServices;
@class Util;
@class GridCell;
@class RecordingVC;
@class XMLParser;
@class ELCAsset;
@class MyConstant;
@class MyView;
@class MIOSDeviceDetails;
@class AudioRecording;

@interface AddMediaFromPhotoDetai : MasterViewController<AVAudioSessionDelegate,AVAudioRecorderDelegate,UIScrollViewDelegate,UITextFieldDelegate,GADBannerViewDelegate>
{
    __weak IBOutlet UIScrollView *scrForm;
    __weak IBOutlet UITextField *txtAddComment;
    __weak IBOutlet UIButton *btnSound;
    ALAssetsLibrary *library;
    BOOL recording;
    BOOL isAudioCommentAdded;
    AudioRecording *audioRecording;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;
@property (nonatomic, strong) NSMutableArray *assetAry,*selectedAssetsImages;
@property (nonatomic, strong) NSString *eventId;
@property (nonatomic, retain) NSMutableArray  *arrOnlyServerImages;
@property (nonatomic, retain) NSMutableArray *serverFileUploadArray;
@property(nonatomic, retain) NSMutableArray *eventMedias;


-(void)loadRecording:(BOOL)load;



@end

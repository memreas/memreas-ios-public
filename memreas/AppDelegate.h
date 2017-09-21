#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
@class AudioRecording;
@class ELCAsset;
@class MyConstant;
@class MyView;
@class NotificationsViewController;
@class QueueController;
@class Util;
@class XMLParser;
@class WebServiceParser;
@class WebServices;
@class Helper;
#import "MBProgressHUD.h"

@import GoogleMaps;
@import GooglePlaces;
@import Firebase;
@import FirebaseCore;


@interface AppDelegate : UIResponder
<
    UIApplicationDelegate,
    MBProgressHUDDelegate
>
{
    MBProgressHUD* progressView;
    NSDictionary* videoInfo;
    NSMutableData* responseData;
}

@property(strong, nonatomic) NSString* strDeviceToken;
@property(strong, nonatomic) NSString* currentView;
@property(strong, nonatomic) UIWindow* window;
@property(strong, nonatomic) NSMutableArray* uploadingFilesArray;
@property(strong, nonatomic) NSMutableArray* succedArray;
@property(strong, nonatomic) NSMutableArray* progressArray;
@property(strong, nonatomic) NSMutableArray* downloadURLArray;
@property(strong, nonatomic) NSMutableArray* dw_succedArray;
@property(strong, nonatomic) NSMutableArray* dw_progressArray;
@property(strong, nonatomic) NSMutableArray* pendingUploadingImages;
@property(strong, nonatomic) NSMutableArray* pendingDownloadingImages;
@property(strong, nonatomic) NSString* eventID;
@property(strong, nonatomic) NSString* firstMediaId;
@property(strong, nonatomic) NSString* comment;
@property(strong, nonatomic) NSString* audioID;
@property(strong, nonatomic) NSString* userId;
@property(strong, nonatomic) NSString* deviceUuid;
@property(strong, nonatomic) NSMutableArray* arrS3FilesArray;

@property BOOL isUploadPaused;
@property BOOL isDownloadPaused;
@property BOOL isAudioComment;
@property BOOL isTextComment;
@property BOOL isAddMemreasDetail;
@property int forAssetSize;
@property int uploadedfileCounter;
@property int currentIndex;
@property int dw_currentIndex;
@property int dw_downloadedFileCounter;
@property int completedUploaded;
@property int completedDownloaded;

@property(copy) void (^backgroundTransferSessionCompletionHandler)();

- (void)stopLoadingFromView;
- (void)startLoading;
- (void)stopLoading;

- (void)runOnMainWithoutDeadlocking:(void (^)(void))callbackBlock;
- (UIViewController *)topViewController;

@end

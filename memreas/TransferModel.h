@import UIKit;
@import Foundation;
@import Photos;
#import <AWSCore/AWSCore.h>
#import "AWSS3.h"
#import "TransferType.h"
#import "TransferState.h"
//#import "MNSURLSessionTask.h"
#import "MediaItem.h"
#import "TransferType.h"
#import "TransferState.h"

@class XMLGenerator;
@class WebServices;
@class MWebServiceHandler;
@class QueueController;
@class QueueUploadController;
@class QueueDownloadController;
@class AMGProgressView;
@class JSONUtil;
@class MediaIdManager;
@class Helper;
@class Util;

@interface TransferModel : NSOperation {
    BOOL executing;
    BOOL finished;
}

// Media related
@property(nonatomic) MediaItem* mediaItem;
@property(nonatomic) NSString* eventId;
@property(nonatomic) NSString* media_id;
@property(nonatomic) int is_profile_pic;
@property(nonatomic) int is_server_image;
@property(nonatomic) NSString* content_type;
@property(nonatomic) NSMutableDictionary* metadata;
@property(nonatomic) NSString* location;
@property(nonatomic) int tag;
@property(nonatomic) NSURL* mediaCopyURL;
@property(nonatomic) UIImage* thumbnail;

// Sync / S3 related
@property(nonatomic) NSString* s3file_name;  // file name
@property(nonatomic) NSString* s3Path;       // user_id
@property(nonatomic) NSURL* assetURL;
@property(nonatomic) TransferType transferType;
@property(nonatomic) TransferState transferState;

// Notification queue
@property(atomic, strong) NSOperationQueue *transferModelNotificationQueue;

// NSURLSessionTask (upload or download)
@property(atomic, strong) NSURLSessionUploadTask* nsurlSessionUploadTask;
@property(atomic, strong) NSURLSessionDownloadTask* nsurlSessionDownloadTask;
@property(atomic, strong) AWSTask* awsTask;

@property(nonatomic) NSUInteger taskIdentifier;
@property(nonatomic) float progress;
@property(nonatomic) NSString* progressText;
@property(nonatomic) bool isTransferComplete;


//Message related
@property(nonatomic) NSString* observerNameGenerateMediaIdMWS;
@property(nonatomic) NSString* observerNameAddMediaEventMWS;
@property(nonatomic) NSString* observerNameMediaDeviceTrackerFireMWS;
@property(nonatomic) NSString* observerNameMediaDeviceTrackerMWS;


@property(nonatomic) NSString* error;


// custom init
- (id)initWithMedia:(MediaItem*)mediaItem_
   withTransferType:(TransferType)transferType_
      andWiths3Path:s3Path_
 andWiths3file_name:s3file_name_;

- (void)copyMedia;
- (void)uploadMedia;
- (void)addMediaEventMWS;
- (void)restart;
- (void)completeOperation;
- (void) sendNotificationAndCompleteOperation;
- (void) updateMediaDeviceTrackerMWS:(NSNotification*)notification;

- (NSString*)getTransferTypeAsString;
- (NSString*)getTransferStateAsString;

@end

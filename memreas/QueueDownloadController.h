@import Foundation;
@class AppDelegate;
@class QueueController;
@class QueueController;
@class ALAssetsLibrary;
@class AWSManager;
@class XMLGenerator;
@class TransferModel;
@class QueueController;
@class JSONUtil;

@protocol QueueDownloadControllerDelegate
    - (void)updateDownloadProgressBar:(NSDictionary *)progressDict;
@end

@interface QueueDownloadController : NSObject  <NSURLSessionDelegate,
                                                NSURLSessionTaskDelegate,
                                                NSURLSessionDownloadDelegate,
                                                NSStreamDelegate>

@property(atomic, strong) NSURLSession* session;
@property(nonatomic, weak) NSObject<QueueDownloadControllerDelegate>* delegate;

+ (QueueDownloadController*)sharedInstance;
+ (void)resetSharedInstance;

@end

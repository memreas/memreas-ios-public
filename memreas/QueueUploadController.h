@import Foundation;
@class QueueController;
@class TransferModel;
@class AppDelegate;
@class AWSManager;
@class JSONUtil;

@protocol QueueUploadControllerDelegate
- (void)updateUploadProgressBar:(NSDictionary *)progressDict;
@end

@interface QueueUploadController : NSObject <NSURLSessionDelegate,
                                             NSURLSessionTaskDelegate,
                                             NSURLSessionDataDelegate>

@property(atomic, strong) NSURLSession* session;
@property(nonatomic, weak) NSObject<QueueUploadControllerDelegate>* delegate;

+ (QueueUploadController*)sharedInstance;
+ (void)resetSharedInstance;


@end

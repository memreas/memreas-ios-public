#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "Reachability1.h"
#import "MyConstant.h"
#import "MediaItem.h"
#import "TransferModel.h"
#import <AWSS3/AWSS3.h>


@protocol QueueControllerDelegate
//    - (void)startCaching
@end

@interface QueueController : NSObject

@property(nonatomic, weak) NSObject<QueueControllerDelegate>* delegate;
@property(atomic, strong) NSOperationQueue* pendingTransferQueue;
@property(atomic, strong)   NSMutableArray* pendingTransferArray;
@property(atomic, strong)   NSMutableArray* completedTransferArray;
@property(nonatomic) BOOL hasInitiatedBackground;

+ (QueueController*)sharedInstance;
+ (void)resetSharedInstance;

- (void)pauseUploading;
- (void)resumeUploading;
- (void)cancelTransferTask:(NSInteger)index;
- (void)cancelTransferTasks;

// For Sync Transfers
- (BOOL) hasPendingTransfers;
- (void)addToPendingTransferArray:(MediaItem*)mediaItem withTransferType:(TransferType)transferType;
- (MediaItem*) findMediaItemByMediaNamePrefix:(NSString*) mediaNamePrefix;
- (BOOL)removeFromPendingTransferArrayByMediaNamePrefix:(NSString *)mediaNamePrefix;
- (TransferModel*) findTransferOpByTaskIdentifier:(NSUInteger) taskIdentifier withTransferType:(TransferType) transferType;

@end


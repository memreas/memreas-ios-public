/**
 * Copyright (C) 2015 memreas llc. - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */
//
//  QueueController.m
//

#import "QueueController.h"
#import "MyConstant.h"


@implementation QueueController

static dispatch_once_t pred;
static QueueController *sharedInstance = nil;

- (id)init {
    if (self = [super init]) {
        ALog(@"QueueController::init");
        self.pendingTransferQueue = [[NSOperationQueue alloc] init];
        self.pendingTransferQueue.maxConcurrentOperationCount = 3;
        self.pendingTransferArray = [[NSMutableArray alloc] init];
        self.completedTransferArray = [[NSMutableArray alloc] init];
    }
    return self;
}

// Get the shared instance and create it if necessary.
+ (QueueController *)sharedInstance {
    dispatch_once(&pred, ^{
        ALog(@"QueueController::dispatch_once->YES");
        sharedInstance = [[QueueController alloc] init];
    });
    return sharedInstance;
}

+ (void)resetSharedInstance {
    sharedInstance = nil;
}

- (BOOL) hasPendingTransfers {
    if ((self.pendingTransferArray != nil) && (self.pendingTransferArray.count >0)) {
        ALog(@"QueueController::hasPendingTransfers->YES");
        return YES;
    }
    ALog(@"QueueController::hasPendingTransfers->NO");
    return NO;
}

//
// Add to queue transfer
//
- (void)addToPendingTransferArray:(MediaItem *)mediaItem
                 withTransferType:(TransferType)transferType {
    
    ALog(@"ENTER (void)addToPendingTransferArray:(MediaItem *)mediaItem withTransferType:(TransferType)transferType\n");
    if (self.pendingTransferArray == nil) {
        self.pendingTransferArray = [[NSMutableArray alloc] init];
    }
    if (self.completedTransferArray == nil) {
        self.completedTransferArray = [[NSMutableArray alloc] init];
    }
    // Create a transfer model
    NSUserDefaults *defaultUser = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [defaultUser valueForKey:@"UserId"];
    mediaItem.transferType = transferType;
    mediaItem.transferState = PENDING;
    TransferModel *transferModel =
    [[TransferModel alloc] initWithMedia:mediaItem
                        withTransferType:transferType
                           andWiths3Path:user_id
                      andWiths3file_name:mediaItem.mediaName];
    
    //
    // Add Pending Transfer Array
    //
    NSMutableDictionary* mediaItemDict = [[NSMutableDictionary alloc] init];
    [mediaItemDict setObject:mediaItem forKey:@"mediaItem"];
    [mediaItemDict setObject:mediaItem.mediaNamePrefix forKey:@"mediaNamePrefix"];
    [self.pendingTransferArray addObject:mediaItemDict];
    [self.pendingTransferQueue addOperation:transferModel];
    
    //
    // Update queue table view
    //
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:TRANSFER_QUEUE_VIEW_RELOAD object:nil];
    });
    
    ALog(@"addToPendingTransferArray::s3file_name::%@",mediaItem.mediaName);
    ALog(@"[self.pendingTransferArray addObject:transferModel] count::%@",@(self.pendingTransferArray.count));
    ALog(@"EXIT (void)addToPendingTransferArray:(MediaItem *)mediaItem withTransferType:(TransferType)transferType\n");
}

//
// Remove from Pending Transfer Array By Media Name Prefix
//
- (BOOL)removeFromPendingTransferArrayByMediaNamePrefix:(NSString *)mediaNamePrefix {
    @try {
    ALog(@"removeFromPendingTransferArrayByMediaNamePrefix:(NSString *)mediaNamePrefix...");
    for (int i=0; i<self.pendingTransferArray.count; i++) {
        ALog(@"removeFromPendingTransferArrayByMediaNamePrefix::about to get mediaItemDict");
        NSDictionary* mediaItemDict = self.pendingTransferArray[i];
        ALog(@"removeFromPendingTransferArrayByMediaNamePrefix::GOT--> mediaItemDict");
        NSString* entryMediaNamePrefix = [mediaItemDict objectForKey:@"mediaNamePrefix"];
        ALog(@"removeFromPendingTransferArrayByMediaNamePrefix::entryMediaNamePrefix-->%@", entryMediaNamePrefix);
        if ([mediaNamePrefix isEqualToString:entryMediaNamePrefix]) {
            ALog(@"removeFromPendingTransferArrayByMediaNamePrefix::mediaNamePrefix::%@",mediaNamePrefix);
            [self.pendingTransferArray removeObject:mediaItemDict];
            ALog(@"REMOVED---->removeFromPendingTransferArrayByMediaNamePrefix::mediaNamePrefix::%@",mediaNamePrefix);
            return YES;
        }
    }
    }@catch (NSException* exception) {
        ALog(@"removeFromPendingTransferArrayByMediaNamePrefix::EXCEPTION--->%@", exception.reason);
        //if not found move it onward
        return YES;
    }
    return NO;
}

/**
 * Web Service Response via notification here...
 */
/*
- (void)handleCompleteTransferModelMWS:(NSNotification*)notification {
    ALog(@"handleCompleteTransferModelMWS:(NSNotification*)notification...");
    @try {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary* mediaItemInfo = [notification userInfo];
            ALog(@"handleCompleteTransferModelMWS::mediaItemInfo::%@",mediaItemInfo);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:TRANSFER_QUEUE_DELETECOMPLETED object:self userInfo:mediaItemInfo];
        });
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}
 */

/* - For background processing ...
 - (BOOL)isTransferQueueProcessing {
 ALog(@"%s", __PRETTY_FUNCTION__);
 NSArray* transferOPs = [transferQueue operations];
 for (NSOperation* op in transferOPs) {
 if (op.isExecuting || op.isReady) {
 return YES;
 }
 }
 return NO;
 }
 */
/*
 - (BOOL)hasCancelledOpsForTransferQueueProcessing {
 ALog(@"%s", __PRETTY_FUNCTION__);
 NSArray* transferOPs = [transferQueue operations];
 for (NSOperation* op in transferOPs) {
 TransferModel* transferModel = (TransferModel*)op;
 if (transferModel.transferState == BACKGROUND_CANCELLED) {
 return YES;
 }
 }
 return NO;
 }
 */


//
// Pause / Resume / Cancel Section
//
- (void)pauseUploading {
    // pauseUploading
    @try {
        //
        // Pause operations in transit
        //
        TransferModel *transferModelInProcess;
        NSArray* operationsArray = self.pendingTransferQueue.operations;
        for (int i = 0; i < operationsArray.count; i++) {
            transferModelInProcess = (TransferModel*) operationsArray[i];
            ALog(@"TransferState: %@, TransferType: %@",
                 [transferModelInProcess getTransferStateAsString],
                 [transferModelInProcess getTransferTypeAsString]);
            if (
                (transferModelInProcess.transferType == UPLOAD) &&
                (
                 (transferModelInProcess.transferState == PENDING) ||
                 (transferModelInProcess.transferState == COPYING) ||
                 (transferModelInProcess.transferState == IN_PROGRESS)
                )
                )
            {
                
                [transferModelInProcess.nsurlSessionUploadTask suspend];
                transferModelInProcess.transferState = PAUSED;
                
                ALog(@"TransferState: %@, TransferType: %@, s3File_name:%@",
                     [transferModelInProcess getTransferStateAsString],
                     [transferModelInProcess getTransferTypeAsString], transferModelInProcess.s3file_name);
            } else if ((transferModelInProcess.transferType == DOWNLOAD) &&
                       (transferModelInProcess.transferState == IN_PROGRESS)) {
                [transferModelInProcess.nsurlSessionDownloadTask suspend];
                transferModelInProcess.transferState = PAUSED;
                ALog(@"TransferState: %@, TransferType: %@, s3File_name:%@",
                     [transferModelInProcess getTransferStateAsString],
                     [transferModelInProcess getTransferTypeAsString], transferModelInProcess.s3file_name);
            }
        }
        //
        // Pause operation queue
        //
        self.pendingTransferQueue.suspended = YES;
        
        //
        // Update view
        //
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:TRANSFER_QUEUE_VIEW_RELOAD object:self];
        });
        
    } @catch (NSException *exception) {
        ALog(@"%@", exception);
    }
}
- (void)resumeUploading {
    // resumeUploading
    @try {
        //
        // Uploads must be restarted, Downloads can resume...
        //
        TransferModel *transferModelInProcess;
        NSArray* operationsArray = self.pendingTransferQueue.operations;
        for (int i = 0; i < operationsArray.count; i++) {
            transferModelInProcess = (TransferModel*) operationsArray[i];
            if ((transferModelInProcess.transferType == UPLOAD) &&
                (transferModelInProcess.transferState == PAUSED)) {
                //
                // Uploads must be restarted
                //
                [transferModelInProcess restart];
                ALog(@"TransferState: %@, TransferType: %@, s3File_name:%@",
                     [transferModelInProcess getTransferStateAsString],
                     [transferModelInProcess getTransferTypeAsString], transferModelInProcess.s3file_name);
            } else if ((transferModelInProcess.transferType == DOWNLOAD) &&
                       (transferModelInProcess.transferState == PAUSED)) {
                //
                // Downloads can resume...
                //
                [transferModelInProcess.nsurlSessionDownloadTask resume];
                transferModelInProcess.transferState = RESUMED;
                ALog(@"TransferState: %@, TransferType: %@, s3File_name:%@",
                     [transferModelInProcess getTransferStateAsString],
                     [transferModelInProcess getTransferTypeAsString], transferModelInProcess.s3file_name);
            }
        }
        //
        // Pause operation queue
        //
        self.pendingTransferQueue.suspended = NO;
        
        //
        // Update view
        //
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:TRANSFER_QUEUE_VIEW_RELOAD object:self];
        });
    } @catch (NSException *exception) {
        ALog(@"%@", exception);
    }
}
- (void)cancelTransferTask:(NSInteger)index {
    @try {
        TransferModel *transferModelInProcess;
        NSArray* operationsArray = self.pendingTransferQueue.operations;
        transferModelInProcess = (TransferModel*) operationsArray[index];
        if (transferModelInProcess.transferType == UPLOAD) {
            ALog(@"transferModelInProcess.nsurlSessionUploadTask cancel");
            [transferModelInProcess.nsurlSessionUploadTask cancel];
        } else if (transferModelInProcess.transferType == DOWNLOAD) {
            ALog(@"transferModelInProcess.nsurlSessionDownloadTask cancel");
            [transferModelInProcess.nsurlSessionDownloadTask cancel];
        }
        transferModelInProcess.transferState = CANCELLED;
        [transferModelInProcess cancel];
        ALog(@"cancelTransferTask ---> TransferState: %@, TransferType: %@",
             [transferModelInProcess getTransferStateAsString],
             [transferModelInProcess getTransferTypeAsString]);
        
        //
        // - complete operation sends notification to delete row
        //
        [transferModelInProcess sendNotificationAndCompleteOperation];
        
    } @catch (NSException *exception) {
        ALog(@"%@", exception);
    }
}

- (void)cancelTransferTasks {
    @try {
        TransferModel *transferModelInProcess;
        NSArray* operationsArray = self.pendingTransferQueue.operations;
        for (int i = 0; i < operationsArray.count; i++) {
            transferModelInProcess = (TransferModel*) operationsArray[i];
            if (transferModelInProcess.transferType == UPLOAD) {
                ALog(@"transferModelInProcess.nsurlSessionDownloadTask cancel row::%@", @(i));
                [transferModelInProcess.nsurlSessionUploadTask cancel];
            } else if (transferModelInProcess.transferType == DOWNLOAD) {
                ALog(@"transferModelInProcess.nsurlSessionDownloadTask cancel row::%@", @(i));
                [transferModelInProcess.nsurlSessionDownloadTask cancel];
            }
            transferModelInProcess.transferState = CANCELLED;
            [transferModelInProcess cancel];
            ALog(@"cancelTransferTasks ----> TransferState: %@, TransferType: %@",
                 [transferModelInProcess getTransferStateAsString],
                 [transferModelInProcess getTransferTypeAsString]);
            
            //
            // - complete operation sends notification to delete row
            //
            [transferModelInProcess sendNotificationAndCompleteOperation];

        } // end for
    } @catch (NSException *exception) {
        ALog(@"%@", exception);
    }
}

//
// Find Transfer op
//
-(TransferModel*) findTransferOpByTaskIdentifier:(NSUInteger) taskIdentifier withTransferType:(TransferType) transferType {
    TransferModel* transferModel;
    for (int i=0; i<self.pendingTransferQueue.operations.count; i++) {
        if (transferModel.transferType == UPLOAD) {
            if (transferModel.taskIdentifier == taskIdentifier) {
                return transferModel;
            }
        } else if (transferModel.transferType == DOWNLOAD) {
            if (transferModel.taskIdentifier == taskIdentifier) {
                return transferModel;
            }
        }
    }
    return nil;
}

-(MediaItem*) findMediaItemByMediaNamePrefix:(NSString*) mediaNamePrefix {
    NSDictionary* mediaItemDict;
    for (int i=0; i<self.pendingTransferArray.count; i++) {
        mediaItemDict = self.pendingTransferArray[i];
        NSString* currentMediaNamePrefix = [mediaItemDict objectForKey:@"mediaNamePrefix"];
        if ([currentMediaNamePrefix isEqualToString:mediaNamePrefix]) {
            return [mediaItemDict objectForKey:@"mediaItem"];
        }
    }
    return nil;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

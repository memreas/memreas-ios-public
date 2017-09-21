#import "AppDelegate.h";
#import "QueueDownloadController.h"
#import "AWSManager.h"
#import "TransferState.h"
#import "XMLGenerator.h"
#import "TransferModel.h"
#import "QueueController.h"
#import "JSONUtil.h"


@implementation QueueDownloadController {
    TransferModel* currentTransferModel;
    AppDelegate* appDelegate;
    AWSManager* aws;
    QueueController* queueController;
}

static QueueDownloadController *sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (QueueDownloadController *)sharedInstance {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[QueueDownloadController alloc]init];
        }
    }
    return sharedInstance;
}

+ (void)resetSharedInstance {
    @synchronized(self) {
        sharedInstance = nil;
    }
}


- (id)init {
    if (self = [super init]) {
        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        aws = [AWSManager sharedInstance];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"transferDownloadQueue"];
        configuration.sessionSendsLaunchEvents = YES;
        configuration.discretionary = YES;
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    return self;
}

//
// NSURLSessionDelegate -
//
- (void)URLSession:(NSURLSession *)session
didBecomeInvalidWithError:(NSError *)error {
    ALog(@"didBecomeInvalidWithError::%@", error);
}

//
// NSURLSession is finished
//
- (void)URLSessionDidFinishEventsForBackgroundURLSession:
(NSURLSession *)session {
    // Let the NSURLSession finish - we'll reset
    appDelegate =
    (AppDelegate *)[UIApplication sharedApplication]
    .delegate;
    if (appDelegate.backgroundTransferSessionCompletionHandler) {
        void (^completionHandler)() =
        appDelegate.backgroundTransferSessionCompletionHandler;
        appDelegate.backgroundTransferSessionCompletionHandler = nil;
        completionHandler();
    }
}



//
// Download section - progress
//
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    @try {
        NSMutableDictionary* transferModelDict = (NSMutableDictionary*) [JSONUtil convertToMutableID:downloadTask.taskDescription];
        //ALog(@"didWriteData::transferModelDict::%@", transferModelDict);
        
        float current_progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        
        int rounded_current_progress = (int)(current_progress * 100);
        NSNumber* last_progress = (NSNumber*) [transferModelDict objectForKey:@"last_progress"];
        int stored_progress = [last_progress intValue];
        if (rounded_current_progress > stored_progress) {
            // Update progress bar
            NSString* progressText = [NSString
                                      stringWithFormat:@"%d%%",
                                      rounded_current_progress];
            [transferModelDict setObject:[NSNumber numberWithFloat:rounded_current_progress] forKey:@"last_progress"];
            [transferModelDict setObject:[NSNumber numberWithFloat:current_progress] forKey:@"current_progress"];
            [transferModelDict setObject:progressText forKey:@"progressText"];
            downloadTask.taskDescription = [JSONUtil convertFromNSDictionary:transferModelDict];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate updateDownloadProgressBar:transferModelDict];
            });
            
        }
    } @catch (NSException *exception) {
        ALog(@"%s exception: %@", __PRETTY_FUNCTION__, exception);
    }
}

//
// Download completion
//
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    
    @try {
        //TransferModel* transferModel;
        NSMutableDictionary* transferModelDict = (NSMutableDictionary*) [JSONUtil convertToMutableID:downloadTask.taskDescription];
        
        //
        // Checking file size
        //
        NSNumber *fileSizeValue = nil;
        NSError *fileSizeError = nil;
        [location getResourceValue:&fileSizeValue
                            forKey:NSURLFileSizeKey
                             error:&fileSizeError];
        if (fileSizeValue) {
            ALog(@"value for %@ is %@", location, fileSizeValue);
        }
        else {
            ALog(@"error getting size for url %@ error was %@", location, fileSizeError);
        }
        
        // Create a NSFileManager instance
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // Get the documents directory URL
        NSArray *documentURLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        NSURL *documentsDirectory = [documentURLs firstObject];
        
        // Get the file name and create a destination URL
        NSURL* mediaCopyURL = [documentsDirectory URLByAppendingPathComponent:[transferModelDict objectForKey:@"s3file_name"]];
        [transferModelDict setObject:[mediaCopyURL copy] forKey:@"mediaCopyURL"];
        
        //
        // Use fileManager to move url - NSData caused app to crash
        //
        NSError* error;
        BOOL success = NO;
        if ([fileManager moveItemAtURL:location toURL:mediaCopyURL error:&error])
        {
            ALog(@"It worked");
            //
            // Checking file size
            //
            NSNumber *fileSizeValue = nil;
            NSError *fileSizeError = nil;
            [mediaCopyURL getResourceValue:&fileSizeValue
                                    forKey:NSURLFileSizeKey
                                     error:&fileSizeError];
            
            //
            // - Debugging only - check file sizes for match
            //
            //if (fileSizeValue) {
            //    ALog(@"value for %@ is %@", mediaCopyURL, fileSizeValue);
            //}
            //else {
            //    ALog(@"error getting size for url %@ error was %@", mediaCopyURL, fileSizeError);
            //}
            //
            success = YES;
        }
        else
        {
            ALog(@"An error occurred");
            success = NO;
        }
        
        if (success) {
            //
            // Now add to Camera Roll via PHAssetChangeRequest
            //
            NSString* mediaType = [transferModelDict objectForKey:@"mediaType"];
            if ([mediaType isEqualToString:@"video"]) {
                //
                // Add Video Asset
                //
                ALog(@"dispatch add image asset");
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    __block NSError* error;
                    __block PHObjectPlaceholder* assetPlaceholder;
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        ALog(@"[transferModelDict objectForKey:@mediaCopyURL]::%@",[transferModelDict objectForKey:@"mediaCopyURL"]);
                        PHAssetChangeRequest *createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[transferModelDict objectForKey:@"mediaCopyURL"]];
                        createAssetRequest.creationDate = [NSDate date];
                        assetPlaceholder = createAssetRequest.placeholderForCreatedAsset;
                        
                    } completionHandler:^(BOOL success, NSError *error) {
                        
                        NSNumber* transferState;
                        if (success) {
                            [transferModelDict setObject:assetPlaceholder.localIdentifier forKey:@"mediaLocalIdentifier"];
                            transferState = [NSNumber numberWithInteger:COMPLETED];
                        } else {
                            transferState = [NSNumber numberWithInteger:FAILED];
                            ALog(@"error in saving to camera roll:::%@", error.localizedDescription);
                        }
                        
                        //
                        // Send Notification to fire mediaDeviceTrackerMWS and complete the transfer model
                        //
                        ALog(@"asset created... mediaLocalIdentifier::%@", [transferModelDict objectForKey:@"mediaLocalIdentifier"]);
                        NSDictionary* mediaDeviceMWSDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:downloadTask.taskIdentifier],@"taskIdentifier",
                                                            [transferModelDict objectForKey:@"mediaLocalIdentifier"],@"mediaLocalIdentifier",
                                                            [NSNumber numberWithInteger:COMPLETED], @"transferState",
                                                            nil];
                        
                        //
                        // Call MediaDeviceTracker
                        //
                        NSString* observerNameMediaDeviceTrackerFireMWS = [NSString stringWithFormat:@"%@_%@", MEDIADEVICETRACKER, [transferModelDict objectForKey:@"mediaNamePrefix"]];
                        [[NSNotificationCenter defaultCenter] postNotificationName:observerNameMediaDeviceTrackerFireMWS object:self userInfo:mediaDeviceMWSDict];
                        ALog(@"video asset created... assetPlaceholder.localIdentifier::%@",assetPlaceholder.localIdentifier);
                    }];
                });
            } else if ([mediaType
                        isEqualToString:@"image"]) {
                //
                // Add Image Asset
                //
                ALog(@"dispatch add image asset");
                dispatch_async(dispatch_get_main_queue(), ^{
                    __block NSError* error;
                    __block PHObjectPlaceholder* assetPlaceholder;
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        ALog(@"[transferModelDict objectForKey:@mediaCopyURL]::%@",[transferModelDict objectForKey:@"mediaCopyURL"]);
                        PHAssetChangeRequest *createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:[transferModelDict objectForKey:@"mediaCopyURL"]];
                        createAssetRequest.creationDate = [NSDate date];
                        assetPlaceholder = createAssetRequest.placeholderForCreatedAsset;
                        
                    } completionHandler:^(BOOL success, NSError *error) {
                        
                        NSNumber* transferState;
                        if (success) {
                            [transferModelDict setObject:assetPlaceholder.localIdentifier forKey:@"mediaLocalIdentifier"];
                            transferState = [NSNumber numberWithInteger:COMPLETED];
                        } else {
                            transferState = [NSNumber numberWithInteger:FAILED];
                        }
                        
                        //
                        // Send Notification to fire mediaDeviceTrackerMWS and complete the transfer model
                        //
                        NSDictionary* mediaDeviceMWSDict = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber numberWithInteger:downloadTask.taskIdentifier] copy],@"taskIdentifier",
                                                            [[transferModelDict objectForKey:@"mediaLocalIdentifier"] copy],@"mediaLocalIdentifier",
                                                            [[NSNumber numberWithInteger:COMPLETED] copy], @"transferState",
                                                            nil];
                        
                        //
                        // Call MediaDeviceTracker
                        //
                        NSString* observerNameMediaDeviceTrackerFireMWS = [NSString stringWithFormat:@"%@_%@", MEDIADEVICETRACKER, [transferModelDict objectForKey:@"mediaNamePrefix"]];
                        [[NSNotificationCenter defaultCenter] postNotificationName:observerNameMediaDeviceTrackerFireMWS object:self userInfo:mediaDeviceMWSDict];
                        ALog(@"image asset created... assetPlaceholder.localIdentifier::%@",assetPlaceholder.localIdentifier);
                    }];
                });
            }
        }
    } @catch (NSException *exception) {
        ALog(@"%s exception: %@", __PRETTY_FUNCTION__, exception);
        //
        // Finalize Operation if error
        //
        //transferModel.transferState = FAILED;
        //[transferModel completeOperation];
    }
}

//
// Download transfer completed
//
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    
    //
    // Move transfer model, mark complete, and remove tempfile even if error
    //
    NSMutableDictionary* transferModelDict = (NSMutableDictionary*) [JSONUtil convertToMutableID:task.taskDescription];
    if (error) {
        NSURL* mediaCopyURL = [transferModelDict objectForKey:@"mediaCopyURL"];
        
        [transferModelDict setObject:[NSNumber numberWithBool:YES] forKey:@"isTransferComplete"];
        [transferModelDict setObject:[NSNumber numberWithInteger:FAILED] forKey:@"transferState"];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:[mediaCopyURL absoluteString]]) {
            NSError* error;
            [[NSFileManager defaultManager] removeItemAtURL:mediaCopyURL
                                                      error:&error];
        } else {
            //do nothing - must have been released
        }
        //
        // Save the JSON back to the taskDescription
        //
        task.taskDescription = [JSONUtil convertFromNSDictionary:transferModelDict];
        
        //
        // Finalize operation
        //
        NSDictionary* mediaDeviceMWSDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:task.taskIdentifier],@"taskIdentifier",
                                            [transferModelDict objectForKey:@"mediaLocalIdentifier"],@"mediaLocalIdentifier",
                                            [NSNumber numberWithInteger:FAILED], @"transferState",
                                            nil];
        NSString* observerNameMediaDeviceTrackerFireMWS = [NSString stringWithFormat:@"%@_%@", MEDIADEVICETRACKER, [transferModelDict objectForKey:@"mediaNamePrefix"]];
        ALog(@"didCompleteWithError::[[NSNotificationCenter defaultCenter] postNotificationName:%@ object:self userInfo:mediaDeviceMWSDict];", observerNameMediaDeviceTrackerFireMWS);
        [[NSNotificationCenter defaultCenter] postNotificationName:observerNameMediaDeviceTrackerFireMWS object:self userInfo:mediaDeviceMWSDict];
    }
    
} // end URLSession:session:task:error




@end;

#import "QueueUploadController.h"
#import "QueueController.h"
#import "TransferModel.h"
#import "AppDelegate.h"
#import "AWSManager.h"
#import "JSONUtil.h"

@implementation QueueUploadController{
    AppDelegate* appDelegate;
    AWSManager* aws;
}

static QueueUploadController *sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (QueueUploadController *)sharedInstance {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[QueueUploadController alloc] init];
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
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"transferUploadQueue"];
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
// Handle background transfers
//
- (void)application:(UIApplication *)application
handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)(void))completionHandler {
    ALog(@"handleEventsForBackgroundURLSession recieved identifier:%@",
          identifier);
    // call completion handler when you're done
    appDelegate.backgroundTransferSessionCompletionHandler = nil;
    completionHandler();
}



//
// NSURLSessionDataDelegate : didReceiveData
//
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
}

//
// Upload transfer in progress
//
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionUploadTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    @try {
        NSMutableDictionary* transferModelDict = (NSMutableDictionary*) [JSONUtil convertToMutableID:task.taskDescription];
        ALog(@"didWriteData::transferModelDict::%@", transferModelDict);
        
        float current_progress = (double)totalBytesSent / (double)totalBytesExpectedToSend;
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
            task.taskDescription = [JSONUtil convertFromNSDictionary:transferModelDict];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate updateUploadProgressBar:transferModelDict];
            });
            
        }
    } @catch (NSException *exception) {
        ALog(@"%s exception: %@", __PRETTY_FUNCTION__, exception);
    }
}

//
// Upload transfer completed
//
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    
    //
    // Move transfer model, mark complete, and remove tempfile even if error
    //
    // check if file exists and release
    NSMutableDictionary* transferModelDict = (NSMutableDictionary*) [JSONUtil convertToMutableID:task.taskDescription];
    if (!error) {
        NSString* s3file_name = [transferModelDict objectForKey:@"s3file_name"];
        NSString* observerNameAddMediaEventMWS = [NSString stringWithFormat:@"%@_%@", ADDMEDIAEVENT, s3file_name];
        //
        // Call web service to store entry in db
        //
        ALog(@"if (!error) ---> URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error...");
        [[NSNotificationCenter defaultCenter] postNotificationName:observerNameAddMediaEventMWS object:self];
    } else {
        // do nothing - it's a temp directory so complete the task and call the ws
        ALog(@"if (error) ---> URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error...");
    }
} // end URLSession:session:task:error



@end


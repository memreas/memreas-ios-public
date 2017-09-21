#import "TransferModel.h"
#import "XMLGenerator.h"
#import "WebServices.h"
#import "MWebServiceHandler.h"
#import "QueueController.h"
#import "QueueUploadController.h"
#import "QueueDownloadController.h"
#import "AMGProgressView.h"
#import "JSONUtil.h"
#import "MediaIdManager.h"
#import "Helper.h"
#import "Util.h"

@implementation TransferModel{
    QueueController* queueController;
    QueueUploadController* queueUploadController;
    QueueDownloadController* queueDownloadController;
}

- (id)init {
    self = [super init];
    if (self) {
        executing = NO;
        finished = NO;
    }
    return self;
}

- (id)initWithMedia:(MediaItem*)mediaItem_
   withTransferType:(TransferType)transferType_
      andWiths3Path:s3Path_
 andWiths3file_name:s3file_name_ {
    self = [self init];
    
    ALog(@"::mediaItem_.mediaId::%@::s3file_name_::%@", mediaItem_.mediaId, mediaItem_.mediaName);
    
    //
    // Setup queue for notifications to avoid deadlock by posting to current thread
    //
    self.transferModelNotificationQueue = [NSOperationQueue mainQueue];
    
//    ALog(@"TransferModel::::[NSThread currentThread]::%@ :: [[NSThread currentThread] threadDictionary]::%@", [NSThread currentThread], [[NSThread currentThread] threadDictionary]);
    queueController = [QueueController sharedInstance];
    queueUploadController = [QueueUploadController sharedInstance];
    queueDownloadController = [QueueDownloadController sharedInstance];
    self.mediaItem = mediaItem_;
    self.transferType = transferType_;
    self.s3Path = s3Path_;
    self.s3file_name = s3file_name_;
    if (self.transferType == UPLOAD) {
        self.content_type = self.mediaItem.mimeType;
    } else if (self.transferType == DOWNLOAD) {
        self.content_type = self.mediaItem.mimeType;
        self.media_id = self.mediaItem.mediaId;
    }
    self.transferState = PENDING;
    if (self.transferType == UPLOAD) {
        self.thumbnail = [self fetchThumbnail];
        
        /**
         * Set Observer for addmediaevent web service request...
         */
        self.observerNameAddMediaEventMWS =
        [NSString stringWithFormat:@"%@_%@", ADDMEDIAEVENT,
         self.s3file_name];
        [[NSNotificationCenter defaultCenter] addObserverForName:self.observerNameAddMediaEventMWS object:nil
                                                           queue:self.transferModelNotificationQueue usingBlock:^(NSNotification *note) {
                                                               [self addMediaEventMWS];
                                                           }];
        
        /**
         * Set Observer for addmediaevent web service response...
         */
        self.observerNameAddMediaEventMWS =
        [NSString stringWithFormat:@"%@_%@", ADDMEDIAEVENT_RESULT_NOTIFICATION,
         self.s3file_name];
        [[NSNotificationCenter defaultCenter] addObserverForName:self.observerNameAddMediaEventMWS object:nil
                                                           queue:self.transferModelNotificationQueue usingBlock:^(NSNotification *note) {
                                                               [self handleAddMediaEventMWS:note];
                                                           }];
    } else if (self.transferType == DOWNLOAD) {
        /**
         * Add Observer to update media device tracker
         */
        self.observerNameMediaDeviceTrackerFireMWS =
        [NSString stringWithFormat:@"%@_%@", MEDIADEVICETRACKER,
         self.mediaItem.mediaNamePrefix];
        //ALog(@"updateMediaDeviceTrackerMWS::observerNameMediaDeviceTrackerFireMWS------------------------------>%@",self.observerNameMediaDeviceTrackerFireMWS);
        [[NSNotificationCenter defaultCenter] addObserverForName:self.observerNameMediaDeviceTrackerFireMWS object:nil
                                                           queue:self.transferModelNotificationQueue usingBlock:^(NSNotification *note) {
                                                               [self updateMediaDeviceTrackerMWS:note];
                                                           }];
        
        
        /**
         * Add Observer for to receive media device track response
         */
        self.observerNameMediaDeviceTrackerMWS =
        [NSString stringWithFormat:@"%@_%@", MEDIADEVICETRACKER_RESULT_NOTIFICATION,
         self.mediaItem.mediaNamePrefix];
        //ALog(@"mediadevicetrackerMWSHandlerComplete::observerNameMediaDeviceTrackerMWS------------------------------>%@",self.observerNameMediaDeviceTrackerMWS);
        [[NSNotificationCenter defaultCenter] addObserverForName:self.observerNameMediaDeviceTrackerMWS object:nil
                                                           queue:self.transferModelNotificationQueue usingBlock:^(NSNotification *note) {
                                                               [self mediadevicetrackerMWSHandlerComplete:note];
                                                           }];
        
    }
    
    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
    self.mediaItem.deviceId = [pref objectForKey:@"device_id"];
    self.mediaItem.deviceType = DEVICE_TYPE;
    self.progressText = @"pending...";
    
    return self;
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return executing;
}

- (BOOL)isFinished {
    return finished;
}

- (void)start {
    // Always check for cancellation before launching the task.
    if ([self isCancelled]) {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        self.transferState = BACKGROUND_CANCELLED;
//        ALog(@"transferModel cancelled for filename:%@", self.s3file_name);
        [self didChangeValueForKey:@"isFinished"];
        
//        ALog(@"exit TransferState: %@, TransferType: %@", [self getTransferStateAsString], [self getTransferTypeAsString]);
        
        return;
    }
    
    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main)
                             toTarget:self
                           withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
//    ALog(@"exit TransferState: %@, TransferType: %@", [self getTransferStateAsString], [self getTransferTypeAsString]);
}

- (void)main {
    @try {
        if ([self isCancelled]) return;
        if ([self isUpload]) {
            // change state
            self.mediaItem.mediaState = IN_TRANSIT;
            
            if (self.mediaItem.hasShootNSData) {
                self.media_id = self.mediaItem.mediaId;
            }
            [self copyMedia];
//            ALog(@"TransferState: %@, TransferType: %@, s3file_name: %@", [self getTransferStateAsString], [self getTransferTypeAsString], self.s3file_name);
        } else {
            self.mediaItem.mediaState = IN_TRANSIT;
            [self downloadMedia];
//            ALog(@"TransferState: %@, TransferType: %@, s3file_name: %@", [self getTransferStateAsString], [self getTransferTypeAsString], self.s3file_name);
        }
    } @catch (NSException* exception) {
        //
        // Complete Operation if error
//        ALog(@"TransferState: %@, TransferType: %@, s3file_name: %@", [self getTransferStateAsString], [self getTransferTypeAsString], self.s3file_name);
        //
        [self sendNotificationAndCompleteOperation];
    }
}


//
// Uploads must restart so start task
//
- (void)restart {
    self.transferState = PENDING;
    [self.nsurlSessionUploadTask cancel];
    self.nsurlSessionUploadTask = nil;
//    ALog(@"TransferState: %@, TransferType: %@, s3file_name: %@", [self getTransferStateAsString], [self getTransferTypeAsString], self.s3file_name);
    [self uploadMedia];
}


- (void)completeOperation {
    if ([self isCancelled]) {
//        ALog(@"if ([self isCancelled])::TransferState: %@, TransferType: %@, s3file_name: %@", [self getTransferStateAsString], [self getTransferTypeAsString], self.s3file_name);
        //return;
        
    }
    if ((self.transferState == COMPLETED) || (self.transferState == FAILED) || (self.transferState == CANCELLED)) {
//        ALog(@"if ((self.transferState == COMPLETED) || (self.transferState == FAILED) || (self.transferState == CANCELLED))::TransferState: %@, TransferType: %@, s3file_name: %@", [self getTransferStateAsString], [self getTransferTypeAsString], self.s3file_name);
        [self willChangeValueForKey:@"isFinished"];
        [self willChangeValueForKey:@"isExecuting"];
        
        executing = NO;
        finished = YES;
        
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
//        ALog(@"TransferState: %@, TransferType: %@, s3file_name: %@", [self getTransferStateAsString], [self getTransferTypeAsString], self.s3file_name);
    }
}


- (UIImage*)fetchThumbnail {
    __block UIImage* image;
    PHImageManager* manager = [PHImageManager defaultManager];
    if ([[self.mediaItem.mediaType lowercaseString] isEqualToString:@"video"]) {
        //
        // video thumbnail
        //
        __block AVAsset* asset;
        [manager requestAVAssetForVideo:self.mediaItem.mediaLocalPHAsset
                                options:nil
                          resultHandler:^(AVAsset* avAsset, AVAudioMix* audioMix,
                                          NSDictionary* info) {
                              asset = avAsset;
                          }];
        
        AVAssetImageGenerator* generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        NSError* error = NULL;
        CMTime time = CMTimeMake(1, 65);
        CGImageRef refImg = [generateImg copyCGImageAtTime:time actualTime:NULL error:&error];
        image = [[UIImage alloc] initWithCGImage:refImg];
    } else {
        //
        // image thumbnail
        //
        [manager requestImageDataForAsset:self.mediaItem.mediaLocalPHAsset
                                  options:nil
                            resultHandler:^(NSData* imageData, NSString* dataUTI,
                                            UIImageOrientation orientation,
                                            NSDictionary* info){
                            }];
        [manager requestImageForAsset:self.mediaItem.mediaLocalPHAsset
                           targetSize:CGSizeMake(100, 100)
                          contentMode:PHImageContentModeAspectFill
                              options:nil
                        resultHandler:^(UIImage* result, NSDictionary* info) {
                            image = result;
                        }];
    }
    return image;
}


//
// Upload section
//
- (void)copyMedia {
    if ([self isCancelled]){
        [self completeOperation];
        return;
    }
    
    // Update status and start copy
    self.transferState = COPYING;
    if (self.transferState != BACKGROUND_CANCELLED) {
        self.progressText = @"preparing...";
    } else {
        self.progressText = @"restarting...";
    }
    
    NSMutableDictionary* transferModelDict = [[NSMutableDictionary alloc] init];
    [transferModelDict setObject:[NSNumber numberWithFloat:0] forKey:@"last_progress"];
    [transferModelDict setObject:[NSNumber numberWithFloat:0] forKey:@"current_progress"];
    [transferModelDict setObject:self.progressText forKey:@"progressText"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [queueUploadController.delegate updateUploadProgressBar:transferModelDict];
    });
    
    PHImageManager* manager = [PHImageManager defaultManager];
    if ([self.mediaItem.mediaType isEqualToString:@"video"]) {
        //
        // Handle Video Copy
        //
        __block AVAsset* avAsset;
        [manager requestAVAssetForVideo:self.mediaItem.mediaLocalPHAsset
                                options:nil
                          resultHandler:^(AVAsset* asset, AVAudioMix* audioMix,
                                          NSDictionary* info) {
                              avAsset = asset;
                              
                              // Debugging metadata of video
                              //ALog(@"started copyMedia for self.s3file_name::%@ requestAVAssetForVideo::info::%@", self.s3file_name, info);
                              
                              // Set location
                              self.location =
                              [NSString stringWithFormat:@"{ \"latitude\" : %f, \"longitude\" : %f }",
                               self.mediaItem.mediaLocalPHAsset.location
                               .coordinate.latitude,
                               self.mediaItem.mediaLocalPHAsset.location
                               .coordinate.longitude];
                              
                              // Check if file exists
                              NSURL* tmpMediaHolder = [NSURL
                                                       fileURLWithPath:[NSTemporaryDirectory()
                                                                        stringByAppendingPathComponent:self.s3file_name]];
                              self.mediaCopyURL = tmpMediaHolder;
                              
                              // check if file exists and release
                              if ([[NSFileManager defaultManager] fileExistsAtPath:tmpMediaHolder.path]) {
                                  NSError* error;
                                  [[NSFileManager defaultManager] removeItemAtURL:tmpMediaHolder
                                                                            error:&error];
                              }
                              
                              AVAssetExportSession* exporter;
                              if ([[self.content_type lowercaseString] containsString:@"mp4"]) {
                                  exporter = [[AVAssetExportSession alloc]
                                              initWithAsset:avAsset
                                              presetName:AVAssetExportPresetPassthrough];
                                  exporter.outputFileType = AVFileTypeMPEG4;
                              } else {
                                  exporter = [[AVAssetExportSession alloc]
                                              initWithAsset:avAsset
                                              presetName:AVAssetExportPresetHighestQuality];
                                  exporter.outputFileType = AVFileTypeQuickTimeMovie;
                              }
                              exporter.outputURL = self.mediaCopyURL;
                              exporter.shouldOptimizeForNetworkUse = YES;
                              [exporter exportAsynchronouslyWithCompletionHandler:^{
                                  if ([exporter status] == AVAssetExportSessionStatusCompleted) {
                                      //
                                      // On completion of copy fetch media_id
                                      //
                                      if (self.mediaItem.copyright == nil) {
                                          //
                                          // On completion of copy fetch media_id if it doesn't exists
                                          //
                                          //ALog(@"started copyMedia for self.s3file_name::%@ requestAVAssetForVideo::info::%@", self.s3file_name, info);
                                          //ALog(@"finished copyMedia for filename:%@", self.s3file_name);
                                          self.media_id = [[MediaIdManager sharedInstance] fetchNextMediaId];
                                          [self uploadMedia];
                                      } else {
                                          //
                                          // we have the media_id already in copyright so upload
                                          //
                                          //ALog(@"finished copyMedia for filename:%@", self.s3file_name);
                                          self.media_id = [self.mediaItem.copyright objectForKey:@"media_id"];
                                          [self uploadMedia];
                                      }
                                      
                                  } else if ([exporter status] == AVAssetExportSessionStatusFailed) {
                                      //ALog(@"Export failed: %@", [[exporter error] localizedDescription]);
                                  } else if ([exporter status] == AVAssetExportSessionStatusCancelled) {
                                      //ALog(@"Export cancelled");
                                  }
                              }];  //avassetexporter
                          }]; // reqeustavasset
    } else if ([self.mediaItem.mediaType isEqualToString:@"image"]) {
        //
        // Handle Image Copy and upload for image
        //
        __block NSData* imageNSData;
        PHImageRequestOptions* imageRequestOptions =
        [[PHImageRequestOptions alloc] init];
        imageRequestOptions.synchronous = YES;
        [manager requestImageDataForAsset:self.mediaItem.mediaLocalPHAsset
                                  options:imageRequestOptions
                            resultHandler:^(NSData* imageData, NSString* dataUTI,
                                            UIImageOrientation orientation,
                                            NSDictionary* info) {
                                imageNSData = imageData;
                                //ALog(@"requestImageDataForAsset::info---->%@", info);
                                
                                //
                                // Must keep folow on code within block for serial processing
                                //
                                // Sample json for location accepted by server - address is optional
                                //
                                //"location": {
                                //    "address": "Senator Speno Memorial Park, 745 E Meadow Ave, East
                                //    Meadow, NY 11554",
                                //    "latitude": 40.707591,
                                //    "longitude": -73.548002
                                //},
                                self.location =
                                [NSString stringWithFormat:@"{ \"latitude\" : %f, \"longitude\" : %f }",
                                 self.mediaItem.mediaLocalPHAsset.location
                                 .coordinate.latitude,
                                 self.mediaItem.mediaLocalPHAsset.location
                                 .coordinate.longitude];
                                
                                //ALog(@"image location---->%@", self.location);
                                
                                self.mediaCopyURL = [NSURL
                                                     fileURLWithPath:[NSTemporaryDirectory()
                                                                      stringByAppendingPathComponent:self.s3file_name]];
                                //Fix Rotation - jpeg only...
                                NSString* mimeType = [self contentTypeForImageData:imageNSData];
                                if ([mimeType isEqualToString:@"image/jpeg"]) {
                                    UIImage *image = [UIImage imageWithData:imageNSData];
                                    image = [self fixrotation:image];
                                    imageNSData = UIImageJPEGRepresentation(image, 1.0);
                                    //NSData *imageData = UIImagePNGRepresentation(image);
                                }

                                // write to file...
                                [imageNSData writeToFile:self.mediaCopyURL.path atomically:YES];
                                if ([[NSFileManager defaultManager]
                                     fileExistsAtPath:self.mediaCopyURL.path]) {
                                    if (self.mediaItem.copyright == nil) {
                                        //
                                        // On completion of copy fetch media_id if it doesn't exists
                                        //
                                        self.media_id = [[MediaIdManager sharedInstance] fetchNextMediaId];
                                        [self uploadMedia];
                                    } else {
                                        
                                        //Debugging
                                        //unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:self.mediaCopyURL.path error:nil] fileSize];
                                        //ALog(@"fileSize::%llu",fileSize);
                                        
                                        //
                                        // we have the media_id already in copyright so upload
                                        //
                                        self.media_id = [self.mediaItem.copyright objectForKey:@"media_id"];
                                        [self uploadMedia];
                                    }
                                    
                                } else {
                                    NSString* error = [NSString
                                                       stringWithFormat:
                                                       @"error copying image media - file at path: %@ does not exist.",
                                                       self.mediaCopyURL.path];
                                    //ALog(@"error copying image media - file at path: %@ does not exist.", self.mediaCopyURL.path;
                                    self.error = error;
                                }
                            }];
    } else if ([self.mediaItem.mediaType isEqualToString:@"audio"]) {
    }
}

//
// Transfer upload started
//
- (void)uploadMedia {
    if ([self isCancelled]){
        [self completeOperation];
        return;
    }

//    ALog(@"starting uploadMedia for filename:%@ self.s3Path::%@, self.media_id::%@, self.s3file_name::%@", self.s3file_name, self.s3Path, self.media_id, self.s3file_name);
    
    //
    // Check transfer state to see if paused
    //
    while ((self.transferState == PAUSED) || ([self.nsurlSessionUploadTask state] == NSURLSessionTaskStateSuspended)) {
        //wait...
        ALog(@"paused waiting -> uploadMedia for filename:%@ self.s3Path::%@, self.media_id::%@, self.s3file_name::%@", self.s3file_name, self.s3Path, self.media_id, self.s3file_name);
        [NSThread sleepForTimeInterval:1.0];
    }
    
    //
    // If not paused then start...
    //
    self.transferState = IN_PROGRESS;

//    ALog(@"starting transfer with new NSURL -> uploadMedia for filename:%@ self.s3Path::%@, self.media_id::%@, self.s3file_name::%@", self.s3file_name, self.s3Path, self.media_id, self.s3file_name);
    
    /**
     * Fetch signed URL
     */
    AWSS3GetPreSignedURLRequest *getPreSignedURLRequest = [AWSS3GetPreSignedURLRequest new];
    getPreSignedURLRequest.bucket = [MyConstant getBUCKET_NAME];
    getPreSignedURLRequest.key = [NSString stringWithFormat:@"%@/%@/%@", self.s3Path, self.media_id, self.s3file_name];
    
    getPreSignedURLRequest.HTTPMethod = AWSHTTPMethodPUT;
    getPreSignedURLRequest.expires = [NSDate dateWithTimeIntervalSinceNow:3600];
    getPreSignedURLRequest.contentType = self.content_type;
    [getPreSignedURLRequest setValue:@"AES256" forRequestParameter:@"x-amz-server-side-encryption"];
    
    [[[AWSS3PreSignedURLBuilder defaultS3PreSignedURLBuilder] getPreSignedURL:getPreSignedURLRequest] continueWithBlock:^id(AWSTask *task) {
        
        if (task.error) {
            ALog(@"Error: %@", task.error);
            [self sendNotificationAndCompleteOperation];
        } else {
            NSURL* presignedURL = task.result;
            
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:presignedURL];
            request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
            [request setHTTPMethod:@"PUT"];
            [request setValue:self.content_type forHTTPHeaderField:@"Content-Type"];
            
            NSDictionary* headers = [request allHTTPHeaderFields];
            //ALog(@"headers: %@", headers);
            @try {
                self.nsurlSessionUploadTask = [queueUploadController.session uploadTaskWithRequest:request
                                                                                          fromFile:self.mediaCopyURL];
                self.taskIdentifier = self.nsurlSessionUploadTask.taskIdentifier;
                
                //
                // Send identifying data back through description as JSON
                //
                NSDictionary* transferModelDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                   [self.mediaItem.mediaNamePrefix copy], @"mediaNamePrefix",
                                                   [NSNumber numberWithFloat:0], @"last_progress",
                                                   [NSNumber numberWithInteger:(NSInteger)self.transferType], @"transferType",
                                                   [self.mediaItem.mediaType copy], @"mediaType",
                                                   [self.s3file_name copy], @"s3file_name",
                                                   nil];
                self.nsurlSessionUploadTask.taskDescription = [JSONUtil convertFromNSDictionary:transferModelDict];
                [self.nsurlSessionUploadTask resume];
            } @catch (NSException* exception) {
                ALog(@"exception creating upload task: %@", exception);
            }
        }
        return nil;
    }];
}

//
// Web Service to finalize upload
//
- (void)addMediaEventMWS {
    @try {
        if ([Util checkInternetConnection]) {
            //ALog(@"Request transferModel.location:- %@", self.location);
            
            // Update text to show finalizing...
            self.progressText = @"finalizing...";
            NSMutableDictionary* transferModelDict = [[NSMutableDictionary alloc] init];
            [transferModelDict setObject:[NSNumber numberWithFloat:0] forKey:@"last_progress"];
            [transferModelDict setObject:[NSNumber numberWithFloat:0] forKey:@"current_progress"];
            [transferModelDict setObject:self.progressText forKey:@"progressText"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [queueUploadController.delegate updateUploadProgressBar:transferModelDict];
            });
            
            //
            // Check for copyright
            //
            NSString* copyright = @"";
            if (self.mediaItem.copyright != nil) {
                copyright = [JSONUtil convertFromNSDictionary:self.mediaItem.copyright];
            }
            /**
             * Use XMLGenerator...
             */
            
            NSString* requestXML =
            [XMLGenerator generateAddMediaEventXML:[Helper fetchSID]
                                        withUserId:[Helper fetchUserId]
                                   andWithDeviceId:[Helper fetchDeviceId]
                                 andWithDeviceTYPE:DEVICE_TYPE
                                    andWithEventId:self.mediaItem.eventId
                                    andWithMediaId:self.media_id
                                      andWithS3Url:@""
                                andWithContentType:self.content_type
                                 andWithS3FileName:self.s3file_name
                              andWithIsServerImage:@"0"
                               andWithIsProfilePic:@"0"
                                   andWithLocation:self.location
                                  andWithCopyRight:copyright isRegistration:NO];
            
            //ALog(@"Request:- %@", requestXML);
            
            /**
             * Use WebServices Request Generator
             */
            
            NSMutableURLRequest* request =
            [WebServices generateWebServiceRequest:requestXML
                                            action:ADDMEDIAEVENT];
            //ALog(@"NSMutableRequest request ----> %@", request);
            
            /**
             * Send Request and Parse Response...
             *  Note: wsHandler notifies handleAddMediaEventMWS
             */
            //ALog(@"wsHandler fetchServerResponse:request action:ADDMEDIAEVENT key:self.observerNameAddMediaEventMWS...");
            MWebServiceHandler* wsHandler = [[MWebServiceHandler alloc] init];
            [wsHandler fetchServerResponse:request
                                    action:ADDMEDIAEVENT
                                       key:self.observerNameAddMediaEventMWS];
        }
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

/**
 * Web Service Response via notification here...
 */
- (void)handleAddMediaEventMWS:(NSNotification*)notification {
    @try {
        NSDictionary* resultTags = [notification userInfo];
        //ALog(@"handleAddMediaEventMWS:resultTags::%@", resultTags);
        // NSString* action = [resultTags objectForKey:@"action"];
        //
        // Handle result here...
        //
        NSString* status = @"";
        status = [resultTags objectForKey:@"status"];
        
        if ([[status lowercaseString] isEqualToString:@"success"]) {
            self.transferState = COMPLETED;
        } else {
            self.transferState = FAILED;
        }
        
        //
        // Finish Finalize
        //
        [self sendNotificationAndCompleteOperation];
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//
// Download Transfer section
//
- (void)downloadMedia {
    if ([self isCancelled]) return;
    
    //ALog(@"starting downloadMedia for filename:%@", self.s3file_name);
    self.transferState = IN_PROGRESS;
    //
    // Set key
    //
    NSString* key;
    if ([[self.mediaItem.mediaType lowercaseString] isEqualToString:@"image"]) {
        key = self.mediaItem.mediaPath;
    } else if ([[self.mediaItem.mediaType lowercaseString] isEqualToString:@"video"]) {
        //
        // down h.264 video - apple doesn't support h.265 yet.
        //
        key = self.mediaItem.mediaUrlWebS3Path;
    }
    //ALog(@"key::%@",key);
    
    AWSS3GetPreSignedURLRequest *getPreSignedURLRequest = [AWSS3GetPreSignedURLRequest new];
    getPreSignedURLRequest.bucket = [MyConstant getBUCKET_NAME];
    getPreSignedURLRequest.key = key;
    getPreSignedURLRequest.HTTPMethod = AWSHTTPMethodGET;
    getPreSignedURLRequest.expires = [NSDate dateWithTimeIntervalSinceNow:3600];
    
    //
    // Download the file
    //
    [[[AWSS3PreSignedURLBuilder defaultS3PreSignedURLBuilder]
      getPreSignedURL:getPreSignedURLRequest]
     continueWithBlock:^id(AWSTask* task) {
         if (task.error) {
             ALog(@"Error: %@", task.error);
             //
             // Finish Finalize even if error
             //
             self.transferState = FAILED;
             [self sendNotificationAndCompleteOperation];
         } else {
             @try {
                 NSURL *presignedURL = task.result;
                 //ALog(@"download presignedURL is: \n%@", presignedURL);
                 
                 NSURLRequest *request = [NSURLRequest requestWithURL:presignedURL];
                 self.nsurlSessionDownloadTask = [queueDownloadController.session downloadTaskWithRequest:request];
                 
                 //
                 // Send identifying data back through description as JSON
                 //
                 self.taskIdentifier = self.nsurlSessionDownloadTask.taskIdentifier;
                 NSDictionary* transferModelDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                    [self.mediaItem.mediaNamePrefix copy], @"mediaNamePrefix",
                                                    [NSNumber numberWithFloat:0], @"last_progress",
                                                    [NSNumber numberWithInteger:(NSInteger)self.transferType], @"transferType",
                                                    [self.mediaItem.mediaType copy], @"mediaType",
                                                    [self.s3file_name copy], @"s3file_name",
                                                    nil];
                 self.nsurlSessionDownloadTask.taskDescription = [JSONUtil convertFromNSDictionary:transferModelDict];
                 
                 //
                 // Kick off the task...
                 //
                 [self.nsurlSessionDownloadTask resume];
                 
             } @catch (NSException* exception) {
                 ALog(@"exception creating upload task: %@", exception);
             }
             
         }
         return nil;
     }];
}

//
// Web Service to update MediaDeviceTracker
//
- (void) updateMediaDeviceTrackerMWS:(NSNotification*)notification {
    if (notification != nil) {
        //ALog(@"- (void) updateMediaDeviceTrackerMWS:(NSNotification*)notification called...");
        NSDictionary* resultTags = [notification userInfo];
        @try {
            //
            // Call MediaDeviceTracker
            //
            if ([Util checkInternetConnection]) {
                NSString* sid = [[NSUserDefaults standardUserDefaults] objectForKey:@"SID"];
                NSString* userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
                NSString* deviceId = [[NSUserDefaults standardUserDefaults] objectForKey:@"device_id"];
                NSNumber* taskIdentifier = [resultTags objectForKey:@"taskIdentifier"];
                NSNumber* transferStateNSNumber = [resultTags objectForKey:@"transferState"];
                self.transferState = [transferStateNSNumber integerValue];
                self.mediaItem.mediaLocalIdentifier = [resultTags objectForKey:@"mediaLocalIdentifier"];
                
                if (self.transferState != FAILED) {
                    
                    /**
                     * Use XMLGenerator...
                     */
                    NSString* requestXML = [XMLGenerator
                                            mediaDeviceTrackerXML:sid
                                            media_id:self.media_id
                                            user_id:userId
                                            device_id:deviceId
                                            device_type:DEVICE_TYPE
                                            device_local_identifier:self.mediaItem.mediaLocalIdentifier
                                            task_identifier:[taskIdentifier stringValue]];
                    //ALog(@"Request:- %@", requestXML);
                    
                    /**
                     * Use WebServices Request Generator
                     */
                    NSMutableURLRequest* request =
                    [WebServices generateWebServiceRequest:requestXML
                                                    action:MEDIADEVICETRACKER];
                    //ALog(@"NSMutableRequest request ----> %@", request);
                    
                    /**
                     * Send Request Async and Parse Response...
                     */
                    MWebServiceHandler* wsHandler = [[MWebServiceHandler alloc] init];
                    //ALog(@"Inside updateMediaDeviceTrackerMWS::self.observerNameMediaDeviceTrackerMWS-------------->%@",self.observerNameMediaDeviceTrackerMWS);
                    [wsHandler fetchServerResponse:request
                                            action:MEDIADEVICETRACKER
                                               key:self.observerNameMediaDeviceTrackerMWS];
                    
                } else if (self.transferState == FAILED) {
                    //
                    // Failure occurred...
                    //
                    [self sendNotificationAndCompleteOperation];
                }
            }
        } @catch (NSException* exception) {
            ALog(@"%@", exception);
        }
    }
    
}


/**
 * Web Service Response via notification here...
 */
- (void)mediadevicetrackerMWSHandlerComplete:(NSNotification*)notification {
    //ALog(@"- (void) mediadevicetrackerMWSHandlerComplete:(NSNotification*)notification");
    NSDictionary* resultTags = [notification userInfo];
    NSString* status = [resultTags objectForKey:@"status"];
    
    //
    // Find the op (success or fail) and close it
    //
    NSString* taskIdentifierNSString = [resultTags objectForKey:@"task_identifier"];
    NSUInteger taskIdentifier = [taskIdentifierNSString intValue];
    TransferModel* transferModel = [self findTransferOpByTaskIdentifier:taskIdentifier withTransferType:DOWNLOAD];
    if ((status != nil) &&
        ([[status lowercaseString] isEqualToString:@"success"])) {
        //ALog(@"status::%@",[resultTags objectForKey:@"status"]);
        //ALog(@"message::%@",[resultTags objectForKey:@"message"]);
        //ALog(@"media_id::%@",[resultTags objectForKey:@"media_id"]);
        //ALog(@"device_id::%@",[resultTags objectForKey:@"device_id"]);
        //ALog(@"device_type::%@",[resultTags objectForKey:@"device_type"]);
        //ALog(@"device_local_identifier::%@",[resultTags objectForKey:@"device_local_identifier"]);
        
        transferModel.transferState = COMPLETED;
        transferModel.mediaItem.mediaState = SYNC;
        ALog(@"TransferState: %@, TransferType: %@, s3file_name: %@", [self getTransferStateAsString], [self getTransferTypeAsString], self.s3file_name);
        
    } else {
        transferModel.transferState = FAILED;
        ALog(@"TransferState: %@, TransferType: %@, s3file_name: %@", [self getTransferStateAsString], [self getTransferTypeAsString], self.s3file_name);
    }
    
    //
    // Close the model
    //
    ALog(@"mediadevicetrackerMWSHandlerComplete::sendNotificationAndCompleteOperation...");
    [self sendNotificationAndCompleteOperation];
    
}

- (void) sendNotificationAndCompleteOperation {
    //NSString *taskIdentifierNSString = [NSString stringWithFormat:@"%@",  @(self.taskIdentifier)];
    self.mediaItem.transferType = self.transferType;
    self.mediaItem.transferState = self.transferState;
    NSDictionary *mediaItemInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [self.mediaItem.mediaNamePrefix copy],@"mediaNamePrefix",
                                   [self.mediaItem.indexPath copy],@"indexPath",
                                   nil];
    //
    // Added Thread Safety to QueueController for notifications
    //
    //ALog(@"sendNotificationAndCompleteOperation::%@", mediaItemInfo);
    [[NSNotificationCenter defaultCenter] postNotificationName:TRANSFER_QUEUE_DELETECOMPLETED object:self userInfo:mediaItemInfo];
    
    //change to delegate --not working from background...
    //__weak typeof(self) weakSelf = self;
    //dispatch_async(dispatch_get_main_queue(), ^{
    //    [weakSelf.delegate completedTransferRow:mediaItemInfo];
    //});
    
    //
    // Complete Op and remove from queue
    //
    [self completeOperation];
}

//
// Find Transfer op
//
-(TransferModel*) findTransferOpByTaskIdentifier:(NSUInteger) taskIdentifier withTransferType:(TransferType) transferType {
    TransferModel* transferModel;
    NSArray* pendingTransferQueueOperationsArray = queueController.pendingTransferQueue.operations;
    for (int i=0; i<pendingTransferQueueOperationsArray.count; i++) {
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

//
// Util methods
//
- (bool) isUpload {
    if (self.transferType == UPLOAD) {
        return YES;
    } else {
        return NO;
    }
}


- (NSString*)getTransferTypeAsString {
    NSString* type;
    switch (self.transferType) {
        case UPLOAD:
            type = @"UPLOAD";
            break;
        case DOWNLOAD:
            type = @"DOWNLOAD";
            break;
        default:
            break;
    }
    return type;
}

- (NSString*)getTransferStateAsString {
    NSString* state;
    switch (self.transferState) {
        case PENDING:
            state = @"PENDING";
            break;
        case ENQUEUED:
            state = @"ENQUEUED";
            break;
        case COPYING:
            state = @"COPYING";
            break;
        case BACKGROUND_CANCELLED:
            state = @"BACKGROUND_CANCELLED";
            break;
        case IN_PROGRESS:
            state = @"IN_PROGRESS";
            break;
        case PAUSED:
            state = @"PAUSED";
            break;
        case RESUMED:
            state = @"RESUMED";
            break;
        case CANCELLED:
            state = @"CANCELLED";
            break;
        case COMPLETED:
            state = @"COMPLETED";
            break;
        case FAILED:
            state = @"FAILED";
            break;
        default:
            break;
    }
    return state;
}

//
// check mime type
//
- (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

//
// fix rotation for jpeg
//
- (UIImage *)fixrotation:(UIImage *)image{
    
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


//
// image copy with metadata - not used
//
- (UIImage*)copyImageAndAddMetaData:(UIImage*)image withALAsset:asset_ {
    NSData* jpeg = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0)];
    
    CGImageSourceRef source =
    CGImageSourceCreateWithData((__bridge CFDataRef)jpeg, NULL);
    
    NSDictionary* metadata = [[asset_ defaultRepresentation] metadata];
    
    NSMutableDictionary* metadataAsMutable = [metadata mutableCopy];
    
    NSMutableDictionary* EXIFDictionary = [metadataAsMutable
                                           objectForKey:(NSString*)kCGImagePropertyExifDictionary];
    NSMutableDictionary* GPSDictionary =
    [metadataAsMutable objectForKey:(NSString*)kCGImagePropertyGPSDictionary];
    NSMutableDictionary* TIFFDictionary = [metadataAsMutable
                                           objectForKey:(NSString*)kCGImagePropertyTIFFDictionary];
    NSMutableDictionary* RAWDictionary =
    [metadataAsMutable objectForKey:(NSString*)kCGImagePropertyRawDictionary];
    NSMutableDictionary* JPEGDictionary = [metadataAsMutable
                                           objectForKey:(NSString*)kCGImagePropertyJFIFDictionary];
    NSMutableDictionary* GIFDictionary =
    [metadataAsMutable objectForKey:(NSString*)kCGImagePropertyGIFDictionary];
    
    if (!EXIFDictionary) {
        EXIFDictionary = [NSMutableDictionary dictionary];
    }
    
    if (!GPSDictionary) {
        GPSDictionary = [NSMutableDictionary dictionary];
    }
    
    if (!TIFFDictionary) {
        TIFFDictionary = [NSMutableDictionary dictionary];
    }
    
    if (!RAWDictionary) {
        RAWDictionary = [NSMutableDictionary dictionary];
    }
    
    if (!JPEGDictionary) {
        JPEGDictionary = [NSMutableDictionary dictionary];
    }
    
    if (!GIFDictionary) {
        GIFDictionary = [NSMutableDictionary dictionary];
    }
    
    [metadataAsMutable setObject:EXIFDictionary
                          forKey:(NSString*)kCGImagePropertyExifDictionary];
    [metadataAsMutable setObject:GPSDictionary
                          forKey:(NSString*)kCGImagePropertyGPSDictionary];
    [metadataAsMutable setObject:TIFFDictionary
                          forKey:(NSString*)kCGImagePropertyTIFFDictionary];
    [metadataAsMutable setObject:RAWDictionary
                          forKey:(NSString*)kCGImagePropertyRawDictionary];
    [metadataAsMutable setObject:JPEGDictionary
                          forKey:(NSString*)kCGImagePropertyJFIFDictionary];
    [metadataAsMutable setObject:GIFDictionary
                          forKey:(NSString*)kCGImagePropertyGIFDictionary];
    
    //
    // Add to TransferModel
    //
    self.metadata = metadataAsMutable;
    CFStringRef UTI = CGImageSourceGetType(source);
    NSMutableData* dest_data = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData(
                                                                         (__bridge CFMutableDataRef)dest_data, UTI, 1, NULL);
    CGImageDestinationAddImageFromSource(
                                         destination, source, 0, (__bridge CFDictionaryRef)metadataAsMutable);
    
    BOOL success = NO;
    success = CGImageDestinationFinalize(destination);
    
    if (!success) {
    }
    
    // dataToUpload_ = dest_data;
    
    CFRelease(destination);
    CFRelease(source);
    
    return image;
}

@end

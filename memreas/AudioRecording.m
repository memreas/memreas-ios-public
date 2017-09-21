#import "AudioRecording.h"
#import "AppDelegate.h"
#import "AWSManager.h"
#import "Helper.h"
#import "Util.h"
#import "XMLGenerator.h"
#import "WebServices.h"
#import "MWebServiceHandler.h"

@implementation AudioRecording{
    AppDelegate *appDelegate;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    ALog(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    
    /**
     * Set Observer for Add Media Event web service...
     */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAddMediaEventMWS:)
                                                 name:ADDMEDIAEVENT_AUDIOCOMMENT_RESULT_NOTIFICATION
                                               object:nil];
    
    /**
     * Set Observer for Add Comment web service...
     */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAddCommentMWS:)
                                                 name:ADDCOMMENTS_AUDIOCOMMENT_RESULT_NOTIFICATION
                                               object:nil];
    

    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *tempDir = NSTemporaryDirectory();
    NSString *soundFilePath = [ tempDir stringByAppendingString:@"sound.caf"];
    NSURL *newURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];
    self.soundFileURL = newURL;
    newURL = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:YES error:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBtnPlayComment:nil];
    [self setBtnRecordComment:nil];
    [self setSoundFileURL:nil];
    [self setMediaId:nil];
    [self setBtnLastCommentPlay:nil];
    self.audioPlayer = nil;
    player = nil;
    _soundFileURL = nil;
    _lastCommentURL = nil;
    self.soundRecorder = nil;
    _mediaId = nil;
    _eventId = nil;
    _comment = nil;
    [super viewDidUnload];
}

#pragma mark
#pragma mark Audio Recoding

- (IBAction)recordOrStop:(id)sender {
    
    if(recording){
        
        [self.soundRecorder stop];
        recording = NO;
        
        [self.btnRecordComment setTitle:@"Start Recording" forState:UIControlStateNormal];
        [self.btnRecordComment setTitle:@"Start Recording" forState:UIControlStateHighlighted];
        
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        self.soundRecorder = nil;
        
    } else{
        
        [[AVAudioSession sharedInstance]  setCategory:AVAudioSessionCategoryRecord error:nil];
        
        NSDictionary *recordSettings = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:44100.0],AVSampleRateConverterAudioQualityKey,[NSNumber numberWithInt:kAudioFormatAppleLossless],AVFormatIDKey,[NSNumber numberWithInt:1],AVNumberOfChannelsKey,[NSNumber numberWithInt:AVAudioQualityMax],AVEncoderAudioQualityKey, nil];
        
        self.soundRecorder = [[AVAudioRecorder alloc] initWithURL:self.soundFileURL settings:recordSettings error:nil];
        //AVAudioRecorder* self.soundRecorder = [[AVAudioRecorder alloc] initWithURL:self.soundFileURL settings:recordSettings error:nil];
        //self.soundRecorder = audioRecorder;
        //audioRecorder = nil;
        
        self.soundRecorder.delegate = self;
        [self.soundRecorder prepareToRecord];
        [self.soundRecorder record];
        
        recordSettings = nil;
        
        [self.btnRecordComment setTitle:@"Stop Recording" forState:UIControlStateNormal];
        [self.btnRecordComment setTitle:@"Stop Recording" forState:UIControlStateHighlighted];
        
        recording = YES;
        
    }
}

#pragma mark
#pragma mark Audio Player

- (IBAction)playLastRecordFile:(id)sender {
    if(playing){
        
        [self.audioPlayer stop];
        playing = NO;
        
        [self.btnPlayComment setTitle:@"Play Recording" forState:UIControlStateNormal];
        [self.btnPlayComment setTitle:@"Play Recording" forState:UIControlStateHighlighted];
        
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        
    } else{
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.soundFileURL error:nil];
        self.audioPlayer = newPlayer;
        newPlayer = nil;
        
        self.audioPlayer.delegate = self;
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
        
        [self.btnPlayComment setTitle:@"Stop Recording" forState:UIControlStateNormal];
        [self.btnPlayComment setTitle:@"Stop Recording" forState:UIControlStateHighlighted];
        
        playing = YES;
        
    }
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if(flag == YES){
        
        if (playing) {
            playing = NO;
            
            [self.btnPlayComment setTitle:@"Play Recording" forState:UIControlStateNormal];
            [self.btnPlayComment setTitle:@"Play Recording" forState:UIControlStateHighlighted];
        }
        if(lastComment){
            lastComment = NO;
            
            [self.btnLastCommentPlay setTitle:@"Play Last Comment" forState:UIControlStateNormal];
            [self.btnLastCommentPlay setTitle:@"Play Last Comment" forState:UIControlStateHighlighted];
        }
        
    }
}

- (IBAction)lastCommentPlay:(id)sender {
    player = [[MPMoviePlayerController alloc] init];
    
    
    [[AVAudioSession sharedInstance]
     setCategory:AVAudioSessionCategoryPlayback
     error:nil];
    
    player.shouldAutoplay = NO;
    player.controlStyle = MPMovieControlStyleFullscreen;
    player.movieSourceType = MPMovieSourceTypeStreaming;
    player.scalingMode = MPMovieScalingModeAspectFill;
    player.contentURL = self.lastCommentURL;
    player.fullscreen = YES;
    [player.view setFrame:self.view.bounds];
    [self.view addSubview:player.view];
    [self.view bringSubviewToFront:player.view];
    [player prepareToPlay];
    
    //handle phone on vibrate...
    [[AVAudioSession sharedInstance]
     setCategory: AVAudioSessionCategoryPlayback
     error: nil];

    
    // Register for the playback finished notification
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(doneButtonClick:)
     name: MPMoviePlayerPlaybackDidFinishNotification
     object: player];
    [player play];
    lastComment = YES;
}
-(void)doneButtonClick:(NSNotification*)aNotification{
    [player stop];
    [player.view removeFromSuperview];
    player = nil;
}
#pragma mark
#pragma mark Audio Uploading
- (IBAction)SaveComment:(id)sender {
    [self uploadAudioFile];
}

-(void) uploadAudioFile{
    
    NSUserDefaults *defaultUser = [NSUserDefaults standardUserDefaults];
    NSString *userId = [defaultUser stringForKey:@"UserId"];
    
    
    NSString *urlString  = [NSString stringWithFormat:@"%@&sid=%@",[MyConstant getUPLOAD_URL],SID];
    
    NSString *tempDir = NSTemporaryDirectory();
    NSString *soundFilePath = [ tempDir stringByAppendingString:@"sound.caf"];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //
    // Upload the audio to S3 if there is audio
    //
    NSURL *commentNSURL = [NSURL URLWithString:soundFilePath];
    NSString* s3file_name = [commentNSURL lastPathComponent];
    NSString *fileExtension = [commentNSURL pathExtension];
    NSString *UTI =
    (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(
                                                                        kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension,
                                                                        NULL);
    self.content_type =
    (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(
                                                                  (__bridge CFStringRef)UTI, kUTTagClassMIMEType);
    ALog(@"starting uploadMedia for filename:%@", self.s3file_name);
    ALog(@"content_type:%@", self.content_type);
    
    //
    // Fetch audio media id
    //
    self.audioMediaId = [[MediaIdManager sharedInstance] fetchNextMediaId];
    
    //
    // Fetch signed URL
    //
    [AWSManager sharedInstance];
    AWSS3GetPreSignedURLRequest *getPreSignedURLRequest =
    [AWSS3GetPreSignedURLRequest new];
    getPreSignedURLRequest.bucket = [MyConstant getBUCKET_NAME];
    NSString *s3Key =
    [NSString stringWithFormat:@"%@/%@/%@", [Helper fetchUserId], self.audioMediaId, self.s3file_name];
    getPreSignedURLRequest.key = s3Key;
    getPreSignedURLRequest.HTTPMethod = AWSHTTPMethodPUT;
    getPreSignedURLRequest.expires = [NSDate dateWithTimeIntervalSinceNow:3600];
    
    // Important: must set contentType for PUT request
    ALog(@"headers: %@", getPreSignedURLRequest);
    getPreSignedURLRequest.contentType = self.content_type;
    
    if ([[NSFileManager defaultManager]
         fileExistsAtPath:soundFilePath]) {
        //
        // Upload the file
        //
        [[[AWSS3PreSignedURLBuilder defaultS3PreSignedURLBuilder]
          getPreSignedURL:getPreSignedURLRequest]
         continueWithBlock:^id(AWSTask *task) {
             if (task.error) {
                 ALog(@"Error: %@", task.error);
             } else {
                 NSURL *presignedURL = task.result;
                 // ALog(@"upload presignedURL is: \n%@", presignedURL);
                 
                 NSMutableURLRequest *request =
                 [NSMutableURLRequest requestWithURL:presignedURL];
                 request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
                 [request setHTTPMethod:@"PUT"];
                 [request setValue:self.content_type
                forHTTPHeaderField:@"Content-Type"];
                 [request setValue:@"AES256"
                forHTTPHeaderField:@"x-amz-server-side-encryption"];
                 
                 NSDictionary *headers = [request allHTTPHeaderFields];
                 ALog(@"headers: %@", headers);
                 @try {
                     self.uploadAudioCommentTask = [[NSURLSession sharedSession]
                                                    uploadTaskWithRequest:request
                                                    fromFile:commentNSURL
                                                    completionHandler:^(NSData *data, NSURLResponse *response,
                                                                        NSError *error) {
                                                        if (!error) {
                                                            ALog(@"upload completed for filename:%@",
                                                                  self.s3file_name);
                                                            //
                                                            // Call web service to store entry in db
                                                            //
                                                            [self addMediaEventMWS];
                                                        } else {
                                                            NSDictionary *userInfo = [error userInfo];
                                                            ALog(@"(void)URLSession:session "
                                                                  @"task:(NSURLSessionTask*)task "
                                                                  @"didCompleteWithError:error called...%@\n "
                                                                  @"userInfo: " @"%@",
                                                                  error, userInfo);
                                                        }
                                                        
                                                    }];
                     [self.uploadAudioCommentTask resume];
                 } @catch (NSException *exception) {
                     ALog(@"exception creating upload task: %@", exception);
                 }
             }
             return nil;
         }];
    } // end if copy file exists
}

//
// Web Service to finalize audio comment upload
//
- (void)addMediaEventMWS {
    @try {
        if ([Util checkInternetConnection]) {
            /**
             * Use XMLGenerator...
             */
            NSString* s3Url = [NSString stringWithFormat:@"%@/%@/%@", [Helper fetchUserId], self.mediaId, self.s3file_name];
            NSString *requestXML =
            [XMLGenerator generateAddMediaEventXML:[Helper fetchSID]
                                        withUserId:[Helper fetchUserId]
                                   andWithDeviceId:[Helper fetchDeviceId]
                                 andWithDeviceTYPE:DEVICE_TYPE
                                    andWithEventId:self.eventId
                                    andWithMediaId:self.mediaId
                                      andWithS3Url:s3Url
                                andWithContentType:self.content_type
                                 andWithS3FileName:self.s3file_name
                              andWithIsServerImage:@"0"
                               andWithIsProfilePic:@"0"
                                   andWithLocation:@""
                                  andWithCopyRight:@""
                                    isRegistration:NO];
            
            ALog(@"Request:- %@", requestXML);
            
            /**
             * Use WebServices Request Generator
             */
            
            NSMutableURLRequest *request =
            [WebServices generateWebServiceRequest:requestXML
                                            action:ADDMEDIAEVENT];
            ALog(@"NSMutableRequest request ----> %@", request);
            
            /**
             * Send Request and Parse Response...
             *  Note: wsHandler notifies handleAddMediaEventMWS
             */
            MWebServiceHandler *wsHandler = [[MWebServiceHandler alloc] init];
            [wsHandler
             fetchServerResponse:request
             action:ADDMEDIAEVENT_AUDIOCOMMENT
             key:ADDMEDIAEVENT_AUDIOCOMMENT_RESULT_NOTIFICATION];
        }
    } @catch (NSException *exception) {
        ALog(@"%@", exception);
    }
}

- (void)handleAddMediaEventMWS:(NSNotification *)notification {
    @try {
        NSDictionary *resultTags = [notification userInfo];
        ALog(@"result tags: %@", resultTags);
        
        //
        // Handle result here...
        //
        NSString *status = @"";
        status = [resultTags objectForKey:@"status"];
        
        if ([[status lowercaseString] isEqualToString:@"success"]) {
            //
            // Call Add Comment here...
            //
            [self addCommentMWS];
        } else {
            //
            // Show error message
            //
            [appDelegate runOnMainWithoutDeadlocking:^(void) {
                
                [Helper showMessageFade:appDelegate.topViewController.view withMessage:@"an error occurred" andWithHideAfterDelay:3];
            }];
            
        }
        
    } @catch (NSException *exception) {
        ALog(@"%@", exception);
    }
}


//
// Web Service to add comment and/or link audio comment.
//
- (void)addCommentMWS {
    @try {
        if ([Util checkInternetConnection]) {
            /**
             * Use XMLGenerator...
             */
            NSString *requestXML =
            [XMLGenerator generateAddCommentXML:[Helper fetchUserId]
                                    withEventId:self.eventId
                                 andWithMediaId:self.mediaId
                            andWithAudioMediaId:self.audioMediaId
                                andWithComments:self.comment];
             
             ALog(@"Request:- %@", requestXML);
            
            /**
             * Use WebServices Request Generator
             */
            
            NSMutableURLRequest *request =
            [WebServices generateWebServiceRequest:requestXML
                                            action:ADDMEDIAEVENT];
            ALog(@"NSMutableRequest request ----> %@", request);
            
            /**
             * Send Request and Parse Response...
             *  Note: wsHandler notifies handleAddMediaEventMWS
             */
            MWebServiceHandler *wsHandler = [[MWebServiceHandler alloc] init];
            [wsHandler
             fetchServerResponse:request
             action:ADDMEDIAEVENT_AUDIOCOMMENT
             key:ADDMEDIAEVENT_AUDIOCOMMENT_RESULT_NOTIFICATION];
        }
    } @catch (NSException *exception) {
        ALog(@"%@", exception);
    }
}



- (void)handleAddCommentMWS:(NSNotification *)notification {
    @try {
        NSDictionary *resultTags = [notification userInfo];
        ALog(@"result tags: %@", resultTags);
        
        //
        // Handle result here...
        //
        NSString *status = @"";
        status = [resultTags objectForKey:@"status"];
        
        if ([[status lowercaseString] isEqualToString:@"success"]) {
            //
            // Done show success message
            //
            [appDelegate runOnMainWithoutDeadlocking:^(void) {
                [Helper showMessageFade:appDelegate.topViewController.view withMessage:@"comment added" andWithHideAfterDelay:3];
            }];
        } else {
            //
            // Show error message
            //
            [appDelegate runOnMainWithoutDeadlocking:^(void) {
                [Helper showMessageFade:appDelegate.topViewController.view withMessage:@"an error occurred" andWithHideAfterDelay:3];
            }];
        }
        
    } @catch (NSException *exception) {
        ALog(@"%@", exception);
    }
    
}

@end

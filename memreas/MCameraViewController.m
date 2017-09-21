#import "MCameraViewController.h"
#import "CheckSumUtil.h"
#import "MyConstant.h"
#import "CopyrightManager.h"
#import "QueueController.h"
#import "JSONUtil.h"

@implementation MCameraViewController {
    // instance variables here
    bool hasFrontCamera;
    bool hasBackCamera;
    bool hasAudio;
    bool isSetToBackCamera;
    bool isRecording;
    bool isSessionRunning;
    bool isDeviceAuthorized;
    bool isAVCaptureDeviceInputAudioGranted;
    bool isAVCaptureDeviceInputVideoGranted;
    bool canRotate;
    bool isSetToRecord;
    NSString* deviceName;
    NSString* modelId;
    UIInterfaceOrientation uiInterfaceOrientation;
    UIDeviceOrientation deviceOrientation;
    AVCaptureVideoOrientation avCaptureVideoOrientation;
    NSOperationQueue* sessionQueue;
    AVCaptureDeviceInput* avCaptureDeviceInputAudio;
    AVCaptureDeviceInput* avCaptureDeviceInputBack;
    AVCaptureDeviceInput* avCaptureDeviceInputFront;
    AVCaptureMovieFileOutput* movieFileOutput;
    AVCaptureStillImageOutput* stillImageOutput;
    AVCaptureMetadataOutput* metadataOutput;
    CopyrightManager* sharedInstanceCopyRightManager;
    NSString* md5_Mrights;
    NSString* sha1_Mrights;
    NSString* sha256_Mrights;
    NSMutableDictionary* copyright;
    NSString* jsonCopyRight;
    UIBackgroundTaskIdentifier backgroundRecordingID;
    UILabel* copyrightLabel;
    CLLocationCoordinate2D locationCLLocationCoordinate2D;
    NSMutableDictionary* copyrightDictionary;
    NSUserDefaults* defaultUser;
    NSString* userId;
    NSString* device_id;
    NSString* device_token;
}

//
// methods
//
#pragma mark - view controller lifecycle functions
- (void)viewDidLoad {
    @try {
        [super viewDidLoad];
        
        //
        // Enable location
        //
        [self currentLocationSettings];
        
        //
        //  Show spinner unitl view is shown
        //
        self.spinnerView.hidden = 0;
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.spinnerLabel setText:@"loading..."];
        });
        
        //
        // initialize variables
        //
        appDelegate =
        (AppDelegate*)[UIApplication sharedApplication]
        .delegate;
        self.avCaptureSession = [[AVCaptureSession alloc] init];
        //self.avCaptureSession.sessionPreset = AVCaptureSessionPresetMedium;
        self.avCaptureSession.sessionPreset = AVCaptureSessionPresetHigh;
        sharedInstanceCopyRightManager = [CopyrightManager sharedInstance];
        
        
        /**
         * Add observer for device orientation and set initial device orientation
         */
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
        self.currentDeviceOrientation = [[UIDevice currentDevice] orientation];
        
        /**
         * Add observer for AVCaptureSessionRuntimeErrorNotification...
         */
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(handleAVCaptureSessionRuntimeErrorNotification:)
         name:AVCaptureSessionRuntimeErrorNotification
         object:nil];
        
        /**
         * Add observer for AVCaptureSessionDidStartRunningNotification...
         */
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(
                            handleAVCaptureSessionDidStartRunningNotification:)
         name:AVCaptureSessionDidStartRunningNotification
         object:nil];
        
        /**
         * Add observer for AVCaptureSessionDidStopRunningNotification...
         */
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(handleAVCaptureSessionDidStopRunningNotification:)
         name:AVCaptureSessionDidStopRunningNotification
         object:nil];
        
        /**
         * Add observer for AVCaptureSessionWasInterruptedNotification...
         */
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(handleAVCaptureSessionWasInterruptedNotification:)
         name:AVCaptureSessionWasInterruptedNotification
         object:nil];
        
        /**
         * Add observer for AVCaptureSessionInterruptionEndedNotification...
         */
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(
                            handleAVCaptureSessionInterruptionEndedNotification:)
         name:AVCaptureSessionInterruptionEndedNotification
         object:nil];
        
        // Init Ops sessionQueue
        sessionQueue = [[NSOperationQueue alloc] init];
        
        //
        //  Setup defaults for segViewSync
        //
        [self.segPhotoVideo setBackgroundColor:[UIColor blackColor]];
        NSDictionary* attributes = [NSDictionary
                                    dictionaryWithObjectsAndKeys:[UIColor whiteColor],
                                    NSForegroundColorAttributeName, nil];
        [self.segPhotoVideo setTitleTextAttributes:attributes
                                          forState:UIControlStateNormal];
        
        //
        //  Setup view as default with light gray text highlight
        //
        attributes = [NSDictionary
                      dictionaryWithObjectsAndKeys:[UIColor blueColor],
                      NSForegroundColorAttributeName, nil];
        [self.segPhotoVideo setTitleTextAttributes:attributes
                                          forState:UIControlStateSelected];
        [self.segPhotoVideo setSelectedSegmentIndex:0];
        
        
        //
        //  Show spinner unitl preview is running
        //
        self.spinnerView.hidden = NO;
        
        //
        // Check cameras available - pass to Ops sessionQueue
        //
        NSBlockOperation* blockOp = [NSBlockOperation blockOperationWithBlock:^{
            // Add background code here...
            NSArray* devices = [AVCaptureDevice devices];
            //
            // For loop assigns camera and audio devices
            //  and set configuration for each
            //
            [self.avCaptureSession beginConfiguration];
            for (AVCaptureDevice* device in devices) {
                deviceName = [device localizedName];
                modelId = [device modelID];
                ALog(@"Device name: %@", deviceName);
                ALog(@"Device model id: %@", modelId);
                
                if ([device hasMediaType:AVMediaTypeVideo] ||
                    [device hasMediaType:AVMediaTypeAudio]) {
                    //
                    // Check if device can be used as input
                    //
                    NSError* error = nil;
                    AVCaptureDeviceInput* input =
                    [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
                    if (input) {
                        if ([device position] == AVCaptureDevicePositionBack) {
                            ALog(@"Device position : back");
                            hasBackCamera = YES;
                            [self checkAccessForDevice:AVMediaTypeVideo];
                            self.avCaptureDeviceBack = device;
                        } else if ([device position] == AVCaptureDevicePositionFront) {
                            ALog(@"Device position : front");
                            hasFrontCamera = YES;
                            [self checkAccessForDevice:AVMediaTypeVideo];
                            self.avCaptureDeviceFront = device;
                        } else if ([device hasMediaType:AVMediaTypeAudio]) {
                            ALog(@"Device audio : yes");
                            hasAudio = YES;
                            [self checkAccessForDevice:AVMediaTypeAudio];
                            self.avCaptureDeviceAudio = device;
                        }
                        // Set Smooth Auto Focus
                        if ([device isSmoothAutoFocusSupported]) {
                            if ([device lockForConfiguration:&error]) {
                                [device setSmoothAutoFocusEnabled:YES];
                                // Set focus point of interest
                                if ([device isFocusPointOfInterestSupported]) {
                                    CGPoint focusPoint = CGPointMake(0.5f, 0.5f);
                                    [device setFocusPointOfInterest:focusPoint];
                                }
                                [device unlockForConfiguration];
                            }
                        }
                        // Set Exposure
                        // Set Continuous Auto Exposure
                        if ([device isExposureModeSupported:
                             AVCaptureExposureModeAutoExpose]) {
                            if ([device lockForConfiguration:&error]) {
                                if ([device isExposurePointOfInterestSupported]) {
                                    CGPoint exposurePoint = CGPointMake(0.5f, 0.5f);
                                    [device setExposurePointOfInterest:exposurePoint];
                                }
                                [device unlockForConfiguration];
                            }
                        }
                        
                        // Set White Balance
                        if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
                            if ([device lockForConfiguration:&error]) {
                                [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
                                [device unlockForConfiguration];
                            }
                        }
                        
                    } else {
                        // do nothing - input is not available...
                    }  // end else if !input
                    
                }  // end if device has video...
            }    // end for
            [self.avCaptureSession commitConfiguration];
            
            //
            // Set and add inputs for devices
            //
            if ((isAVCaptureDeviceInputAudioGranted) &&
                (isAVCaptureDeviceInputVideoGranted)) {
                
                NSError* error;
                [self.avCaptureSession beginConfiguration];
                
                
                avCaptureDeviceInputBack =
                [AVCaptureDeviceInput deviceInputWithDevice:self.avCaptureDeviceBack
                                                      error:&error];
                avCaptureDeviceInputFront = [AVCaptureDeviceInput
                                             deviceInputWithDevice:self.avCaptureDeviceFront
                                             error:&error];
                avCaptureDeviceInputAudio = [AVCaptureDeviceInput
                                             deviceInputWithDevice:self.avCaptureDeviceAudio
                                             error:&error];
                
                //
                // Set back as default input
                //
                
                [self.avCaptureSession addInput:avCaptureDeviceInputBack];
                [self.avCaptureSession addInput:avCaptureDeviceInputAudio];
                isSetToBackCamera = YES;
                
                //
                // Set output to still image as default...
                //
                [self fetchAVCaptureMovieFileOutput];
                [self fetchAVCaptureStillImageFileOutput];
                
                //
                // Commit the configuration
                //
                [self.avCaptureSession commitConfiguration];
            }
            // end if ((isAVCaptureDeviceInputAudioGranted) && (isAVCaptureDeviceInputVideoGranted))
            
            
            //
            // Update the UI
            //
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //
                // Set Copyright
                //
                [weakSelf resetCopyright];
                [weakSelf.copyright_preview setText:[NSString stringWithFormat:@"md5:%@ sha256:%@",md5_Mrights,sha256_Mrights]];
                
                //
                // Setup portrait orientation
                //
                uiInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
                avCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
                weakSelf.avCaptureVideoPreviewLayer.connection.videoOrientation = avCaptureVideoOrientation;
                
                //
                // Preview Layer
                //
                weakSelf.avCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:weakSelf.avCaptureSession];
                weakSelf.avCaptureVideoPreviewLayer.frame = weakSelf.view.bounds;
                weakSelf.avCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                
                
                //
                // Add preview and controls on top
                //
                [weakSelf.cameraView.layer addSublayer:weakSelf.avCaptureVideoPreviewLayer];
                [weakSelf.view bringSubviewToFront:weakSelf.bottomBarView];
                [weakSelf.view bringSubviewToFront:weakSelf.copyright_preview];
                
                //
                //  Show spinner unitl preview is running
                //
                weakSelf.spinnerView.hidden = YES;
                
                //
                // Ok now start, stop, then start running...
                //
                [weakSelf.avCaptureSession startRunning];
                
            });
        }];
        [sessionQueue addOperation:blockOp];
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

- (void) resetCopyright {
    @try {
        //
        // Set Preview copyright view
        //
        copyright = [sharedInstanceCopyRightManager fetchNextCopyRight];
        
        //
        // Add copyright to capture file
        //
        defaultUser = [NSUserDefaults standardUserDefaults];
        userId = [defaultUser stringForKey:@"UserId"];
        device_id = [defaultUser stringForKey:@"device_id"];
        device_token = [defaultUser stringForKey:@"device_token"];
        
        md5_Mrights = [copyright objectForKey:@"copyright_id_md5"];
        sha1_Mrights = [copyright objectForKey:@"copyright_id_sha1"];
        sha256_Mrights = [copyright objectForKey:@"copyright_id_sha256"];
        copyrightDictionary = [[NSMutableDictionary alloc] init];
        
        //
        // Set copyright_preview
        //
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self.copyright_preview setBackgroundColor:[UIColor lightGrayColor]];
            //[weakSelf.copyright_preview setBackgroundColor:[UIColor blueColor]];
            //[weakSelf.copyright_preview setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-90))];
            //[weakSelf.copyright_preview setTransform:CGAffineTransformMakeRotation(M_PI_2)];
            //[weakSelf.copyright_preview setTextColor:[UIColor blueColor]];
            //[weakSelf.copyright_preview size:COPYRIGHT_FONT_SIZE]];
            
            [weakSelf.copyright_preview setText:[NSString stringWithFormat:@"md5:%@ sha256:%@",md5_Mrights,sha256_Mrights]];
            [weakSelf.view bringSubviewToFront:weakSelf.copyright_preview];
        });
        
        
    } @catch (NSException* exception) {
        @try {
            [CopyrightManager resetSharedInstance];
            [CopyrightManager sharedInstance];
            copyright = [[CopyrightManager sharedInstance] fetchNextCopyRight];
            //
            // If no error a new batch was retrieved
            //
            [self resetCopyright];
        } @catch (NSException* exception) {
            //
            //something is wrong .. popout of camera
            //
            [self releaseOnBack];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    @try {
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //
    // setup for photo so no rotation
    //
    canRotate = NO;
    [self viewWillLayoutSubviews];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    @try {
        [self resignFirstResponder];
        [super viewWillDisappear:animated];
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self releaseOnBack];
}

- (void)releaseOnBack {
    @try {
        //
        //  Show spinner unitl view is shown
        //
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.spinnerView.hidden = 0;
            [weakSelf.spinnerLabel setText:@"closing..."];
            [self.avCaptureSession stopRunning];
            isSessionRunning = NO;
            [self dismissViewControllerAnimated:YES completion:nil];
        });
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be
     recreated (or reloaded from disk) later.
     */
}

#pragma mark -
#pragma mark Custom methods
- (void)handleAVCaptureSessionRuntimeErrorNotification:(NSDictionary*)userInfo {
    //
    // handle error here
    //
    ALog(@"%s,handleAVCaptureSessionRuntimeErrorNotification occurred",
         __PRETTY_FUNCTION__);
}

- (void)handleAVCaptureSessionDidStartRunningNotification:
(NSDictionary*)userInfo {
    //
    // handle error here
    //
    //ALog(@"%s,handleAVCaptureSessionDidStartRunningNotification occurred",__PRETTY_FUNCTION__);
    
    //
    //set flag to running
    //
    isSessionRunning = YES;
}

- (void)handleAVCaptureSessionDidStopRunningNotification:
(NSDictionary*)userInfo {
    //
    // handle here
    //
    ALog(@"%s,handleAVCaptureSessionDidStopRunningNotification occurred",
         __PRETTY_FUNCTION__);
}

- (void)handleAVCaptureSessionWasInterruptedNotification:
(NSDictionary*)userInfo {
    //
    // handle error here
    //
    ALog(@"%s,handleAVCaptureSessionWasInterruptedNotification occurred",
         __PRETTY_FUNCTION__);
}

- (void)handleAVCaptureSessionInterruptionEndedNotification:
(NSDictionary*)userInfo {
    //
    // handle error here
    //
    ALog(@"%s,handleAVCaptureSessionInterruptionEndedNotification occurred",
         __PRETTY_FUNCTION__);
}

- (void)setFlash:(AVCaptureDevice*)device withFlashOn:(bool) flashOn {
    //
    // Note: should be called within NSOperation
    //
    NSError* error;
    // Set Auto Flash
    if (([device hasFlash]) && (flashOn)) {
        if ([device lockForConfiguration:&error]) {
            [device setFlashMode:AVCaptureFlashModeAuto];
            [device unlockForConfiguration];
        }
    } else if (([device hasFlash]) && (!flashOn)) {
        if ([device lockForConfiguration:&error]) {
            [device setFlashMode:AVCaptureFlashModeOff];
            [device unlockForConfiguration];
        }
    }
}

- (void)setTorch:(AVCaptureDevice*)device withTorchOn:(bool) torchOn {
    //
    // Note: should be called within NSOperation
    //
    NSError* error;
    // Set Auto Torch for Video Capture
    if (([device hasFlash]) && (torchOn)) {
        if ([device lockForConfiguration:&error]) {
            [device setTorchMode:AVCaptureTorchModeAuto];
            [device unlockForConfiguration];
        }
    } else if (([device hasFlash]) && (!torchOn)) {
        if ([device lockForConfiguration:&error]) {
            [device setTorchMode:AVCaptureTorchModeOff];
            [device unlockForConfiguration];
        }
    }
}

- (void)checkAccessForDevice:(NSString*)mediaType {
    [AVCaptureDevice requestAccessForMediaType:mediaType
                             completionHandler:^(BOOL granted) {
                                 if (granted) {
                                     if (mediaType == AVMediaTypeAudio) {
                                         isAVCaptureDeviceInputAudioGranted = YES;
                                         ALog(@"access GRANTED for: %@", mediaType);
                                     } else if (mediaType == AVMediaTypeVideo) {
                                         isAVCaptureDeviceInputVideoGranted = YES;
                                         ALog(@"access GRANTED for: %@", mediaType);
                                     }
                                 } else {
                                     ALog(@"access not granted for: %@", mediaType);
                                 }
                             }];
}

- (IBAction)segmentChanged:(UISegmentedControl*)sender {
    
    switch (self.segPhotoVideo.selectedSegmentIndex) {
            //
            // Setup Photo
            //
        case 0:
            isSetToRecord = NO;
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:UIInterfaceOrientationPortrait] forKey:@"orientation"];
            canRotate = NO;
            break;
            //
            // Setup Video
            //
        case 1:
            isSetToRecord = YES;
            canRotate = YES;
            break;
        default:
            break;
    }
}

- (BOOL)shouldAutorotate {
    //
    // canRotate is set in shoot method, initially YES
    //
    return canRotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (isSetToRecord) {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
}

/*
 - (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
 if (isSetToRecord) {
 return uiInterfaceOrientation
 }
 return UIInterfaceOrientationPortrait;
 }
 */




- (IBAction)cameraSwitch:(id)sender {
    if (!isRecording) {
        
        //
        // Now we can switch the camera if need be...
        //
        __weak typeof(self) weakSelf = self;
        if (isSetToBackCamera) {
            //
            // disable icon
            //
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.btnFrontBackCameraSelection setEnabled:NO];
            });
            
            NSBlockOperation* blockOp = [NSBlockOperation blockOperationWithBlock:^{
                NSError* error;
                [weakSelf.avCaptureSession beginConfiguration];
                
                //
                //button press so flip
                //
                [weakSelf.avCaptureSession removeInput:avCaptureDeviceInputBack];
                avCaptureDeviceInputFront =
                [AVCaptureDeviceInput deviceInputWithDevice:self.avCaptureDeviceFront error:&error];
                if (avCaptureDeviceInputFront) {
                    [weakSelf.avCaptureSession addInput:avCaptureDeviceInputFront];
                    isSetToBackCamera = NO;
                }
                [weakSelf.avCaptureSession commitConfiguration];
            }];
            [sessionQueue addOperation:blockOp];
            
            //
            // change and enable switch icon
            //
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.btnFrontBackCameraSelection.imageView setImage:[UIImage imageNamed:@"blue-camera-front-icon.png"]];
                [weakSelf.btnFrontBackCameraSelection setEnabled:YES];
            });
            
        } else if (!isSetToBackCamera) {
            //
            // disable icon
            //
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.btnFrontBackCameraSelection setEnabled:NO];
            });
            
            NSBlockOperation* blockOp = [NSBlockOperation blockOperationWithBlock:^{
                NSError* error;
                [weakSelf.avCaptureSession beginConfiguration];
                
                [weakSelf.avCaptureSession removeInput:avCaptureDeviceInputFront];
                avCaptureDeviceInputBack = [AVCaptureDeviceInput deviceInputWithDevice:weakSelf.avCaptureDeviceBack error:&error];
                if (avCaptureDeviceInputBack) {
                    [weakSelf.avCaptureSession addInput:avCaptureDeviceInputBack];
                    isSetToBackCamera = YES;
                }
                [weakSelf.avCaptureSession commitConfiguration];
            }];
            [sessionQueue addOperation:blockOp];
            
            //
            // switch icon - must come after blockOp
            //
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.btnFrontBackCameraSelection.imageView setImage:[UIImage imageNamed:@"blue-camera-back-icon.png"]];
                [weakSelf.btnFrontBackCameraSelection setEnabled:YES];
            });
            
        }
    } // can't change camera if we're recording...
}

#pragma mark layout
- (void)deviceDidRotate:(NSNotification *)notification
{
    self.currentDeviceOrientation = [[UIDevice currentDevice] orientation];
    uiInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (canRotate) {
        [self viewWillLayoutSubviews];
    }
}

- (void)viewWillLayoutSubviews {
    
    self.avCaptureVideoPreviewLayer.frame = self.view.bounds;
    if (self.avCaptureVideoPreviewLayer.connection.supportsVideoOrientation) {
        self.avCaptureVideoPreviewLayer.connection.videoOrientation = [self
                                                                       interfaceOrientationToVideoOrientation:[UIApplication sharedApplication]
                                                                       .statusBarOrientation];
    }
}

- (AVCaptureVideoOrientation)interfaceOrientationToVideoOrientation:
(UIInterfaceOrientation)orientation {
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
        case UIInterfaceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
        case UIInterfaceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeLeft;
        case UIInterfaceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeRight;
        default:
            break;
    }
    ALog(@"Warning - Didn't recognise interface orientation (%@)", @(orientation));
    return AVCaptureVideoOrientationPortrait;
}

#pragma mark backPress
- (IBAction)backPressed:(id)sender {
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    [self releaseOnBack];
}

#pragma mark Recorder
- (IBAction)shoot:(id)sender {
    //
    // Change Icon
    //
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.btnShoot.imageView
         setImage:[UIImage imageNamed:@"media-recording.png"]];
    });
    
    //
    // Ensure connection is valid
    //
    if (!isSetToRecord) {
        [self handleStillImage];
    } else {
        [self handleVideoRecord];
    }
    
}


#pragma mark outputs
//
// Fetch outputs section
//
- (void)fetchAVCaptureMovieFileOutput {
    
    //
    // Note: call to this method should be within an NSOperation
    //
    movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([self.avCaptureSession canAddOutput:movieFileOutput]) {
        [self.avCaptureSession addOutput:movieFileOutput];
        self.avCaptureConnection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([self.avCaptureConnection isVideoStabilizationSupported]) {
            self.avCaptureConnection.preferredVideoStabilizationMode =
            AVCaptureVideoStabilizationModeAuto;
        }
    }
}

- (void)fetchAVCaptureStillImageFileOutput {
    
    //
    // Note: call to this method should be within an NSOperation
    //
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    if ([self.avCaptureSession canAddOutput:stillImageOutput]) {
        [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
        [self.avCaptureSession addOutput:stillImageOutput];
    }
}



#pragma handleStillImage
- (void) handleStillImage {
    NSBlockOperation* blockOp = [NSBlockOperation blockOperationWithBlock:^{
        
        [self setFlash:self.avCaptureDeviceBack withFlashOn:YES];
        [self setTorch:self.avCaptureDeviceBack withTorchOn:NO];
        
        UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
        if ([self.avCaptureConnection isVideoOrientationSupported]) {
            if (deviceOrientation == UIDeviceOrientationPortrait)
            {
                // Portrait
                [self.avCaptureConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
            } else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown)
            {
                // Portrait - upside down
                [self.avCaptureConnection setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
            } else if (deviceOrientation == UIDeviceOrientationLandscapeLeft)
            {
                // Landscape left
                [self.avCaptureConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
            } else if (deviceOrientation == UIDeviceOrientationLandscapeRight)
            {
                // Landscape right
                [self.avCaptureConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
            }
        }
        
        //
        //  Capture Image
        //
        [stillImageOutput
         captureStillImageAsynchronouslyFromConnection:
         [stillImageOutput connectionWithMediaType:AVMediaTypeVideo]
         completionHandler:
         ^(CMSampleBufferRef
           imageDataSampleBuffer,
           NSError* error) {
             
             if (imageDataSampleBuffer) {
                 //
                 // Fetch dictionary, update, and
                 // add
                 // copyright
                 //
                 NSMutableDictionary* metadataWithCopyRightNSMutableDictionary = [self fetchMetaDataUpdateAddCopyRight: imageDataSampleBuffer];
                 
                 //
                 //  Fetch original jpeg, rotate for CIImage and inscribe copyright
                 //
                 [self finalizeImageRotateInscribeAddMetaData:imageDataSampleBuffer
                                                 withMetaData:metadataWithCopyRightNSMutableDictionary];
                 //
                 // Store image
                 //
                 [[[ALAssetsLibrary alloc] init] writeImageDataToSavedPhotosAlbum:self.imageWithMD5SHA1InscribedNSData
                                                                         metadata:metadataWithCopyRightNSMutableDictionary
                                                                  completionBlock:^(NSURL *assetURL, NSError *error) {
                                                                      
                                                                      if (error != nil) {
                                                                          ALog(@"error storing image as alasset");
                                                                      } else {
                                                                          ALog(@"image stored as alasset %@", assetURL);
                                                                          
                                                                          //
                                                                          // Generate checksum and add
                                                                          // to copyright for upload
                                                                          //
                                                                          NSString* fileCheckSumMD5 =[CheckSumUtil md5HashOfNSURL:assetURL];
                                                                          NSString* fileCheckSumSHA1 = [CheckSumUtil sha1HashOfNSURL:assetURL];
                                                                          NSString* fileCheckSumSHA256 = [CheckSumUtil sha256HashOfNSURL:assetURL];
                                                                          [copyright setObject:fileCheckSumMD5 forKey:@"fileCheckSumMD5"];
                                                                          [copyright setObject:fileCheckSumSHA1 forKey:@"fileCheckSumSHA1"];
                                                                          [copyright setObject:fileCheckSumSHA256 forKey:@"fileCheckSumSHA256"];
                                                                          
                                                                          //
                                                                          // init mediaItem
                                                                          //
                                                                          self.mediaItem = [[MediaItem alloc] initWithNSURL:assetURL];
                                                                          
                                                                          self.mediaItem.metadata = metadataWithCopyRightNSMutableDictionary;
                                                                          ALog(@"self.mediaItem.metadata::%@",self.mediaItem.metadata);
                                                                          
                                                                          //
                                                                          // Set mediaItem copyright
                                                                          //
                                                                          self.mediaItem.copyright = copyright;
                                                                          
                                                                          //
                                                                          // Set mediaItem copyright
                                                                          //
                                                                          self.mediaItem.mediaId = [copyright objectForKey:@"media_id"];
                                                                          
                                                                          //
                                                                          // Set mediaItem hasNSData and shootNSData
                                                                          //
                                                                          self.mediaItem.hasShootNSData = YES;
                                                                          self.mediaItem.shootNSData = self.imageWithMD5SHA1InscribedNSData;
                                                                          
                                                                          //
                                                                          // Fetch thumbnail and update
                                                                          //
                                                                          [self.mediaItem fetchThumbnailForPHAsset:self.thumbnail.bounds.size];
                                                                          
                                                                          //
                                                                          // Change Icon
                                                                          //
                                                                          __weak typeof(self) weakSelf = self;
                                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                                              [weakSelf.thumbnail setContentMode:UIViewContentModeScaleAspectFit];
                                                                              [weakSelf.thumbnail setImage:weakSelf.mediaItem.mediaLocalThumbnail];
                                                                          });
                                                                          
                                                                          //
                                                                          // Upload to S3
                                                                          //
                                                                          [[QueueController sharedInstance] addToPendingTransferArray:self.mediaItem
                                                                                                                     withTransferType:UPLOAD];
                                                                          
                                                                          //Release resource locks if any
                                                                          self.mediaItem = nil;
                                                                          self.imageWithMD5SHA1InscribedCIImage = nil;
                                                                          self.imageWithMD5SHA1InscribedNSData = nil;
                                                                          self.imageWithMD5SHA1InscribedUIImage = nil;
                                                                      } // end else if (error == nil)
                                                                      // end ALAssetsLibrary completion block
                                                                      
                                                                      //
                                                                      // complete the operation here
                                                                      //
                                                                      NSBlockOperation* stilImageCompletion = [NSBlockOperation blockOperationWithBlock:^{
                                                                          [self.avCaptureSession stopRunning];
                                                                          [self resetCopyright];
                                                                          
                                                                          __weak typeof(self) weakSelf = self;
                                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                                              [weakSelf.copyright_preview setText:[NSString stringWithFormat:@"md5:%@ sha256:%@",md5_Mrights,sha256_Mrights]];
                                                                              [weakSelf.view bringSubviewToFront:weakSelf.copyright_preview];
                                                                          });
                                                                          
                                                                          //
                                                                          // Start running session
                                                                          //
                                                                          [self.avCaptureSession startRunning];
                                                                          
                                                                          //
                                                                          // Turn on recording icon
                                                                          //
                                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                                              [weakSelf.btnShoot.imageView setImage:[UIImage imageNamed:@"media-recording-start.png"]];
                                                                          });
                                                                          //};
                                                                      }];
                                                                      [sessionQueue addOperation:stilImageCompletion];
                                                                      
                                                                      
                                                                  }];
             }  // end if (imageDataSampleBuffer)
         }];  // end operation block still
    }];
    [sessionQueue addOperation:blockOp];
}

- (void) handleVideoRecord {
    if (!isRecording) {
        canRotate=NO;
        NSBlockOperation* blockOp = [NSBlockOperation blockOperationWithBlock:^{
            
            //
            //  Shoot Video - set torch if needed
            //
            [self setFlash:self.avCaptureDeviceBack withFlashOn:NO];
            [self setTorch:self.avCaptureDeviceBack withTorchOn:YES];
            
            //
            //  Record
            //
            if ([[UIDevice currentDevice] isMultitaskingSupported])
            {
                // Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL:
                // callback is not received until AVCam returns to the foreground unless you request background execution time.
                // This also ensures that there will be time to write the file to the assets library when AVCam is backgrounded.
                // To conclude this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error: after the recorded file has been saved.
                backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
            }
            
            // Update the orientation on the movie file output video connection before starting recording.
            uiInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
            avCaptureVideoOrientation = (AVCaptureVideoOrientation) uiInterfaceOrientation;
            [[movieFileOutput connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:avCaptureVideoOrientation];
            
            
            //
            // Set metadata for the video file
            //
            NSArray *existingMetadataArray = movieFileOutput.metadata;
            NSMutableArray *newMetadataArray = nil;
            if (existingMetadataArray) {
                newMetadataArray = [existingMetadataArray mutableCopy];
            }
            else {
                newMetadataArray = [[NSMutableArray alloc] init];
            }
            
            //
            // Start recording to a temporary file.
            //
            NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"movie" stringByAppendingPathExtension:@"mov"]];
            [movieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
            
            
            //
            // Change Icon
            //
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.btnShoot.imageView
                 setImage:[UIImage imageNamed:@"media-recording.png"]];
            });
            isRecording = YES;
        }];
        //[blockOpCompletion addDependency:blockOp];
        [sessionQueue addOperation:blockOp];
        //[sessionQueue addOperation:blockOpCompletion];
        
        
    } else {
        //stop recording
        [movieFileOutput stopRecording];
        isRecording = NO;
        canRotate=YES;
        
        //
        // Change Icon
        //
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.btnShoot.imageView
             setImage:[UIImage imageNamed:@"media-recording-start.png"]];
        });
        
    }
}


#pragma mark File Output Delegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    if (error) {
        ALog(@"%@", error);
    }
    
    // Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
    backgroundRecordingID = UIBackgroundTaskInvalid;
    UIBackgroundTaskIdentifier backgroundRecordingIDForCompletionBlock = backgroundRecordingID;
    backgroundRecordingID = UIBackgroundTaskInvalid;
    
    //
    // Overlay copyright - fetch asset
    //
    AVAsset* avAsset = [AVAsset assetWithURL:outputFileURL];
    
    //
    // Debugging - check metadata
    //
    ALog(@"avAsset.metadata::%@",avAsset.metadata);
    
    //
    // Composition - Video and Audio
    //
    AVMutableComposition* mutableComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack* videoCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack* audioCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    
    //
    // Add the assets
    //
    AVAssetTrack *videoAssetTrack = [[avAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVAssetTrack *audioAssetTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration) ofTrack:videoAssetTrack atTime:kCMTimeZero error:nil];
    [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAssetTrack.timeRange.duration) ofTrack:audioAssetTrack atTime:kCMTimeZero error:nil];
    
    //
    // Adjust Orientation
    //
    uiInterfaceOrientation = [self orientationForTrack:videoAssetTrack];
    CGSize videoSize; //[[[videoAssetUrl tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize];
    if (UIInterfaceOrientationIsPortrait(uiInterfaceOrientation)) {
        // Invert the width and height for the video tracks to ensure that they display properly.
        videoSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
    } else if (UIInterfaceOrientationIsLandscape(uiInterfaceOrientation)) {
        // If the videos weren't shot in portrait mode, we can just use their natural sizes.
        videoSize = videoAssetTrack.naturalSize;
    }
    
    //
    // Copyright set in Preview Layer
    //
    [copyrightDictionary setValue:@"memreas user copyright identifiers"
                           forKey:@"header"];
    [copyrightDictionary setValue:userId forKey:@"user_id"];
    [copyrightDictionary setValue:device_id forKey:@"device_id"];
    [copyrightDictionary setValue:device_token forKey:@"device_token"];
    [copyrightDictionary setValue:md5_Mrights forKey:@"copyright_id_md5"];
    [copyrightDictionary setValue:sha1_Mrights forKey:@"copyright_id_sha1"];
    jsonCopyRight = [JSONUtil convertFromNSDictionary:copyrightDictionary];
    
    //
    // Text layer
    //
    CATextLayer *copyrightLayer = [CATextLayer layer];
    copyrightLayer.string = [NSString stringWithFormat:@"md5:%@ sha256:%@",md5_Mrights,sha256_Mrights];
    copyrightLayer.font = CFBridgingRetain(NSCOPYRIGHT_FONT);
    copyrightLayer.fontSize = 18;
    [copyrightLayer setForegroundColor:[UIColor blueColor].CGColor];
    //?? titleLayer.shadowOpacity = 0.5;
    copyrightLayer.alignmentMode = kCAAlignmentCenter;
    copyrightLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    
    //
    // Setup layers
    //
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    //parentLayer.frame = rect;
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    //videoLayer.frame = rect;
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:copyrightLayer]; //ONLY IF WE ADDED TEXT
    
    //
    // Composition Tool
    //
    AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
    videoComp.renderSize = videoSize;
    videoComp.frameDuration = CMTimeMake(1, 30);
    videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    //
    // Instructions
    //
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mutableComposition duration]);
    AVAssetTrack *videoTrack = [[mutableComposition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction* videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
    // Set the transform of the first layer instruction to the preferred transform of the first video track.
    CGAffineTransform videoPreferredTransform = videoAssetTrack.preferredTransform;
    [videoLayerInstruction setTransform:videoPreferredTransform atTime:kCMTimeZero];
    instruction.layerInstructions = [NSArray arrayWithObject:videoLayerInstruction];
    videoComp.instructions = [NSArray arrayWithObject: instruction];
    
    //
    // Export session
    //
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mutableComposition presetName:AVAssetExportPresetHighestQuality];
    _assetExport.videoComposition = videoComp;
    
    
    //
    // Fetch metadata
    //
    NSArray *existingMetadataArray = avAsset.metadata;
    NSMutableArray *newMetadataArray = nil;
    if (existingMetadataArray) {
        newMetadataArray = [existingMetadataArray mutableCopy];
    }
    else {
        newMetadataArray = [[NSMutableArray alloc] init];
    }
    
    
    //
    // Old location copyright
    //
    
    AVMutableMetadataItem *item = [[AVMutableMetadataItem alloc] init];
    item.keySpace = AVMetadataKeySpaceCommon;
    item.key = AVMetadataCommonKeyCopyrights;
    item.value = jsonCopyRight;
    [newMetadataArray addObject:item];
    _assetExport.metadata = newMetadataArray;
    ALog(@"exportAVAsset.metadata::%@", _assetExport.metadata);
    
    
    //
    // Mix to temp file
    //
    NSString *outputFilePathWithCopyRight = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"movie" stringByAppendingPathExtension:@"mov"]];
    NSURL    *outputFilePathWithCopyRightUrl = [NSURL fileURLWithPath:outputFilePathWithCopyRight];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePathWithCopyRight])
    {
        [[NSFileManager defaultManager] removeItemAtPath:outputFilePathWithCopyRight error:nil];
    }
    
    _assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    _assetExport.outputURL = outputFilePathWithCopyRightUrl;
    _assetExport.shouldOptimizeForNetworkUse = YES;
    
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:outputFilePathWithCopyRightUrl completionBlock:^(NSURL *assetURL, NSError *error) {
             if (error)
                 ALog(@"%@", error);
             
             [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
             [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:outputFilePathWithCopyRight] error:nil];
             
             if (backgroundRecordingIDForCompletionBlock != UIBackgroundTaskInvalid)
                 [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
             
             //
             // Generate checksum and add
             // to copyright for upload
             //
             NSString* fileCheckSumMD5 =[CheckSumUtil md5HashOfNSURL:assetURL];
             NSString* fileCheckSumSHA1 = [CheckSumUtil sha1HashOfNSURL:assetURL];
             NSString* fileCheckSumSHA256 = [CheckSumUtil sha256HashOfNSURL:assetURL];
             [copyright setObject:fileCheckSumMD5 forKey:@"fileCheckSumMD5"];
             [copyright setObject:fileCheckSumSHA1 forKey:@"fileCheckSumSHA1"];
             [copyright setObject:fileCheckSumSHA256 forKey:@"fileCheckSumSHA256"];
             
             //
             // init mediaItem
             //
             self.mediaItem = [[MediaItem alloc] initWithNSURL:assetURL];
             
             //
             // Set mediaItem copyright
             //
             self.mediaItem.copyright = copyright;
             
             //
             // Set mediaItem
             // copyright
             //
             self.mediaItem.mediaId = [copyright objectForKey:@"media_id"];
             
             //
             // Fetch thumbnail and update
             //
             [self.mediaItem fetchThumbnailForPHAsset:self.thumbnail.bounds.size];
             
             //
             // Check metadata
             //
             AVAsset* exportAVAsset = [AVAsset assetWithURL:outputFileURL];
             ALog(@"exportAVAsset.metadata::%@", exportAVAsset.metadata);
             
             
             //
             // Upload to S3
             //
             [[QueueController sharedInstance] addToPendingTransferArray:self.mediaItem
                                                        withTransferType:UPLOAD];
             
             //
             // Change Icon
             //
             __weak typeof(self) weakSelf = self;
             dispatch_async(dispatch_get_main_queue(), ^{
                 [weakSelf.thumbnail setContentMode:UIViewContentModeScaleAspectFit];
                 [weakSelf.thumbnail setImage:weakSelf.mediaItem.mediaLocalThumbnail];
             });
         }];
     }];
    
    
    //
    // Ok now we can end reset
    //
    NSBlockOperation* recordOpCompletion = [NSBlockOperation blockOperationWithBlock:^{
        //blockOp.completionBlock = ^{
        [self.avCaptureSession stopRunning];
        [self resetCopyright];
        //
        // refresh Preview and copyright
        //
        //[self refreshPreview:NO];
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.copyright_preview setText:[NSString stringWithFormat:@"md5:%@ sha256:%@",md5_Mrights,sha256_Mrights]];
            [weakSelf.view bringSubviewToFront:weakSelf.copyright_preview];
        });
        
        [self.avCaptureSession startRunning];
        
        //};
    }];
    [sessionQueue addOperation:recordOpCompletion];
    
}

//
// Fetch, update, and add copyright to metadata (exif, gps, tiff)
//
- (NSMutableDictionary*)fetchMetaDataUpdateAddCopyRight:
(CMSampleBufferRef)imageDataSampleBuffer {
    //
    // Fetch dictionary from sample buffer
    //
    CFDictionaryRef metaDict = CMCopyDictionaryOfAttachments(NULL, imageDataSampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadataNSDictionary = CFBridgingRelease(metaDict);
    ALog(@"fetchMetatDataUpdateAddCopyRight::metadata::%@",metadataNSDictionary);
    
    //
    // Fetch mutable copy of metadata
    //
    //CFMutableDictionaryRef mutableCFDictionaryCreateMutableCopy = CFDictionaryCreateMutableCopy(NULL, 0, metaDict);
    NSMutableDictionary *mutableNSDictionary =  CFBridgingRelease(CFDictionaryCreateMutableCopy(NULL, 0, metaDict));
    
    //Fetch main dictionaries
    NSMutableDictionary *exifDictionary = [metadataNSDictionary objectForKey:(NSString *)kCGImagePropertyExifDictionary];
    if (!exifDictionary) {
        exifDictionary = [[NSMutableDictionary dictionary]init];
    }
    NSMutableDictionary *gpsDictionary = [metadataNSDictionary objectForKey:(NSString *)kCGImagePropertyGPSDictionary];
    if (!gpsDictionary) {
        gpsDictionary = [[NSMutableDictionary dictionary]init];
    }
    
    //
    // Create formatted date
    //
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:timeZone];
    
    
    //
    // Set GPS Data
    //
    NSString *latitudeRef = locationCLLocationCoordinate2D.latitude < 0.0 ? @"S" : @"N";
    NSString *longitudeRef = locationCLLocationCoordinate2D.longitude < 0.0 ? @"W" : @"E";
    [gpsDictionary setValue:[NSNumber numberWithDouble:ABS(locationCLLocationCoordinate2D.latitude)] forKey:(NSString*)kCGImagePropertyGPSLatitude];
    [gpsDictionary setValue:[NSNumber numberWithDouble:ABS(locationCLLocationCoordinate2D.longitude)] forKey:(NSString*)kCGImagePropertyGPSLongitude];
    
    [gpsDictionary setValue:latitudeRef forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
    [gpsDictionary setValue:longitudeRef forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
    
    [formatter setDateFormat:@"HH:mm:ss.SS"];
    [gpsDictionary setValue:[formatter stringFromDate:[NSDate date]] forKey:(NSString*)kCGImagePropertyGPSTimeStamp];
    [formatter setDateFormat:@"dd-MMM-yyyy"];
    [gpsDictionary setValue:[formatter stringFromDate:[NSDate date]] forKey:(NSString*)kCGImagePropertyGPSDateStamp];
    [gpsDictionary setObject:[NSNumber numberWithFloat:locationCLLocationCoordinate2D.latitude]
                      forKey:(NSString*)kCGImagePropertyGPSLatitude];
    [gpsDictionary setObject:[NSNumber numberWithFloat:locationCLLocationCoordinate2D.longitude]
                      forKey:(NSString*)kCGImagePropertyGPSLongitude];
    [mutableNSDictionary setObject:gpsDictionary forKey:(NSString *)kCGImagePropertyGPSDictionary];
    
    //
    // fetch copyright
    //
    copyright = [sharedInstanceCopyRightManager fetchNextCopyRight];
    
    //
    // Add copyright to EXIF
    //
    md5_Mrights = [copyright objectForKey:@"copyright_id_md5"];
    sha1_Mrights = [copyright objectForKey:@"copyright_id_sha1"];
    sha256_Mrights = [copyright objectForKey:@"copyright_id_sha256"];
    
    [copyrightDictionary setValue:@"memreas user copyright identifiers"
                           forKey:@"header"];
    [copyrightDictionary setValue:userId forKey:@"user_id"];
    [copyrightDictionary setValue:device_id forKey:@"device_id"];
    [copyrightDictionary setValue:device_token forKey:@"device_token"];
    [copyrightDictionary setValue:md5_Mrights forKey:@"copyright_id_md5"];
    [copyrightDictionary setValue:sha1_Mrights forKey:@"copyright_id_sha1"];
    [copyrightDictionary setValue:sha256_Mrights forKey:@"copyright_id_sha256"];
    jsonCopyRight = [JSONUtil convertFromNSDictionary:copyrightDictionary];
    [exifDictionary setValue:jsonCopyRight
                      forKey:(NSString*)kCGImagePropertyExifUserComment];
    
    ALog(@"fetchMetatDataUpdateAddCopyRight::mutableNSDictionary::%@",mutableNSDictionary);
    
    return mutableNSDictionary;
}

//
// Fetch
//
- (void) finalizeImageRotateInscribeAddMetaData:(CMSampleBufferRef)imageDataSampleBuffer
                                   withMetaData:(NSMutableDictionary*) metadataWithCopyRightNSMutableDictionary {
    //
    //  Fetch original jpeg, rotate for CIImage and inscribe copyright
    //
    NSData* jpeg = [AVCaptureStillImageOutput
                    jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
    UIImage* originalBufferUIImage = [UIImage imageWithData:jpeg];
    
    NSString* md5_sha1_Mrights =
    [NSString stringWithFormat:@"md5:%@ sha1:%@", md5_Mrights, sha1_Mrights];
    //__block UIImage* imageWithMD5Inscribed =
    //[self rotateUIImageAddCopyRight:originalBufferUIImage
    //                  withCopyRight:md5_sha1_Mrights];
    
    //__block UIImage* imageWithMD5Inscribed =
    //[self rotateUIImageAddCopyRight:originalBufferUIImage withCopyRight:md5_sha1_Mrights];
    __block UIImage* imageWithMD5Inscribed =
    [self inscribeCopyRight:originalBufferUIImage withCopyRight:md5_sha1_Mrights];
    
    //
    // update metadata with orientation
    //
    //[metadataWithCopyRightNSMutableDictionary setObject:[NSNumber numberWithInt:[[UIApplication sharedApplication] statusBarOrientation]] forKey:@"Orientation"];
    
    [metadataWithCopyRightNSMutableDictionary setObject:[NSNumber numberWithInt:self.currentDeviceOrientation] forKey:@"Orientation"];
    //self.imageWithMD5SHA1InscribedUIImage = imageWithMD5Inscribed;
    
    
    //
    //  Fetch Image as CGImageSourceRef
    //
    NSData* imageWithMD5InscribedNSData = UIImageJPEGRepresentation(imageWithMD5Inscribed, 1.0);
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge_retained CFDataRef)imageWithMD5InscribedNSData, NULL);
    //CFDataRef imageWithMD5InscribedCFDataRef =
    //CFDataCreate(NULL, [imageWithMD5InscribedNSData bytes],
    //             [imageWithMD5InscribedNSData length]);
    //CGImageSourceRef source = CGImageSourceCreateWithData(imageWithMD5InscribedCFDataRef, NULL);
    
    //
    // Create empty NSMutable data - has autorelease
    //
    CFStringRef UTI = CGImageSourceGetType(source);
    self.imageWithMD5SHA1InscribedNSData = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)self.imageWithMD5SHA1InscribedNSData,UTI,1,NULL);
    
    
    //
    // If destination we can continue else image isn't correct.
    //
    if (!destination) {
        ALog(@"***Could not create image " @"destination ***");
    } else {
        
        
        //
        // add the image contained in the image source to the destination,
        // overidding the old metadata with our modified metadata
        //
        CGImageDestinationAddImageFromSource(destination, source, 0, (__bridge CFMutableDictionaryRef)metadataWithCopyRightNSMutableDictionary);
        
        // tell the destination to write the image data and metadata into our data
        // object. It will return false if something goes wrong
        BOOL success = CGImageDestinationFinalize(destination);
        
        if (!success) {
            ALog(@"***Could not create data from image destination ***");
        } else {
            ALog(@"***Created data from image destination!!! ***");
            self.imageWithMD5SHA1InscribedCIImage = [CIImage imageWithData:self.imageWithMD5SHA1InscribedNSData];
            self.imageWithMD5SHA1InscribedUIImage = [[UIImage alloc] initWithCIImage:self.imageWithMD5SHA1InscribedCIImage];
        }
    }
}


-(UIImage*)inscribeCopyRight:(UIImage*)image withCopyRight:(NSString*)copyright
{
    
    UIFont *font = [UIFont fontWithName:NSCOPYRIGHT_FONT size:COPYRIGHT_FONT_SIZE];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width, image.size.height)];
    CGRect rect = CGRectMake(0, 0, image.size.width,self.copyright_preview.frame.size.height);
    [[UIColor clearColor] set];
    
    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc] initWithString:copyright];
    NSRange range = NSMakeRange(0, [attString length]);
    
    [attString addAttribute:NSFontAttributeName value:font range:range];
    [attString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:range];
    
    NSShadow* shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    shadow.shadowOffset = CGSizeMake(1.0f, 1.5f);
    [attString addAttribute:NSShadowAttributeName value:shadow range:range];
    
    [attString drawInRect:CGRectIntegral(rect)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIColor*)getColorfromColorString:(NSString*)colorname {
    SEL labelColor = NSSelectorFromString(colorname);
    UIColor* color = [UIColor performSelector:labelColor];
    return color;
}

- (UIInterfaceOrientation)orientationForTrack:(AVAssetTrack *)videoTrack
{
    //AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize size = [videoTrack naturalSize];
    CGAffineTransform txf = [videoTrack preferredTransform];
    
    if (size.width == txf.tx && size.height == txf.ty) {
        ALog(@"UIInterfaceOrientationLandscapeRight");
        return UIInterfaceOrientationLandscapeRight;
    } else if (txf.tx == 0 && txf.ty == 0) {
        ALog(@"UIInterfaceOrientationLandscapeLeft");
        return UIInterfaceOrientationLandscapeLeft;
    } else if (txf.tx == 0 && txf.ty == size.width) {
        ALog(@"UIInterfaceOrientationLandscapeUpsideDown");
        return UIInterfaceOrientationPortraitUpsideDown;
    } else {
        ALog(@"UIInterfaceOrientationPortrait");
        return UIInterfaceOrientationPortrait;
    }
}

-(void) currentLocationSettings
{
    //---- For getting current gps location
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    currentLocation = [locations objectAtIndex:0];
    
    locationCLLocationCoordinate2D.longitude = currentLocation.coordinate.longitude;
    locationCLLocationCoordinate2D.latitude = currentLocation.coordinate.latitude;
    [locationManager stopUpdatingLocation];
}

@end

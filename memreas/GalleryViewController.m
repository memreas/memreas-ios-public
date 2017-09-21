#define IS_IPHONE_5                                                         \
(fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)568) < \
DBL_EPSILON)

#import "GalleryViewController.h"
#import "ELCAsset.h"
#import "GridCell.h"
#import "MyConstant.h"
#import "MyView.h"
#import "MyMovieViewController.h"
#import "FullScreenView.h"
#import "GridCell.h"
#import "Util.h"
#import "MediaIdManager.h"
#import "CopyrightManager.h"
#import "MIOSDeviceDetails.h"
#import "SettingButton.h"
#import "NSIndexSet+Convenience.h"
#import "NSIndexSet+Convenience.h"
#import "UICollectionView+Convenience.h"
#import "UICollectionView+Convenience.h"
#import "UIImageView+AFNetworking.h"
#import "NSString+SrtingUrlValidation.h"

@implementation GalleryViewController {
    GalleryManager* sharedGalleryInstance;
    QueueController* sharedQueueControllerInstance;
    GMSMapView* googleMap;
    CLLocationManager* locationManager;
    MBProgressHUD* HUD;
    NSInteger currentIndexFullScreen;
    CGColorRef lightGrayCGColorRef;
    CGColorRef blackCGColorRef;
    CGSize cellSize;
    CGRect previousPreheatRect;
    BOOL isScrolling;
    BOOL needsRefresh;
    BOOL needsReload;
    NSUInteger galleryCount;
    PHImageRequestOptions* phImageRequestOptions;
    PHImageRequestOptions* phImageCachingOptions;
    PHCachingImageManager* cachingImageManager;
    NSInteger dynamicCellSize;
    UIRefreshControl *refreshControl;
}

static bool isReturningFromFullScreen=NO;

+(void) setReturningFromFullScreen:(bool) returning {
    isReturningFromFullScreen = returning;
}

+(bool) isReturningFromFullScreen {
    return isReturningFromFullScreen;
}

#pragma mark - view controller lifecycle functions
- (void)viewDidLoad {
    @try {
        [super viewDidLoad];
        
        //
        // Google Banner View
        //
        self.bannerView.adUnitID = [[MIOSDeviceDetails sharedInstance] getAdUnitId];
        self.bannerView.rootViewController = self;
        [self.bannerView loadRequest:[GADRequest request]];
        
        //
        // Set Page Title
        //
        if (IS_IPAD) {
            [self.navigationController.navigationBar
             setBackgroundImage:[UIImage imageNamed:@"gallery"]
             forBarMetrics:UIBarMetricsDefault];
        } else {
            [self.navigationController.navigationBar
             setBackgroundImage:[UIImage imageNamed:@"nav_gallery"]
             forBarMetrics:UIBarMetricsDefault];
        }
        
        //
        // Set Observer for getuserdetails web services...
        //
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleGetUserDetailsMWS:)
                                                     name:GETUSERDETAILS_RESULT_NOTIFICATION
                                                   object:nil];
        
        //
        // Set Observer for getuserdetails web services...
        //
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleUpdateProgressMWS:)
                                                     name:GALLERY_UPDATE_PROGRESS
                                                   object:nil];
        
        //
        // Set Observer for getuserdetails web services...
        //
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(closeSpinnerView)
                                                     name:GALLERY_CLOSE_SPINNER
                                                   object:nil];
        
        
        //
        // Refresh Gallery
        //
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshGalleryView)
                                                     name:GALLERY_REFRESH_VIEW
                                                   object:self];
        
        //
        // Notifications menu
        //
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(openMenu)
                                                     name:@"OPEN"
                                                   object:self];
        
        //
        // Add observer for photo library
        //
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        self.isPhotoChangeObserverOn = YES;
        
        //
        // Caching manager
        //
        //self.cachingImageManager = [[PHCachingImageManager alloc] init];
        //[self startCaching];
        
        
        // set color refs
        lightGrayCGColorRef = [[UIColor lightGrayColor] CGColor];
        blackCGColorRef = [[UIColor blackColor] CGColor];
        
        //
        // Set current controller
        //
        appDelegate.currentView = @"GalleryViewController";
        
        //
        // Hide full screen
        //
        self.fullScreenView.hidden = 1;
        
        //
        // Gallery View - hide sync section
        //
        self.syncView.hidden = 1;
        
        //
        // Gallery View - hide sync section
        //
        self.galleryView.hidden = 0;
        
        //
        // Set segment controller view
        //
        [self.segViewSync setBackgroundColor:[UIColor blackColor]];
        NSDictionary* attributes = [NSDictionary
                                    dictionaryWithObjectsAndKeys:[UIColor whiteColor],
                                    NSForegroundColorAttributeName, nil];
        [self.segViewSync setTitleTextAttributes:attributes
                                        forState:UIControlStateNormal];
        
        //
        //  Setup view as default with light gray text highlight
        //
        attributes = [NSDictionary
                      dictionaryWithObjectsAndKeys:[UIColor lightGrayColor],
                      NSForegroundColorAttributeName, nil];
        [self.segViewSync setTitleTextAttributes:attributes
                                        forState:UIControlStateSelected];
        [self.segViewSync setSelectedSegmentIndex:0];
        
        //
        // set titles
        //
        [self.segViewSync setTitle:@"view" forSegmentAtIndex:0];
        [self.segViewSync setTitle:@"shoot" forSegmentAtIndex:1];
        [self.segViewSync setTitle:@"sync" forSegmentAtIndex:2];
        [self.segViewSync setTitle:@"location" forSegmentAtIndex:3];
        
        //
        // Setup swipe gesture for Full Screen
        //
        UISwipeGestureRecognizer* swipeLeft = [[UISwipeGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(handleSwipe:)];
        UISwipeGestureRecognizer* swipeRight = [[UISwipeGestureRecognizer alloc]
                                                initWithTarget:self
                                                action:@selector(handleSwipe:)];
        [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
        [self.fullScreenImageView addGestureRecognizer:swipeLeft];
        [self.fullScreenImageView addGestureRecognizer:swipeRight];
        
        
        //
        // Sync Info Boxes
        // 1 - Red
        // 2 - Yellow
        // 3 - Orange
        // 4 - Green
        //
        [[self.btnRed layer] setBorderWidth:2.0f];
        [[self.btnRed layer] setBorderColor:[UIColor redColor].CGColor];
        self.btnRed.tag = 1;
        [self.btnRed addTarget:self
                        action:@selector(showAlertforSyncIcons:)
              forControlEvents:UIControlEventTouchUpInside];
        [[self.btnYellow layer] setBorderWidth:2.0f];
        [[self.btnYellow layer] setBorderColor:[UIColor yellowColor].CGColor];
        self.btnYellow.tag = 2;
        [self.btnYellow addTarget:self
                           action:@selector(showAlertforSyncIcons:)
                 forControlEvents:UIControlEventTouchUpInside];
        [[self.btnOrange layer] setBorderWidth:2.0f];
        [[self.btnOrange layer] setBorderColor:[UIColor orangeColor].CGColor];
        self.btnOrange.tag = 3;
        [self.btnOrange addTarget:self
                           action:@selector(showAlertforSyncIcons:)
                 forControlEvents:UIControlEventTouchUpInside];
        [[self.btnGreen layer] setBorderWidth:2.0f];
        [[self.btnGreen layer] setBorderColor:[UIColor greenColor].CGColor];
        self.btnGreen.tag = 4;
        [self.btnGreen addTarget:self
                          action:@selector(showAlertforSyncIcons:)
                forControlEvents:UIControlEventTouchUpInside];
        
        //
        // Set options for synchronous thumbnails
        //
        phImageRequestOptions = [[PHImageRequestOptions alloc] init];
        phImageRequestOptions.synchronous = NO;
        phImageRequestOptions.deliveryMode =
        PHImageRequestOptionsDeliveryModeHighQualityFormat;
        //phImageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
        
        //
        // Set bounce effects
        //
        self.gridCollectionView.bounces = YES;
        self.gridCollectionView.alwaysBounceVertical = YES;
        
        // Initialize Map
        [self initLocationForMap];
        
        //
        // Show Spinner
        //
        [self openSpinnerView];
        
        //
        //  Fetch User Detail
        //
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            //Background Thread
            [self getCurrentUserDetail];
        });
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    @try {
        
        //trying to fix status bar issue
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        [super viewDidAppear:animated];
        
        
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        
        // setup cell size
        if (IS_IPAD) {
            dynamicCellSize = CELLSIZE_IPAD;
        } else {
            dynamicCellSize = CELLSIZE_IPHONE;
        }
        
        //
        // Show default view
        //
        [self.segViewSync setSelectedSegmentIndex:0];
        [self openSpinnerView];
        [self segmentChanged:self.segViewSync];
        [self closeSpinnerView];
        
        //
        // Call to load gallery in background...
        //
        if (sharedGalleryInstance == nil) {
            [self reloadGallery];
        }
        
        //
        // Call to update view if change to photos observer called
        //
        if (needsReload) {
            //[self reloadGallery];
            [self viewDidLoad];
            needsReload = NO;
        }
        
        

        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

- (void)getCurrentUserDetail {
    /**
     * Use XMLGenerator...
     */
    NSString* requestXML = [XMLGenerator generateGetUserDetailsXML:[Helper fetchSID]
                                                           user_id:[Helper fetchUserId]];
    //ALog(@"Request:- %@", requestXML);
    
    /**
     * Use WebServices Request Generator
     */
    
    NSMutableURLRequest* request =
    [WebServices generateWebServiceRequest:requestXML action:GETUSERDETAILS];
    //ALog(@"NSMutableRequest request ----> %@", request);
    
    /**
     * Send Request and Parse Response...
     */
    MWebServiceHandler* wsHandler = [[MWebServiceHandler alloc] init];
    [wsHandler fetchServerResponse:request action:GETUSERDETAILS key:GETUSERDETAILS_RESULT_NOTIFICATION];
}


- (void)handleGetUserDetailsMWS:(NSNotification*)notification {
    NSDictionary* resultTags = [notification userInfo];
    NSString* status = @"";
    status = [resultTags objectForKey:@"status"];
    if ([[status lowercaseString] isEqualToString:@"success"]) {
        NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary* userDetailDict = [[NSMutableDictionary alloc] init];
        [userDetailDict setObject:[resultTags objectForKey:@"username"]
                           forKey:@"ownerName"];
        [userDetailDict setObject:[resultTags objectForKey:@"profile"]
                           forKey:@"ownerImage"];
        [userDefault setObject:userDetailDict forKey:@"userDetail"];
        [userDefault synchronize];
    }
}


- (void) openSpinnerView {
    //
    // spinner closes in cell count
    //
    self.spinnerView.hidden = 0;
    self.viewLoading.hidden = 0;
}

- (void) closeSpinnerView {
    //
    // spinner closes in cell count
    //
    self.spinnerView.hidden = 1;
    self.viewLoading.hidden = 1;
}


- (void)handleUpdateProgressMWS:(NSNotification*)notification {
    NSDictionary* resultTags = [notification userInfo];
    NSString* progress = @"";
    progress = [resultTags objectForKey:@"progress"];
    
    [self.lblProgress setText:progress];
}


- (void)updateLblProgress:(NSString*)txtProgress {
    [self.lblProgress setText:txtProgress];
    //[self.lblProgress performSelectorOnMainThread:@selector(setText:) withObject:txtProgress waitUntilDone:YES];
}


- (void)viewWillDisappear:(BOOL)animated {
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

#pragma mark
#pragma mark Segment Control method
- (IBAction)segmentChanged:(UISegmentedControl*)sender {
    
    switch (self.segViewSync.selectedSegmentIndex) {
        case 0:
            //
            // re-register change observer if camera was called
            //
            if (!self.isPhotoChangeObserverOn) {
                [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
            }
            self.syncView.hidden = 1;
            self.spinnerView.hidden = 1;
            break;
        case 1:
            self.syncView.hidden = 1;
            self.spinnerView.hidden = 1;
            //
            // Unregister change observer while camera is running
            //
            if (self.isPhotoChangeObserverOn) {
                [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
            }
            //
            // Now segue
            //
            [self performSegueWithIdentifier:@"segueMCameraViewController"
                                      sender:self];
            break;
        case 2:
            //
            // re-register change observer if camera was called
            //
            if (!self.isPhotoChangeObserverOn) {
                [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
            }
            self.syncView.hidden = 0;
            self.spinnerView.hidden = 1;
            break;
        case 3:
            //
            // re-register change observer if camera was called
            //
            if (!self.isPhotoChangeObserverOn) {
                [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
            }
            self.syncView.hidden = 1;
            self.spinnerView.hidden = 1;
            [self performSegueWithIdentifier:@"segueGalleryLocationViewController"
                                      sender:self];
            break;
        default:
            break;
    }
    
    [self refreshGalleryView];
}

#pragma mark
#pragma mark Gallery refresh and reload methods

- (void)refreshGalleryView {
    //not scrolling and view is showing
    if ((!isScrolling) && (self.isViewLoaded && self.view.window))  {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.gridCollectionView reloadData];
        });
    }
}

- (void) reloadGallery {
    @try {
        
        //if (self.isViewLoaded && self.view.window){
        //}
        
        //
        // stop caching
        //
        [self stopCaching];
        
        // viewController is visible
        [self openSpinnerView];
        [GalleryManager resetSharedGalleryInstance]; // sets to nil and recreates
        sharedGalleryInstance = [GalleryManager sharedGalleryInstance];
        sharedGalleryInstance.delegate = self;
        [self startCaching];
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}



#pragma mark
#pragma mark Photo Library Change Observer
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    /*
     if ((!isScrolling) && !sharedGalleryInstance.isLoading) {
     __weak typeof(self) weakSelf = self;
     dispatch_async(dispatch_get_main_queue(), ^{
     [weakSelf reloadGallery];
     });
     } else if (isScrolling) {
     needsRefresh = YES;
     }
     
     //check the queue controller - only update once done - avoid crash...
     //even if scrolling grid must reload...
     sharedQueueControllerInstance = [QueueController sharedInstance];
     if ((!sharedGalleryInstance.isLoading) &&
     (![sharedQueueControllerInstance hasPendingTransfers])) {
     __weak typeof(self) weakSelf = self;
     dispatch_async(dispatch_get_main_queue(), ^{
     [weakSelf reloadGallery];
     });
     }
     */
    needsReload = YES;
    
}



#pragma mark
#pragma mark Gallery related methods
- (void)stopCaching {
    [self.cachingImageManager stopCachingImagesForAllAssets];
    self.cachingImageManager = nil;
}
- (void)startCaching {
    
    //
    // set to nil if active...
    //
    self.cachingImageManager = nil;
    
    //
    // Start Caching
    //
    self.cachingImageManager = [[PHCachingImageManager alloc] init];
    phImageCachingOptions = [[PHImageRequestOptions alloc] init];
    phImageCachingOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    [self.cachingImageManager
     startCachingImagesForAssets:sharedGalleryInstance.phAssetsNSMutableArray
     targetSize:CGSizeMake(dynamicCellSize,
                           dynamicCellSize)
     contentMode:PHImageContentModeAspectFill
     options:phImageCachingOptions];
}


- (void)fetchImage:(PHAsset*) localMediaPHAsset
        withCGSize:(CGSize)size
andWithUIImageView:(UIImageView*)imageView
   andWithDispatch:(BOOL)doDispatch{
    [self.cachingImageManager
     requestImageForAsset:localMediaPHAsset
     targetSize:size
     contentMode:PHImageContentModeAspectFit
     options:phImageRequestOptions  // synchronous
     resultHandler:^(UIImage* result, NSDictionary* info) {
         if (doDispatch) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [imageView setImage:result];
             });
         }
     }];
}


#pragma mark - UIScrollViewDelegate

-(void) displayfetch:(bool)turnOn andWithIsReloading:(bool) isReloading {
    NSString* fetchingMsg = @"fetching";
    NSString* reloadingMsg = @"reloading";
    NSString* msg = @"";
    
    if (isReloading) {
        msg = reloadingMsg;
    } else {
        msg = fetchingMsg;
    }
    __weak typeof(self) weakSelf = self;
    if (turnOn) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.spinnerView.hidden = 0;
            weakSelf.viewLoading.hidden = 0;
            [weakSelf.lblProgress setText:msg];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.spinnerView.hidden = 1;
            weakSelf.viewLoading.hidden = 1;
        });
        
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    isScrolling = YES;
    [self displayfetch:YES andWithIsReloading:needsRefresh];
    //[self.cachingImageManager stopCachingImagesForAllAssets];
    
}
-(void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self handleScrolling:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self handleScrolling:scrollView];
}

- (void) handleScrolling:(UIScrollView *)scrollView {
    isScrolling = NO;
    [self displayfetch:NO andWithIsReloading:NO];
    if ((self.lastContentOffset <= 0) && (0 >= scrollView.contentOffset.y)) {
        needsRefresh = YES;
        //
        // Ask user if they want to refresh
        //
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"gallery refresh"
                                              message:@"do you want to refresh your gallery?"
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"cancel", @"cancel action")
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           ALog(@"cancel action");
                                       }];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"ok", @"ok action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       ALog(@"ok action");
                                       @try {
                                           [self closeSpinnerView];
                                           [self reloadGallery];
                                           needsRefresh = NO;
                                       } @catch (NSException* exception) {
                                           ALog(@"%@", exception);
                                       }
                                   }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    self.lastContentOffset = scrollView.contentOffset.y;
}

#pragma mark
#pragma mark Collection View Method
//
// GridCollectionvsView Delegates
//
- (NSInteger) checkGalleryCount {
    if (needsReload) {
        return 0;
    }
    if ((sharedGalleryInstance.hasFinishedLoading) && (!isScrolling)){
        self.spinnerView.hidden = 1;
        self.viewLoading.hidden = 1;
        @synchronized(sharedGalleryInstance) {
            galleryCount = sharedGalleryInstance.galleryNSMutableArray.count;
        }
    }
    return galleryCount;

}
- (NSInteger)collectionView:(UICollectionView*)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [self checkGalleryCount];
}

//set a custom size for iPad...
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(dynamicCellSize, dynamicCellSize);
}
- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
                 cellForItemAtIndexPath:(NSIndexPath*)indexPath {
    @try {
        // Fetch mediaItem...
        
        MediaItem* mediaItem;
        @synchronized(sharedGalleryInstance) {
            mediaItem = [sharedGalleryInstance.galleryNSMutableArray[indexPath.item] copy];
        }
        
        //borderWidth
        float widthB = 2;
        
        //
        // Handle Server items
        //
        if (mediaItem.mediaState == SERVER) {
            __weak GridCell* cell = (GridCell*)
            [collectionView dequeueReusableCellWithReuseIdentifier:@"ServerCell"
                                                      forIndexPath:indexPath];
            
            //fix for resizing cell..
            cell.contentView.frame = cell.bounds;
            cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            //
            // Setup cell - clear any past references i.e. image or video thumbnails
            //
            __weak MyView* myView = cell.myView;
            myView.btnPhoto.tag = indexPath.item;
            myView.imgPhoto.layer.cornerRadius = 10;
            myView.imgPhoto.layer.masksToBounds = YES;
            myView.imgPhoto.clipsToBounds = YES;
            myView.layer.borderWidth = widthB;
            [myView setBackgroundColor:[UIColor clearColor]];
            myView.layer.borderColor = [UIColor clearColor].CGColor;
            [myView.btnPhoto setBackgroundImage:nil forState:UIControlStateNormal];
            [myView.btnPhoto setBackgroundImage:nil forState:UIControlStateSelected];
            myView.btnPhoto.selected = NO;
            
            //
            // Clear thumbnail
            //
            [myView.imgPhoto setImage:[UIImage imageNamed:@"gallery_img"]];
            [myView.imgVideo setContentMode:UIViewContentModeCenter];
            
            //ALog(@"media_transcode_status::%@",mediaItem.mediaTranscodeStatus);
            if ([[mediaItem.mediaTranscodeStatus lowercaseString] isEqualToString:@"success"]) {
                
                //                [myView.imgPhoto setImage:[UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:mediaItem.mediaThumbnailUrl79x80[0]]]]];
                [myView.imgPhoto setImageWithURL:[NSURL URLWithString:[[mediaItem.mediaThumbnailUrl79x80 firstObject] urlEnocodeString]] placeholderImage:[UIImage imageNamed:@"gallery_img"]];
                
            } else if ([[mediaItem.mediaTranscodeStatus lowercaseString] isEqualToString:@"failure"]) {
                [myView.imgPhoto setImage:[UIImage imageNamed:@"gallery_img"]];
            } else {
                [myView.imgPhoto setImage:[UIImage imageNamed:@"TranscodingDisc"]];
            }
            
            [myView.btnPhoto removeTarget:self
                                   action:@selector(showAlertForAlreadyExsist)
                         forControlEvents:UIControlEventTouchUpInside];
            
            //
            // Handle tabs...
            //
            switch (self.segViewSync.selectedSegmentIndex) {
                case 0: {
                    // View
                    [myView.btnPhoto removeTarget:self
                                           action:@selector(mediaTouchForSync:)
                                 forControlEvents:UIControlEventTouchUpInside];
                    [myView.btnPhoto setBackgroundImage:nil
                                               forState:UIControlStateNormal];
                    [myView.btnPhoto addTarget:self
                                        action:@selector(openGalleryMedia:)
                              forControlEvents:UIControlEventTouchUpInside];
                    break;
                }
                    
                case 1: {
                    // Shoot
                    [myView.btnPhoto removeTarget:self
                                           action:@selector(mediaTouchForSync:)
                                 forControlEvents:UIControlEventTouchUpInside];
                    [myView.btnPhoto setBackgroundImage:nil
                                               forState:UIControlStateNormal];
                    [myView.btnPhoto addTarget:self
                                        action:@selector(openGalleryMedia:)
                              forControlEvents:UIControlEventTouchUpInside];
                    [self setBorderColor:cell withMediaState:mediaItem.mediaState];
                    break;
                }
                    
                case 2: {
                    // Sync
                    [myView.btnPhoto removeTarget:self
                                           action:@selector(openGalleryMedia:)
                                 forControlEvents:UIControlEventTouchUpInside];
                    [myView.btnPhoto addTarget:self
                                        action:@selector(mediaTouchForSync:)
                              forControlEvents:UIControlEventTouchUpInside];
                    [self setBorderColor:cell withMediaState:mediaItem.mediaState];
                    // Set cell selectedForSync
                    if (![mediaItem.codecLevel isEqualToString:@"mp42"]) {
                        if (mediaItem.isSelectedForSync) {
                            myView.btnPhoto.selected = YES;
                            [myView.btnPhoto setImage:[UIImage imageNamed:@"Overlay"]
                                             forState:UIControlStateNormal];
                        } else {
                            myView.btnPhoto.selected = NO;
                            [myView.btnPhoto setImage:nil
                                             forState:UIControlStateNormal];
                        }
                    }
                    break;
                }
                    
                default:
                    break;
            }
            
            // Set URLs for videos and images only...
            // ALog(@"server mediaItem.mediaType -----> %@", mediaItem.mediaType);
            if (([mediaItem.mediaType length] != 0) &&
                [mediaItem.mediaType isEqualToString:@"video"]) {
                // Video
                // Apply first image
                [myView.imgPhoto setImageWithURL:[NSURL URLWithString:[[mediaItem.mediaThumbnailUrl79x80 firstObject] urlEnocodeString]] placeholderImage:[UIImage imageNamed:@"gallery_img"]];
                
                
                //                [myView.imgPhoto setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:mediaItem.mediaThumbnailUrl79x80[0]]]]];
                
                [myView.imgVideo setContentMode:UIViewContentModeCenter];
                [myView.imgVideo setImage:[UIImage imageNamed:@"video_play"]];
                myView.imgVideo.hidden = 0;
            } else if (([mediaItem.mediaType length] != 0) &&
                       [mediaItem.mediaType isEqualToString:@"image"]) {
                [myView.btnPhoto setImage:nil forState:UIControlStateNormal];
                [myView.imgPhoto stopAnimating];
                myView.imgPhoto.animationImages = nil;
                
                // ALog(@"79x80 url: %@", mediaItem.mediaThumbnailUrl79x80[0]);
                [myView.imgPhoto setImageWithURL:[NSURL URLWithString:[[mediaItem.mediaThumbnailUrl79x80 firstObject] urlEnocodeString]] placeholderImage:[UIImage imageNamed:@"gallery_img"]];
                
                //                [myView.imgPhoto setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:mediaItem.mediaThumbnailUrl79x80[0]]]]];
                myView.imgVideo.hidden = 1;
            }
            
            if (sharedGalleryInstance.galleryNSMutableArray.count <= indexPath.item) {
                self.viewLoading.hidden = 1;
            }
            
            return cell;
        } else {
            //
            // Handle Sync / NOT_SYNC items
            //
            __weak GridCell* cell = (GridCell*)
            [collectionView dequeueReusableCellWithReuseIdentifier:@"LocalCell"
                                                      forIndexPath:indexPath];
            
            //fix for resizing cell..
            cell.contentView.frame = cell.bounds;
            cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            NSInteger currentTag = indexPath.item;
            cell.tag = currentTag;
            ELCAsset* elcAsset = cell.elcAsset;
            // clear cell for reuse
            [elcAsset.assetImageViewHome setImage:nil];
            [elcAsset.overlayViewHome setImage:nil];
            [elcAsset.videoImageViewHome setImage:nil];
            
            [elcAsset setBackgroundColor:[UIColor clearColor]];
            elcAsset.assetImageViewHome.layer.cornerRadius = 10;
            elcAsset.assetImageViewHome.layer.masksToBounds = YES;
            elcAsset.assetImageViewHome.clipsToBounds = YES;
            elcAsset.layer.borderWidth = widthB;
            elcAsset.layer.borderColor = [UIColor clearColor].CGColor;
            elcAsset.layer.cornerRadius = 10;
            elcAsset.buttonHome.tag = indexPath.item;
            elcAsset.buttonHome.selected = NO;
            elcAsset.overlayViewHome.hidden = YES;
            elcAsset.buttonHome.hidden = NO;
            
            
            //
            // Fetch Thumbnail - synchronous
            //
            cellSize = cell.size;
            [self fetchImage:[mediaItem.mediaLocalPHAsset copy]
                  withCGSize:cell.size
          andWithUIImageView:elcAsset.assetImageViewHome
             andWithDispatch:YES];
            
            if (elcAsset.assetImageViewHome.image == nil) {
                [elcAsset.assetImageViewHome
                 setImage:[UIImage imageNamed:@"gallery_img_load"]];
            }
            
            // Set URLs for videos and images only...
            // ALog(@"local mediaItem.mediaType -----> %@", mediaItem.mediaType);
            if ([mediaItem.mediaType isEqualToString:@"video"]) {
                [elcAsset.videoImageViewHome setContentMode:UIViewContentModeCenter];
                [elcAsset.videoImageViewHome
                 setImage:[UIImage imageNamed:@"video_play"]];
                elcAsset.videoImageViewHome.hidden = 0;
            } else {
                elcAsset.videoImageViewHome.hidden = 1;
            }
            
            [elcAsset setParent:self];
            elcAsset.tag = indexPath.item;
            
            switch (self.segViewSync.selectedSegmentIndex) {
                case 0: {
                    // View
                    [elcAsset.buttonHome removeTarget:self
                                               action:@selector(mediaTouchForSync:)
                                     forControlEvents:UIControlEventTouchUpInside];
                    [elcAsset.buttonHome addTarget:self
                                            action:@selector(openGalleryMedia:)
                                  forControlEvents:UIControlEventTouchUpInside];
                    
                    elcAsset.overlayViewHome.hidden = YES;
                    elcAsset.buttonHome.hidden = NO;
                    [elcAsset.buttonHome setBackgroundImage:nil
                                                   forState:UIControlStateNormal];
                    [cell bringSubviewToFront:elcAsset];
                    break;
                }
                case 1: {
                    // Shoot
                    elcAsset.layer.borderColor = [UIColor redColor].CGColor;
                    [elcAsset.buttonHome removeTarget:self
                                               action:@selector(mediaTouchForSync:)
                                     forControlEvents:UIControlEventTouchUpInside];
                    [elcAsset.buttonHome addTarget:self
                                            action:@selector(openGalleryMedia:)
                                  forControlEvents:UIControlEventTouchUpInside];
                    [self setBorderColor:cell withMediaState:mediaItem.mediaState];
                    
                    elcAsset.buttonHome.hidden = NO;
                    [elcAsset.buttonHome setBackgroundImage:nil
                                                   forState:UIControlStateNormal];
                    [cell bringSubviewToFront:elcAsset.buttonHome];
                    elcAsset.overlayViewHome.hidden = YES;
                    break;
                }
                case 2: {
                    // Sync - handle In_Transit also
                    ALog(@"getMediaStateAsString-->%@", [mediaItem getMediaStateAsString]);
                    //elcAsset.layer.borderColor = [UIColor redColor].CGColor;
                    [self setBorderColor:cell withMediaState:mediaItem.mediaState];
                    elcAsset.buttonHome.hidden = NO;
                    [elcAsset.buttonHome removeTarget:self
                                               action:@selector(openGalleryMedia:)
                                     forControlEvents:UIControlEventTouchUpInside];
                    [elcAsset.buttonHome addTarget:self
                                            action:@selector(mediaTouchForSync:)
                                  forControlEvents:UIControlEventTouchUpInside];
                    [self setBorderColor:cell withMediaState:mediaItem.mediaState];
                    
                    // Set cell selectedForSync
                    if (mediaItem.isSelectedForSync) {
                        [elcAsset.buttonHome
                         setBackgroundImage:[UIImage imageNamed:@"Overlay"]
                         forState:UIControlStateNormal];
                    } else {
                        [elcAsset.buttonHome setBackgroundImage:nil
                                                       forState:UIControlStateNormal];
                    }
                    [cell bringSubviewToFront:elcAsset];
                    break;
                }
                default:
                    break;
            }
            //ALog(@"%@%@ %s %d %s %s", @"END LOCAL CELL COUNT::", @(galleryCount), __FILE__, __LINE__, __PRETTY_FUNCTION__, __FUNCTION__);
            return cell;
            
        }  // end else if local
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

#pragma mark
#pragma mark Refresh Ok/Cancel
/*
 - (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
 {
 //ALog(@"Button Index =%ld",buttonIndex);
 if (buttonIndex == 0)
 {
 ALog(@"You have clicked Cancel");
 }
 else if(buttonIndex == 1)
 {
 ALog(@"You have clicked Ok");
 }
 }
 */
#pragma mark
#pragma mark Button Touch Handling
- (IBAction)doneAction:(id)sender {
    @try {
        if (self.selectedForSync.count > 0) {
            
            // add transfer
            QueueController* queueController = [QueueController sharedInstance];
            for (MediaItem* mediaItem in self.selectedForSync) {
                if (mediaItem.mediaState == NOT_SYNC) {
                    [queueController addToPendingTransferArray:mediaItem
                                              withTransferType:UPLOAD];
                    mediaItem.mediaState = IN_TRANSIT;
                } else if (mediaItem.mediaState == SERVER) {
                    [queueController addToPendingTransferArray:mediaItem
                                              withTransferType:DOWNLOAD];
                    mediaItem.mediaState = IN_TRANSIT;
                }
                mediaItem.isSelectedForSync = NO;
            }
            queueController = nil;
            
            [self clearSelected:self];
            //update colors
            [self.gridCollectionView reloadData];
            // Segue to Queue tab here...
            [self.tabBarController setSelectedIndex:1];
            
        } else {
            [Helper showMessageFade:self.view withMessage:@"no media selected" andWithHideAfterDelay:3];
        }
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

- (IBAction)clearSelected:(id)sender {
    [self.selectedForSync removeAllObjects];
    [self.gridCollectionView reloadData];
}

- (void)setBorderColor:(GridCell*)cell
        withMediaState:(MediaItemState)mediaState {
    @try {
        MyView* myView = cell.myView;
        ELCAsset* elcAsset = cell.elcAsset;
        if (mediaState == SYNC) {
            elcAsset.layer.borderColor = [UIColor greenColor].CGColor;
            cell.layer.borderColor = [UIColor greenColor].CGColor;
            
            if (self.segViewSync.selectedSegmentIndex == 2) {
                [myView.btnPhoto addTarget:self
                                    action:@selector(showAlertForAlreadyExsist)
                          forControlEvents:UIControlEventTouchUpInside];
                [myView.btnPhoto removeTarget:self
                                       action:@selector(mediaTouchForSync:)
                             forControlEvents:UIControlEventTouchUpInside];
            }
        } else if (mediaState == NOT_SYNC) {
            elcAsset.layer.borderColor = [UIColor redColor].CGColor;
            cell.layer.borderColor = [UIColor redColor].CGColor;
        } else if (mediaState == IN_TRANSIT) {
            elcAsset.layer.borderColor = [UIColor orangeColor].CGColor;
            cell.layer.borderColor = [UIColor orangeColor].CGColor;
            
            if (self.segViewSync.selectedSegmentIndex == 2) {
                [cell.btnPhoto addTarget:self
                                  action:@selector(showAlertForMediaInTransit)
                        forControlEvents:UIControlEventTouchUpInside];
                [cell.btnPhoto removeTarget:self
                                     action:@selector(mediaTouchForSync:)
                           forControlEvents:UIControlEventTouchUpInside];
            }
        } else if (mediaState == SERVER) {
            myView.layer.borderColor = [UIColor yellowColor].CGColor;
            cell.layer.borderColor = [UIColor yellowColor].CGColor;
        }
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

- (void)mediaTouchForSync:(id)sender {
    /**
     * Check for sync tab
     */
    if (self.segViewSync.selectedSegmentIndex == 2) {
        UIButton* btn = (UIButton*)sender;
        NSInteger tag = btn.tag;
        MediaItem* mediaItem = sharedGalleryInstance.galleryNSMutableArray[tag];
        
        if (self.selectedForSync == nil) {
            self.selectedForSync = [[NSMutableArray alloc] init];
        }
        if (btn.selected) {
            if ((mediaItem.mediaState == SERVER) ||
                (mediaItem.mediaState == NOT_SYNC)) {
                btn.selected = NO;
                //[btn setBackgroundImage:[UIImage imageNamed:nil]
                //               forState:UIControlStateNormal];
                [btn setBackgroundImage:nil
                               forState:UIControlStateNormal];
                [self.selectedForSync removeObject:mediaItem];
                mediaItem.isSelectedForSync = NO;
                //} else if ((mediaItem.mediaState == SYNC) || (mediaItem.mediaState == IN_TRANSIT)) {
            } else {
                // set to no for SYNC and IN_TRANSIT
                mediaItem.isSelectedForSync = NO;
            }
        } else {
            if ((mediaItem.mediaState == SERVER) ||
                (mediaItem.mediaState == NOT_SYNC)) {
                [self.selectedForSync addObject:mediaItem];
                mediaItem.isSelectedForSync = YES;
                btn.selected = YES;
                [btn setBackgroundImage:[UIImage imageNamed:@"Overlay"]
                               forState:UIControlStateNormal];
            } else if (mediaItem.mediaState == IN_TRANSIT) {
                // show alert
                mediaItem.isSelectedForSync = NO;
                [self showAlertForMediaInTransit];
            } else if (mediaItem.mediaState == SYNC) {
                // show alert
                mediaItem.isSelectedForSync = NO;
                [self showAlertForAlreadyExsist];
            }
        }
    }  // end if(self.segViewSync.selectedSegmentIndex == 2)
}

- (void)showAlertforSyncIcons:(UIButton*) sender {
    // 1 - red
    // 2 - yellow
    // 3 - orange
    // 4 - green
    NSString* msg;
    if (sender.tag == 1) {
        msg = @"red - device media";
    } else if (sender.tag == 2) {
        msg = @"yellow - cloud media";
    } else if (sender.tag == 3) {
        msg = @"orange - queued";
    } else if (sender.tag == 4) {
        msg = @"green - media syncd";
    }
    
    [Helper showMessageFade:self.view withMessage:msg andWithHideAfterDelay:2];
    
}

- (void)showAlertForMediaInTransit {
    [Helper showMessageFade:self.view withMessage:@"media is queued" andWithHideAfterDelay:2];
}
- (void)showAlertForAlreadyExsist {
    
    [Helper showMessageFade:self.view withMessage:@"media is syncd" andWithHideAfterDelay:2];
}

- (void)openGalleryMedia:(id)sender {
    @try {
        UIButton* btn = (UIButton*)sender;
        MediaItem* mediaItem = sharedGalleryInstance.galleryNSMutableArray[btn.tag];
        currentIndexFullScreen = btn.tag;
        [self enterFullScreenMode:currentIndexFullScreen withMediaItem:mediaItem];
        // ALog(@"openGalleryMedia::currentIndexFullScreen:%lu", btn.tag);
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

- (IBAction)backPressed:(id)sender {
    self.fullScreenView.hidden = 1;
    self.fullScreenImageView.image = nil;
    self.galleryView.hidden = 0;
}

- (IBAction)fullScreenPlayButtonTapped:(id)sender {
    
    //6-NOV-2016 return is breaking UI by showing status bar
    [self performSegueWithIdentifier:@"segueAVMoviePlayerViewController" sender:sender];
    
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    UIButton* btn = (UIButton*)sender;
    
    if ([[segue identifier] isEqualToString:@"segueAVMoviePlayerViewController"]) {
        MyMovieViewController* myMovieViewController =
        [segue destinationViewController];
        myMovieViewController.index = btn.tag;
    }
    
}

- (IBAction)prepareForUnwind:(UIStoryboardSegue*)segue {
}

- (void)enterFullScreenMode:(NSInteger)index
              withMediaItem:(MediaItem*)mediaItem {
    @try {
        // on a single  tap, call zoomToRect in UIScrollView
        if (![GalleryViewController isReturningFromFullScreen]) {
            
            self.galleryView.hidden = 1;
            self.spinnerView.hidden = 1;
            //self.bannerView.hidden = 1;
            self.fullScreenPlayButton.hidden = 1;
            self.fullScreenView.hidden = 0;
            self.fullScreenImageView.userInteractionEnabled = YES;
            
            if ((mediaItem.mediaState == SERVER) &&
                ([[mediaItem.mediaType lowercaseString] isEqualToString:@"video"])) {
                
                [self.fullScreenImageView setImageWithURL:[NSURL URLWithString:[[mediaItem.mediaThumbnailUrl1280x720 firstObject] urlEnocodeString]] placeholderImage:[UIImage imageNamed:@"gallery_img"]];
                
                self.fullScreenPlayButton.hidden = 0;
            } else if ((mediaItem.mediaState == SERVER) &&
                       ([[mediaItem.mediaType lowercaseString]
                         isEqualToString:@"image"])) {
                [self.fullScreenImageView setImageWithURL:[NSURL URLWithString:[[mediaItem.mediaUrl firstObject] urlEnocodeString]] placeholderImage:[UIImage imageNamed:@"gallery_img"]];
            } else {
                // Fetch via PHCachingImageManager for local images
                [self fetchImage:[mediaItem.mediaLocalPHAsset copy]
                      withCGSize:self.fullScreenImageView.bounds.size
              andWithUIImageView:self.fullScreenImageView
                 andWithDispatch:YES];
            }
            
            //
            // Set Play Image Icon
            //
            if ([[mediaItem.mediaType lowercaseString] isEqualToString:@"video"]) {
                self.fullScreenPlayButton.hidden = 0;
                self.fullScreenPlayButton.tag = currentIndexFullScreen;
                [self.view bringSubviewToFront:self.fullScreenPlayButton];
            } else {
                self.fullScreenPlayButton.hidden = 1;
            }
            
        } else {
            [GalleryViewController setReturningFromFullScreen:NO];
        }
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

- (void)handleSwipe:(UISwipeGestureRecognizer*)swipe {
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        //        ALog(@"Left Swipe currentIndex:%lu", (long)currentIndexFullScreen);
        if (currentIndexFullScreen != sharedGalleryInstance.galleryNSMutableArray.count) {
            currentIndexFullScreen = currentIndexFullScreen + 1;
        }
        
        MediaItem* mediaItem =
        sharedGalleryInstance.galleryNSMutableArray[currentIndexFullScreen];
        [self enterFullScreenMode:currentIndexFullScreen withMediaItem:mediaItem];
    }
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        //        ALog(@"Right Swipe currentIndexFullScreen:%lu", (long)currentIndexFullScreen);
        if (currentIndexFullScreen != 0) {
            currentIndexFullScreen = currentIndexFullScreen - 1;
        }
        
        MediaItem* mediaItem =
        sharedGalleryInstance.galleryNSMutableArray[currentIndexFullScreen];
        [self enterFullScreenMode:currentIndexFullScreen withMediaItem:mediaItem];
    }
}

#pragma mark - search and notifications menu open
- (void)openMenu {
    UIButton* btn = (id)[self.navigationItem.rightBarButtonItem customView];
    [SettingButton notificationClicked:(id)btn];
}

#pragma mark - base functions
- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - Map Initialization
- (void)initLocationForMap {
    locationManager = [[CLLocationManager alloc] init];
    
    if (IS_OS_8_OR_LATER) {
        [locationManager requestWhenInUseAuthorization];
    } else {
        [locationManager requestAlwaysAuthorization];
    }
}

//
// Google Banner View
//
//self.bannerView.adUnitID = [[MIOSDeviceDetails sharedInstance] getAdUnitId];
//self.bannerView.rootViewController = self;
//[self.bannerView loadRequest:[GADRequest request]];


#pragma mark
#pragma mark GAdBannerViewDelegate Method

- (void)adViewDidReceiveAd:(GADBannerView *) bannerView {
    ALog(@"ad was received...");
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    ALog(@"didFailToReceiveAdWithError: %@...", error.localizedFailureReason);
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView {
    ALog(@"adViewWillPresentScreen...");
}
- (void)adViewDidDismissScreen:(GADBannerView *)bannerView {
    ALog(@"adViewDidDismissScreen...");
}
- (void)adViewWillDismissScreen:(GADBannerView *)bannerView {
    ALog(@"adViewWillDismissScreen...");
}

@end

#import "QueueViewController.h"
#import "MasterViewController.h"
#import "AppDelegate.h"
#import "MyConstant.h"
#import "GridCell.h"
#import "MyView.h"
#import "UploadCustomCell.h"
#import "WebServiceParser.h"
#import "WebServices.h"
#import "MIOSDeviceDetails.h"
#import "AMGProgressView.h"


@implementation QueueViewController {
    WebServiceParser* wspListPhotos;
    NSArray* imageListingArray;
    int scrollViewWidth;
    AppDelegate* appDelegate;
    QueueController* queueSharedInstance;
    QueueUploadController* queueUploadSharedInstance;
    QueueDownloadController* queueDownloadSharedInstance;
    bool isScrolling;
    NSArray* viewTransferArray;
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Setting"]) {
        UIViewController* destViewController = segue.destinationViewController;
        destViewController.hidesBottomBarWhenPushed = YES;
    }
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)logoutButtonWasPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - View lifecycle
- (void)viewDidDisappear:(BOOL)animated {
}

- (BOOL) isViewVisible {
    if (self.isViewLoaded && self.view.window) {
        // viewController is visible
        return YES;
    }
    return NO;
}

- (void)viewDidLoad {
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
         setBackgroundImage:[UIImage imageNamed:@"queue"]
         forBarMetrics:UIBarMetricsDefault];
    } else {
        [self.navigationController.navigationBar
         setBackgroundImage:[UIImage imageNamed:@"nav_Queue"]
         forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    @try {
        /**
         * Set Observer for queue refresh...
         */
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(completedTransferRow:)
                                                     name:TRANSFER_QUEUE_DELETECOMPLETED
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadViews)
                                                     name:TRANSFER_QUEUE_VIEW_RELOAD
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadCompletedView)
                                                     name:COMPLETED_VIEW_LOAD
                                                   object:nil];
        ALog(@"viewWillAppear::addObserver::completed...");
        
        //
        // Set segment controller view
        //
        [self.sgmTransferOrCompleteTab setBackgroundColor:[UIColor blackColor]];
        NSDictionary* attributes = [NSDictionary
                                    dictionaryWithObjectsAndKeys:[UIColor whiteColor],
                                    NSForegroundColorAttributeName, nil];
        [self.sgmTransferOrCompleteTab setTitleTextAttributes:attributes
                                                     forState:UIControlStateNormal];
        
        //
        //  Setup view as default with light gray text highlight
        //
        attributes = [NSDictionary
                      dictionaryWithObjectsAndKeys:[UIColor lightGrayColor],
                      NSForegroundColorAttributeName, nil];
        [self.sgmTransferOrCompleteTab setTitleTextAttributes:attributes
                                                     forState:UIControlStateSelected];
        [self.sgmTransferOrCompleteTab setSelectedSegmentIndex:0];
        self.progress = [NSMutableDictionary dictionary];
        
        isPaused = NO;
        isScrolling = NO;
        self.viewTransfer.hidden = NO;
        self.viewComplete.hidden = YES;
        
        //
        // Setup QueueController access
        //
        queueSharedInstance = [QueueController sharedInstance];
        queueUploadSharedInstance = [QueueUploadController sharedInstance];
        queueDownloadSharedInstance = [QueueDownloadController sharedInstance];
        queueUploadSharedInstance.delegate = self;
        queueDownloadSharedInstance.delegate = self;
        queueSharedInstance.delegate = self;
        
        //
        // Set current controller
        //
        appDelegate.currentView = @"QueueViewController";
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    @try {
        [self.tableViewTransfers reloadData];
        [self.gridViewTransfersCompleted reloadData];
        
        // TODO - Upload
        //ALog(@"pendingTransferArrayCount::%@ pendingTransferQueueCount::%@ completedTransferArrayCount::%@ ",@([queueSharedInstance.pendingTransferArray count]), @([queueSharedInstance.pendingTransferQueue operationCount]), @([queueSharedInstance.completedTransferArray count]));
        
        if ( (queueSharedInstance.pendingTransferArray.count == 0) && (queueSharedInstance.completedTransferArray.count > 0)) {
            //all transfers completed so show completed tab
            [self.sgmTransferOrCompleteTab setSelectedSegmentIndex:1];
            [self segmentedClicked:self.sgmTransferOrCompleteTab];
            //send notification to refresh Gallery View
            
        } else if ( (queueSharedInstance.pendingTransferArray.count > 0) && ([queueSharedInstance.pendingTransferQueue operationCount]) == 0) {
            //error?
            //ALog(@"ERROR??:: pendingTransferArrayCount::%@ pendingTransferQueueCount::%@ completedTransferArrayCount::%@ ",@([queueSharedInstance.pendingTransferArray count]), @([queueSharedInstance.pendingTransferQueue operationCount]), @([queueSharedInstance.completedTransferArray count]));
        } else {
            //otherwise show transer tab
            [self.sgmTransferOrCompleteTab setSelectedSegmentIndex:0];
            [self segmentedClicked:self.sgmTransferOrCompleteTab];
        }
        
        
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

- (void)onClickSetting {
    [self performSegueWithIdentifier:@"Setting" sender:nil];
}


//
// Deleted completed transfer row
//
- (void)completedTransferRow:(NSNotification *)notification{
    NSDictionary *mediaItemDict = [notification userInfo];
    [self deleteCompletedTransferRowWithDict:mediaItemDict];
}

- (void) deleteCompletedTransferRowWithDict:(NSDictionary*)mediaItemDict {
    
    @synchronized(queueSharedInstance.pendingTransferArray) {
        NSString* mediaNamePrefix = [mediaItemDict objectForKey:@"mediaNamePrefix"];
        MediaItem* mediaItem;
        BOOL moveToCompletedTab = NO;
        mediaItem = [[queueSharedInstance findMediaItemByMediaNamePrefix:mediaNamePrefix] copy];
        mediaItem.isSelectedForSync = NO;
        if (mediaItem == nil) {
            //do nothing...
            //ALog(@"deleteCompletedTransferRowWithDict::mediaItem == nil");
        } else {
            [queueSharedInstance.completedTransferArray addObject:mediaItem];
        }
        if (queueSharedInstance.pendingTransferArray.count > 0) {
            [queueSharedInstance removeFromPendingTransferArrayByMediaNamePrefix:mediaNamePrefix];
        }
        if (queueSharedInstance.pendingTransferArray.count == 0) {
            moveToCompletedTab = YES;
        }
        [self.tableViewTransfers reloadData];
        
        // delegate controls removal...
        if (moveToCompletedTab) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.gridViewTransfersCompleted reloadData];
                [self loadCompletedView];
            });
        }
    }
}

//
// Reload both queue and completed tabs
//
- (void)reloadViews {
    if (self.isViewLoaded && self.view.window) {
        // viewController is visible
        [self.tableViewTransfers reloadData];
        [self.gridViewTransfersCompleted reloadData];
    }
    
}

- (void)loadCompletedView {
    @try {
        if (self.isViewLoaded && self.view.window) {
            // Move to completed tab within queue
            [self.sgmTransferOrCompleteTab setSelectedSegmentIndex:1];
            [self segmentedClicked:self.sgmTransferOrCompleteTab];
        }
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

#pragma mark
#pragma mark UITableView Delegate methods
- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)section {
    return queueSharedInstance.pendingTransferArray.count;
}

// TODO - Upload
- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    @try {
        //ALog(@"loading queue table view progress bars...");
        UploadCustomCell* cell;
        AMGProgressView* progressView;
        UIView* cellThumbnailView;
        
        //[MIOSDeviceDetails sharedInstance];
        NSMutableDictionary* mediaItemDict = queueSharedInstance.pendingTransferArray[indexPath.row];
        MediaItem* mediaItem = [mediaItemDict objectForKey:@"mediaItem"];
        
        //
        // Set indexPath in case it changed
        //
        mediaItem.indexPath = indexPath;
        
        //
        // Process Upload vs Download
        //
        if (mediaItem.transferType == UPLOAD) {
            // fetch cell and thumbnail holder
            cell = [tableView dequeueReusableCellWithIdentifier:@"UploadCustomCell"];
            
            // fetch cell progressBar, set colors, and set model progress
            // red to green for uploads
            progressView = cell.uploadProgressbar;
            progressView.backgroundColor = [UIColor blackColor];
            progressView.gradientColors = @[ [UIColor redColor], [UIColor greenColor] ];
            
            // reset cell
            cellThumbnailView = cell.uploadTransferView;
            cell.fileName = mediaItem.mediaName;
            
            //set % for progress view
            //[cell.uploadProgressbar sendSubviewToBack:cell.contentView];
            [cell.uploadPercentage setTextColor:[UIColor whiteColor]];
            //[cell.uploadPercentage bringSubviewToFront:cell.contentView];
            progressView.progress = 0;
            if (mediaItem.mediaState == IN_TRANSIT) {
                [cell.uploadPercentage setText:@"transferring..."];
            } else {
                [cell.uploadPercentage setText:@"pending..."];
            }
            [cell.uploadProgressbar bringSubviewToFront:cell.uploadPercentage];
            
        } else {
            // fetch cell and thumbnail holder
            cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadCustomCell"];
            
            // fetch cell progressBar, set colors, and set model progress
            // yellow to green for downloads
            progressView = cell.uploadProgressbar;
            progressView.backgroundColor = [UIColor blackColor];
            progressView.gradientColors = @[ [UIColor greenColor], [UIColor yellowColor] ];
            //revers progress view so it's right to left for download
            progressView.transform = CGAffineTransformMakeScale(-1.0f, 1.0f);
            //now reset % progress so it's flipped back and readable
            cell.uploadPercentage.transform = CGAffineTransformMakeScale(-1.0f, 1.0f);
            
            // reset cell
            cellThumbnailView = cell.uploadTransferView;
            cell.fileName = mediaItem.mediaName;
            
            //set % for progress view
            //[cell.uploadProgressbar sendSubviewToBack:cell.contentView];
            [cell.uploadPercentage setTextColor:[UIColor whiteColor]];
            //[cell.uploadPercentage bringSubviewToFront:cell.contentView];
            progressView.progress = 0;
            if (mediaItem.mediaState == IN_TRANSIT) {
                [cell.uploadPercentage setText:@"transferring..."];
            } else {
                [cell.uploadPercentage setText:@"pending..."];
            }
            [cell.uploadProgressbar bringSubviewToFront:cell.uploadPercentage];
        }
        
        //
        // x - cancel button
        //
        cell.btnClose.hidden = NO;
        cell.btnClose.tag = indexPath.row;
        [cell.btnClose addTarget:self
                          action:@selector(clickCancelTransfer:)
                forControlEvents:UIControlEventTouchUpInside];
        
        
        // view settings
        progressView.layer.cornerRadius = 15;
        progressView.layer.masksToBounds = 1;
        progressView.clipsToBounds = 1;
        progressView.emptyPartAlpha = 1;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // Set Image here...
        UIImageView* imageView = [cell uploadImageView];
        if (mediaItem.transferType == UPLOAD) {
            //ALog(@"setting upload thumbnail for filename:%@", mediaItem.mediaName);
            [mediaItem fetchThumbnailForPHAsset:imageView.bounds.size];
            imageView.image = mediaItem.mediaLocalThumbnail;
        } else {
            //ALog(@"setting download thumbnail for filename:%@", mediaItem.mediaName);
            NSString* thumbURl = mediaItem.mediaThumbnailUrl79x80[0];
            [imageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:thumbURl]]]];
            
        }
        // Set Video Icon here...
        UIImageView* videoIconView = [cell uploadVideoView];
        [videoIconView setContentMode:UIViewContentModeCenter];
        if ([[mediaItem.mediaType lowercaseString]
             isEqualToString:@"video"]) {
            //ALog(@"setting video play icon for filename:%@", mediaItem.mediaName);
            videoIconView.image = [UIImage imageNamed:@"video_play"];
        } else {
            //ALog(@"unsetting video play icon for filename:%@", mediaItem.mediaName);
            videoIconView.image = nil;
        }
        
        //
        // Set cell view settings
        //
        imageView.layer.cornerRadius = 5;
        imageView.layer.masksToBounds = YES;
        imageView.clipsToBounds = YES;
        
        // Make sure the constraints have been added to this cell, since it may have just been created from scratch
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        
        return cell;
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

//
// Progress Bar Status
//
- (void)clickCancelTransfer:(UIButton*) sender {
    [queueSharedInstance cancelTransferTask:sender.tag];
}

//
// Progress Bar Status
//

//
// Up/Download Delegates
//
- (void)updateUploadProgressBar:(NSDictionary*)progressDict {
    [self updateProgressBar:progressDict];
}
- (void)updateDownloadProgressBar:(NSDictionary*)progressDict {
    [self updateProgressBar:progressDict];
}
- (void)updateModelProgressBar:(NSDictionary*)progressDict {
    if (self.isViewLoaded && self.view.window) {
        [self updateProgressBar:progressDict];
    }
}
- (void)updateProgressBar:(NSDictionary*)progressDict {
    if (!isScrolling) {
        //
        // Find by mediaName
        //
        NSString* mediaNamePrefix = [progressDict objectForKey:@"mediaNamePrefix"];
        MediaItem* mediaItem = [queueSharedInstance findMediaItemByMediaNamePrefix:mediaNamePrefix];
        NSArray* paths = [self.tableViewTransfers indexPathsForVisibleRows];
        if ([paths containsObject:mediaItem.indexPath]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // if visible update progress
                UploadCustomCell* cell = (UploadCustomCell*)[self.tableViewTransfers
                                                             cellForRowAtIndexPath:[NSIndexPath indexPathForRow:mediaItem.indexPath.row inSection:0]];
                AMGProgressView* progressBar = [cell uploadProgressbar];
                
                NSNumber* progress = [progressDict objectForKey:@"current_progress"];
                progressBar.progress = [progress floatValue];
                //[cell.uploadPercentage setTextColor:[UIColor whiteColor]];
                [cell.uploadPercentage setText:[progressDict objectForKey:@"progressText"]];
                [cell.uploadPercentage bringSubviewToFront:cell.uploadPercentage];
                //[self.tableViewTransfers reloadData];
                ALog(@"cell is visible and has match ... s3File_name::%@ :: mediaItem.indexPath.row::%@ progress::%@ progressText::%@",[progressDict objectForKey:@"mediaNamePrefix"], @(mediaItem.indexPath.row), @(progressBar.progress), [progressDict objectForKey:@"progressText"]);
            });
        }
    } else {
        ALog(@"updateProgressBar::isScrolling::true...");
    }
}

#pragma mark
#pragma mark UIScrollview Delegate methods
- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView {
    isScrolling = true;
}
- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView
                  willDecelerate:(BOOL)decelerate {
    isScrolling = true;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView {
    isScrolling = false;
    [self.tableViewTransfers reloadData];
    [self.gridViewTransfersCompleted reloadData];
}

#pragma mark
#pragma mark Button touch event handling

- (IBAction)btnPauseClicked:(UIButton*)sender {
    @try {
        if (self.sgmTransferOrCompleteTab.selectedSegmentIndex == 0){
            if (queueSharedInstance.pendingTransferArray.count > 0) {
                
                if ([sender.currentTitle isEqual:@"pause"]) {
                    [sender setTitle:@"resume" forState:UIControlStateNormal];
                    [[QueueController sharedInstance] pauseUploading];
                } else {
                    [[QueueController sharedInstance] resumeUploading];
                    [sender setTitle:@"pause" forState:UIControlStateNormal];
                    //[self btnResumeClicked:nil];
                }
            } else {
                [sender setTitle:@"pause" forState:UIControlStateNormal];
            }
        }
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

// TODO - Upload
- (IBAction)btnClearClicked:(id)sender {
    NSString* msg = @"";
    if (self.sgmTransferOrCompleteTab.selectedSegmentIndex == 0) {
        msg = @"cancel all transfers";
        if (queueSharedInstance.pendingTransferArray.count > 0) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"confirmation"
                                                            message:msg
                                                           delegate:self
                                                  cancelButtonTitle:@"no"
                                                  otherButtonTitles:@"yes", nil];
            [alert show];
        }
    } else {
        msg = @"clear media";
        if (queueSharedInstance.completedTransferArray.count > 0) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"confirmation"
                                                            message:msg
                                                           delegate:self
                                                  cancelButtonTitle:@"no"
                                                  otherButtonTitles:@"yes", nil];
            [alert show];
        }
    }
    
}

// This function will be called by the UIAlertView.
- (void)alertView:(UIAlertView*)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // The cancel button ("no") is always index 0.
    // The index of the other buttons is the order they're defined.
    ALog(@"dismissed alert view with buttonIndex: %@", @(buttonIndex));
    if (self.sgmTransferOrCompleteTab.selectedSegmentIndex == 0) {
        if (buttonIndex == 1) {
            [queueSharedInstance cancelTransferTasks];
        }
    } else if (self.sgmTransferOrCompleteTab.selectedSegmentIndex == 1) {
        if (buttonIndex == 1) {
            [queueSharedInstance.completedTransferArray removeAllObjects];
            [self reloadViews];
        }
    }
}

// TODO - Upload
- (void)btnStopClicked:(id)sender {
    @try {
        CGPoint buttonPosition =
        [sender convertPoint:CGPointZero toView:self.tableViewTransfers];
        NSIndexPath* indexPath =
        [self.tableViewTransfers indexPathForRowAtPoint:buttonPosition];
        
        if (self.sgmTransferOrCompleteTab.selectedSegmentIndex == 0) {
            ALog(@"queueSharedInstance cancelTransferTask:indexPath.item indexPath.row:%@", @(indexPath.row));
            [queueSharedInstance cancelTransferTask:indexPath.item];
        }
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}
#pragma mark
#pragma mark UIAlert view delegate

// TODO - Upload
- (void)alertView:(UIAlertView*)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    @try {
        ALog(@"buttonIndex : %ld", (long)buttonIndex);
        if (buttonIndex == 1) {
            if (self.sgmTransferOrCompleteTab.selectedSegmentIndex == 0) {
                appDelegate.isUploadPaused = YES;
                
                ALog(@"queueSharedInstance cancelTransferTasks");
                [queueSharedInstance cancelTransferTasks];
            } else {
                ALog(@"queueSharedInstance cancelTransferTask:buttonIndex::%@", @(buttonIndex));
                [queueSharedInstance cancelTransferTask:buttonIndex];
                [self reloadViews];
            }
        }
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

#pragma mark
#pragma mark Segment Controller event handling

- (IBAction)segmentedClicked:(UISegmentedControl*)sender {
    @try {
        [self.gridViewTransfersCompleted reloadData];
        UISegmentedControl* segmentController = (UISegmentedControl*)sender;
        int selectedIndex = (int)segmentController.selectedSegmentIndex;
        
        if (selectedIndex == 0) {
            self.btnPause.hidden = 0;
            self.btnResume.hidden = 0;
            self.viewTransfer.hidden = NO;
            self.viewComplete.hidden = YES;
        } else {
            self.btnPause.hidden = YES;
            self.btnResume.hidden = YES;
            self.viewTransfer.hidden = YES;
            self.viewComplete.hidden = NO;
        }
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

#pragma mark
#pragma mark Collection View

- (NSInteger)numberOfSectionsInCollectionView:
(UICollectionView*)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView
     numberOfItemsInSection:(NSInteger)section {
    NSUInteger completedTransferArrayCount = queueSharedInstance.completedTransferArray.count;
    //    ALog(@"completedTransferArrayCopy.count::%lu", (unsigned long)completedTransferArrayCount);
    return completedTransferArrayCount;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
                 cellForItemAtIndexPath:(NSIndexPath*)indexPath {
    @try {
        GridCell* cell = (GridCell*)
        [collectionView dequeueReusableCellWithReuseIdentifier:@"ServerCell"
                                                  forIndexPath:indexPath];
        
        MediaItem* mediaItem = queueSharedInstance.completedTransferArray[indexPath.row];
        
        cell.imgPhoto.layer.cornerRadius = 5;
        cell.imgPhoto.layer.masksToBounds = YES;
        cell.imgPhoto.clipsToBounds = YES;
        
        if ([[mediaItem.mediaType lowercaseString]
             isEqualToString:@"video"]) {
            [cell.imgVideo setImage:[UIImage imageNamed:@"video_play"]];
            cell.imgVideo.center = cell.center;
        } else {
            [cell.imgVideo setImage:nil];
        }
        
        if (mediaItem.transferType == UPLOAD) {
            [cell.imgPhoto setImage:mediaItem.mediaLocalThumbnail];
            //            ALog(@"completed local thumbnail url::%@", mediaItem.mediaLocalThumbnail);
        } else {
            NSString* thumbURl = mediaItem.mediaThumbnailUrl79x80[0];
            //            ALog(@"completed download thumbnail url::%@", thumbURl);
            UIImage* thumbUIImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:thumbURl]]];
            [cell.imgPhoto setImage:thumbUIImage];
        }
        return cell;
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    ALog(@"dealloc::removeObserver...");
}

#pragma mark
#pragma mark GAdBannerViewDelegate Method

- (void)adViewDidReceiveAd:(GADBannerView *) bannerView {
    //ALog(@"ad was received...");
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    //ALog(@"didFailToReceiveAdWithError: %@...", error.localizedFailureReason);
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView {
    //ALog(@"adViewWillPresentScreen...");
}
- (void)adViewDidDismissScreen:(GADBannerView *)bannerView {
    //ALog(@"adViewDidDismissScreen...");
}
- (void)adViewWillDismissScreen:(GADBannerView *)bannerView {
    //ALog(@"adViewWillDismissScreen...");
}


@end

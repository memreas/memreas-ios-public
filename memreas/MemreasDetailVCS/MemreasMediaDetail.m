@import AVKit;
@import AVFoundation;
#import "MemreasDetailViewController.h"
#import "MemreasMediaDetail.h"
#import "XMLGenerator.h"
#import "XCollectionCell.h"
#import "FullScreenMode.h"
#import "GalleryManager.h"
#import "QueueController.h"
#import "NSDictionary+valueAdd.h"
#import "NSString+SrtingUrlValidation.h"


@implementation MemreasMediaDetail

-(void)viewDidLoad{
    @try {
        [super viewDidLoad];
        
        /**
         * Set Observers for notifications...
         */
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleReporMediaInappropriateMWS:)
                                                     name:REPORTMEDIAINAPPROPRIATE_RESULT_NOTIFICATION
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(responseForLikemedia:)
                                                     name:MEMREAS_MEDIA_DETAIL_LIKE_MEDIA_RESPONSE
                                                   object:nil];
        
        self.headerView.selectedSegmentIndex = self.selectedSegmentIndex;
        self.headerView.dicPassedEventDetail = self.dicPassedEventDetail;
        self.strEventID = [self.dicPassedEventDetail valueForKeyPath:@"event_id.text"];
        self.collectionComment.dicPassedEventDetail = self.dicPassedEventDetail;
        
        //
        // Check if public
        //
        if ([MemreasMainViewController fetchIsPublic]) {
            self.menubarView.hidden = 1;
            self.menubarPublicView.hidden = 0;
        } else {
            self.menubarView.hidden = 0;
            self.menubarPublicView.hidden = 1;
        }
        
        
        NSDictionary * dic = self.dicPassedEventDetail;
        if ([[dic valueForKeyPath:@"event_media"] isKindOfClass:[NSArray class]]) {
            self.arrGalleryMedia = [dic valueForKeyPath:@"event_media"];
        }else if([[dic valueForKeyPath:@"event_media"] isKindOfClass:[NSDictionary class]]){
            self.arrGalleryMedia = @[[dic valueForKeyPath:@"event_media"] ];
        }
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [flowLayout setMinimumInteritemSpacing:0.0f];
        [flowLayout setMinimumLineSpacing:0.0f];
        [self.collectionGallery setPagingEnabled:YES];
        [self.collectionGallery setCollectionViewLayout:flowLayout];
        
        
        [self.collectionGallery reloadData];
        [self loadControl:self.selectedIndexPath];
        
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
    
}

-(void)setDicPassedEventDetail:(NSDictionary *)dicPassedEventDetail{
    _dicPassedEventDetail = dicPassedEventDetail;
    [self viewDidLoad];
}
-(void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath{
    _selectedIndexPath = selectedIndexPath;
    [self performSelector:@selector(scrollAtIndex) withObject:nil afterDelay:0.5];
    
}


-(void)scrollAtIndex{
    [self.collectionGallery scrollToItemAtIndexPath:self.selectedIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:false];
    [self loadControl:self.selectedIndexPath];
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath {
}

- (NSInteger)numberOfSections {
    return 1;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    return self.arrGalleryMedia.count;
}


#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.arrGalleryMedia.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.bounds.size;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath {
    
    static NSString* cellIdentifier = @"Cell";
    XCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                                                      forIndexPath:indexPath];
    NSDictionary *dic = self.arrGalleryMedia[indexPath.item];
    [cell loadImageWithURLString:dic andImageKey: @"event_media_448x306"];
    cell.playButton.cell = cell;
    cell.playButton.cell.bounds = collectionView.bounds;
    cell.playButton.tag = indexPath.item;
    [cell.playButton addTarget:self action:@selector(playViderForDic:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.playerViewController) {
        
        [self.playerViewController.player pause];
        [self.playerViewController.view removeFromSuperview];
        self.playerViewController.player = nil;
        self.playerViewController = nil;
    }
    cell.viewVideo.hidden = true;
    
    UIColor* syncMediaStateColor = [self setBorderColor:[dic objectForKey:@"event_media_name"]];
    cell.layer.borderColor = syncMediaStateColor.CGColor;
    cell.layer.borderWidth = 2.0;
    cell.layer.masksToBounds = true;
    
    return cell;
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (!decelerate) {
        [self loadControl:nil];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self loadControl:nil];
}


#pragma mark - set border color for download
- (UIColor*)setBorderColor:(NSDictionary*) eventMediaNameDict {
    //events can't have red or orange syncState
    UIColor* syncStateColor = [UIColor clearColor];
    @try {
        GalleryManager* sharedInstance = [GalleryManager sharedGalleryInstance];
        NSString* event_media_name = [eventMediaNameDict objectForKey:@"text"];
        MediaItem* mediaEventItem = [sharedInstance.dictGallery objectForKey:event_media_name];
        
        if (mediaEventItem != nil) {
            if (mediaEventItem.mediaState == SYNC) {
                syncStateColor = [UIColor greenColor];
            } else if (mediaEventItem.mediaState == SERVER) {
                syncStateColor = [UIColor yellowColor];
            }
        }
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
    return syncStateColor;
}

-(void)loadControl:(NSIndexPath*)selectedIndex{
    
    @try {
        
        NSIndexPath *indexPath ;
        if (selectedIndex) {
            indexPath = selectedIndex;
        }else{
            indexPath = [self currentDisplayingIndexPath];
        }
        NSDictionary *dicSelected = self.arrGalleryMedia[indexPath.item];
        self.collectionComment.media_id = [dicSelected valueForKeyPath:@"event_media_id.text"];
        self.strMediaID = self.collectionComment.media_id;
        
        NSArray *arrComment;
        
        if ([[self.dicPassedEventDetail valueForKeyPath:@"comments.comment"] isKindOfClass:[NSArray class]]) {
            arrComment = [self.dicPassedEventDetail valueForKeyPath:@"comments.comment"];
        }else if([[self.dicPassedEventDetail valueForKeyPath:@"comments.comment"] isKindOfClass:[NSDictionary class]]){
            arrComment = @[[self.dicPassedEventDetail valueForKeyPath:@"comments.comment"] ];
        }
        
        NSPredicate *predicateComment = [NSPredicate predicateWithFormat:@"(self.type.text == 'text' || self.type.text == 'audio') && (comment_media_id.text == %@)",[dicSelected valueForKeyPath:@"event_media_id.text"]];
        
        NSPredicate *predicateLike = [NSPredicate predicateWithFormat:@"(self.type.text == 'like') && (comment_media_id.text == %@)",[dicSelected valueForKeyPath:@"event_media_id.text"]];
        
        [self.btnLikeCount setTitle:[NSString stringWithFormat:@"%ld",(long)[[arrComment filteredArrayUsingPredicate:predicateLike] count]] forState:UIControlStateNormal];
        [self.btnCommentCount setTitle:[NSString stringWithFormat:@"%ld",(long)[[arrComment filteredArrayUsingPredicate:predicateComment] count]] forState:UIControlStateNormal];
        
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
    
}

-(NSIndexPath*)currentDisplayingIndexPath{
    NSArray*array =[self.collectionGallery indexPathsForVisibleItems];
    return [array lastObject];
}

#pragma mark - IB Actions

-(void)fullscreenModebackbuttonPressed:(id)sender{
    
    @try {
        
        self.navigationController.navigationBarHidden = NO;
        self.tabBarController.tabBar.hidden = NO;
        [UIView beginAnimations:nil context:NULL];
        [UIView animateWithDuration:0.7
                         animations:^{
                             self.fullScreenView.view.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             [self.fullScreenView removeFromParentViewController];
                             [self.fullScreenView.view removeFromSuperview];
                             self.fullScreenView = nil;
                         }];
        [UIView commitAnimations];
        
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
}



- (IBAction)btnFullScreenMode:(UIButton*)sender {
    
    @try {
        
        //
        // If video is playing pause it.
        //
        if (self.playerViewController) {
            
            [self.playerViewController.player pause];
        }
        
        NSIndexPath *indexPath = [self currentDisplayingIndexPath];
        self.fullScreenView = [[UIStoryboard storyboardWithName:@"MemreasDetail" bundle:nil]
                               instantiateViewControllerWithIdentifier:@"FullScreenView"];
        
        self.fullScreenView.delegate = self;
        self.fullScreenView.arrGalleryMedia = self.arrGalleryMedia;
        
        [self.parentViewController addChildViewController:self.fullScreenView];
        [self.parentViewController.view addSubview:self.fullScreenView.view];
        
        self.fullScreenView.view.alpha = 0;
        
        self.navigationController.navigationBarHidden = YES;
        self.tabBarController.tabBar.hidden = YES;
        self.fullScreenView.selectedIndexPath = indexPath;
        
        // Pass parameter
        [UIView beginAnimations:nil context:NULL];
        [UIView animateWithDuration:1.5
                         animations:^{
                             self.fullScreenView.view.alpha = 1;
                             
                         }
                         completion:^(BOOL finished) {
                             self.fullScreenView.selectedIndexPath = indexPath;
                         }];
        
        [UIView commitAnimations];
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

- (IBAction)btnCommentTapped:(id)sender {
    
    @try {
        
        NSIndexPath *indexPath = [self currentDisplayingIndexPath];
        
        NSDictionary *dic = self.arrGalleryMedia[indexPath.item];
        
        NSMutableDictionary  *input = [NSMutableDictionary dictionary];
        [input addValueToDictionary:[self.dicPassedEventDetail valueForKeyPath:@"event_id.text"] andKeyIs:@"event_id"];
        [input addValueToDictionary:[dic valueForKeyPath:@"event_media_id.text" ] andKeyIs:@"media_id"];
        MemreasDetailViewController* parent = (MemreasDetailViewController*)self.parentViewController;
        [parent loadRecording:YES anddicEventMediaDetail:input];
        
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
}

- (IBAction)btnShowComments:(id)sender {
    
    @try {
        
        if (self.collectionComment.arrComments.count == 0) {
            [Helper showMessageFade:self.view withMessage:@"no comments..." andWithHideAfterDelay:3];
        } else {
            MemreasDetailViewController* parent = (MemreasDetailViewController*)self.parentViewController;
            [parent showComments:YES withComments:self.collectionComment.arrComments andWithEventDetail:self.collectionComment.dicPassedEventDetail];
        }
    } @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
}


- (IBAction)btnLikeTap:(id)sender {
    
    @try {
        
        NSIndexPath *indexPath = [self currentDisplayingIndexPath];
        
        NSDictionary *dic = self.arrGalleryMedia[indexPath.item];
        
        [self likeMedia:[dic valueForKeyPath:@"event_media_id.text"]];
        
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
    
}


- (IBAction)downloadAction:(id)sender {
    @try {
        
        // add transfer
        
        NSIndexPath *indexPath = [self currentDisplayingIndexPath];
        NSDictionary *dic = self.arrGalleryMedia[indexPath.item];
        MediaItem *mediaItem = [self generateMediaItemForDownload:dic];
        
        QueueController* queueController = [QueueController sharedInstance];
        [queueController addToPendingTransferArray:mediaItem withTransferType:DOWNLOAD];
        queueController = nil;
        
        [Helper showMessageFade:self.view withMessage:@"media submitted for download" andWithHideAfterDelay:3];
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

-(MediaItem*)generateMediaItemForDownload:(NSDictionary*)dictionary{
    
    MediaItem *mediaItem = [[MediaItem alloc]init];
    
    mediaItem.mediaState = SERVER;
    mediaItem.mediaId =  [dictionary valueForKeyPath:@"event_media_id.text"];
    mediaItem.deviceId =  [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    mediaItem.deviceType =  DEVICE_TYPE;
    mediaItem.mediaDate =  [[NSDate  date]timeIntervalSinceNow];
    mediaItem.mediaTranscodeStatus =  @"success";
    mediaItem.codecLevel = nil;
    mediaItem.mediaUrl =  [[dictionary valueForKeyPath:@"event_media_url.text"] convertToJson];
    mediaItem.mediaPath =  [dictionary valueForKeyPath:@"event_media_s3_url_path.text"];
    
    mediaItem.mediaUrlHls =  [[dictionary valueForKeyPath:@"event_media_url_hls.text"] convertToJson];
    mediaItem.mediaUrlWeb =  [[dictionary valueForKeyPath:@"event_media_url_web.text"] convertToJson];
    mediaItem.mediaUrlDownload =   [[dictionary valueForKeyPath:@"event_media_s3file_download_path.text"] convertToJson];
    mediaItem.mediaUrlWebS3Path =  [dictionary valueForKeyPath:@"event_media_s3_url_web_path.text"];
    mediaItem.mediaUrl1080pS3Path =  nil;
    mediaItem.metadata =  nil;
    
    mediaItem.mediaLocation = nil;
    mediaItem.hasLocation = NO;
    
    mediaItem.mediaThumbnailUrl79x80 =  [[dictionary valueForKeyPath:@"event_media_79x80.text"] convertToJson];
    mediaItem.mediaThumbnailUrl98x78 =  [[dictionary valueForKeyPath:@"event_media_98x78.text"] convertToJson];
    mediaItem.mediaThumbnailUrl448x306 =  [[dictionary valueForKeyPath:@"event_media_448x306.text"] convertToJson];
    mediaItem.mediaThumbnailUrl1280x720 = nil;
    mediaItem.mediaType =  [dictionary valueForKeyPath:@"event_media_type.text"];
    mediaItem.mimeType = nil;
    mediaItem.userMediaDevice = nil;
    
    mediaItem.mediaName =  [[mediaItem.mediaPath componentsSeparatedByString:@"/"] lastObject];
    mediaItem.mediaName =  [mediaItem.mediaName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    mediaItem.mediaNamePrefix =  [dictionary valueForKeyPath:@"event_media_name.text"];
    
    return mediaItem;
    
}


-(void)playViderForDic:(PlayerVideoBtn*)sender{
    
    @try {
        
        NSDictionary *dic = self.arrGalleryMedia[sender.tag];
        
        XCollectionCell *cell = sender.cell;
        
        cell.viewVideo.hidden = false;
        
        NSString*urlString=[[[dic valueForKeyPath:@"event_media_url.text"] convertToJsonWithFirstObject]urlEnocodeString];
        NSURL *videoURL = [NSURL URLWithString:urlString];
        AVPlayer *player = [AVPlayer playerWithURL:videoURL];
        
        
        self.playerViewController  = [[AVPlayerViewController alloc]init];
        
        
        //handle phone on vibrate...
        [[AVAudioSession sharedInstance]
         setCategory: AVAudioSessionCategoryPlayback
         error: nil];
        
        
        self.playerViewController.player = player;
        [self.playerViewController.player play];
        
        [self addChildViewController:self.playerViewController];
        self.playerViewController.view.frame = cell.viewVideo.frame;
        [cell.viewVideo addSubview:self.playerViewController.view];
        
        //        [self presentViewController:playerViewController animated:YES completion:nil];
        
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
}

#pragma mark - Web services

- (void)likeMedia:(NSString*)mediaID {
    
    @try {
        NSMutableDictionary *input  = [NSMutableDictionary dictionary];
        NSString *webMethod = LIKEMEDIA;
        [input addValueToDictionary:mediaID andKeyIs:@"media_id"];
        [input addValueToDictionary:@"1" andKeyIs:@"is_like"];
        [input addValueToDictionary:[self.dicPassedEventDetail valueForKeyPath:@"event_id.text"] andKeyIs:@"event_id"];
        
        /**
         * Send Request and Parse Response...
         *  Note: wsHandler calls
         */
        if ([Util checkInternetConnection]) {
            /**
             * Use XMLGenerator...
             */
            NSString* requestXML = [XMLGenerator generateXMLForInputDictionary:input andSID:[Helper fetchSID] andWebMethod:webMethod];
            ALog(@"Request:- %@", requestXML);
            
            /**
             * Use WebServices Request Generator
             */
            NSMutableURLRequest* request =
            [WebServices generateWebServiceRequest:requestXML
                                            action:webMethod];
            // ALog(@"NSMutableRequest request ----> %@", request);
            
            /**
             * Send Request and handle Resonse via Notification
             */
            MWebServiceHandler* wsHandler = [[MWebServiceHandler alloc] init];
            [wsHandler fetchServerResponse:request action:webMethod key:MEMREAS_MEDIA_DETAIL_LIKE_MEDIA_RESPONSE];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showHUDAddedTo:self.view animated:true];
        });
        
        
    } @catch (NSException* exception) {
        ALog(@"object type = %@", [[GalleryManager class] debugDescription]);
        ALog(@"%@", exception);
    }
}


-(void)responseForLikemedia:(NSNotification *)notification
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    });
    
    NSDictionary *dictionary = notification.userInfo;
    
    @try {
        
        if ([[dictionary valueForKeyPath:@"likemediaresponse.status.text"] isEqualToUpperCase:@"Success"]) {
            NSInteger likeCount =        [self.btnLikeCount.currentTitle integerValue];
            likeCount++;
            [self.btnLikeCount setTitle:[NSString stringWithFormat:@"%ld",(long)likeCount] forState:UIControlStateNormal];
        }
        
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
}

#pragma mark - Web services related


- (IBAction)reporInappropriateCheckboxState:(id)sender
{
    UIButton *reportCheckBox = (UIButton*) sender;
    if (reportCheckBox.tag == 0) {
        // check the box
        reportCheckBox.tag = 1;
        [reportCheckBox setImage:[UIImage imageNamed:@"selected_check.png"] forState:UIControlStateNormal];
    } else {
        reportCheckBox.tag = 0;
        [reportCheckBox setImage:[UIImage imageNamed:@"unselected_check.png"] forState:UIControlStateNormal];
        
    }
}


-(IBAction) showReportPopup:(id) sender {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:weakSelf.view animated:true];
        weakSelf.detailStackView.hidden = 1;
        weakSelf.reportInappropriateMediaView.hidden = 0;
        [weakSelf.lblReportHeader setFont:[UIFont fontWithName:@"SegoeScript-Bold" size:22]];
        
        [weakSelf.view bringSubviewToFront:weakSelf.reportInappropriateMediaView];
        [MBProgressHUD hideHUDForView:weakSelf.view animated:true];
    });
    
    ALog(@"-(IBAction) showReportPopup:(id) sender called...");
}


- (IBAction) submitReportPopup:(id) sender {
    
    //
    // Retrieve check boxes
    //
    NSMutableArray* arrReasonTypes = [[NSMutableArray alloc] init];
    
    if (self.btnESC.tag == 1) {
        [arrReasonTypes addObject:self.lblESC.text];
    }
    if (self.btnEVC.tag == 1) {
        [arrReasonTypes addObject:self.lblEVC.text];
    }
    if (self.btnEHS.tag == 1) {
        [arrReasonTypes addObject:self.lblEHS.text];
    }
    if (self.btnIOC.tag == 1) {
        [arrReasonTypes addObject:self.lblIOC.text];
    }
    
    //
    // Submit web service here
    //
    if (arrReasonTypes.count > 0) {
        /*
         * check connection
         */
        if ([Util checkInternetConnection]) {
            
            /**
             * Use WebServices Request Generator
             */
            NSString* requestXML = [XMLGenerator generateXMLForMediaInappropriate:self.strEventID
                                                                      withMedidId:self.strMediaID
                                                                  withReasonTypes:arrReasonTypes];
            NSMutableURLRequest* request =
            [WebServices generateWebServiceRequest:requestXML
                                            action:REPORTMEDIAINAPPROPRIATE];
            ALog(@"NSMutableRequest request ----> %@", request);
            
            /**
             * Send Request and Parse Response...
             *  Note: wsHandler notifies handleAddMediaEventMWS
             */
            MWebServiceHandler* wsHandler = [[MWebServiceHandler alloc] init];
            [wsHandler fetchServerResponse:request
                                    action:REPORTMEDIAINAPPROPRIATE
                                       key:REPORTMEDIAINAPPROPRIATE_RESULT_NOTIFICATION];
        }
        
        //
        // Let notification handle closure
        //
        //[Helper showMessageFade:weakSelf.view withMessage:@"report submitted" andWithHideAfterDelay:2];
        ALog(@"-(IBAction) submitReportPopup:(id) sender called...");
    } else {
        [Helper showMessageFade:self.view withMessage:@"Please select a reason or cancel" andWithHideAfterDelay:2];
    }
} // end - (IBAction) submitReportPopup:(id) sender

-(IBAction) cancelReportPopup:(id) sender {
    
    //
    // Reset form
    //
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:weakSelf.view animated:true];
        weakSelf.reportInappropriateMediaView.hidden = 1;
        weakSelf.detailStackView.hidden = 0;
        [MBProgressHUD hideHUDForView:weakSelf.view animated:true];
    });
    ALog(@"-(IBAction) cancelReportPopup:(id) sender called...");
}

/**
 * Web Service Response via notification here...
 */
- (void)handleReporMediaInappropriateMWS:(NSNotification*)notification {
    @try {
        NSDictionary* resultTags = [notification userInfo];
        NSString* status = @"";
        NSString* msg = @"";
        status = [resultTags objectForKey:@"status"];
        status = [resultTags objectForKey:@"message"];
        if ([[status lowercaseString] isEqualToString:@"success"]) {
            [Helper showMessageFade:self.view withMessage:@"media reported" andWithHideAfterDelay:2];
        } else {
            [Helper showMessageFade:self.view withMessage:msg andWithHideAfterDelay:2];
        }
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showHUDAddedTo:weakSelf.view animated:true];
            weakSelf.reportInappropriateMediaView.hidden = 1;
            weakSelf.detailStackView.hidden = 0;
            [MBProgressHUD hideHUDForView:weakSelf.view animated:true];
        });
        
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}



@end

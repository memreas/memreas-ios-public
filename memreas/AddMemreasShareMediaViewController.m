#import "AddMemreasShareMediaViewController.h"
#import "AddMemreasShareMediaSelectViewController.h"
#import "AddMemreasShareFriendsViewController.h"
#import "MyConstant.h"
#import "GalleryManager.h"
#import "MediaItem.h"
#import "GridCell.h"
#import "ShareCreator.h"
#import "MIOSDeviceDetails.h"
#import "UIImageView+AFNetworking.h"


@implementation AddMemreasShareMediaViewController{
    //
    // local vars here
    //
    GalleryManager* sharedGalleryInstance;
    ShareCreator* shareCreatorInstance;
    PHImageRequestOptions* phImageRequestOptionsASHM;
    PHImageRequestOptions* phImageCachingOptionsASHM;
    PHCachingImageManager* cachingImageManager;
    
}


#pragma mark
#pragma mark View Life cycle

//
// Methods
//
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //
    // Start Caching
    //
    [self startCaching];
    
    //
    // Add observer for handle method
    //
    SEL handleAddEventSelector = @selector(handleAddEvent:);
    SEL handleAddMediaToEventSelector = @selector(handleAddMediaToEvent:);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:handleAddEventSelector
                                                 name:ADDEVENT_MEDIA_EVENT_RESULT_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:handleAddMediaToEventSelector
                                                 name:ADDEVENT_MEDIA_MEDIA_RESULT_NOTIFICATION
                                               object:nil];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //
    // Google Banner View
    //
    self.bannerView.adUnitID = [[MIOSDeviceDetails sharedInstance] getAdUnitId];
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
    
    //   SegoeScript-Bold
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"SegoeScript-Bold" size:22]}];
    self.navigationItem.title = @"share";
    
    //
    // Set Page Title
    //
    if (IS_IPAD) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"BlankHeader"] forBarMetrics:UIBarMetricsDefault];
    }else{
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"BlankHeader"] forBarMetrics:UIBarMetricsDefault];
    }
    
    if (self.eventID){
        self.btnNext.hidden = true;
    }
    
    //
    // Fetch Gallery Manager
    //
    sharedGalleryInstance = [GalleryManager sharedGalleryInstance];
    
    
    //
    // Fetch ShareCreator
    //
    shareCreatorInstance = [ShareCreator sharedInstance];
    
    //
    // Check if media has been selected
    //
    if (shareCreatorInstance.selectedMedia.count == 0) {
        [self performSegueWithIdentifier:@"segueShareAddMediaSelect"
                                  sender:self];
    }
    
    
}

#pragma mark
#pragma mark GridCollectionvsView Delegates

//
// GridCollectionvsView Delegates
//
- (NSInteger)collectionView:(UICollectionView*)collectionView
     numberOfItemsInSection:(NSInteger)section {
    
    return shareCreatorInstance.selectedMedia.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
                 cellForItemAtIndexPath:(NSIndexPath*)indexPath {
    @try {
        //
        // Fetch mediaItem...
        //
        
        MediaItem* mediaItem;
        mediaItem = shareCreatorInstance.selectedMedia[indexPath.item] ;
        
        //
        // Handle Server items
        //
        if (mediaItem.mediaState == SERVER) {
            __weak GridCell* cell = (GridCell*)
            [collectionView dequeueReusableCellWithReuseIdentifier:@"ServerCell"
                                                      forIndexPath:indexPath];
            //
            // Setup cell - clear any past references i.e. image or video thumbnails
            //
            NSInteger currentTag = indexPath.item;
            cell.tag = currentTag;
            
            __weak MyView* myView = cell.myView;
            myView.btnPhoto.tag = indexPath.item;
            [myView setBackgroundColor:[UIColor clearColor]];
            
            // Handle overlay...
            [myView.btnPhoto setBackgroundImage:nil forState:UIControlStateNormal];
            
            // Set URLs for videos and images only...
            // ALog(@"server mediaItem.mediaType -----> %@", mediaItem.mediaType);
            
            
            if (([mediaItem.mediaType length] != 0) &&
                [mediaItem.mediaType isEqualToString:@"video"]) {
                // Video
                // Apply first image
                // ALog(@"79x80 url: %@", mediaItem.mediaThumbnailUrl79x80[0]);
                
                NSURL *url = [NSURL URLWithString:[mediaItem.mediaThumbnailUrl79x80[0] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
                [myView.imgPhoto setImageWithURL:url placeholderImage:[UIImage imageNamed:@"gallery_img"]];
                [myView.imgVideo setContentMode:UIViewContentModeCenter];
                [myView.imgVideo setImage:[UIImage imageNamed:@"video_play"]];
                myView.imgVideo.hidden = 0;
            } else if (([mediaItem.mediaType length] != 0) &&
                       [mediaItem.mediaType isEqualToString:@"image"]) {
                [myView.btnPhoto setImage:nil forState:UIControlStateNormal];
                [myView.imgPhoto stopAnimating];
                myView.imgPhoto.animationImages = nil;
                NSURL *url = [NSURL URLWithString:[mediaItem.mediaThumbnailUrl79x80[0] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
                [myView.imgPhoto setImageWithURL:url placeholderImage:[UIImage imageNamed:@"gallery_img"]];
                myView.imgVideo.hidden = 1;
            }
            
            // Set Border COLOR
            [self setBorderColor:cell withMediaState:mediaItem.mediaState];
            
            return cell;
        } else {
            //
            // Handle Sync / NOT_SYNC items
            //
            __weak GridCell* cell = (GridCell*) [collectionView dequeueReusableCellWithReuseIdentifier:@"LocalCell" forIndexPath:indexPath];
            
            //
            // Setup cell - clear any past references i.e. image or video thumbnails
            //
            NSInteger currentTag = indexPath.item;
            cell.tag = currentTag;
            
            
            ELCAsset* elcAsset = cell.elcAsset;
            // clear cell for reuse
            [elcAsset.assetImageViewHome setImage:nil];
            [elcAsset.overlayViewHome setImage:nil];
            [elcAsset.videoImageViewHome setImage:nil];
            
            [elcAsset setBackgroundColor:[UIColor clearColor]];
            elcAsset.buttonHome.tag = indexPath.item;
            elcAsset.overlayViewHome.hidden = YES;
            
            NSInteger cellSizeForiPadHW = 200;
            NSInteger cellSizeForiPhoneHW = 100;
            cell.tag = currentTag;
            if (IS_IPAD) {
                cell.size = CGSizeMake(cellSizeForiPadHW, cellSizeForiPadHW);
            } else {
                cell.size = CGSizeMake(cellSizeForiPhoneHW, cellSizeForiPhoneHW);
            }
            
            
            //
            // Fetch Thumbnail - synchronous
            //
            [self fetchImage:[mediaItem.mediaLocalPHAsset copy]
                  withCGSize:cell.size
          andWithUIImageView:elcAsset.assetImageViewHome
              andWithDispath:YES];
            
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
            
            //
            // Handle overlay...
            //
            [elcAsset.buttonHome setBackgroundImage:nil forState:UIControlStateNormal];

            //
            // Set Border COLOR
            //
            [self setBorderColor:cell withMediaState:mediaItem.mediaState];
            
            return cell;
            
        }
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}


#pragma mark
#pragma mark IBActions Methods

- (IBAction)handleAudioComment:(id)sender {
    //
    // Handle Audio Comment
    //
}

- (IBAction)handleNextAction:(id)sender {
    //
    // Segue to memreas page
    //
    [self performSegueWithIdentifier:@"segueShareMediaAddFriends" sender:self];
    
}

- (IBAction)handleDoneAction:(id)sender {
    //
    // Done so create event then add media on notification
    //
    [shareCreatorInstance addeventWSCall:ADDEVENT_MEDIA_EVENT_RESULT_NOTIFICATION];
}

- (IBAction)handleCancelAction:(id)sender {
    
    @try {
        //
        // on cancel go back to prior view - cancel on share should clear form.
        //
        [self.navigationController popViewControllerAnimated:true];
        /*
        if (self.eventID) {
            [self.navigationController popViewControllerAnimated:true];
        }else{
            [self.tabBarController setSelectedIndex:3];
            [ShareCreator resetSharedInstance];
            [self.navigationController popToRootViewControllerAnimated:true];
            
        }
        */
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
}

- (IBAction)handleAddMediaPopup:(id)sender {
    [self performSegueWithIdentifier:@"segueShareAddMediaSelect"
                              sender:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark
#pragma mark Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    @try {
        
        if([segue.identifier isEqualToString:@"segueShareAddMediaSelect"]){
            AddMemreasShareMediaSelectViewController *memreasSelectVC = segue.destinationViewController;
            memreasSelectVC.delegate = self;
        }
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
}



#pragma mark
#pragma mark Select Media Delegates


-(void)addMemreasShareSelectMedia:(AddMemreasShareMediaSelectViewController *)addMemerasShareSelectVC{
    
    @try {
        [self.collectionView reloadData];
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
}

#pragma mark
#pragma mark Gallery related methods and objects

- (void)setBorderColor:(GridCell*)cell
        withMediaState:(MediaItemState)mediaState {
    
    @try {
        
        cell.layer.borderWidth = 2.0;
        cell.layer.masksToBounds = YES;
        cell.layer.cornerRadius = 5.0;
        
        switch (mediaState) {
                
            case SYNC:{
                cell.layer.borderColor = [UIColor greenColor].CGColor;
                break;
            }
            case SERVER:{
                cell.layer.borderColor = [UIColor yellowColor].CGColor;
                break;
            }
            case IN_TRANSIT:{
                cell.layer.borderColor = [UIColor orangeColor].CGColor;
                break;
            }
            case NOT_SYNC:{
                cell.layer.borderColor = [UIColor redColor].CGColor;
                break;
            }
            default:{
                cell.layer.borderColor = [UIColor clearColor].CGColor;
                break;
            }
        }
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}


- (void) startCaching {
    
    //
    // Start Caching
    //
    cachingImageManager = [[PHCachingImageManager alloc] init];
    phImageCachingOptionsASHM = [[PHImageRequestOptions alloc] init];
    phImageCachingOptionsASHM.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    NSInteger cellSizeForiPadHW = 200;
    [cachingImageManager
     startCachingImagesForAssets:sharedGalleryInstance.phAssetsNSMutableArray
     targetSize:CGSizeMake(cellSizeForiPadHW,
                           cellSizeForiPadHW)
     contentMode:PHImageContentModeAspectFit
     options:phImageCachingOptionsASHM];
    
}


- (void) fetchImage:(PHAsset*) localMediaPHAsset
        withCGSize:(CGSize)size
andWithUIImageView:(UIImageView*)imageView
    andWithDispath:(BOOL)doDispatch{
    
    
    [cachingImageManager
     requestImageForAsset:localMediaPHAsset
     targetSize:size
     contentMode:PHImageContentModeAspectFit
     options:phImageRequestOptionsASHM  // synchronous
     resultHandler:^(UIImage* result, NSDictionary* info) {
         if (doDispatch) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [imageView setImage:result];
             });
         }
     }];
    
}


- (void) handleAddEvent:(NSNotification*)notification {
    //
    // At this point the event is created so the media needs to be added
    //
    NSDictionary* resultTags = [notification userInfo];
    NSString* status = [resultTags objectForKey:@"status"];
    NSString* message = [resultTags objectForKey:@"message"];
    if ([status isEqualToString:@"Success"]) {
        shareCreatorInstance.eventId = [resultTags objectForKey:@"event_id"];
        if (shareCreatorInstance.selectedMedia.count > 0) {
            [shareCreatorInstance addMediaToEvent:shareCreatorInstance.eventId withNotificationKey:ADDEVENT_MEDIA_MEDIA_RESULT_NOTIFICATION];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                //just move to memreas - no media
                [shareCreatorInstance resetSharedInstance];
                [self performSelector:@selector(moveToMemreas) withObject:nil afterDelay:1.0];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [self.tabBarController setSelectedIndex:3];
            });
            
        }
    } else {
        // show error message
        [Helper showMessageFade:self.view withMessage:message andWithHideAfterDelay:3];
    }
}

- (void) handleAddMediaToEvent:(NSNotification*)notification {
    //
    // At this point the event is created and media added so move to memreas tab
    //
    NSDictionary* resultTags = [notification userInfo];
    NSString* status = [resultTags objectForKey:@"status"];
    NSString* message = [resultTags objectForKey:@"message"];
    if ([status isEqualToString:@"Success"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //
            // Event created and media added to move to memreas
            //
            [shareCreatorInstance resetSharedInstance];
            [self performSelector:@selector(moveToMemreas) withObject:nil afterDelay:1.0];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self.tabBarController setSelectedIndex:3];
        });
    } else {
        // show error message
        [Helper showMessageFade:self.view withMessage:message andWithHideAfterDelay:3];
    }
}

-(void) moveToMemreas{
   [self.navigationController popToRootViewControllerAnimated:true];
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

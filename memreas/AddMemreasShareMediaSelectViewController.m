#import "AddMemreasShareMediaSelectViewController.h"
#import "MyConstant.h"
#import "ShareCreator.h"
#import "GalleryManager.h"
#import "GridCell.h"
#import "UIImageView+AFNetworking.h"
#import "NSDictionary+valueAdd.h"

@interface AddMemreasShareMediaSelectViewController ()

@property PHCachingImageManager* cachingImageManager;
@property (nonatomic,strong ) NSMutableArray*arrTempDatasaveForCancel;


@end

@implementation AddMemreasShareMediaSelectViewController {
    //
    // local vars here
    //
    ShareCreator* shareCreatorInstance;
    GalleryManager* sharedGalleryInstance;
    
}

#pragma mark
#pragma mark View life cycle
//
// Methods
//
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //
    // Set Page Title
    //
    if (IS_IPAD) {
        self.headerImageView.image = [UIImage imageNamed:@"select gallery photos"];
    }
    
    
    //
    // Add a gray border to the view
    //
    self.popupView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    //
    // Fetch ShareCreator
    //
    shareCreatorInstance = [ShareCreator sharedInstance];
    
    //
    // Fetch Gallery Manager
    //
    sharedGalleryInstance = [GalleryManager sharedGalleryInstance];
    
    //Start Caching media
    
    [self startCaching];
    
    // Data save for cancel
    self.arrTempDatasaveForCancel = shareCreatorInstance.selectedMedia;
    
    //
    // Add observer for handle method
    //
    SEL handleAddMediaToEventSelector = @selector(handleAddMediaToEvent:);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:handleAddMediaToEventSelector
                                                 name:MEMREAS_ADDMEDIA_RESULT_NOTIFICATION
                                               object:nil];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark
#pragma mark GridCollection View Delegates

//
// GridCollectionvsView Delegates
//
- (NSInteger)collectionView:(UICollectionView*)collectionView
     numberOfItemsInSection:(NSInteger)section {
    
    return sharedGalleryInstance.galleryNSMutableArray.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
                 cellForItemAtIndexPath:(NSIndexPath*)indexPath {
    @try {
        //
        // Fetch mediaItem...
        //
        MediaItem* mediaItem;
        @synchronized(sharedGalleryInstance) {
            mediaItem = sharedGalleryInstance.galleryNSMutableArray[indexPath.item] ;
        }
        
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
            
            //
            // Handle tabs...
            //
            if ([shareCreatorInstance.selectedMedia containsObject:mediaItem]) {
                [myView.btnPhoto setBackgroundImage:[UIImage imageNamed:@"Overlay"] forState:UIControlStateNormal];
            }else{
                [myView.btnPhoto setBackgroundImage:nil forState:UIControlStateNormal];
            }
            [myView.btnPhoto addTarget:self action:@selector(selectMedia:) forControlEvents:UIControlEventTouchUpInside];
            
            // Set URLs for videos and images only...
            // ALog(@"server mediaItem.mediaType -----> %@", mediaItem.mediaType);
            
            
            if (([mediaItem.mediaType length] != 0) &&
                [mediaItem.mediaType isEqualToString:@"video"]) {
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
            // Handle tabs...
            //
            
            if ([shareCreatorInstance.selectedMedia containsObject:mediaItem]) {
                [elcAsset.buttonHome setBackgroundImage:[UIImage imageNamed:@"Overlay"] forState:UIControlStateNormal];
            }else{
                [elcAsset.buttonHome setBackgroundImage:nil forState:UIControlStateNormal];
            }
            [elcAsset.buttonHome addTarget:self action:@selector(selectMedia:) forControlEvents:UIControlEventTouchUpInside];
            
            
            // Set Border COLOR
            [self setBorderColor:cell withMediaState:mediaItem.mediaState];
            return cell;
            
        }
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}



#pragma mark
#pragma mark Share Media related methods

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
                cell.layer.borderColor = [UIColor redColor].CGColor;
                break;
            }
        }
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}


-(void)selectMedia:(UIButton*)sender{
    
    @try {
        
        MediaItem* mediaItem = sharedGalleryInstance.galleryNSMutableArray[sender.tag];
        NSMutableArray *tempArray = shareCreatorInstance.selectedMedia;
        
        if ([tempArray containsObject:mediaItem]) {
            [tempArray removeObject:mediaItem];
        }else{
            if (mediaItem.mediaState == IN_TRANSIT) {
                // show error message
                [Helper showMessageFade:self.view withMessage:@"media syncing - please try later" andWithHideAfterDelay:3];
            } else {
                [tempArray addObject:mediaItem];
            }
        }
        shareCreatorInstance.selectedMedia = tempArray;
        [self.gridCollectionView reloadData];
        
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
}


#pragma mark
#pragma mark Gallery related methods and objects
PHImageRequestOptions* phImageRequestOptionsSHM;
PHImageRequestOptions* phImageCachingOptionsSHM;


- (void)startCaching {
    
    //
    // Start Caching
    //
    self.cachingImageManager = [[PHCachingImageManager alloc] init];
    phImageCachingOptionsSHM = [[PHImageRequestOptions alloc] init];
    phImageCachingOptionsSHM.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    NSInteger cellSizeForiPadHW = 200;
    [self.cachingImageManager
     startCachingImagesForAssets:sharedGalleryInstance.phAssetsNSMutableArray
     targetSize:CGSizeMake(cellSizeForiPadHW,
                           cellSizeForiPadHW)
     contentMode:PHImageContentModeAspectFit
     options:phImageCachingOptionsSHM];
    
}


- (void)fetchImage:(PHAsset*) localMediaPHAsset
        withCGSize:(CGSize)size
andWithUIImageView:(UIImageView*)imageView
    andWithDispath:(BOOL)doDispatch{

    [self.cachingImageManager
     requestImageForAsset:localMediaPHAsset
     targetSize:size
     contentMode:PHImageContentModeAspectFit
     options:phImageRequestOptionsSHM  // synchronous
     resultHandler:^(UIImage* result, NSDictionary* info) {
         if (doDispatch) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [imageView setImage:result];
             });
         }
     }];
    
}



#pragma mark
#pragma mark IBActions related methods

//
// Add Share button Handlers
//
- (IBAction)okAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        //
        // Return to parent with updates
        //
        [self.delegate addMemreasShareSelectMedia:self];
    }];
    
}

- (IBAction)cancelAction:(id)sender {
    // Data save for cancel
    
    shareCreatorInstance.selectedMedia =    self.arrTempDatasaveForCancel ;
    
    [self dismissViewControllerAnimated:YES completion:^{
        //
        // clear selections updates here
        //
        
        [self.delegate addMemreasShareSelectMedia:self];
        
    }];
}


//
// Memreas Add Media button Handlers
//
- (IBAction)okMemreasAction:(id)sender {
    
    //
    // At this point the event is created so the media needs to be added
    //
    shareCreatorInstance.eventId = self.eventId;
    if (shareCreatorInstance.selectedMedia.count > 0) {
        [shareCreatorInstance addMediaToEvent:shareCreatorInstance.eventId withNotificationKey:MEMREAS_ADDMEDIA_RESULT_NOTIFICATION];
    } else {
        // show error message
        if (self.isViewLoaded && self.view.window) {
            [Helper showMessageFade:self.view withMessage:@"please select media or cancel" andWithHideAfterDelay:3];
        }
    }
}

- (IBAction)cancelMemreasAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        //
        // Dismiss modal here
        //
        [shareCreatorInstance resetSharedInstance];
        if (self.isViewLoaded && self.view.window) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
        
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }];
    
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
            // Initiate refresh of events...
            //
            NSMutableDictionary* resultInfo = [NSMutableDictionary dictionary];
            [resultInfo addValueToDictionary:@"Success" andKeyIs:@"status"];
            [resultInfo addValueToDictionary:@"updates submitted..." andKeyIs:@"message"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:MEMREAS_SELECT_RESULT_REFRESH_NOTIFICATION
                                                                object:self
                                                              userInfo:resultInfo];
            
            //
            // media added so dismiss modal
            //
            [shareCreatorInstance resetSharedInstance];
            if (self.isViewLoaded && self.view.window) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    } else {
        // show error message
        if (self.isViewLoaded && self.view.window) {
            [Helper showMessageFade:self.view withMessage:message andWithHideAfterDelay:3];
        }
    }
}




@end

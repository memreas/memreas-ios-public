/**
 * Copyright (C) 2015 memreas llc. - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */
//
//  HomeViewController.m
//

#define IS_IPHONE_5                                                         \
  (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)568) < \
   DBL_EPSILON)

#import "HomeViewController.h"

#pragma mark - Home View Controller
#pragma mark -

#import "FullScreenView.h"

@interface HomeViewController ()<GMSMapViewDelegate,
                                 CLLocationManagerDelegate,
                                 MBProgressHUDDelegate> {
}

@property(nonatomic, assign) IBOutlet UIScrollView* svMapImages;
@property(nonatomic, assign) IBOutlet UIScrollView* svPhotoEditor;
@property(weak, nonatomic) IBOutlet UIView* viewLoading;
@property(nonatomic, strong) HomeLocationView* location;
@property(nonatomic, strong) FullScreenView* fullScreenView;
@end

@implementation HomeViewController {
  BOOL m_bAddrUpdateOk;
  float heightOfViewScroll;
  GMSMapView* googleMap;
  CLLocationManager* locationManager;
  MBProgressHUD* HUD;
  CopyrightManager* sharedInstanceCopyrightManager;
  GalleryManager* sharedGalleryInstance;
}

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

- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
  return UIInterfaceOrientationPortrait;
}

#pragma mark - Object Initialization
- (void)initLocationForMap {
  locationManager = [[CLLocationManager alloc] init];

  if (IS_OS_8_OR_LATER) {
    [locationManager requestWhenInUseAuthorization];
  } else {
    [locationManager requestAlwaysAuthorization];
  }
}

#pragma mark - View lifecycle

- (void)openMenu {
  UIButton* btn = (id)[self.navigationItem.rightBarButtonItem customView];
  [SettingButton notificationClicked:(id)btn];
}

- (void)viewDidLoad {
  NSLog(@"%s", __PRETTY_FUNCTION__);
  @try {
    [super viewDidLoad];

    if (aLAssetsLibrary == nil) {
      aLAssetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    //
    // Observers
    //
    //[[NSNotificationCenter defaultCenter]
    //    addObserver:self
    //       selector:@selector(refreshGalleryView)
    //           name:REFRESH_GALLERY_VIEW
    //        object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self
    //                                         selector:@selector(openMenu)
    //                                             name:@"OPEN"
    //                                           object:nil];

    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = NO;

    self.selectedForSync = [[NSMutableArray alloc] init];

    [SettingButton addRightBarButtonAsNotificationInViewController:self];
    [SettingButton addLeftSearchInViewController:self];

    self.btnGreen.layer.borderColor = [UIColor greenColor].CGColor;
    self.btnYellow.layer.borderColor = [UIColor yellowColor].CGColor;
    self.btnRed.layer.borderColor = [UIColor redColor].CGColor;
    self.btnRed.layer.borderWidth = 1;
    self.btnYellow.layer.borderWidth = 1;
    self.btnGreen.layer.borderWidth = 1;

    if ([UIImage
            instancesRespondToSelector:@selector(imageWithRenderingMode:)]) {
      [self.segViewSync setImage:[[UIImage imageNamed:@"home_tab_view_select"]
                                     imageWithRenderingMode:
                                         UIImageRenderingModeAlwaysOriginal]
               forSegmentAtIndex:0];
      [self.segViewSync setImage:[[UIImage imageNamed:@"home_tab_edit_unselect"]
                                     imageWithRenderingMode:
                                         UIImageRenderingModeAlwaysOriginal]
               forSegmentAtIndex:1];
      [_segViewSync setImage:[[UIImage imageNamed:@"home_tab_sync_unselect"]
                                 imageWithRenderingMode:
                                     UIImageRenderingModeAlwaysOriginal]
           forSegmentAtIndex:2];
      [_segViewSync setImage:[[UIImage imageNamed:@"home_tab_location_unselect"]
                                 imageWithRenderingMode:
                                     UIImageRenderingModeAlwaysOriginal]
           forSegmentAtIndex:3];

    } else {
      [self.segViewSync setImage:[UIImage imageNamed:@"home_tab_view_select"]
               forSegmentAtIndex:0];
      [self.segViewSync setImage:[UIImage imageNamed:@"home_tab_edit_unselect"]
               forSegmentAtIndex:1];
      [_segViewSync setImage:[UIImage imageNamed:@"home_tab_sync_unselect"]
           forSegmentAtIndex:2];
      [_segViewSync setImage:[UIImage imageNamed:@"home_tab_location_unselect"]
           forSegmentAtIndex:3];
    }

    [self.segViewSync setSelectedSegmentIndex:0];
    [self NormalView];

    appDelegate =
        (RootViewControllerAppDelegate*)[UIApplication sharedApplication]
            .delegate;
    x = 2, y = 2;
    counter_images = 0;

    // Initialize Map
    [self initLocationForMap];

    [self performSelector:@selector(heightSET) withObject:nil afterDelay:1];

  } @catch (NSException* exception) {
    NSLog(@"%@", exception);
  }
}

- (void)viewWillAppear:(BOOL)animated {
  NSLog(@"%s", __PRETTY_FUNCTION__);

  @try {
    [super viewWillAppear:animated];

    [[UIApplication sharedApplication]
        setStatusBarOrientation:UIInterfaceOrientationPortrait
                       animated:NO];

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
    // Fix for constraint errors
    //
    // self.gridCollectionView.translatesAutoresizingMaskIntoConstraints = NO;

    // Refresh Indicator
    self.viewLoading.hidden = 0;

    [self performSelector:@selector(setingOFSEG) withObject:nil afterDelay:1];
    [self NormalView];

    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    appDelegate.currentView = @"HomeViewController";

    // Necessory for video player nil
    self.myMovieViewController = nil;

  } @catch (NSException* exception) {
    NSLog(@"%@", exception);
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  // set sharedGalleryInstance
  sharedGalleryInstance = [GalleryManager sharedGalleryInstance];

  isFirstTime = YES;
  appDelegate.forAssetSize = 1;
  self.serverMediaFileNames = [[NSMutableArray alloc] init];

  if (self.selectedForSync == nil) {
    self.selectedForSync = [[NSMutableArray alloc] init];
  }

  [self.selectedForSync removeAllObjects];
  [self clearSelected:nil];
}

- (void)heightSET {
  heightOfViewScroll = self.gridCollectionView.frame.size.height;
}

- (void)setingOFSEG {
  @try {
    [self.segViewSync setSelectedSegmentIndex:0];
    [self segmentChange:self.segViewSync];

  } @catch (NSException* exception) {
    NSLog(@"%@", exception);
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  [self resignFirstResponder];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"uploadImages"]) {
  } else if ([segue.identifier isEqualToString:@"Setting"]) {
    UIViewController* destViewController = segue.destinationViewController;
    destViewController.hidesBottomBarWhenPushed = YES;
  }
}

- (void)onClickSetting {
  [self performSegueWithIdentifier:@"Setting" sender:nil];
}

#pragma mark
#pragma mark ColorDelegate Method
//??
- (void)changeMediaColorOfTag:(long)tag {
}
//??
- (void)download_changeMediaColorOfTag:(int)tag {
}

#pragma mark
#pragma mark Collection View Method
- (void)checkForTranscodingInProgress:(GridCell*)cell
                        andDictionary:(NSDictionary*)dic {
  NSLog(@"%s", __PRETTY_FUNCTION__);

  @try {
    // NSLog(@"%@",[dic [@"metadata"] convertToJson]);

    NSString* strTranscodeEnd = [[[dic[@"metadata"] convertToJson]
        valueForKeyPath:@"S3_files.transcode_progress"] lastObject];
    NSString* type =
        [NSString stringWithFormat:@"%@", [dic valueForKey:@"type"]];
    if ([type isEqualToString:@"video"]) {
      if (![strTranscodeEnd rangeOfString:@"transcode_built_thumbnails"]
               .length &&
          0) {
        cell.myView.imgPhoto.image = [UIImage imageNamed:@"TranscodingDisc"];
      }

    } else if (![strTranscodeEnd rangeOfString:@"transcode_end"].length && 0) {
      cell.myView.imgPhoto.image = [UIImage imageNamed:@"TranscodingDisc"];
    }

  } @catch (NSException* exception) {
    NSLog(@"%@", exception);
  }
}

- (void)refreshGalleryView {
  @try {
    //[appDelegate runOnMainWithoutDeadlocking:^{
    //  [self.gridCollectionView reloadData];
    //}];

    [self.gridCollectionView reloadData];
  } @catch (NSException* exception) {
    NSLog(@"%@", exception);
  }
}

- (NSInteger)collectionView:(UICollectionView*)collectionView
     numberOfItemsInSection:(NSInteger)section {
  NSLog(@"%s::returning sharedGalleryInstance.arrGallery.count: %lu",
        __PRETTY_FUNCTION__,
        (unsigned long)sharedGalleryInstance.galleryNSMutableArray.count);

  NSLog(@"collectionView.delegate::%@, collectionView.dataSource::%@",
        collectionView.delegate, collectionView.dataSource);

  return sharedGalleryInstance.galleryNSMutableArray.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
                 cellForItemAtIndexPath:(NSIndexPath*)indexPath {
  @try {
    // Turn off Refresh Indicator
    self.viewLoading.hidden = 1;

    // Fetch mediaItem...
    MediaItem* mediaItem = sharedGalleryInstance.galleryNSMutableArray[indexPath.item];
    float widthB = 2;

    // Fetch PHImageManager
    PHImageManager* phImageManager = [PHImageManager defaultManager];
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

      // NSLog(@"79x80 url: %@", mediaItem.mediaThumbnailUrl79x80[0]);
      [myView.imgPhoto setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:mediaItem.mediaThumbnailUrl79x80[0]]]]];

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
          [myView.btnPhoto addTarget:self
                              action:@selector(openGalleryMedia:)
                    forControlEvents:UIControlEventTouchUpInside];
          break;
        }

        case 1: {
          // Edit
          [myView.btnPhoto removeTarget:self
                                 action:@selector(mediaTouchForSync:)
                       forControlEvents:UIControlEventTouchUpInside];
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
          if (mediaItem.isSelectedForSync) {
            myView.btnPhoto.selected = YES;
            [myView.btnPhoto setImage:[UIImage imageNamed:@"Overlay"]
                             forState:UIControlStateNormal];

          } else {
            myView.btnPhoto.selected = NO;
            [myView.btnPhoto setImage:[UIImage imageNamed:nil]
                             forState:UIControlStateNormal];
          }
          break;
        }

        default:
          break;
      }

      // Set URLs for videos and images only...
      NSLog(@"mediaItem.mediaType -----> %@", mediaItem.mediaType);
      if (([mediaItem.mediaType length] != 0) &&
          [mediaItem.mediaType isEqualToString:@"video"]) {
        // Video
        // Apply first image
        // NSLog(@"79x80 url: %@", mediaItem.mediaThumbnailUrl79x80[0]);
        [myView.imgPhoto setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:mediaItem.mediaThumbnailUrl79x80[0]]]]];
        [myView.imgVideo setContentMode:UIViewContentModeCenter];
        [myView.imgVideo setImage:[UIImage imageNamed:@"video_play"]];

      } else if (([mediaItem.mediaType length] != 0) &&
                 [mediaItem.mediaType isEqualToString:@"image"]) {
        [myView.btnPhoto setImage:nil forState:UIControlStateNormal];
        [myView.imgPhoto stopAnimating];
        myView.imgPhoto.animationImages = nil;

        // NSLog(@"79x80 url: %@", mediaItem.mediaThumbnailUrl79x80[0]);
        [myView.imgPhoto setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:mediaItem.mediaThumbnailUrl79x80[0]]]]];
      }

      if (sharedGalleryInstance.galleryNSMutableArray.count <= indexPath.item) {
        self.viewLoading.hidden = 1;
      }

      //
      // ToDo - update transcoding method...
      //
      //[self checkForTranscodingInProgress:cell andDictionary:dicTemp];

      return cell;

    } else {
      //
      // Handle Sync / NOT_SYNC items
      //
      GridCell* cell = (GridCell*)
          [collectionView dequeueReusableCellWithReuseIdentifier:@"LocalCell"
                                                    forIndexPath:indexPath];
      ELCAsset* elcAsset = cell.elcAsset;

      [phImageManager
          requestImageForAsset:mediaItem.mediaLocalPHAsset
                    targetSize:cell.size
                   contentMode:PHImageContentModeAspectFit
                       options:nil
                 resultHandler:^(UIImage* result, NSDictionary* info) {
                   self.thumbnail = result;
                 }];

      //  [elcAsset.assetImageViewHome
      //     setImage:[UIImage
      //                 imageWithCGImage:[mediaItem.mediaLocalAsset
      //                 thumbnail]]]
      [elcAsset.assetImageViewHome setImage:self.thumbnail];
      // elcAsset.asset = mediaItem.mediaLocalPHAsset;
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

      if (mediaItem.mediaLocalPHAsset.mediaType == PHAssetMediaTypeVideo) {
        [elcAsset.videoImageViewHome setContentMode:UIViewContentModeCenter];
        [elcAsset.videoImageViewHome
            setImage:[UIImage imageNamed:@"video_play"]];
      } else {
        [elcAsset.videoImageViewHome setImage:nil];
      }

      [elcAsset setParent:self];
      elcAsset.tag = indexPath.item;
      ELCAsset* view = cell.elcAsset;

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
          [cell bringSubviewToFront:view];
          break;
        }
        case 1: {
          // Edit
          elcAsset.layer.borderColor = [UIColor redColor].CGColor;
          [elcAsset.buttonHome removeTarget:self
                                     action:@selector(mediaTouchForSync:)
                           forControlEvents:UIControlEventTouchUpInside];
          [elcAsset.buttonHome addTarget:self
                                  action:@selector(openGalleryMedia:)
                        forControlEvents:UIControlEventTouchUpInside];
          [self setBorderColor:cell withMediaState:mediaItem.mediaState];

          view.buttonHome.hidden = NO;
          [cell bringSubviewToFront:view.buttonHome];
          elcAsset.overlayViewHome.hidden = YES;
          break;
        }
        case 2: {
          // Sync
          elcAsset.layer.borderColor = [UIColor redColor].CGColor;
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
            [elcAsset.buttonHome setBackgroundImage:[UIImage imageNamed:nil]
                                           forState:UIControlStateNormal];
          }
          [cell bringSubviewToFront:view];
          break;
        }
        default:
          break;
      }

      NSLog(@"published cell for mediaItem url:: %@", mediaItem.mediaLocalPath);
      return cell;
    }

  } @catch (NSException* exception) {
    NSLog(@"%@", exception);
  }
}

- (void)showAlertForAlreadyExsist {
  UIAlertController* co = [UIAlertController
      alertControllerWithTitle:@""
                       message:@"This media is already available in local "
                       @"directory. You can not sync again."
                preferredStyle:UIAlertControllerStyleAlert];

  UIAlertAction* al = [UIAlertAction actionWithTitle:@"OK"
                                               style:UIAlertActionStyleCancel
                                             handler:^(UIAlertAction* action){
                                                 // do close
                                             }];

  [co addAction:al];
  [self presentViewController:co animated:1 completion:nil];
}

- (NSArray*)convertToJson:(NSString*)jsonString {
  // create our request
  NSError* error;
  NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
  return [NSJSONSerialization JSONObjectWithData:data
                                         options:kNilOptions
                                           error:&error];
}

#pragma mark
#pragma mark Segment Control method

- (IBAction)segmentChange:(id)sender {
  @try {
    UISegmentedControl* segmentController = (UISegmentedControl*)sender;
    NSUInteger selectedIndex = segmentController.selectedSegmentIndex;

    if ([UIImage
            instancesRespondToSelector:@selector(imageWithRenderingMode:)]) {
      [_segViewSync setImage:[[UIImage
                                 imageNamed:(selectedIndex == 0
                                                 ? @"home_tab_view_select"
                                                 : @"home_tab_view_unselect")]
                                 imageWithRenderingMode:
                                     UIImageRenderingModeAlwaysOriginal]
           forSegmentAtIndex:0];
      [_segViewSync setImage:[[UIImage
                                 imageNamed:(selectedIndex == 1
                                                 ? @"home_tab_edit_select"
                                                 : @"home_tab_edit_unselect")]
                                 imageWithRenderingMode:
                                     UIImageRenderingModeAlwaysOriginal]
           forSegmentAtIndex:1];
      [_segViewSync setImage:[[UIImage
                                 imageNamed:(selectedIndex == 2
                                                 ? @"home_tab_sync_select"
                                                 : @"home_tab_sync_unselect")]
                                 imageWithRenderingMode:
                                     UIImageRenderingModeAlwaysOriginal]
           forSegmentAtIndex:2];
      [_segViewSync
                   setImage:[[UIImage imageNamed:
                                          (selectedIndex == 3
                                               ? @"home_tab_location_select"
                                               : @"home_tab_location_unselect")]
                                imageWithRenderingMode:
                                    UIImageRenderingModeAlwaysOriginal]
          forSegmentAtIndex:3];
    } else {
      [_segViewSync setImage:[UIImage
                                 imageNamed:(selectedIndex == 0
                                                 ? @"home_tab_view_select"
                                                 : @"home_tab_view_unselect")]
           forSegmentAtIndex:0];
      [_segViewSync setImage:[UIImage
                                 imageNamed:(selectedIndex == 1
                                                 ? @"home_tab_edit_select"
                                                 : @"home_tab_edit_unselect")]
           forSegmentAtIndex:1];
      [_segViewSync setImage:[UIImage
                                 imageNamed:(selectedIndex == 2
                                                 ? @"home_tab_sync_select"
                                                 : @"home_tab_sync_unselect")]
           forSegmentAtIndex:2];
      [_segViewSync setImage:[UIImage imageNamed:
                                          (selectedIndex == 3
                                               ? @"home_tab_location_select"
                                               : @"home_tab_location_unselect")]
           forSegmentAtIndex:3];
    }

    self.gridCollectionView.hidden =
        !(selectedIndex == 0 || selectedIndex == 2);

    [self clearSelected:nil];
    [self NormalView];

    switch (segmentController.selectedSegmentIndex) {
      case 0: {
        [self loadLocation:0];

        float realheight = heightOfViewScroll;
        self.gridCollectionView.frame =
            CGRectMake(self.gridCollectionView.frame.origin.x,
                       self.gridCollectionView.frame.origin.y,
                       self.gridCollectionView.frame.size.width, realheight);
        break;
      }

      case 1: {
        [self loadLocation:0];
        float realheight = heightOfViewScroll;
        self.gridCollectionView.frame =
            CGRectMake(self.gridCollectionView.frame.origin.x,
                       self.gridCollectionView.frame.origin.y,
                       self.gridCollectionView.frame.size.width, realheight);
        break;
      }

      case 2: {
        [self syncView];
        [self loadLocation:0];
        float realheight = heightOfViewScroll - 35;
        self.gridCollectionView.frame =
            CGRectMake(self.gridCollectionView.frame.origin.x,
                       self.gridCollectionView.frame.origin.y,
                       self.gridCollectionView.frame.size.width, realheight);
        break;
      }

      case 3: {
        [self loadLocation:1];
        break;
      }
    }

    [self.gridCollectionView reloadData];

  } @catch (NSException* exception) {
    NSLog(@"%@", exception);
  }
}

#pragma mark
#pragma mark Location Load
- (void)loadLocation:(BOOL)load {
  @try {
    int yX = 85;
    __weak HomeViewController* wSelf = self;
    if (load) {
      self.location = [self.storyboard
          instantiateViewControllerWithIdentifier:@"HomeLocationView"];
      self.location.view.frame =
          CGRectMake(0, yX, self.location.view.frame.size.width,
                     self.location.view.frame.size.height - 190);
      [self addChildViewController:self.location];
      [self.view addSubview:self.location.view];

      self.location.view.alpha = 0;
      // Pass parameter

      [UIView beginAnimations:nil context:NULL];
      self.location.view.alpha = 1;
      [UIView commitAnimations];

    } else {
      [UIView beginAnimations:nil context:NULL];
      [UIView animateWithDuration:0.5
          animations:^{
            self.location.view.alpha = 0;
          }
          completion:^(BOOL finished) {
            [wSelf.location removeFromParentViewController];
            [wSelf.location.view removeFromSuperview];
            wSelf.location = nil;

          }];
      [UIView commitAnimations];
    }

  } @catch (NSException* exception) {
    NSLog(@"%@", exception);
  }
}

#pragma mark

- (void)syncView {
  _btnYellow.hidden = NO;
  _btnRed.hidden = NO;
  _btnGreen.hidden = NO;
  _btnClear.hidden = NO;
  _btnDone.hidden = NO;
}

- (void)NormalView {
  _btnYellow.hidden = YES;
  _btnRed.hidden = YES;
  _btnGreen.hidden = YES;
  _btnClear.hidden = YES;
  _btnDone.hidden = YES;
}

- (void)EditView {
  _btnYellow.hidden = YES;
  _btnRed.hidden = YES;
  _btnGreen.hidden = YES;
  _btnClear.hidden = YES;
  _btnDone.hidden = YES;
}

#pragma mark
#pragma mark Button Touch Handling
- (IBAction)doneAction:(id)sender {
  @try {
    // add transfer
    for (MediaItem* mediaItem in self.selectedForSync) {
      if (mediaItem.mediaState == NOT_SYNC) {
        [[QueueController sharedInstance] addToPendingTransferArray:mediaItem
                                                   withTransferType:UPLOAD];
      } else if (mediaItem.mediaState == SERVER) {
        [[QueueController sharedInstance] addToPendingTransferArray:mediaItem
                                                   withTransferType:DOWNLOAD];
      }
      mediaItem.isSelectedForSync = false;
    }

    [self clearSelected:self];
    // Segue to Queue tab here...
    [self.tabBarController setSelectedIndex:1];

  } @catch (NSException* exception) {
    NSLog(@"%@", exception);
  }
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
      // do nothing - default is red
      // myView.layer.borderColor = [UIColor redColor].CGColor;
      // cell.layer.borderColor = [UIColor redColor].CGColor;
    } else if (mediaState == SERVER) {
      myView.layer.borderColor = [UIColor yellowColor].CGColor;
      cell.layer.borderColor = [UIColor yellowColor].CGColor;
    }
  } @catch (NSException* exception) {
    NSLog(@"%@", exception);
  }
}

- (void)mediaTouchForSync:(id)sender {
  /**
   * Check for sync tab
   */
  if (_segViewSync.selectedSegmentIndex == 2) {
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
        [btn setBackgroundImage:[UIImage imageNamed:nil]
                       forState:UIControlStateNormal];
        [self.selectedForSync removeObject:mediaItem];
        mediaItem.isSelectedForSync = false;
      } else if (mediaItem.mediaState == SYNC) {
        // do nothing...
        mediaItem.isSelectedForSync = false;
      }
    } else {
      if ((mediaItem.mediaState == SERVER) ||
          (mediaItem.mediaState == NOT_SYNC)) {
        [self.selectedForSync addObject:mediaItem];
        mediaItem.isSelectedForSync = true;
        btn.selected = YES;
        [btn setBackgroundImage:[UIImage imageNamed:@"Overlay"]
                       forState:UIControlStateNormal];
      } else if (mediaItem.mediaState == SYNC) {
        // show alert
        mediaItem.isSelectedForSync = false;
        UIAlertView* theAlert =
            [[UIAlertView alloc] initWithTitle:@"sync'd"
                                       message:@"media is already synchronized"
                                      delegate:self
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
        [theAlert show];
      }
    }
  }  // end if(_segViewSync.selectedSegmentIndex == 2)
}

- (IBAction)clearSelected:(id)sender {
  [self.selectedForSync removeAllObjects];
  [self.gridCollectionView reloadData];
}
- (void)openGalleryMedia:(id)sender {
  @try {
    UIButton* btn = (UIButton*)sender;
    MediaItem* mediaItem = sharedGalleryInstance.galleryNSMutableArray[btn.tag];
    if ([mediaItem.mediaType isEqualToString:@"video"]) {
      NSURL* contentURL;
      if (mediaItem.mediaState != SERVER) {
        // Fetch local URL
        __block AVPlayerItem* avPlayerItem;
        __block NSDictionary* avInfo;
        PHImageManager* manager = [PHImageManager defaultManager];
        [manager requestPlayerItemForVideo:mediaItem.mediaLocalPHAsset
                                   options:nil
                             resultHandler:^(AVPlayerItem* playerItem,
                                             NSDictionary* info) {
                               avPlayerItem = playerItem;
                               avInfo = info;
                             }];
        NSLog(@"avInfo: %@", avInfo);
        // contentURL = [[mediaItem.mediaLocalAsset defaultRepresentation]
        // url];
      } else {
        // Fetch Server URL
        if (mediaItem.mediaUrlHls != nil) {
          contentURL = [NSURL URLWithString:mediaItem.mediaUrlHls[0]];
        } else if (mediaItem.mediaUrl1080p != nil) {
          contentURL = [NSURL URLWithString:mediaItem.mediaUrl1080p[0]];
        } else if (mediaItem.mediaUrlWeb != nil) {
          contentURL = [NSURL URLWithString:mediaItem.mediaUrlWeb[0]];
        }
      }
      /*
    // Play it Sam...
    self.myMovieViewController =
        [[MyMovieViewController alloc] initWithContentURL:contentURL];
    // start movie...
    [self
        presentMoviePlayerViewControllerAnimated:self.myMovieViewController];
    [self.myMovieViewController start];
       */
    } else if ([mediaItem.mediaType isEqualToString:@"image"]) {
      /**
       * TODO - full screen image with rotation...
       */
      [self enterOrExitFullScreenMode:btn.tag];
    }
  } @catch (NSException* exception) {
    NSLog(@"%@", exception);
  }
}

- (void)doneButtonClick:(NSNotification*)aNotification {
  [self.myMovieViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)enterOrExitFullScreenMode:(NSUInteger)index {
  @try {
    if (!self.fullScreenView) {
      self.fullScreenView = [self.storyboard
          instantiateViewControllerWithIdentifier:@"FullScreenView"];

      [self addChildViewController:self.fullScreenView];
      [self.view addSubview:self.fullScreenView.view];

      self.fullScreenView.view.alpha = 0;

      self.navigationController.navigationBarHidden = YES;
      self.tabBarController.tabBar.hidden = YES;

      // Pass parameter
      [UIView beginAnimations:nil context:NULL];
      [UIView animateWithDuration:1.5
          animations:^{
            self.fullScreenView.view.alpha = 1;
            self.fullScreenView.index = index;

          }
          completion:^(BOOL finished){

          }];

      [UIView commitAnimations];

    } else {
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

  } @catch (NSException* exception) {
    NSLog(@"%@", exception);
  }
}
- (void)errorIndownloading:(NSString*)url {
  @try {
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    [MBProgressHUD hideAllHUDsForView:window animated:1];
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:@"Can not download the image."
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];

  } @catch (NSException* exception) {
    NSLog(@"%@", exception);
  }
}

#pragma mark
#pragma mark AdBannerViewDelegate Method

- (BOOL)bannerViewActionShouldBegin:(ADBannerView*)banner
               willLeaveApplication:(BOOL)willLeave {
  //    NSLog(@"Banner view is beginning ad action");
  return YES;
}

- (void)bannerView:(ADBannerView*)banner
    didFailToReceiveAdWithError:(NSError*)error {
  NSLog(@"banner error : %@", error.description);
}

#pragma mark
#pragma mark Button Clicked

- (IBAction)btnRedClicked:(id)sender {
  UIAlertView* alertColor = [[UIAlertView alloc]
          initWithTitle:@"Memreas"
                message:@"Red highlight means media is in your gallery"
               delegate:self
      cancelButtonTitle:@"OK"
      otherButtonTitles:nil, nil];
  [alertColor show];
}
- (IBAction)btnYellowClicked:(id)sender {
  UIAlertView* alertColor = [[UIAlertView alloc]
          initWithTitle:@"Memreas"
                message:@"Yellow highlight denotes media is in memreas cloud"
               delegate:self
      cancelButtonTitle:@"OK"
      otherButtonTitles:nil, nil];
  [alertColor show];
}
- (IBAction)btnGreenClicked:(id)sender {
  UIAlertView* alertColor =
      [[UIAlertView alloc] initWithTitle:@"Memreas"
                                 message:@"Green highlight denotes media is in "
                                 @"memreas cloud and your gallery"
                                delegate:self
                       cancelButtonTitle:@"OK"
                       otherButtonTitles:nil, nil];
  [alertColor show];
}

@end

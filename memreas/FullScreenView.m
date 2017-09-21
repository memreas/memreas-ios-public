#import "FullScreenView.h"

@interface FullScreenView ()

@property(nonatomic, strong) MyMovieViewController* myMovieViewController;

@end

@implementation FullScreenView {
    GalleryManager* sharedGalleryInstance;
    AppDelegate* appDelegate;
}

- (void)viewDidLoad {
  ALog(@"%s", __PRETTY_FUNCTION__);
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  sharedGalleryInstance = [GalleryManager sharedGalleryInstance];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little
 preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)backPressed:(id)sender {
  [self.navigationController popViewControllerAnimated:NO];
}

- (void)setIndex:(NSUInteger)index {
  _index = index;

  @try {
    [self.collectionView
        scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.index
                                                    inSection:0]
               atScrollPosition:UICollectionViewScrollPositionRight
                       animated:0];
  } @catch (NSException* exception) {
    ALog(@"%@", exception);
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

#pragma mark
#pragma mark Collection View Method

- (NSInteger)numberOfSectionsInCollectionView:
    (UICollectionView*)collectionView {
  return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return sharedGalleryInstance.galleryNSMutableArray.count;
}

- (void)viewFrame:(GridCell*)cell {
  cell.myView.imgPhoto.hidden = NO;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
                 cellForItemAtIndexPath:(NSIndexPath*)indexPath {
  MediaItem* mediaItem = sharedGalleryInstance.galleryNSMutableArray[indexPath.item];
  NSURL* contentURL;
  if (mediaItem.mediaState != SERVER) {
    // Fetch local URL
    contentURL = [[NSURL alloc] initWithString:mediaItem.mediaLocalPath];
  } else {
    // Fetch Server URL
    contentURL = [NSURL URLWithString:mediaItem.mediaUrl[0]];
  }

  if (mediaItem.mediaState == SERVER) {
    GridCell* cell = (GridCell*)
        [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell"
                                                  forIndexPath:indexPath];
    [cell.myView.scroll setZoomScale:1 animated:0];

    if ([mediaItem.mediaType isEqualToString:@"video"]) {
      // Video
      cell.imgVideo.hidden = 0;
      cell.imgVideo.userInteractionEnabled = YES;
      cell.imgVideo.tag = indexPath.item;
      [cell.myView.imgPhoto setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:mediaItem.mediaThumbnailUrl79x80[0]]]]];

    } else {
      cell.imgVideo.hidden = 1;
      [cell.myView.imgPhoto stopAnimating];
      cell.myView.imgPhoto.animationImages = nil;
      cell.myView.ary = nil;
      [cell.myView.imgPhoto setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:mediaItem.mediaThumbnailUrl79x80[0]]]]];
        
    }

    [self performSelector:@selector(viewFrame:) withObject:cell afterDelay:0.5];

    return cell;

  } else {
    /**
     * Handle SYNC / NOT_SYNC items...
     */
    GridCell* cell = (GridCell*)
        [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell"
                                                  forIndexPath:indexPath];

    [cell.myView.scroll setZoomScale:1 animated:0];
    if ([mediaItem.mediaType isEqualToString:@"video"]) {
      // Video
      cell.imgVideo.hidden = 0;
      cell.imgVideo.tag = indexPath.item;
      cell.imgVideo.userInteractionEnabled = YES;

      PHImageManager* manager = [PHImageManager defaultManager];
      CGSize size = CGSizeMake(100, 100);
      [manager requestImageForAsset:mediaItem.mediaLocalPHAsset
                         targetSize:size
                        contentMode:PHImageContentModeAspectFit
                            options:nil
                      resultHandler:^(UIImage* result, NSDictionary* info) {
                        [cell.myView.imgPhoto setImage:result];
                      }];
    } else {
      cell.imgVideo.hidden = 1;
      [cell.myView.imgPhoto stopAnimating];
      cell.myView.imgPhoto.animationImages = nil;
      cell.myView.ary = nil;
      PHImageManager* manager = [PHImageManager defaultManager];
      __block UIImage* thumbnail;
      CGSize size = CGSizeMake(100, 100);
      [manager requestImageForAsset:mediaItem.mediaLocalPHAsset
                         targetSize:size
                        contentMode:PHImageContentModeAspectFit
                            options:nil
                      resultHandler:^(UIImage* result, NSDictionary* info) {
                        thumbnail = result;
                      }];

      [cell.myView.imgPhoto setImage:thumbnail];
    }
    [self performSelector:@selector(viewFrame:) withObject:cell afterDelay:0.5];
    return cell;
  }
}

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath*)indexPath {
  return self.collectionView.bounds.size;
}

#pragma mark - Google Cast methods
@end

#import "MemreasLocationViewController.h"
#import "GridCell.h"
#import "GalleryManager.h"
#import "AFNetworking.h"
#import "MemreasDetailViewController.h"


@implementation MemreasLocationViewController{
    NSIndexPath* indexPathSelected;
    NSIndexPath* indexPathForlastRow;
    NSDictionary* selectedDic;
    CLLocation* selectedLocation;
    NSString* selectedAddress;
    MBProgressHUD* progressView;
    NSString* localAddress;
    GMSPlacesClient* gmsPlacesClient;
}

static int indexPathItemSelected;

//
// method implementation
//
- (void)viewDidLoad {
    ALog(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    
    //
    // Init places client
    //
    gmsPlacesClient = [[GMSPlacesClient alloc] init];
    
    // map setup
    self.googlemap.myLocationEnabled = YES;
    self.googlemap.delegate = self;
    
    MediaItem* mediaItem;
    indexPathSelected = [NSIndexPath indexPathWithIndex:0];
    mediaItem = self.arrMemreasEventGallery[indexPathSelected.item];
    mediaItem.isSelectedForLocation = YES;
    
    
    //
    // Initialize Google Map
    //
    if (mediaItem.hasLocation) {
        [self initUIGoogleMap:mediaItem.mediaLocation withZoom:GOOGLEMAPZOOMLOCAL];
    } else {
        [self initUIGoogleMap:nil withZoom:GOOGLEMAPZOOMWORLD];
    }
    
    //
    // Header View
    //
    self.headerView.selectedSegmentIndex = self.selectedSegmentIndex;
    self.headerView.dicPassedEventDetail = self.dicPassedEventDetail;
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) viewDidAppear:(BOOL)animated {
    //remove spinner view is showing...
    self.spinnerView.hidden = 1;
}

#pragma mark - UITableView DataSource
#pragma mark - gallery slider datasource

- (NSInteger)numberOfSectionsInCollectionView:
(UICollectionView*)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.arrMemreasEventGallery.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
                 cellForItemAtIndexPath:(NSIndexPath*)indexPath {
    GridCell* cell = (GridCell*)
    [collectionView dequeueReusableCellWithReuseIdentifier:@"LocationCell"
                                              forIndexPath:indexPath];
    cell.layer.borderWidth = 1;
    indexPathForlastRow = indexPath;
    
    // Fetch mediaItem...
    MediaItem* mediaItem;
    mediaItem = [self.arrMemreasEventGallery objectAtIndex:indexPath.item];
    
    /**
     * Handle Server items
     */
    if (mediaItem.mediaState == SERVER) {
        [cell.imgPhoto setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:mediaItem.mediaThumbnailUrl79x80[0]]]]];
        
    } else {
        /**
         * Handle Sync / NOT_SYNC items
         */
        PHImageManager* manager = [PHImageManager defaultManager];
        __block UIImage* thumbnail;
        float height = cell.size.height;
        float width = cell.size.width;
        CGSize size = CGSizeMake(height, width);
        [manager requestImageForAsset:mediaItem.mediaLocalPHAsset
                           targetSize:size
                          contentMode:PHImageContentModeAspectFit
                              options:nil
                        resultHandler:^(UIImage* result, NSDictionary* info) {
                            thumbnail = result;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [cell.imgPhoto setImage:thumbnail];
                            });
                            
                        }];
        
    }
    // set border color
    [self setBorderColor:cell withMediaItem:mediaItem];
    
    //show checkbox for selected mediaId
    if (indexPathItemSelected == indexPath.item) {
        cell.btnPhoto.hidden = 0;
    } else {
        cell.btnPhoto.hidden = 1;
    }

    // tag cell
    cell.tag = indexPath.item;
    
    return cell;
}

- (void)collectionView:(UICollectionView*)collectionView
didSelectItemAtIndexPath:(NSIndexPath*)indexPath {
    @try {
        
        
        //
        // Set checkmark section
        // - set new check based on selection
        // - reload
        //
        MediaItem* mediaItem;
        indexPathSelected = indexPath;
        indexPathItemSelected = indexPath.item;
        mediaItem = [self.arrMemreasEventGallery objectAtIndex:indexPath.item];
        mediaItem.isSelectedForLocation = YES;
        
        //
        // Show cell as selected
        //
        [self.gridGalleryCollectionView reloadData];
        
        //
        // Map location section...
        // Case 1: Media hasLocation
        // Case 2: location is nil
        //
        if (mediaItem.hasLocation) {
            selectedLocation = mediaItem.mediaLocation;
        } else {
            selectedLocation = nil;
        }
        
        /**
         * Now handle map update...
         */
        [self fetchAndDisplayMap];
        
    } @catch (NSException* exception) {
        ALog(@"didSelectItemAtIndexPath excception::%@", exception);
    }
}

- (void) fetchAndDisplayMap {
    if (selectedLocation != nil) {
        [self startActivity:@"updating map..."];
        NSString* str = [[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/"
                          @"geocode/json?latlng=%f,%f&sensor=true",
                          selectedLocation.coordinate.latitude,
                          selectedLocation.coordinate.longitude]
                         stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        ALog(@"Google Maps URL request::%@", str);
        /*
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager
                                                  manager];
        [manager GET:str parameters:nil success:^(AFHTTPRequestOperation
                                                  *operation, id responseObject) {
            
            [self stopActivity];
            //ALog(@"responseObject::",responseObject);
            //NSDictionary* responseObjectDict = responseObject;
            NSString* formatted_address =[[[responseObject valueForKeyPath:@"results"]
                                           firstObject] valueForKey:@"formatted_address"];
            
            [self.googlemap clear];
            GMSCameraPosition *camera = [GMSCameraPosition
                                         cameraWithLatitude:selectedLocation.coordinate.latitude
                                         longitude:selectedLocation.coordinate.longitude zoom:GOOGLEMAPZOOMLOCAL];
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = camera.target;
            marker.snippet = formatted_address;
            //marker.icon = cell.imgPhoto.image;
            marker.map = self.googlemap;
            [self.googlemap setCamera:camera];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ALog(@"%@",error);
            [self stopActivity];
            
        }];
        */
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager GET:str parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            ALog(@"JSON: %@", responseObject);
            [self stopActivity];
            //ALog(@"responseObject::",responseObject);
            //NSDictionary* responseObjectDict = responseObject;
            NSString* formatted_address =[[[responseObject valueForKeyPath:@"results"]
                                           firstObject] valueForKey:@"formatted_address"];
            
            [self.googlemap clear];
            GMSCameraPosition *camera = [GMSCameraPosition
                                         cameraWithLatitude:selectedLocation.coordinate.latitude
                                         longitude:selectedLocation.coordinate.longitude zoom:GOOGLEMAPZOOMLOCAL];
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = camera.target;
            marker.snippet = formatted_address;
            //marker.icon = cell.imgPhoto.image;
            marker.map = self.googlemap;
            [self.googlemap setCamera:camera];
            
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            ALog(@"Error: %@", error);
            [self stopActivity];
        }];
        
        [self stopActivity];
    } else {
        [Helper showMessageFade:self.view withMessage:@"no location associated with media" andWithHideAfterDelay:3];
        
        CLLocation* location = [[CLLocation alloc] initWithLatitude:0 longitude:0];
        [self initUIGoogleMap:location withZoom:GOOGLEMAPZOOMWORLD];
    }
   
}

#pragma mark - Show loading dialog for Google Map

- (void)startActivity:(NSString*)message {
    progressView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:progressView];
    if (message) {
        progressView.detailsLabelText = message;
    }
    
    [progressView show:YES];
}

- (void)stopActivity {
    //[self.gridGalleryCollectionView reloadData];
    
    [progressView removeFromSuperview];
    [progressView hide:YES];
    progressView = nil;
}

#pragma mark - Load and Show Google Map

- (void)initUIGoogleMap:(CLLocation*)location withZoom:(float)mapzoom {
    @try {
        double latitude, longitude;
        selectedLocation = nil;
        if (location == nil) {
            latitude = self.googlemap.myLocation.coordinate.latitude;
            longitude = self.googlemap.myLocation.coordinate.longitude;
            selectedLocation = self.googlemap.myLocation;
        } else {
            latitude = location.coordinate.latitude;
            longitude = location.coordinate.longitude;
            selectedLocation = location;
        }
        
        // Update search bar with formatted address...
        /**
         * TODO - move url into constants...
         */
        [self startActivity:@"updating map..."];
        if (selectedLocation == nil) {
            NSString* str =
            [[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/"
              @"geocode/json?latlng=%f,%f&sensor=true",
              latitude, longitude]
             stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            /**
             * TODO change to new web service call...
             */
            /*
            AFHTTPRequestOperationManager* manager =
            [AFHTTPRequestOperationManager manager];
            [manager GET:str
              parameters:nil
                 success:^(AFHTTPRequestOperation* operation, id responseObject) {
                     [self stopActivity];
                     NSString* locationNSString =
                     [[[responseObject valueForKeyPath:@"results"] firstObject]
                      valueForKey:@"formatted_address"];
                     localAddress = locationNSString;
                     
                 }
                 failure:^(AFHTTPRequestOperation* operation, NSError* error) {
                     ALog(@"%@", error);
                     [self stopActivity];
                 }];
            */
            
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            [manager GET:str parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                ALog(@"JSON: %@", responseObject);
                [self stopActivity];
                NSString* locationNSString =
                [[[responseObject valueForKeyPath:@"results"] firstObject]
                 valueForKey:@"formatted_address"];
                localAddress = locationNSString;
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                ALog(@"Error: %@", error);
                [self stopActivity];
            }];
            
        } // end if search text == nil
        [self.googlemap clear];
        GMSCameraPosition* camera = [GMSCameraPosition cameraWithLatitude:latitude
                                                                longitude:longitude
                                                                     zoom:mapzoom];
        GMSMarker* marker = [[GMSMarker alloc] init];
        marker.position = camera.target;
        marker.snippet = localAddress;
        marker.map = self.googlemap;
        [self.googlemap setCamera:camera];
        [self stopActivity];
        
    }
    
    @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

- (void)setBorderColor:(GridCell*)cell withMediaItem:(MediaItem*)mediaItem {
    @try {
        if (mediaItem.mediaState == SYNC) {
            cell.layer.borderColor = [UIColor greenColor].CGColor;
        } else if (mediaItem.mediaState == NOT_SYNC) {
            cell.layer.borderColor = [UIColor redColor].CGColor;
        } else if (mediaItem.mediaState == SERVER) {
            cell.layer.borderColor = [UIColor yellowColor].CGColor;
        } else if (mediaItem.mediaState == IN_TRANSIT) {
            cell.layer.borderColor = [UIColor orangeColor].CGColor;
        }
        if (mediaItem.hasLocation) {
            cell.layer.borderColor = [UIColor blueColor].CGColor;
        }
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

- (void) fetchLocationForImage:(PHAsset*) asset {
    [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                      options:nil
                                                resultHandler:
     ^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
         CIImage* ciImage = [CIImage imageWithData:imageData];
         ALog(@"Metadata : %@", ciImage.properties);
     }];
}

- (CLLocation*)getLocation:(MediaItem*)mediaItem {
    /**
     * Handle Server items
     */
    CLLocation* location;
    if (mediaItem.mediaState == SERVER) {
        NSDictionary* locationDic = mediaItem.metadata;
        selectedDic = locationDic;
        NSDictionary* jsonResponse = mediaItem.metadata;
        ALog(@"%@",jsonResponse);
        
        if (![[jsonResponse valueForKeyPath:@"S3_files.location"]
              isKindOfClass:[NSString class]] &&
            ![[jsonResponse valueForKeyPath:@"S3_files.location"]
              isKindOfClass:[NSNull class]]) {
                localAddress =
                [jsonResponse valueForKeyPath:@"S3_files.location.address"];
                location = [[CLLocation alloc]
                            initWithLatitude:
                            [[jsonResponse
                              valueForKeyPath:@"S3_files.location.latitude"] floatValue]
                            longitude:[[jsonResponse
                                        valueForKeyPath:
                                        @"S3_files.location.longitude"] floatValue]];
            }
    } else {
        location = mediaItem.mediaLocation;
    }
    
    return location;
}

#pragma mark - IBAction close

- (IBAction)cancelPressed:(id)sender {
    MemreasDetailViewController *memreasDetailVC =(MemreasDetailViewController*) [self parentViewController];
    [memreasDetailVC loadLocation:NO];
}

#pragma mark - IBAction previous / next


- (NSArray*) fetchVisibleIndexPaths {
    NSMutableArray* indexPathsArray = [[NSMutableArray alloc] init];
    //
    // Fetch Index Paths viewable
    //
    for (UICollectionViewCell *cell in [self.gridGalleryCollectionView visibleCells]) {
        NSIndexPath *indexPath = [self.gridGalleryCollectionView indexPathForCell:cell];
        [indexPathsArray addObject:indexPath];
    }
    return indexPathsArray;
    
}

- (IBAction)nextPressed:(id)sender {
    @try {
        NSArray* visibleIndexPaths = [self fetchVisibleIndexPaths];
        NSIndexPath* startIndexPath = [visibleIndexPaths firstObject];
        NSUInteger count = visibleIndexPaths.count;
        NSUInteger nextStartIndexPath = startIndexPath.item + count;
        
        [self.gridGalleryCollectionView
         scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:nextStartIndexPath inSection:0]
         atScrollPosition:UICollectionViewScrollPositionRight
         animated:1];
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}
- (IBAction)previousPressed:(id)sender {
    @try {
        NSArray* visibleIndexPaths = [self fetchVisibleIndexPaths];
        NSIndexPath* startIndexPath = [visibleIndexPaths firstObject];
        NSUInteger count = visibleIndexPaths.count;
        NSUInteger nextStartIndexPath = startIndexPath.item - count;
        if ((startIndexPath.item - count) <= 0) {
            nextStartIndexPath = 0;
        } else {
            nextStartIndexPath = startIndexPath.item - count;
        }
        [self.gridGalleryCollectionView
         scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:nextStartIndexPath inSection:0]
         atScrollPosition:UICollectionViewScrollPositionLeft
         animated:1];
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

@end

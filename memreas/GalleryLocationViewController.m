#import "GalleryLocationViewController.h"
#import "GridCell.h"
#import "GalleryManager.h"
#import "AFNetworking.h"
#import "QueueController.h"

@implementation GalleryLocationViewController{
    NSIndexPath* indexPathSelected;
    NSIndexPath* indexPathForlastRow;
    GalleryManager* sharedGalleryInstance;
    NSDictionary* selectedDic;
    CLLocation* selectedLocation;
    NSString* selectedAddress;
    MBProgressHUD* progressView;
    NSString* localAddress;
    NSMutableArray* typeAheadResultsArray;
    NSMutableDictionary* typeAheadResultsDict;
    GMSPlacesClient* gmsPlacesClient;
}
static int indexPathItemSelected;

//
// method implementation
//
- (void)viewDidLoad {
    ALog(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    
    sharedGalleryInstance = [GalleryManager sharedGalleryInstance];

    // Fetch Location async for Gallery...
    //[self performSelectorInBackground:@selector(fetchLocatonForGalleryAsync)
    //                       withObject:nil];
    
    //
    // Init structures
    //
    typeAheadResultsDict = [[NSMutableDictionary alloc] init];
    typeAheadResultsArray = [[NSMutableArray alloc] init];
    
    //
    // Init places client
    //
    gmsPlacesClient = [GMSPlacesClient sharedClient];
    
    // map setup
    self.googlemap.myLocationEnabled = YES;
    self.googlemap.delegate = self;
    
    // init map
    MediaItem* mediaItem;
    @synchronized(sharedGalleryInstance) {
        mediaItem = sharedGalleryInstance.imageGalleryNSMutableArray[indexPathItemSelected];
    }
    
    if (mediaItem.hasLocation) {
        selectedLocation = mediaItem.mediaLocation;
        [self initUIGoogleMap:selectedLocation withZoom:GOOGLEMAPZOOMLOCAL];
    } else {
        selectedLocation = nil;
        [self initUIGoogleMap:selectedLocation withZoom:GOOGLEMAPZOOMWORLD];
    }

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) viewDidAppear:(BOOL)animated {
    //remove spinner view is showing...
    self.spinnerView.hidden = 1;
    
}

#pragma mark-------- search bar delegate ---------

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self fetchMapPredictionsfromSearchText:searchBar.text withSeachButtonTouched:YES];
    [self.searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.text = @"";
    typeAheadResultsDict = nil;
    [self.searchBar resignFirstResponder];
    self.mapTableView.hidden = 1;
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 5) {
        [self fetchMapPredictionsfromSearchText:searchText withSeachButtonTouched:NO];
    }
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

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)section {
    ALog(@"%s", __PRETTY_FUNCTION__);
    return typeAheadResultsArray.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell* cell =
    [tableView dequeueReusableCellWithIdentifier:@"SearchCell"
                                    forIndexPath:indexPath];
    GMSAutocompletePrediction* result = typeAheadResultsArray[indexPath.row];
    cell.textLabel.text = result.attributedFullText.string;
    
    return cell;
}

- (void)tableView:(UITableView*)tableView
didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    GMSAutocompletePrediction* result = typeAheadResultsArray[indexPath.row];
    self.mapTableView.hidden = 1;
    self.searchBar.text = result.attributedFullText.string;
    selectedAddress = result.attributedFullText.string;
    [self.searchBar resignFirstResponder];
    [self updateMapByPlaceID:result.placeID];
}

#pragma mark - Place API methods

- (void) updateMapByPlaceID:(NSString*) placeId {
    [gmsPlacesClient lookUpPlaceID:placeId callback:^(GMSPlace * _Nullable result, NSError * _Nullable error) {
        if (error != nil) {
            ALog(@"lookUpPlaceID:placeId callback::error::%@",error);
        } else {
            ALog(@"lookUpPlaceID:placeId callback::result::%@",result);
            CLLocation* location = [[CLLocation alloc] initWithLatitude:result.coordinate.latitude longitude:result.coordinate.longitude];
            selectedLocation = location;
            [self initUIGoogleMap:location withZoom:GOOGLEMAPZOOMLOCAL];
        }
    }];
    [self stopActivity];
}

- (void) fetchMapPredictionsfromSearchText:(NSString*) searchText withSeachButtonTouched:(BOOL) searchButtonTouched {
    
    [gmsPlacesClient autocompleteQuery:searchText
                                bounds:nil
                                filter:nil
                              callback:^(NSArray *results, NSError *error) {
                                  if (error != nil) {
                                      ALog(@"Autocomplete error %@", [error localizedDescription]);
                                      self.mapTableView.hidden = 1;
                                      return;
                                  }
                                  [typeAheadResultsArray removeAllObjects];
                                  [typeAheadResultsDict removeAllObjects];
                                  
                                  for (GMSAutocompletePrediction* result in results) {
                                      ALog(@"Result attributedFullText:::%@ with placeID %@", result.attributedFullText.string, result.placeID);
                                      //[typeAheadResultsArray addObject:result.attributedFullText.string];
                                      [typeAheadResultsArray addObject:result];
                                  }
                                  if ((typeAheadResultsArray.count > 0) && (!searchButtonTouched)) {
                                      self.mapTableView.hidden = 0;
                                      __weak typeof(self) weakSelf = self;
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [weakSelf.mapTableView reloadData];
                                      });
                                  } else if ((typeAheadResultsArray.count > 0) && (searchButtonTouched)) {
                                      GMSAutocompletePrediction* result = results[0];
                                      self.mapTableView.hidden = 1;
                                      selectedAddress = result.attributedFullText.string;
                                      [self updateMapByPlaceID:result.placeID];
                                  }
                              }];
}

#pragma mark - gallery slider datasource

- (NSInteger)numberOfSectionsInCollectionView:
(UICollectionView*)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return sharedGalleryInstance.imageGalleryNSMutableArray.count;
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
    @synchronized(sharedGalleryInstance) {
        mediaItem = sharedGalleryInstance.imageGalleryNSMutableArray[indexPath.item];
    }
    
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
        @synchronized(sharedGalleryInstance) {
            mediaItem = sharedGalleryInstance.imageGalleryNSMutableArray[indexPathSelected.item];
        }
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
        if (selectedLocation != nil) {
            [self startActivity:@"updating map..."];
            NSString* str = [[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/"
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
                ALog(@"responseObject::",responseObject);
                NSDictionary* responseObjectDict = responseObject;
                NSString* formatted_address =[[[responseObject valueForKeyPath:@"results"]
                                               firstObject] valueForKey:@"formatted_address"];
                self.searchBar.text = formatted_address;
                
                [self.googlemap clear];
                GMSCameraPosition *camera = [GMSCameraPosition
                                             cameraWithLatitude:selectedLocation.coordinate.latitude
                                             longitude:selectedLocation.coordinate.longitude zoom:GOOGLEMAPZOOMLOCAL];
                GMSMarker *marker = [[GMSMarker alloc] init];
                marker.position = camera.target;
                marker.snippet = self.searchBar.text;
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
                ALog(@"responseObject::%@",responseObject);
                NSDictionary* responseObjectDict = responseObject;
                NSString* formatted_address =[[[responseObject valueForKeyPath:@"results"]
                                               firstObject] valueForKey:@"formatted_address"];
                self.searchBar.text = formatted_address;
                
                [self.googlemap clear];
                GMSCameraPosition *camera = [GMSCameraPosition
                                             cameraWithLatitude:selectedLocation.coordinate.latitude
                                             longitude:selectedLocation.coordinate.longitude zoom:GOOGLEMAPZOOMLOCAL];
                GMSMarker *marker = [[GMSMarker alloc] init];
                marker.position = camera.target;
                marker.snippet = self.searchBar.text;
                //marker.icon = cell.imgPhoto.image;
                marker.map = self.googlemap;
                [self.googlemap setCamera:camera];
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                ALog(@"Error: %@", error);
                [self stopActivity];
            }];
            [self stopActivity];
        } else {
            UIAlertController* alert = [UIAlertController
                                        alertControllerWithTitle:@"location not found"
                                        message:@"there is no location associated with this media, "
                                        @"you can add a new location by search and tap on "
                                        @"ok"
                                        preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"close" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            
            CLLocation* location = [[CLLocation alloc] initWithLatitude:0 longitude:0];
            [self initUIGoogleMap:location withZoom:GOOGLEMAPZOOMWORLD];
            self.searchBar.text = @"";
        }
        //[collectionView reloadData];
    } @catch (NSException* exception) {
        ALog(@"didSelectItemAtIndexPath excception::%@", exception);
        //[collectionView reloadData];
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
    [self.gridGalleryCollectionView reloadData];
    
    [progressView removeFromSuperview];
    [progressView hide:YES];
    progressView = nil;
}

#pragma mark - Load and Show Google Map

- (void)initUIGoogleMap:(CLLocation*)location withZoom:(float)mapzoom {
    @try {
        double latitude, longitude;
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
        if (self.searchBar.text == nil) {
            NSString* str =
            [[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/"
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
                     self.searchBar.text = locationNSString;
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
                self.searchBar.text = locationNSString;
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
        marker.snippet = self.searchBar.text;
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



- (void)fetchLocatonForGalleryAsync {
    @try {
        if (!sharedGalleryInstance.hasLocationsLoaded) {
            for (int i = 0; i < sharedGalleryInstance.imageGalleryNSMutableArray.count; i++) {
                MediaItem* mediaItem = sharedGalleryInstance.imageGalleryNSMutableArray[i];
                mediaItem.mediaLocation = [self getLocation:mediaItem];
                
                // debugging
                if (mediaItem.mediaLocation != nil) {
                    double lat = mediaItem.mediaLocation.coordinate.latitude;
                    double lng = mediaItem.mediaLocation.coordinate.longitude;
                    ALog(@"name: %@, Latitude:%f,  Longitude:%f",
                          mediaItem.mediaNamePrefix, lat, lng);
                    mediaItem.hasLocation = true;
                } else {
                    mediaItem.hasLocation = false;
                    ALog(@"name: %@, Location is nil", mediaItem.mediaNamePrefix);
                }
            }
            sharedGalleryInstance.hasLocationsLoaded = true;
        }
        // Set flag to note locations loaded...
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
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
                self.searchBar.text =
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
        /**
         * Handle SYNC and NOT_SYNC items
         */
        location = mediaItem.mediaLocation;
    }
    
    return location;
}

- (IBAction)okPressed:(id)sender {
    @try {
        ALog(@"ok pressed\n");
        MediaItem* mediaItem;
        if (indexPathSelected != nil) {
            @synchronized(sharedGalleryInstance) {
                mediaItem = sharedGalleryInstance.imageGalleryNSMutableArray[indexPathSelected.item];
            }
            if ((mediaItem.mediaLocation == nil) && (mediaItem.mediaState == NOT_SYNC)) {
                //
                // Upload media and set location on server side
                //
                ALog(@"adding media to queue with location for sync\n");
                mediaItem.mediaLocation = selectedLocation;
                mediaItem.hasLocation = YES;
                [[QueueController sharedInstance] addToPendingTransferArray:mediaItem withTransferType:UPLOAD];
                
                //
                // Show alert that media sync and location worked
                //
                UIAlertController* alert = [UIAlertController
                                            alertControllerWithTitle:@"media location"
                                            message:@"media sync'd and location set"
                                            preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"close" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {}];
                
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                
                //
                // Set mediaState to SYNC to avoid duplicate uploads
                //
                mediaItem.mediaState = SYNC;
            } else if ((mediaItem.mediaLocation == nil) && ((mediaItem.mediaState == SERVER) || (mediaItem.mediaState == SYNC))) {
                //
                // Set media specific observer here
                //
                self.observerNameUpdateMediaMWS = [NSString stringWithFormat:@"%@_%@", UPDATEMEDIA_RESULT_NOTIFICATION,
                 mediaItem.mediaId];
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(updateMediaMWSHandlerComplete:)
                                                             name:self.observerNameUpdateMediaMWS
                                                           object:nil];
                

                
                //
                // Set location on server side
                //
                ALog(@"calling updatemedia with location for server or sync items\n");
                mediaItem.mediaLocation = selectedLocation;
                mediaItem.hasLocation = YES;
                NSUserDefaults* defaultUser = [NSUserDefaults standardUserDefaults];
                NSString* sid = [defaultUser stringForKey:@"SID"];
                
                if ([Util checkInternetConnection]) {
                    /**
                     * Use XMLGenerator...
                     */
                    
                    NSString* requestXML = [XMLGenerator generateUpdateMediaXML:sid
                                                                       media_id:mediaItem.mediaId
                                                                        address:selectedAddress
                                                                       latitude:selectedLocation.coordinate.latitude
                                                                      longitude:selectedLocation.coordinate.longitude];
                    ALog(@"Request:- %@", requestXML);
                    
                    /**
                     * Use WebServices Request Generator
                     */
                    
                    NSMutableURLRequest* request =
                    [WebServices generateWebServiceRequest:requestXML
                                                    action:UPDATEMEDIA];
                    //ALog(@"NSMutableRequest request ----> %@", request);
                    
                    /**
                     * Send Request and Parse Response...
                     *  Note: wsHandler calls objectParsed_ListAllMedia
                     */
                    MWebServiceHandler* wsHandler = [[MWebServiceHandler alloc] init];
                    [wsHandler fetchServerResponse:request
                                            action:UPDATEMEDIA
                                               key:UPDATEMEDIA_RESULT_NOTIFICATION];
                }
            }
        } else {
            UIAlertController* alert = [UIAlertController
                                        alertControllerWithTitle:@"select media"
                                        message:@"select an image to view location"
                                        preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"close" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

/**
 * Web Service Response via notification here...
 */
- (void)updateMediaMWSHandlerComplete:(NSNotification*)notification {
    @try {
        NSDictionary* resultTags = [notification userInfo];
        //
        // Handle result here...
        //
        NSString* status = @"";
        status = [resultTags objectForKey:@"status"];
        if ([[status lowercaseString] isEqualToString:@"success"]) {
            //
            // Show alert that media sync and location worked
            //
            UIAlertController* alert = [UIAlertController
                                        alertControllerWithTitle:@"media location"
                                        message:@"media location set"
                                        preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"close" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            //
            // Show alert that media sync and location worked
            //
            UIAlertController* alert = [UIAlertController
                                        alertControllerWithTitle:@"media location"
                                        message:@"unable to update media location"
                                        preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"close" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

- (IBAction)cancelPressed:(id)sender {
    [self releaseOnBack];
}
- (void)releaseOnBack {
    @try {
        //
        //  Show spinner unitl view is shown
        //
        self.spinnerView.hidden = 0;
        [self dismissViewControllerAnimated:YES completion:nil];
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
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

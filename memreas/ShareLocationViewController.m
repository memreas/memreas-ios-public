#import "ShareLocationViewController.h"
#import "GridCell.h"
#import "ShareCreator.h"
#import "AFNetworking.h"
#import "GalleryManager.h"
#import "MBProgressHUD.h"

@implementation ShareLocationViewController{
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
    //[super viewDidLoad];
    
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
            [[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/"
              @"geocode/json?latlng=%f,%f&sensor=true",
              latitude, longitude]
             stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
            
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

- (IBAction)okPressed:(id)sender {
    @try {
        ALog(@"ok pressed\n");
        MediaItem* mediaItem;
        if (selectedLocation != nil) {
            //
            // return address here...
            //
            [self.delegate okPassBackAddress:selectedAddress withLocation:selectedLocation];
            [self releaseOnBack];
        } else {
            [Helper showMessageFade:self.view withMessage:@"please enter a location" andWithHideAfterDelay:3];
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





@end

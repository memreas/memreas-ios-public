#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import <UIKit/UIKit.h>
#import "MasterViewController.h"
@import GooglePlaces;
@class GridCell;
@class GalleryManager;
@class AFNetworking;
@class QueueController;


@interface GalleryLocationViewController : MasterViewController<
    GMSMapViewDelegate,
    UISearchBarDelegate,
    CLLocationManagerDelegate>{
}

//
// properties
//
@property(weak, nonatomic) IBOutlet GMSMapView* googlemap;
@property (nonatomic) IBOutlet UISearchBar* searchBar;
@property (nonatomic) IBOutlet UITableView* mapTableView;
@property (nonatomic) IBOutlet UIButton* btnSwipeLeft;
@property (nonatomic) IBOutlet UICollectionView* gridGalleryCollectionView;
@property (nonatomic) IBOutlet UIButton* btnSwipeRight;
@property(nonatomic) IBOutlet UIView* spinnerView;
@property(nonatomic) IBOutlet UIImageView* poweredByGoogleImageView;
@property(nonatomic) NSString* observerNameUpdateMediaMWS;


//
// methods
//

#pragma mark cancelPress
- (IBAction)cancelPressed:(id)sender;
@end

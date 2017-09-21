#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
@import GooglePlaces;
#import "MasterViewController.h"
#import "HeaderView.h"
@class GridCell;
@class GalleryManager;
@class AFNetworking;

@interface MemreasLocationViewController : MasterViewController< GMSMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate>

//
// properties
//
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@property (nonatomic,strong) NSDictionary *dicPassedEventDetail;
@property (nonatomic,assign) NSInteger selectedSegmentIndex;
@property(weak, nonatomic) IBOutlet GMSMapView* googlemap;
@property (nonatomic) IBOutlet UIButton* btnSwipeLeft;
@property (nonatomic) IBOutlet UICollectionView* gridGalleryCollectionView;
@property (nonatomic) IBOutlet UIButton* btnSwipeRight;
@property(nonatomic) IBOutlet UIView* spinnerView;
@property(nonatomic) IBOutlet UIImageView* poweredByGoogleImageView;
@property(nonatomic) NSArray* arrMemreasEventGallery;


//
// methods
//

#pragma mark cancelPress
- (IBAction)cancelPressed:(id)sender;
@end

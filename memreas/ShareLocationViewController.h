@import Foundation;
@import GoogleMaps;
@import UIKit;
@import GooglePlaces;
#import "MasterViewController.h"
@class GridCell;
@class ShareCreator;
@class AFNetworking;
@class GalleryManager;
@class MBProgressHUD;


@protocol ShareLocationControllerDelegate <NSObject>
@required
- (void
   ) okPassBackAddress:(NSString*) address withLocation:(CLLocation*) location;
@end


@interface ShareLocationViewController : MasterViewController
<
    GMSMapViewDelegate,
    UISearchBarDelegate,
    CLLocationManagerDelegate
>
{
}

//
// properties
//
@property(weak, nonatomic) IBOutlet GMSMapView* googlemap;
@property (nonatomic) IBOutlet UISearchBar* searchBar;
@property (nonatomic) IBOutlet UITableView* mapTableView;
@property (nonatomic) IBOutlet UIView* spinnerView;
@property (nonatomic) IBOutlet UIImageView* poweredByGoogleImageView;
// Delegate
@property(nonatomic, weak) NSObject<ShareLocationControllerDelegate>* delegate;

//
// methods
//

#pragma mark cancelPress
- (IBAction)cancelPressed:(id)sender;
@end

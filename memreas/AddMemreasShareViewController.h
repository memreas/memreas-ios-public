#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MapKit/MapKit.h>
#import "MyConstant.h"
#import "Util.h"
#import "GridCell.h"
#import "GalleryManager.h"
#import "AddMediaViewController.h"
#import "AddMemreasShareMediaViewController.h"
#import "AddMemreasShareFriendsViewController.h"
#import "AddMemreasCollectionCell.h"
#import "FriendsCell.h"
#import "MemreasDetailCell.h"
#import "AudioRecording.h"
#import "Helper.h"
#import "MapLocationPicker.h"
#import "ShareLocationViewController.h"
#import "ShareCreator.h"
#import "JSONUtil.h"
#import "MIOSDeviceDetails.h"
@import GoogleMobileAds;
@import GooglePlaces;

@interface AddMemreasShareViewController : MasterViewController <UITextFieldDelegate, GADBannerViewDelegate, ShareLocationControllerDelegate> {
}

//
// properties
//
@property (weak, nonatomic) IBOutlet UIScrollView* detailsScrollView;
@property (weak, nonatomic) IBOutlet UIStackView* detailsStackView;
@property (weak, nonatomic) IBOutlet UIButton* btnMemreasDetails;
@property (weak, nonatomic) IBOutlet UIButton* btnMedia;
@property (weak, nonatomic) IBOutlet UIButton* btnFriends;
@property (weak, nonatomic) IBOutlet UIView *viewDatepicker;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtDate;
@property (weak, nonatomic) IBOutlet UITextField *txtLocation;
@property (nonatomic) NSDictionary* addressDict;
@property (nonatomic) UITextField *txtLocationsCity;
@property (weak, nonatomic) IBOutlet UIButton *btnViewable;
@property (weak, nonatomic) IBOutlet UITextField *txtFrom;
@property (weak, nonatomic) IBOutlet UITextField *txtTo;
@property (weak, nonatomic) IBOutlet UITextField *txtGhost;
@property (weak, nonatomic) IBOutlet UIButton *btnFriendsCanPost;
@property (weak, nonatomic) IBOutlet UIButton *btnFriendsCanAdd;
@property (weak, nonatomic) IBOutlet UIButton *btnPublic;
@property (weak, nonatomic) IBOutlet UIButton *btnGhost;
@property (weak, nonatomic) IBOutlet UIDatePicker *pckrDate;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;
@property (nonatomic) MapLocationPicker*mapPicker;
@property (nonatomic) CLLocation *selectedLocation;
@property (nonatomic) BOOL isDone;
@property (weak, nonatomic) IBOutlet UIImageView *imgDate;
@property (weak, nonatomic) IBOutlet UIImageView *imgFromDate;
@property (weak, nonatomic) IBOutlet UIImageView *imgToDate;
@property (weak, nonatomic) IBOutlet UIImageView *imgGhostDate;

@property (weak, nonatomic) IBOutlet UIButton* btnNext;
@property (weak, nonatomic) IBOutlet UIButton* btnDone;
@property (weak, nonatomic) IBOutlet UIButton* btnCancel;


//
// methods
//
-(IBAction) handleDateField:(id) sender;
-(IBAction) handleFromDateField:(id) sender;
-(IBAction) handleToDateField:(id) sender;
-(IBAction) handleGhostDateField:(id) sender;
-(IBAction) handleLocationField:(id) sender;


- (IBAction)handleMediaSegue:(id)sender;
- (IBAction)handleDoneAction:(id)sender;
- (IBAction)handleFriendsSegue:(id)sender;


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;


@end

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@import AVKit;
@import AVFoundation;
@import CoreText;
@import ImageIO;
@import MobileCoreServices;
@class CheckSumUtil;
@class MyConstant;
@class CopyrightManager;
#import "MediaItem.h"
#import "AppDelegate.h"
@class JSONUtil;

@interface MCameraViewController : UIViewController <AVCaptureFileOutputRecordingDelegate,
                                                     CLLocationManagerDelegate> {
  AppDelegate *appDelegate;
  CLLocationManager *locationManager;
  CLLocation *currentLocation;
}

//
// properties
//
@property(nonatomic) IBOutlet UILabel* copyright_preview;
@property(nonatomic) IBOutlet UIView *bottomBarView;
@property(nonatomic) IBOutlet UIView *spinnerView;
@property(nonatomic) IBOutlet UILabel *spinnerLabel;
@property(nonatomic) IBOutlet UIButton *btnBack;
@property(nonatomic) IBOutlet UISegmentedControl *segPhotoVideo;
@property(nonatomic) IBOutlet UIButton *btnFrontBackCameraSelection;
@property(nonatomic) IBOutlet UILabel *lblTimer;
@property(nonatomic) IBOutlet UIImageView *thumbnail;
@property(nonatomic) IBOutlet UIView *cameraView;
@property(nonatomic) IBOutlet UIButton *btnShoot;
@property AVCaptureSession *avCaptureSession;
@property AVCaptureDevice *avCaptureDeviceFront;
@property AVCaptureDevice *avCaptureDeviceBack;
@property AVCaptureDevice *avCaptureDeviceAudio;
@property AVCaptureConnection *avCaptureConnection;
@property AVCaptureVideoPreviewLayer *avCaptureVideoPreviewLayer;
@property CATextLayer *copyrightLayer;
@property(nonatomic) MediaItem *mediaItem;
@property(nonatomic) NSData* imageWithMD5SHA1InscribedNSData;
@property(nonatomic) CIImage* imageWithMD5SHA1InscribedCIImage;
@property(nonatomic) UIImage* imageWithMD5SHA1InscribedUIImage;
@property (nonatomic) UIDeviceOrientation currentDeviceOrientation;


- (IBAction)backPressed:(id)sender;
@end

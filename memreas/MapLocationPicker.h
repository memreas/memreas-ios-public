#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "AFNetworking.h"


@class MapLocationPicker;
@protocol MapPickLocation <NSObject>

-(void)mapPicker:(MapLocationPicker*)mapPicker didFinishWithPickLocation:(NSString*)address   andLocation:(CLLocation*)location;

@end

@interface MapLocationPicker : UIViewController

@property (nonatomic,assign)id <MapPickLocation>delegate;
@property(nonatomic,strong)NSString*searchText;
@property (nonatomic,strong) CLLocation *selectedLocation;
@end

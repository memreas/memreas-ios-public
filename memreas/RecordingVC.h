#import <UIKit/UIKit.h>
@class MemreasDetailViewController;
@class AddMediaFromPhotoDetai;
@class MyConstant;
@class XMLGenerator;
@class MediaIdManager;
@class AudioRecording;
@class GalleryManager;
@class Helper;

@interface RecordingVC : UIViewController


@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) NSString*strTime ;
@property (nonatomic)int time;
-(void)stopMeter;
-(void)startMeter;

@property (nonatomic) IBOutlet UILabel *lblTimer;
@property (weak, nonatomic) IBOutlet UILabel *lblSpeakNow;
@property (nonatomic) IBOutlet UISlider *slider;
@property (nonatomic) IBOutlet UIButton *btnPlay;
@property (nonatomic) NSDictionary*dicPassedEventDetail;
@property (nonatomic) IBOutlet UITextField* tfComment;
@end

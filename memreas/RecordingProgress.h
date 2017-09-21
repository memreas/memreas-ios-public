#import <UIKit/UIKit.h>

@interface RecordingProgress : UIView

@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) IBOutlet UILabel *lbl ;
@property (nonatomic,strong) NSString*strTime ;
@property (nonatomic)int time;
-(void)stopMeter;
-(void)startMeter;
@end

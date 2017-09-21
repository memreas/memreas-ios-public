#import "RecordingProgress.h"

@implementation RecordingProgress

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.backgroundColor = [UIColor blackColor];
}

- (NSString *)timeFormatted:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
//    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}
-(void)setUP:(NSTimer*)timeer{
    self.time++;
    self.lbl.text = [self timeFormatted:self.time];
    self.strTime = [self timeFormatted:self.time];
    
}
-(void)stopMeter{
    [self removeFromSuperview];
    self.lbl = nil;
    [self.timer invalidate];
    self.timer = nil;
    self.time = 0;


}

-(void)startMeter{
//  _lbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 279, 50)];
//    [self addSubview:self.lbl];
    self.lbl.textColor = [UIColor redColor];
    self.lbl.textAlignment = NSTextAlignmentCenter;
    self.time = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setUP:) userInfo:nil repeats:YES];
}

@end

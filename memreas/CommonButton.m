#import "CommonButton.h"
#import "MyConstant.h"

@implementation CommonButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib{

    if (IS_IPAD) {
        [self setBackgroundImage:[UIImage imageNamed:@"BlackbuttoniPad"] forState:UIControlStateNormal];

    }else{
        
        [self setBackgroundImage:[UIImage imageNamed:@"BlackButtoniPhone"] forState:UIControlStateNormal];

    }

}

@end

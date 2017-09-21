#import "CommonButtonOpen.h"
#import "MyConstant.h"

@implementation CommonButtonOpen

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib{
    
    if (IS_IPAD) {
        
        [self setBackgroundImage:[UIImage imageNamed:@"BlackButtoniPadOpen"] forState:UIControlStateNormal];

    }else{
        
        [self setBackgroundImage:[UIImage imageNamed:@"BlackButtoniPhoneopen"] forState:UIControlStateNormal];

    }
    
}


@end

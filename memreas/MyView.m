#import "MyView.h"

@implementation MyView

@synthesize imageURL=_imageURL;
@synthesize eventID;
@synthesize eventName;
@synthesize profileImageURL;
@synthesize createName;
@synthesize friend_can_post;
@synthesize friend_can_share;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.viewBack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.viewBack setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.viewBack];
        self.imgPhoto = [[UIImageView alloc] init];
        self.imgPhoto.frame = CGRectMake(1,1,frame.size.width-2,frame.size.height-2);
        self.imgPhoto.contentMode = UIViewContentModeScaleAspectFit;
        self.imgPhoto.backgroundColor =[UIColor blackColor];
        [self addSubview:self.imgPhoto];
        self.btnPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnPhoto.frame = self.imgPhoto.frame;
        [self addSubview:self.btnPhoto];
        self.backgroundColor = [UIColor clearColor];
        self.strUserImages = [NSMutableArray array];
        self.scroll.maximumZoomScale =10.0;
    }
    return self;
}




#pragma mark
#pragma mark - JMImageCache1Delegate Methods

//int animationDuration =3;

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imgPhoto;
}

-(void)startAni{
    [self.imgPhoto stopAnimating];
    self.imgPhoto.animationImages= self.ary;
    self.imgPhoto.animationDuration=self.ary.count+1;
    [self.imgPhoto startAnimating];

}
@end

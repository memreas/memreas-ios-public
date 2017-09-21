#import "XCollectionCell.h"
#import "MyConstant.h"
#import "UIImageView+AFNetworking.h"
#import "NSString+SrtingUrlValidation.h"
#import "NSDictionary+valueAdd.h"

@implementation PlayerVideoBtn


@end

@implementation XCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)loadImageWithURLString:(NSDictionary *)dic andImageKey:(NSString *)key{
    
    @try {
        self.playButton.hidden=![[[dic valueForKeyPath:@"event_media_type.text"] uppercaseString] isEqualToString:@"VIDEO"];
        [self.image setImageWithURL:[NSURL URLWithString:[[[[dic valueForKey:key] valueForKey:@"text"] convertToJsonWithFirstObject] urlEnocodeString]] placeholderImage:CommonGalleryImageLoading];
        [self.image setContentMode:UIViewContentModeScaleAspectFill];
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }

 }



#pragma mark -
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.image;
}

-(void)startAnim{
    [self.image stopAnimating];
    self.image.animationImages= self.aryImages ;
    self.image.animationDuration=self.aryImages .count+1;
    [self.image startAnimating];
    
}

@end

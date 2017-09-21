#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>


@interface ELCAsset : UIView {
	ALAsset *asset;
	UIImageView *overlayView;
    UIView *viewBack;
	BOOL selected;
	//id parent;
}

@property ALAsset *asset;
@property id parent;

-(id)initWithAsset:(ALAsset*)_asset;
-(id)initWithAsset:(ALAsset*)_asset withFrame:(CGRect)frame;
-(BOOL)selected;
-(void)setSelected:(BOOL)_selected;
-(void)setColor:(UIColor *)color;
-(void)colorHide;
-(void)colorUnhide;

@property (weak, nonatomic) IBOutlet UIButton* buttonHome;
@property (weak, nonatomic) IBOutlet UIImageView* assetImageViewHome;
@property (weak, nonatomic) IBOutlet UIImageView* videoImageViewHome;
@property (weak, nonatomic) IBOutlet UIImageView* overlayViewHome;

-(void)toggleSelection;
@end

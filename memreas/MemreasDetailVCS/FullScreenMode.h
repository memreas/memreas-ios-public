#import <UIKit/UIKit.h>


@protocol FullScreenModeDelegate <NSObject>

-(void)fullscreenModebackbuttonPressed:(id)sender ;

@end

@interface FullScreenMode : UIViewController

@property (weak, nonatomic) IBOutlet UICollectionView *collectionGallery;
@property (nonatomic,assign) NSIndexPath* selectedIndexPath;
@property (nonatomic,strong)NSArray *arrGalleryMedia;
@property (nonatomic) id <FullScreenModeDelegate>
delegate;
@end

#import <UIKit/UIKit.h>

@interface AddMemreasCollectionCell : UITableViewCell<UICollectionViewDataSource,UICollectionViewDelegate>


@property (nonatomic, weak) IBOutlet UICollectionView * collectionView;
@property (nonatomic, weak) IBOutlet UITextField * txtComment;
@property (nonatomic, weak) IBOutlet UIButton  * btnAudio;
@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly) NSMutableArray * arrOnlyServerImages;
@property (nonatomic, readonly) NSMutableArray * assetAry;
@property (nonatomic, readonly) NSMutableArray * selectedFileDownload,*selectedAssetsImages;

@end

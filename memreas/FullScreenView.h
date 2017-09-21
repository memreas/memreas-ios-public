#import <UIKit/UIKit.h>
#import "GalleryManager.h"
#import "GridCell.h"
#import "MyMovieViewController.h"
#import "GalleryViewController.h"
#import "MyConstant.h"

@interface FullScreenView
    : UICollectionViewController<UICollectionViewDelegateFlowLayout>

@property(nonatomic, assign) NSUInteger index;

@end

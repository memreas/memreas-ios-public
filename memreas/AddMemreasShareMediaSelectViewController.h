#import <Foundation/Foundation.h>
#import "MasterViewController.h"
@class MyConstant;
@class ShareCreator;
@class GalleryManager;
@class GridCell;


@class AddMemreasShareMediaSelectViewController;

@protocol AddShareMediaDelegate <NSObject>
@required
-(void)addMemreasShareSelectMedia:(AddMemreasShareMediaSelectViewController*)addMemerasShareSelectVC;

@end


@interface AddMemreasShareMediaSelectViewController : MasterViewController
//
// properties
//
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *galleryView;
@property (weak, nonatomic) IBOutlet UICollectionView *gridCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (nonatomic) id <AddShareMediaDelegate> delegate;
@property (nonatomic) NSString* eventId;

//
// methods
//
- (IBAction)okAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end

/**
 * Copyright (C) 2015 memreas llc. - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */
//
//  HomeViewController.h
//  memreas
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <GoogleMaps/GoogleMaps.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ELCAsset.h"
#import "DownloadController.h"
#import "GalleryManager.h"
#import "GridCell.h"
#import "HomeLocationView.h"
#import "MasterViewController.h"
#import "MyConstant.h"
#import "MyView.h"
#import "MyMovieViewController.h"
#import "GridCell.h"
#import "QueueController.h"
#import "RootViewControllerAppDelegate.h"
#import "Util.h"
#import "QueueViewController.h"
@import Photos;

@class EventMapPopView;
@class GMSMarker;

@interface HomeViewController : UIViewController<ADBannerViewDelegate,
                                                 ColorChangeDelegate,
                                                 DownloadColorChangeDelegate,
                                                 UICollectionViewDelegate,
                                                 UICollectionViewDataSource> {
  BOOL isFirstTime;

  ALAssetsLibrary* aLAssetsLibrary;

  int x, y, counter_images;
  int visitedPage, noOfImagesOnScreen;

  RootViewControllerAppDelegate* appDelegate;
}

@property(nonatomic) IBOutlet UIView* mainView;
@property(nonatomic) IBOutlet UIView* centerView;
@property(nonatomic) IBOutlet UIView* galleryView;
@property(nonatomic) IBOutlet UIView* syncButtonsView;
@property(nonatomic) IBOutlet UISegmentedControl* segViewSync;
@property(nonatomic) IBOutlet UIButton* btnClear;
@property(nonatomic) IBOutlet UIButton* btnDone;
@property(nonatomic) IBOutlet UIButton* btnRed;
@property(nonatomic) IBOutlet UIButton* btnYellow;
@property(nonatomic) IBOutlet UIButton* btnGreen;
@property(nonatomic) IBOutlet ADBannerView* advertiseView;
@property(nonatomic) IBOutlet UICollectionView* gridCollectionView;
@property(nonatomic) IBOutlet UIView* fullImageView;
@property(nonatomic) IBOutlet UIButton* btnCloseFullScreen;

@property(nonatomic) NSMutableArray* assetGroups;
@property(nonatomic) NSMutableArray* assetAry;
@property(nonatomic) NSMutableArray* elcAssets;
@property(nonatomic) NSMutableArray* selectedForSync;
@property(nonatomic) NSMutableArray* imageURLArray;
@property(nonatomic) NSMutableArray* arrOnlyServerImages;
@property(nonatomic) NSMutableArray* serverMediaFileNames;
@property MPMoviePlayerController* player;
@property MyMovieViewController* myMovieViewController;
@property(nonatomic) GMSMarker* marker;
@property UIImage* thumbnail;

- (IBAction)segmentChange:(id)sender;
- (void)enterOrExitFullScreenMode:(NSUInteger)index;
- (void)refreshGalleryView;

@end

/**
 * Copyright (C) 2015 memreas llc. - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */
//
//  MemreasGallery.h
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "XMLParser.h"
#import "ELCAsset.h"
#import "MyConstant.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioRecording.h"
#import "MyView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MasterViewController.h"
#import <UIKit/UIKit.h>
#import "MIOSDeviceDetails.h"
@import GoogleMobileAds;

@class MemreasGallery;

@protocol MemreasGallery <NSObject>

- (void)imagePickerController:(MemreasGallery *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(MemreasGallery *)picker;

@end


@interface MemreasGallery : UIViewController <AVAudioSessionDelegate,AVAudioRecorderDelegate,UIScrollViewDelegate,UITextFieldDelegate,GADBannerViewDelegate>
{
    __weak IBOutlet UIScrollView *scrForm;
    __weak IBOutlet UITextField *txtAddComment;
    __weak IBOutlet UIButton *btnSound;
    ALAssetsLibrary *library;
    AudioRecording *audioRecording;
    BOOL recording;
    BOOL isAudioCommentAdded;
}



@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,assign) id <MemreasGallery> delegate;
@property (nonatomic, strong) NSMutableArray *assetAry,*selectedAssetsImages;
@property (nonatomic, strong) NSString *eventId;
@property (nonatomic, retain) NSMutableArray  *arrOnlyServerImages;
@property (nonatomic, retain) NSMutableArray *serverFileUploadArray;
@property(nonatomic, retain) NSMutableArray *eventMedias;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;






@end

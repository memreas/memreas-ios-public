#import "MyMovieViewController.h"

//#define radians(angle) ((angle) / 180.0 * M_PI)
//#define SPIN_TAG 1000
//#define METERS_PER_MILE 10000

@implementation MyMovieViewController {
    MediaItem* mediaItem;
    NSURL* contentUrl;
    GalleryManager* sharedGalleryInstance;
    BOOL needsAWSSignedCookie;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    sharedGalleryInstance = [GalleryManager sharedGalleryInstance];
    mediaItem = sharedGalleryInstance.galleryNSMutableArray[self.index];
    
    needsAWSSignedCookie = NO;
    if (mediaItem.mediaState != SERVER) {
        //
        // Fetch local URL
        //
        [[PHImageManager defaultManager]
         requestAVAssetForVideo:mediaItem.mediaLocalPHAsset
         options:nil
         resultHandler:^(AVAsset* avAsset, AVAudioMix* audioMix,
                         NSDictionary* info) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 AVPlayerItem* playerItem =
                 [AVPlayerItem playerItemWithAsset:avAsset];
                 playerItem.audioMix = audioMix;
                 //handle phone on vibrate...
                 [[AVAudioSession sharedInstance]
                  setCategory: AVAudioSessionCategoryPlayback
                  error: nil];
                 self.player = [AVPlayer playerWithPlayerItem:playerItem];
             });
         }];
    } else {
        //
        // Fetch Server URL
        //
        if (mediaItem.mediaUrlHls != nil) {
            contentUrl = [NSURL URLWithString:mediaItem.mediaUrlHls[0]];
        } else if (mediaItem.mediaUrlWeb != nil) {
            contentUrl = [NSURL URLWithString:mediaItem.mediaUrlWeb[0]];
        }
        //handle phone on vibrate...
        [[AVAudioSession sharedInstance]
         setCategory: AVAudioSessionCategoryPlayback
         error: nil];
        self.player = [AVPlayer playerWithURL:contentUrl];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self.player play];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

@end

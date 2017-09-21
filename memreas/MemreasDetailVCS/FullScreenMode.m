#import "FullScreenMode.h"
#import "XCollectionCell.h"
#import "MyConstant.h"
#import "JSONUtil.h"
#import "NSString+SrtingUrlValidation.h"
@import AVFoundation;
@import AVKit;

@implementation FullScreenMode


-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    [self.collectionGallery setPagingEnabled:YES];
    [self.collectionGallery setCollectionViewLayout:flowLayout];
}

- (IBAction)btnBackPressed:(id)sender {
    
    @try {
        
        [self.delegate fullscreenModebackbuttonPressed:self];
        
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
}

-(void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath{
    _selectedIndexPath = selectedIndexPath;
    if (self.selectedIndexPath) {
        [self performSelector:@selector(scrollAtIndex) withObject:nil afterDelay:0.2];
    }
    
}
-(void)scrollAtIndex{
    [self.collectionGallery scrollToItemAtIndexPath:self.selectedIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:false];
}

-(void)playViderForDic:(UIButton*)sender{
    
    @try {
        
        NSDictionary *dic = self.arrGalleryMedia[sender.tag];
        
        NSString*urlString=[[[dic valueForKeyPath:@"event_media_url.text"] convertToJsonWithFirstObject]urlEnocodeString];
        NSURL *videoURL = [NSURL URLWithString:urlString];
        AVPlayer *player = [AVPlayer playerWithURL:videoURL];
        AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc]init];

        //handle phone on vibrate...
        [[AVAudioSession sharedInstance]
         setCategory: AVAudioSessionCategoryPlayback
         error: nil];

        
        playerViewController.player = player;
        [playerViewController.player play];
        [self presentViewController:playerViewController animated:YES completion:nil];
        
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
}


#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.arrGalleryMedia.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath {
    
    static NSString* cellIdentifier = @"Cell";
    XCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSDictionary *dic = self.arrGalleryMedia[indexPath.item];
    [cell loadImageWithURLString:dic andImageKey: @"event_media_448x306"];
    
    cell.playButton.tag = indexPath.item;
    [cell.playButton addTarget:self action:@selector(playViderForDic:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout   sizeForItemAtIndexPath:(NSIndexPath*)indexPath {
    return collectionView.bounds.size;
}


@end

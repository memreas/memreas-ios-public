#import "MemreasDetailGallery.h"
#import "MWebServiceHandler.h"
#import "HeaderView.h"
#import "XCollectionCell.h"
#import "CommentCollectionCell.h"
#import "GalleryManager.h"
#import "MemreasDetailViewController.h"
#import "Util.h"
#import "NSDictionary+valueAdd.h"
#import "UIImageView+AFNetworking.h"
#import "UIViewController+Logout.h"
#import "NSString+SrtingUrlValidation.h"

@interface MemreasDetailGallery ()
@property (nonatomic,strong)NSArray *arrGalleryMedia;
@end

@implementation MemreasDetailGallery{
    NSInteger dynamicCellSizeHeight, dynamicCellSizeWidth;
}

#pragma mark - View life cycle

-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    @try {
        
        /**
         * Set Observers for notifications...
         */
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(responseForLikeMedia:)
                                                     name:MEMREAS_DETAIL_GALLERY_LIKE_MEDIA_RESPONSE
                                                   object:nil];
        
        
        self.headerView.selectedSegmentIndex = self.selectedSegmentIndex;
        self.headerView.dicPassedEventDetail = self.dicPassedEventDetail;
        self.collectionComment.dicPassedEventDetail = self.dicPassedEventDetail;
        
        NSDictionary * dic = self.dicPassedEventDetail;
        if ([[dic valueForKeyPath:@"event_media"] isKindOfClass:[NSArray class]]) {
            self.arrGalleryMedia = [dic valueForKeyPath:@"event_media"];
        }else if([[dic valueForKeyPath:@"event_media"] isKindOfClass:[NSDictionary class]]){
            self.arrGalleryMedia = @[[dic valueForKeyPath:@"event_media"] ];
        }
        [self.collectionGallery reloadData];
        
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
    
}

#pragma mark - Web services
- (IBAction)addLikeDetailGallery:(id)sender {
    
    @try {
        NSMutableDictionary *input  = [NSMutableDictionary dictionary];
        
        NSString *webMethod =@"likemedia";
        //        [input addValueToDictionary:@"" andKeyIs:@"media_id"];
        [input addValueToDictionary:@"1" andKeyIs:@"is_like"];
        [input addValueToDictionary:[self.dicPassedEventDetail valueForKeyPath:@"event_id.text"] andKeyIs:@"event_id"];
        
        /**
         * Send Request and Parse Response...
         *  Note: wsHandler calls
         */
        if ([Util checkInternetConnection]) {
            /**
             * Use XMLGenerator...
             */
            NSString* requestXML = [XMLGenerator generateXMLForInputDictionary:input andSID:[Helper fetchSID] andWebMethod:webMethod];
            ALog(@"Request:- %@", requestXML);
            
            /**
             * Use WebServices Request Generator
             */
            NSMutableURLRequest* request =
            [WebServices generateWebServiceRequest:requestXML
                                            action:webMethod];
            // ALog(@"NSMutableRequest request ----> %@", request);
            
            /**
             * Send Request and handle Resonse via Notification
             */
            MWebServiceHandler* wsHandler = [[MWebServiceHandler alloc] init];
            [wsHandler fetchServerResponse:request action:LIKEMEDIA key:MEMREAS_DETAIL_GALLERY_LIKE_MEDIA_RESPONSE];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showHUDAddedTo:self.view animated:YES ];
        });
        
        /**
         * Send Request and Parse Response...
         *  Note: wsHandler calls
         */
        /*
         MWebServiceHandler* wsHandler = [[MWebServiceHandler alloc] init];
         [wsHandler fetchServerResponseWithwebMethodName:webMethod andAction:webMethod andInput:input andDelegate:self andCallBackSelector:@selector(responseForLikemedia:) andRequestXML:nil];
         */
    } @catch (NSException* exception) {
        ALog(@"object type = %@", [[GalleryManager class] debugDescription]);
        ALog(@"%@", exception);
    }
}


-(void)responseForLikeMedia:(NSNotification *)notification
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    });
    
    NSDictionary *dictionary = notification.userInfo;
    
    
    @try {
        
        [self checkForLogOut:[dictionary description]];
        
        if ([[dictionary valueForKeyPath:@"likemediaresponse.status.text"] isEqualToUpperCase:@"Success"]) {
            
            NSInteger likeCount = [self.headerView.btnLikeUserHeader.currentTitle integerValue];
            likeCount++;
            [self.headerView.btnLikeUserHeader setTitle:[NSString stringWithFormat:@"%ld",(long)likeCount] forState:UIControlStateNormal];
            
        }
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
}


#pragma mark - UICollectionView Delegate
//set a custom size for iPad...
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // setup cell size
    if (IS_IPAD) {
        dynamicCellSizeHeight = MEMREAS_GALLERY_CELLSIZE_IPAD;
        dynamicCellSizeWidth = MEMREAS_GALLERY_CELLSIZE_IPAD;
    } else {
        dynamicCellSizeHeight = MEMREAS_GALLERY_CELLSIZE_IPHONE;
        dynamicCellSizeWidth = MEMREAS_GALLERY_CELLSIZE_IPHONE;
    }
    
    
    return CGSizeMake(dynamicCellSizeWidth, dynamicCellSizeHeight);
}



- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath {
    MemreasDetailViewController *parent =(MemreasDetailViewController*) self.parentViewController;
    NSDictionary *dic = self.arrGalleryMedia[indexPath.item];
    [parent galleryMediaSelect:self selectedMedia:dic andSelectedIndexPath:indexPath];
}
#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.arrGalleryMedia.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath {
    
    static NSString* cellIdentifier = @"Cell";
    XCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                                                      forIndexPath:indexPath];
    NSDictionary *dic = self.arrGalleryMedia[indexPath.item];
    [cell loadImageWithURLString:dic andImageKey: @"event_media_98x78"];
    
    cell.playButton.userInteractionEnabled = NO;
    
    UIColor* syncStateColor = [self setBorderColor:[dic objectForKey:@"event_media_name"]];
    cell.layer.borderColor = syncStateColor.CGColor;
    cell.layer.borderWidth = 2.0;
    cell.layer.masksToBounds = true;
    
    return cell;
    
}

#pragma mark - set border color
- (UIColor*)setBorderColor:(NSDictionary*) eventMediaNameDict {
    UIColor* syncStateColor = [UIColor redColor];
    @try {
        GalleryManager* sharedInstance = [GalleryManager sharedGalleryInstance];
        NSString* event_media_name = [eventMediaNameDict objectForKey:@"text"];
        MediaItem* mediaEventItem = [sharedInstance.dictGallery objectForKey:event_media_name];
        
        //
        if (mediaEventItem != nil) {
            if (mediaEventItem.mediaState == SYNC) {
                syncStateColor = [UIColor greenColor];
            } else if (mediaEventItem.mediaState == IN_TRANSIT) {
                syncStateColor = [UIColor orangeColor];
            } else if (mediaEventItem.mediaState == SERVER) {
                syncStateColor = [UIColor yellowColor];
            }
        } else {
            //
            // media is not in our gallery (i.e. friends / public)
            //
            syncStateColor = [UIColor clearColor];
        }
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
    return syncStateColor;
}

- (IBAction)btnShowComments:(id)sender {
    
    @try {
        
        if (self.collectionComment.arrComments.count == 0) {
            [Helper showMessageFade:self.view withMessage:@"no comments..." andWithHideAfterDelay:3];
        } else {
            MemreasDetailViewController* parent = (MemreasDetailViewController*)self.parentViewController;
            [parent showComments:YES withComments:self.collectionComment.arrComments andWithEventDetail:self.collectionComment.dicPassedEventDetail];
        }
        
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
}

@end

//
// CommentCollection
//
@implementation CommentCollection
-(void)awakeFromNib{
    self.delegate = self;
    self.dataSource = self;
    [self reloadData];
    
}

-(void)setMedia_id:(NSString *)media_id{
    
    _media_id = media_id;
    [self defaultLoad];
    
}

-(void)defaultLoad{
    
    NSDictionary * dic = self.dicPassedEventDetail;
    if ([[dic valueForKeyPath:@"comments.comment"] isKindOfClass:[NSArray class]]) {
        self.arrComments = [dic valueForKeyPath:@"comments.comment"];
    }else if([[dic valueForKeyPath:@"comments.comment"] isKindOfClass:[NSDictionary class]]){
        self.arrComments = @[[dic valueForKeyPath:@"comments.comment"] ];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(self.type.text == 'text' || self.type.text == 'audio') && (comment_media_id.text == %@)",self.media_id];
    self.arrComments = [self.arrComments filteredArrayUsingPredicate:predicate];
    [self reloadData];
    
    
}

-(void)setDicPassedEventDetail:(NSDictionary *)dicPassedEventDetail{
    _dicPassedEventDetail = dicPassedEventDetail;
    [self defaultLoad];
}


#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.arrComments.count == 0) {
        // show empty comment cell...
        return 1;
    }
    return self.arrComments.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.bounds.size;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath {
    
    static NSString* cellIdentifier = @"Cell";
    CommentCollectionCell* cellCmt = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    //
    // If no comments show empty cell
    //
    if (self.arrComments.count == 0) {
        [cellCmt.imgUser setImage:[UIImage imageNamed:@"user_img.png"]];
        cellCmt.tfComment.text = @"no comments - add one below...";
        cellCmt.tfComment.hidden = false;
        cellCmt.viewAudioPlayer.hidden =true;
    } else {
        NSDictionary* dict = self.arrComments[indexPath.item];
        
        NSString* avatar = [[[[dict objectForKey:@"profile_pic"] objectForKey:@"text"] convertToJsonWithFirstObject] urlEnocodeString];
        [cellCmt.imgUser setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:@"user_img.png"]];
        
        if ([[dict valueForKeyPath:@"type.text"] isEqualToString:@"text"]) {
            cellCmt.tfComment.text = [NSString stringWithFormat:@"%@", [[dict objectForKey:@"comment_text"] objectForKey:@"text"]];
            cellCmt.tfComment.hidden = false;
            cellCmt.viewAudioPlayer.hidden =true;
            
        } else if ([[dict valueForKeyPath:@"type.text"] isEqualToString:@"audio"]) {
            
            [cellCmt.btnPlay addTarget:self action:@selector(btnPlay:) forControlEvents:UIControlEventTouchUpInside];
            cellCmt.tfComment.hidden = true;
            cellCmt.viewAudioPlayer.hidden =false;
            
        }
    } //end else if arrComments !nil
    
    
    cellCmt.tfComment.layer.cornerRadius = 5;
    cellCmt.tfComment.layer.borderColor = [UIColor whiteColor].CGColor;
    cellCmt.tfComment.layer.borderWidth = 2.0;
    cellCmt.tfComment.layer.masksToBounds = true;
    
    cellCmt.viewAudioPlayer.layer.cornerRadius = 5;
    cellCmt.viewAudioPlayer.layer.borderColor = [UIColor whiteColor].CGColor;
    cellCmt.viewAudioPlayer.layer.borderWidth = 2.0;
    cellCmt.viewAudioPlayer.layer.masksToBounds = true;
    
    cellCmt.imgUser.layer.masksToBounds = 1;
    cellCmt.imgUser.layer.cornerRadius = 10;
    
    // Player default setup
    cellCmt.btnPlay.tag = indexPath.item;
    cellCmt.btnPlay.cell = cellCmt;
    cellCmt.lblTime.text = [self timeFormatted:0];
    [cellCmt.active stopAnimating];
    [cellCmt.btnPlay setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    cellCmt.slider.value = 0;
    cellCmt.lblTime.textColor = [UIColor whiteColor];
    cellCmt.slider.userInteractionEnabled = 0;
    [self.playAu pause];
    isPlay = 0;
    
    return cellCmt;
    
}



#pragma mark -
#pragma mark - Audio Player

bool isPlay;

- (NSString *)timeFormatted:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

- (CMTime)playerItemDuration {
    @try {
        AVPlayerItem* thePlayerItem = [self.playAu currentItem];
        if (thePlayerItem.status == AVPlayerItemStatusReadyToPlay) {
            return ([thePlayerItem duration]);
        }
        
        return (kCMTimeInvalid);
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}


- (void)syncScrubber:(CommentCollectionCell*)cell {
    
    @try {
        
        CMTime playerDuration = [self playerItemDuration];
        
        if (CMTIME_IS_INVALID(playerDuration)) {
            cell.slider.minimumValue = 0.0;
            return;
        }
        
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration) && (duration > 0)) {
            
            cell.slider.maximumValue = duration;
            float minValue = [cell.slider minimumValue];
            float maxValue = duration;
            
            double time = CMTimeGetSeconds([_playAu currentTime]);
            
            [cell.slider setValue:(maxValue - minValue) * time / duration + minValue];
            
            cell.lblTime.text = [self timeFormatted:time];
            [cell.active stopAnimating];
            
            //            if (self.playAu.rate == 0.0) {
            if ( cell.slider.value >= maxValue) {
                
                [cell.slider setValue:0];
                cell.lblTime.text = [self timeFormatted:0];
                isPlay = 0;
                [self.playAu pause];
                [cell.btnPlay setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
                self.playAu = nil;
                //                [tableComment reloadData];
            }
        }
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

- (void)btnPlay:(PlayerAudioButton*)sender {
    @try {
        
        // Sample URL for testing
        // NSURL *url = [NSURL
        // URLWithString:@"http://media.nhacvietplus.com.vn/upload/music/gaquay/blogradio342/fulltrack/blogradio342.mp3"];
        
        NSDictionary* dict = self.arrComments[sender.tag];
        NSURL* url = [NSURL URLWithString: [[[dict valueForKeyPath:@"audio_media_url.text"] convertToJsonWithFirstObject]urlEnocodeString]];
        AVPlayerItem* playerItem = [[AVPlayerItem alloc] initWithURL:url];
        
        __block CommentCollectionCell* CELL = sender.cell;
        
        if (isPlay == NO && url) {
            _playAu = [[AVPlayer alloc] initWithPlayerItem:playerItem];
            
            __block  CommentCollection __weak *blockSelf = self;
            [_playAu addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds( 1.0 / 60.0, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time) {
                [blockSelf  syncScrubber:sender.cell];
            }];
            
            [_playAu play];
            [CELL.active startAnimating];
            [sender setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
            isPlay = YES;
            
        } else {
            [_playAu pause];
            [sender setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
            isPlay = 0;
            _playAu = nil;
            [CELL.active stopAnimating];
            //            [tableComment reloadData];
        }
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}


@end

#import "CommentVC.h"
#import "Helper.h"
#import "XMLParser.h"
#import "CellComment.h"
#import "CommentCollectionCell.h"
#import "AudioRecording.h"
#import "NotificationsViewController.h"
#import "RecordingVC.h"
#import "MemreasDetailViewController.h"
#import "UIImageView+AFNetworking.h"

@interface CommentVC ()
{
    
    BOOL isPlay;
    AudioRecording *audioRecording;
    
}

@property (nonatomic, strong) AVPlayer *playAu;
@property (weak, nonatomic) IBOutlet UIView *viewForUP;
@property (nonatomic,strong) RecordingVC*recordingVC;


@end

@implementation CommentVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    ALog(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController]
 // Pass the selected object to the new view controller.
 }
 */


#pragma  mark
#pragma  mark Webservice call & parsing
-(void) listComments:(NSString*)mediaIDpassed
{
    
    @try {
        
        [MBProgressHUD showHUDAddedTo:self.tableComment animated:1];
        
        //ADDTOXMLGENERATOR
        NSString *urlString = [NSString stringWithFormat:@"%@?action=listcomments&sid=%@",[MyConstant getWEB_SERVICE_URL],SID];
        NSMutableString *xml = [[NSMutableString alloc] init];
        [xml appendFormat:@"xml=<xml><listcomments>"];
        [xml appendFormat:@"<event_id>%@</event_id>",self.dicEventNSDictionary [@"event_id"]];
        [xml appendFormat:@"<page>1</page>"];
        [xml appendFormat:@"<limit>100</limit>"];
        
        if (mediaIDpassed) {
            [xml appendFormat:@"<media_id>%@</media_id>",mediaIDpassed];
        }
        
        [xml appendFormat:@"</listcomments></xml>"];
        
        [[[XMLParser alloc]init] parseWithURL:urlString typeParse:1 soapMessage:xml startTag:nil completedSelector:@selector(objectParsed_Comments:) handler:self];
        xml = nil;
        urlString = nil;
    }
    
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
}


- (void)objectParsed_Comments:(NSDictionary*)result
{
    
    [MBProgressHUD hideAllHUDsForView:self.tableComment animated:1];
    
    if([[[[result objectForKey:@"xml"] objectForKey:@"listcommentsresponse"] objectForKey:@"comments"] objectForKey:@"comment"] != nil)
    {
        id obj = [[[[result objectForKey:@"xml"] objectForKey:@"listcommentsresponse"] objectForKey:@"comments"] objectForKey:@"comment"];
        
        if ([obj isKindOfClass:[NSDictionary class]]) {
            self.arrComment = (NSArray*)@[obj];
        }else{
            self.arrComment = obj;
        }
    }else{
        self.arrComment = (NSArray*)@[];
    }
    
}


#pragma mark - TableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.arrComment count];
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(void)btnPlayau :(NSURL*)url
{
    
}




-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *indentifier = @"Comment";
    CellComment *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    
    NSDictionary *dict = self.arrComment[indexPath.section];
    
    ALog(@"DICCCCC   ===  %@",dict);
    
    NSString *avatar = [[[dict objectForKey:@"profile_pic"] objectForKey:@"text"] convertToJsonWithFirstObject];
    
    [cell.imgUser setImageWithURL:[NSURL URLWithString:avatar]  placeholderImage:[UIImage imageNamed:@"user_img.png"]];
    //[cell.imgUser setImage:[UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:avatar]]]];
    
    bool isAudio = NO;
    if ([[dict valueForKeyPath:@"type.text"] isEqualToString:@"text"]) {
        NSString* text = [NSString stringWithFormat:@"%@",[[self.arrComment[indexPath.section] objectForKey:@"comment_text"] objectForKey:@"text"]];
        cell.tfComment.text = text;
    } else if ([[dict valueForKeyPath:@"type.text"] isEqualToString:@"audio"]){
        cell.btnPlay.tag = indexPath.section;
        //cell.lblTime.text = [dict valueForKeyPath:@"commented_about.text"];
        isPlay = NO;
        [cell.btnPlay addTarget:self action:@selector(btnPlay:) forControlEvents:UIControlEventTouchUpInside];
        isAudio = YES;
    } else if ([[dict valueForKeyPath:@"type.text"] isEqualToString:@""]) {
        NSString* text = [NSString stringWithFormat:@"%@",[[self.arrComment[indexPath.section] objectForKey:@"comment_text"] objectForKey:@"text"]];
        if ([text isKindOfClass:[NSString class]]) {
            cell.tfComment.text = text;
        } else {
            // must be audio
            cell.btnPlay.tag = indexPath.section;
            isPlay = NO;
            [cell.btnPlay addTarget:self action:@selector(btnPlay:) forControlEvents:UIControlEventTouchUpInside];
            isAudio = YES;
        }
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imgUser.layer.masksToBounds =1;
    cell.imgUser.layer.cornerRadius=10;
    if (!isAudio){
        cell.audioCommentView.hidden = 0;
        cell.textCommentView.hidden = 1;
        cell.tfComment.textColor = [UIColor blueColor];
        cell.tfComment.layer.cornerRadius =10;
    } else {
        cell.audioCommentView.hidden = 1;
        cell.textCommentView.hidden = 0;
        cell.lblTime.text = [self timeFormatted:0];
        cell.lblTime.textColor = [UIColor whiteColor];
        [cell.btnPlay setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        cell.slider.value =0;
        cell.slider.userInteractionEnabled =0;
        
        [self.playAu pause];
        isPlay=0;
        cell.backgroundView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    cell.tag = indexPath.section;
    [cell.active stopAnimating];
    
    return cell;
    
}

- (NSString *)timeFormatted:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    //    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}


- (IBAction)btnPlay:(PlayerAudioButton*)sender {
    @try {
        
        // Sample URL for testing
        // NSURL *url = [NSURL
        // URLWithString:@"http://media.nhacvietplus.com.vn/upload/music/gaquay/blogradio342/fulltrack/blogradio342.mp3"];
        
        NSDictionary* dict = self.arrComment[sender.tag];
        NSURL* url = [NSURL URLWithString: [[[dict valueForKeyPath:@"audio_media_url.text"] convertToJsonWithFirstObject]urlEnocodeString]];
        AVPlayerItem* playerItem = [[AVPlayerItem alloc] initWithURL:url];
        
        __block CellComment* CELL = sender.cell;
        
        if (isPlay == NO && url) {
            _playAu = [[AVPlayer alloc] initWithPlayerItem:playerItem];
            
            __block  CommentVC __weak *blockSelf = self;
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

- (void)syncScrubber:(CellComment*)cell {
    
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


/*
-(IBAction)btnPlay:(UIButton*)sender
{
    UIButton *audio = (UIButton *)sender;
    
    ALog(@"%@",[[sender.superview superview] superview]);
    
    
    //Sample URL for testing
    // NSURL *url = [NSURL URLWithString:@"http://media.nhacvietplus.com.vn/upload/music/gaquay/blogradio342/fulltrack/blogradio342.mp3"];
    
    NSDictionary *dict = self.arrComment[audio.tag];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[[[dict objectForKey:@"audio_media_url"] objectForKey:@"text"] convertToJsonWithFirstObject]]];
    AVPlayerItem* playerItem = [[AVPlayerItem alloc] initWithURL:url];
    
    __block CellComment*CELL;
    
    CELL = (CellComment*)[sender.superview superview] ;
    
    for (int i=0; i<10; i++) {
        
        CELL = (CellComment*) [CELL superview];
        
        if ([CELL isKindOfClass:[UICollectionViewCell class]] ||[CELL isKindOfClass:[UITableViewCell class]]) {
            break;
        }
        
        
    }
    
    
    __weak CommentVC*common = self;
    
    if (isPlay == NO) {
        
        _playAu = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        
        //            __block NSObject *blockSelf = self;
        [_playAu addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0 / 60.0, NSEC_PER_SEC)
                                              queue:NULL
                                         usingBlock:^(CMTime time){
                                             [common syncScrubber:CELL];
                                         }];
        
        [_playAu play];
        [CELL.active startAnimating];
        
        [audio setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        isPlay = YES;
        
    }else{
        [_playAu pause];
        [audio setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        isPlay = 0;
        _playAu =nil;
        [CELL.active stopAnimating];
        [self.tableComment reloadData];
        
    }
    
}
 
 - (void)syncScrubber:(CellComment*)cell
 {
 CMTime playerDuration = [self playerItemDuration];
 if (CMTIME_IS_INVALID(playerDuration))
 {
 cell.slider.minimumValue = 0.0;
 return;
 }
 
 double duration = CMTimeGetSeconds(playerDuration);
 if (isfinite(duration) && (duration > 0))
 {
 float minValue = [cell.slider minimumValue];
 float maxValue = [cell.slider maximumValue];
 double time = CMTimeGetSeconds([_playAu currentTime]);
 [cell.slider setValue:(maxValue - minValue) * time / duration + minValue];
 cell.lblTime.text = [self timeFormatted:time];
 
 [cell.active stopAnimating];
 
 if (maxValue ==cell.slider.value) {
 
 [cell.slider setValue:0];
 cell.lblTime.text = [self timeFormatted:0];
 isPlay=0;
 [_playAu pause];
 [cell.btnPlay setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
 
 _playAu =nil;
 
 [self.tableComment reloadData];
 
 
 }
 
 }
 }

*/

- (IBAction)btnSoundClicked:(id)sender {
    
    [self loadRecording:YES];
}


-(void)loadRecording:(BOOL)load{
    
    @try {
        
        
        int h = 480;
        int yX = 44;
        if (load) {
            self.recordingVC =[self.storyboard instantiateViewControllerWithIdentifier:@"RecordingVC"];
            self.recordingVC.view.frame = CGRectMake (0, yX, 320, h);
            [self addChildViewController:self.recordingVC];
            self.recordingVC.view.alpha=0;
            [self.view addSubview:self.recordingVC.view];
            
            // Pass parameter
            self.recordingVC.dicPassedEventDetail = @{@"event_id": self.dicEventNSDictionary[@"event_id"] ,@"media_id":self.dicEventNSDictionary[@"media_id"]};
            
            [UIView beginAnimations:nil context:NULL];
            self.recordingVC.view.alpha=1;
            [UIView commitAnimations];
            
        }else{
            
            [UIView beginAnimations:nil context:NULL];
            [UIView animateWithDuration:0.5 animations:^{
                self.recordingVC.view.alpha=0;
                
            } completion:^(BOOL finished) {
                [self.recordingVC removeFromParentViewController];
                [self.recordingVC.view removeFromSuperview];
                self.recordingVC =nil;
            }];
            [UIView commitAnimations];
        }
        
        
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
}

- (CMTime)playerItemDuration
{
    AVPlayerItem *thePlayerItem = [_playAu currentItem];
    if (thePlayerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        return([thePlayerItem duration]);
    }
    
    return(kCMTimeInvalid);
}



- (IBAction)okTapped:(id)sender {
    
    
    if (self.txtMemreasComment.text.length) {
        [self addCommentToMedia];
    }
    
    [audioRecording recordOrStop:audioRecording.btnRecordComment];
    [audioRecording.soundRecorder stop];
    audioRecording.soundRecorder = nil;
    
    
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [self reloadData];
    
}


//#define isMyVdo [[arrMedias[detailImageCounter][@"type"] uppercaseString] isEqualToString:@"VIDEO"]

-(void)reloadData{
    [self listComments:nil];
}

- (IBAction)closeP:(id)sender {
    
    [self clos];
}

-(void)clos{
    
    [audioRecording.soundRecorder stop];
    
    audioRecording.soundRecorder = nil;
    
    
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [audioRecording recordOrStop:audioRecording.btnRecordComment];
    
    NotificationsViewController *parent = (NotificationsViewController*) self.parentViewController;
    [self loadComment:0  andDictionary:self.dicEventNSDictionary ];
    
}

- (void)loadComment:(BOOL)load andDictionary:(NSDictionary*)dic {
    int h = 470;
    int yX = 0;
    
    if (load) {
        //self = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentVC"];
        self.view.frame = CGRectMake(0, yX, 320, h);
        [self addChildViewController:self];
        [self.view addSubview:self.view];
        self.view.alpha = 0;
        // Pass parameter
        self.dicEventNSDictionary = dic;
        
        [UIView beginAnimations:nil context:NULL];
        self.view.alpha = 1;
        [UIView commitAnimations];
    } else {
        //[self callForFeedBackNotificationStatus:@"1"
        //                             andMessage:@""
        //              andNotificationDictionary:dic];
        [UIView beginAnimations:nil context:NULL];
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.view.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             [self removeFromParentViewController];
                             [self.view removeFromSuperview];
                         }];
        [UIView commitAnimations];
    }
}



-(void)addCommentToMedia{
    
    [MBProgressHUD showHUDAddedTo:self.tableComment animated:1];
    //ADDTOXMLGENERATOR
    NSUserDefaults *defaultUser = [NSUserDefaults standardUserDefaults];
    //    int userId = [[defaultUser objectForKey:@"UserId"] intValue];
    NSString *urlString = [NSString stringWithFormat:@"%@?action=addcomments&sid=%@",[MyConstant getWEB_SERVICE_URL],SID];
    NSMutableString *xml = [[NSMutableString alloc] init];
    [xml appendFormat:@"xml=<xml><addcomment>"];
    [xml appendFormat:@"<user_id>%@</user_id>",[defaultUser objectForKey:@"UserId"]];
    [xml appendFormat:@"<event_id>%@</event_id>",self.dicEventNSDictionary[@"event_id"]];
    [xml appendFormat:@"<media_id>%@</media_id>",self.dicEventNSDictionary[@"media_id"]];
    [xml appendFormat:@"<comments>%@</comments>",self.txtMemreasComment.text];
    [xml appendFormat:@"<audio_url></audio_url>"];
    [xml appendFormat:@"</addcomment></xml>"];
    [[[XMLParser alloc]init] parseWithURL:urlString soapMessage:xml startTag:@"addcommentresponse" completedSelector:@selector(objectParsed_addCommentToMedia:) handler:self];
    xml = nil;
    urlString = nil;
    
}
-(void)objectParsed_addCommentToMedia:(NSMutableDictionary *)dictionary{
    
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Comment has been submitted" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    //[alert show];
    //alert = nil;
    
    [Helper showMessageFade:self.view withMessage:@"Comment submitted" andWithHideAfterDelay:2];
    dictionary = nil;
    
    [self clos];
}



#pragma mark
#pragma mark UITextfield Delegate methods



-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
    
}



-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.viewForUP.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
    
    [self.txtMemreasComment resignFirstResponder];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.viewForUP.transform = CGAffineTransformMakeTranslation(0, -96);
    [UIView commitAnimations];
    
}

#pragma mark
#pragma mark - Unwind segue call
- (IBAction)closeComments:(id)sender {
    //[self performSegueWithIdentifier:@"segueUnwindToMemreasParent" sender:sender];
    MemreasDetailViewController *memreasDetailVC =(MemreasDetailViewController*) [self parentViewController];
    [memreasDetailVC showComments:NO withComments:nil andWithEventDetail:nil];
    
}



@end

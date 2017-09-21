#import "RecordingVC.h"


#import "MemreasDetailViewController.h"
#import "AddMediaFromPhotoDetai.h"
#import "MyConstant.h"
#import "XMLGenerator.h"
#import "MediaIdManager.h"
#import "AudioRecording.h"
#import "GalleryManager.h"
#import "Helper.h"


@interface RecordingVC ()<UITextFieldDelegate>
{
    
    AudioRecording *audioRecording;
    BOOL recording;
    AppDelegate *appDelegate;
    
}

@property (weak, nonatomic) IBOutlet UITextField *txtComment;


@end

@implementation RecordingVC

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
    [super viewDidLoad];
    
    [self.tfComment becomeFirstResponder];
    [self.tfComment resignFirstResponder];
    
    self.lblSpeakNow.text = @"Start now";
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.txtComment.delegate = self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSString *)timeFormatted:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    //    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}
-(void)setUP:(NSTimer*)timeer{
    self.time++;
    self.slider.value = self.time;
    self.lblTimer.text = [self timeFormatted:self.time];
    self.strTime = [self timeFormatted:self.time];
    
}
-(void)stopMeter{
    
    [self.timer invalidate];
    self.timer = nil;
    self.time = 0;
    self.lblTimer.text = [self timeFormatted:self.time];
    self.slider.value = self.time;
    
}

-(void)startMeter{
    
    self.lblTimer.textColor = [UIColor redColor];
    self.lblTimer.textAlignment = NSTextAlignmentCenter;
    self.time = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setUP:) userInfo:nil repeats:YES];
}





#define isMyVdo [[arrMedias[detailImageCounter][@"type"] uppercaseString] isEqualToString:@"VIDEO"]



-(void)hideME{
    
    [self btnCloseRecordingMenu:nil];
    
}


- (IBAction)btnPlayTapped:(id)sender {
    
    if(audioRecording == nil){
        audioRecording = [[AudioRecording alloc] init];
        [audioRecording viewDidLoad];
    }
    
    if(recording){
        appDelegate.eventID = self.dicPassedEventDetail[@"event_id"];
        [self.btnPlay setImage:[UIImage imageNamed:@"center_mic"] forState:UIControlStateNormal];
        recording = NO;
        
        self.lblSpeakNow.text =@"Start now";
        self.lblSpeakNow.textColor = [UIColor whiteColor];
        
        
        appDelegate.isAudioComment = YES;
        appDelegate.firstMediaId = self.dicPassedEventDetail[@"media_id"];
        [audioRecording recordOrStop:audioRecording.btnRecordComment];
        
        //
        // Fetch a media id for the recording
        //
        NSString* audio_media_id = [[MediaIdManager sharedInstance] fetchNextMediaId];

        //
        // If Detail audio set media id
        //
        NSString* media_id = @"";
        if (![MemreasDetailViewController fetchIsGallery]) {
            //
            // Detail - set media_id
            //
            media_id = self.dicPassedEventDetail[@"media_id"];
        }

        
        //
        // Upload the audio recording
        //
        audioRecording.mediaId = [self.dicPassedEventDetail valueForKeyPath:@"media_id"];
        audioRecording.audioMediaId = audio_media_id;
        audioRecording.eventId = self.dicPassedEventDetail[@"event_id"];
        audioRecording.comment = self.txtComment.text;
        [audioRecording uploadAudioFile];
        
        /*
        __weak typeof(self) weakSelf = self;
        [[UploadController sharedInstance] addUploadAudioItems:nil event_id:self.dicPassedEventDetail[@"event_id"] media_id:media_id audio_media_id:audio_media_id completion:^{
            //
            // Add the comment with the audio id
            //
            [weakSelf addCommentToMedia:[self.dicPassedEventDetail valueForKeyPath:@"event_id"]
                            withMediaId:[self.dicPassedEventDetail valueForKeyPath:@"media_id"]
                         andWithAudioId:audio_media_id
                        andWithComments:self.txtComment.text];
            ALog(@"The task is complete");
            
            
        }];
         */
        
         //
         // Show submission dialog
         //
         [Helper showMessageFade:self.view withMessage:@"submitting comment(s)..." andWithHideAfterDelay:3];
         
         //
         // Close comment dialog
         //
         [self performSelector:@selector(hideME) withObject:nil afterDelay:3];
         
        //
        // Stop meter to show accurate time
        //
        [self stopMeter];
        
        //
        // reset first responder for audio
        //
        [self.tfComment becomeFirstResponder];
        
    } else{
        [self.btnPlay setImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
        
        self.lblSpeakNow.text =@"Recording...";
        self.lblSpeakNow.textColor = [UIColor redColor];
        
        //resign responder for text while recording
        [self.tfComment resignFirstResponder];
        
        //
        // start recording and meter
        //
        recording = YES;
        [audioRecording recordOrStop:audioRecording.btnRecordComment];
        [self startMeter];
    }
    
}

- (void)addCommentToMedia:(NSString*) event_id withMediaId:(NSString*) media_id andWithAudioId:(NSString*) audio_media_id andWithComments:(NSString*) comments {
    
    @try {
        
        //
        // For event level set media_id = @""
        //
        if (media_id == nil) {
            media_id = @"";
        }
        
        /*
         * check connection
         */
        if ([Util checkInternetConnection]) {
            
            /**
             * Use WebServices Request Generator
             */
            NSString* requestXML = [XMLGenerator generateAddCommentXML:[Helper fetchUserId]
                                                           withEventId:event_id
                                                        andWithMediaId:media_id
                                                   andWithAudioMediaId:audio_media_id
                                                       andWithComments:comments];
            NSMutableURLRequest* request =
            [WebServices generateWebServiceRequest:requestXML
                                            action:ADDCOMMENTS];
            //ALog(@"NSMutableRequest request ----> %@", request);
            
            /**
             * Send Request and Parse Response...
             *  Note: wsHandler notifies handleAddMediaEventMWS
             */
            MWebServiceHandler* wsHandler = [[MWebServiceHandler alloc] init];
            [wsHandler fetchServerResponse:request
                                    action:ADDCOMMENTS
                                       key:ADDCOMMENT_RESULT_NOTIFICATION];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        });
        
        //
        // Close comment dialog
        //
        [self performSelector:@selector(hideME) withObject:nil afterDelay:0];
        
        
    } @catch (NSException* exception) {
        ALog(@"object type = %@", [[GalleryManager class] debugDescription]);
        ALog(@"%@", exception);
    }
}



#pragma mark - Add comment OK button action
- (IBAction)btnOkTapped:(id)sender {
    
    @try {
        
        //
        // Check if text then submit ws
        //
        bool submitted = NO;
        if (self.txtComment.text && self.txtComment.text.length > 0)
        {
            [self addCommentToMedia:[self.dicPassedEventDetail valueForKeyPath:@"event_id"] withMediaId:[self.dicPassedEventDetail valueForKeyPath:@"media_id"] andWithAudioId:@"" andWithComments:self.txtComment.text];
            submitted = YES;
        }
        if (recording) {
            submitted = YES;
            [self btnPlayTapped:sender];
        }
        
        if (!submitted) {
            [Helper showMessageFade:self.view withMessage:@"Please submit a text or audio comment" andWithHideAfterDelay:2];
        }
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
}




#pragma mark - Text field delegate

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    
    [self.tfComment becomeFirstResponder];
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    });
    
    CGRect frame = self.view.frame;
    self.view.frame = CGRectMake(frame.origin.x, frame.origin.y-150,frame.size.width, frame.size.height);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    CGRect frame = self.view.frame;
    self.view.frame = CGRectMake(frame.origin.x, frame.origin.y+150,frame.size.width, frame.size.height);
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self.view endEditing:true];
    [self.tfComment resignFirstResponder];
    return YES;
}

#pragma mark - IB Actions


- (IBAction)btnCloseRecordingMenu:(UIButton *)sender {
    
    @try {
        
        
        [self.btnPlay setImage:[UIImage imageNamed:@"center_mic"] forState:UIControlStateNormal];
        recording = NO;
        
        self.lblSpeakNow.text =@"Start now";
        self.lblSpeakNow.textColor = [UIColor whiteColor];
        
        
        [audioRecording recordOrStop:audioRecording.btnRecordComment];
        
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
         
        [self stopMeter];
        
        AddMediaFromPhotoDetai *mediaDetail =(AddMediaFromPhotoDetai*) [self parentViewController];
        [mediaDetail loadRecording:NO];
        
        
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
}

@end

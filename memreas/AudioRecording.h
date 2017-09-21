#import <UIKit/UIKit.h>
#import "MyConstant.h"
#import "MyConstant.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "XMLParser.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "MediaIdManager.h"
@class AWSManager;
@class Helper;
@class Util;
@class XMLGenerator;
@class WebServices;
@class MWebServiceHandler;

@interface AudioRecording : UIViewController<AVAudioPlayerDelegate, AVAudioSessionDelegate,AVAudioRecorderDelegate>
{
    BOOL recording, playing, lastComment;
    AVAudioRecorder *soundRecorder;
    AVAudioPlayer *audioPlayer;
    MPMoviePlayerController* player;
}
@property (weak, nonatomic) IBOutlet UIButton *btnLastCommentPlay;
@property (weak, nonatomic) IBOutlet UIButton *btnRecordComment;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayComment;
@property (strong, nonatomic) NSURL *soundFileURL,*lastCommentURL;
@property (strong, nonatomic) AVAudioRecorder *soundRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSString *s3file_name, *content_type, *mediaId, *eventId, *comment, *audioMediaId;
@property NSURLSessionUploadTask *uploadAudioCommentTask;

-(void) uploadAudioFile;
- (IBAction)recordOrStop:(id)sender;
@end

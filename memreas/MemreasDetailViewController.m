#define SPIN_TAG 1000
#define METERS_PER_MILE 10000
#define INTERVAL 8

#import "MemreasDetailViewController.h"
#import "MemreasLocationViewController.h"
#import "AddMemreasShareMediaSelectViewController.h"
#import "AddMemreasShareFriendsSelectViewController.h"
#import "AddMemreasShareFriendsViewController.h"
#import "MemreasLocationViewController.h"
#import "AddMemreasShareMediaViewController.h"
#import "ShareCreator.h"
#import "XMLParser.h"
#import "MyConstant.h"
#import "MyView.h"
#import "AudioRecording.h"
#import "Helper.h"
#import "MIOSDeviceDetails.h"
#import "MemreasDetailGallery.h"
#import "MemreasMediaDetail.h"
#import "AddMediaFromPhotoDetai.h"
#import "AudioRecording.h"
#import "XCollectionCell.h"
#import "RecordingProgress.h"
#import "CellComment.h"
#import "Util.h"
#import "XMLReader.h"
#import "CommentCollectionCell.h"
#import "FullScreenView.h"
#import "RecordingVC.h"
#import "CommentVC.h"
#import "AFNetworking/UIImageView+AFNetworking.h"
#import "NSDictionary+valueAdd.h"

static NSInteger lastSegmentGalleryOrDetail = 0;

@implementation MemreasDetailViewController

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @try {
        
        //
        // Google Banner View
        //
        self.bannerView.adUnitID = [[MIOSDeviceDetails sharedInstance] getAdUnitId];
        self.bannerView.rootViewController = self;
        [self.bannerView loadRequest:[GADRequest request]];

        //
        // populate dicPassedEventDetail here for refresh case
        //
        self.dicPassedEventDetail = self.arrEventsForSegment[[self.index integerValue]];
        
        if (IS_IPAD) {
            [self.navigationController.navigationBar
             setBackgroundImage:[UIImage imageNamed:@"memreas"]
             forBarMetrics:UIBarMetricsDefault];
        } else {
            [self.navigationController.navigationBar
             setBackgroundImage:[UIImage imageNamed:@"nav_Memreas"]
             forBarMetrics:UIBarMetricsDefault];
        }
        
        // Set up segment Control
        self.segGalleryDetail.layer.cornerRadius = 5.0;
        self.segGalleryDetail.layer.masksToBounds = true;
        
        //
        //  Setup view as default with light gray text highlight - default
        //
        [self.segGalleryDetail setBackgroundColor:[UIColor blackColor]];
        NSDictionary* attributes = [NSDictionary
                                    dictionaryWithObjectsAndKeys:[UIColor whiteColor],
                                    NSForegroundColorAttributeName, nil];
        [self.segGalleryDetail setTitleTextAttributes:attributes
                                             forState:UIControlStateNormal];
        [self.segGalleryDetail setTitleTextAttributes:attributes forState:UIControlStateNormal];
        
        //
        //  Setup view as default with light gray text highlight on select
        //
        attributes = [NSDictionary
                      dictionaryWithObjectsAndKeys:[UIColor lightGrayColor],
                      NSForegroundColorAttributeName, nil];
        [self.segGalleryDetail setTitleTextAttributes:attributes
                                             forState:UIControlStateSelected];
        [self.segGalleryDetail setTitleTextAttributes:attributes forState:UIControlStateSelected];
        [self segmentChange:self.segGalleryDetail];
        
        
        
        /**
         * Set Observer for addcomment web service to refresh
         */
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleRefreshMemreasMWS)
                                                     name:MEMREAS_SELECT_RESULT_REFRESH_NOTIFICATION
                                                   object:self];
        
        //
        // Add observer for handle method - must be in here so SMS view will show.
        //
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleFriendsMessaging)
                                                     name:MEMREAS_ADDFRIENDS_HANDLER_NOTIFICATION
                                                   object:nil];
        
        
        //
        // Add observer for handle method - must be in here so SMS view will show.
        //
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleAddMemreasFriendsToEventCompleted:)
                                                     name:MEMREAS_ADDFRIENDS_SELECT_RESULT_NOTIFICATION
                                                   object:nil];
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

- (void) handleRefreshMemreasMWS {
    
    //
    // populate dicPassedEventDetail here for refresh case
    //
    self.dicPassedEventDetail = self.arrEventsForSegment[[self.index integerValue]];
    
    //
    // reload grid...
    //
    [self viewWillLayoutSubviews];
    [self segmentChange:self.segGalleryDetail];

    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    @try {
        
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    @try {
        [super viewDidAppear:animated];
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Gallery Controller Delegate

-(void)galleryMediaSelect:(MemreasDetailGallery*)gallery selectedMedia:(NSDictionary*)selectedDic andSelectedIndexPath:(NSIndexPath*)indexPath{
    
    @try {
        self.segGalleryDetail.selectedSegmentIndex = 1;
        [self segmentChange:self.segGalleryDetail];
        self.vcDetail.selectedIndexPath = indexPath;
        self.vcDetail.collectionComment.media_id = [selectedDic valueForKeyPath:@"event_media_id.text"];
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
}


#pragma mark
#pragma mark Segment Controller Delegate

+ (bool) fetchIsGallery
{
    if (lastSegmentGalleryOrDetail == 0) {
        return true;
    }
    return false;
}


- (IBAction)segmentChange:(UISegmentedControl*)segmentController {
    
    
    @try {
        
        [self.vcDetail.view removeFromSuperview];
        [self.vcGallery.view removeFromSuperview];
        [self.vcLocation.view removeFromSuperview];
        
        switch (segmentController.selectedSegmentIndex) {
            case 0: {
                //
                // Gallery
                //
                if (!self.vcGallery) {
                    self.vcGallery = [[UIStoryboard storyboardWithName:@"MemreasDetail" bundle:nil] instantiateViewControllerWithIdentifier:@"MemreasGallery"];
                }
                self.vcGallery.collectionComment.media_id = nil;
                self.vcGallery.selectedSegmentIndex = self.selectedSegmentIndex;
                self.vcGallery.dicPassedEventDetail = self.dicPassedEventDetail;
                self.vcGallery.headerView.selectedSegmentIndex = self.selectedSegmentIndex;
                self.vcGallery.headerView.selectedEventIndex = self.vcDetail.selectedIndexPath.item;
                [self.vcGallery.headerView setDicPassedEventDetail:self.vcDetail.dicPassedEventDetail];
                //CGRect rect = CGRectMake(0, 0, self.viewContainer.frame.size.width, self.viewContainer.frame.size.height);
                //self.vcGallery.view.frame = rect;
                //self.vcGallery.view.frame = self.viewContainer.frame;
                
                [self addChildViewController:self.vcGallery];
                [self.viewContainer addSubview:self.vcGallery.view];
                
                //set to viewContainer constraints
                [Helper setNSLayoutConstraintsParentMargins:self.viewContainer withChildView:self.vcGallery.view andWithSpacing:0];
                
                //
                // Store for location closure
                //
                lastSegmentGalleryOrDetail = segmentController.selectedSegmentIndex;
                break;
            }
                
            case 1: {
                //
                // Detail
                //
                if (!self.vcDetail) {
                    self.vcDetail = [[UIStoryboard storyboardWithName:@"MemreasDetail" bundle:nil] instantiateViewControllerWithIdentifier:@"MemreasDetailDetail"];
                }
                
                // use this var to close location view
                lastSegmentGalleryOrDetail = segmentController.selectedSegmentIndex;
                
                self.vcDetail.selectedSegmentIndex = self.selectedSegmentIndex;
                self.vcDetail.dicPassedEventDetail = self.dicPassedEventDetail;
                CGRect rect = CGRectMake(0, 0, self.viewContainer.frame.size.width, self.viewContainer.frame.size.height);
                self.vcDetail.view.frame = rect;
                [self addChildViewController:self.vcDetail];
                [self.viewContainer addSubview:self.vcDetail.view];
                
                //
                // Store for location closure
                //
                lastSegmentGalleryOrDetail = segmentController.selectedSegmentIndex;
                break;
                
            }
            case 2: {
                //
                // Location
                //
                [self loadLocation:YES];
                // don't set lastSegmentGalleryOrDetail since we want to return to prior view
                break;
            }
                
            default:
                break;
        }
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

- (void)enterOrExitFullScreenMode:(NSUInteger)index {
    @try {
        if (!self.fullScreenView) {
            self.fullScreenView = [self.storyboard
                                   instantiateViewControllerWithIdentifier:@"FullScreenView"];
            
            [self addChildViewController:self.fullScreenView];
            [self.view addSubview:self.fullScreenView.view];
            
            self.fullScreenView.view.alpha = 0;
            
            self.navigationController.navigationBarHidden = YES;
            self.tabBarController.tabBar.hidden = YES;
            self.fullScreenView.index = index;
            
            // Pass parameter
            [UIView beginAnimations:nil context:NULL];
            [UIView animateWithDuration:1.5
                             animations:^{
                                 self.fullScreenView.view.alpha = 1;
                                 
                             }
                             completion:^(BOOL finished) {
                                 self.fullScreenView.index = index;
                             }];
            
            [UIView commitAnimations];
            
        } else {
            self.navigationController.navigationBarHidden = NO;
            self.tabBarController.tabBar.hidden = NO;
            [UIView beginAnimations:nil context:NULL];
            [UIView animateWithDuration:0.7
                             animations:^{
                                 self.fullScreenView.view.alpha = 0;
                             }
                             completion:^(BOOL finished) {
                                 [self.fullScreenView removeFromParentViewController];
                                 [self.fullScreenView.view removeFromSuperview];
                                 self.fullScreenView = nil;
                             }];
            [UIView commitAnimations];
        }
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

#pragma mark
#pragma mark  IB Actions

- (IBAction)addCommentClicked:(id)sender {
    [self loadRecording:true];
}

- (IBAction)addMediaClicked:(id)sender {
    @try {
        [self performSegueWithIdentifier:@"segueMemreasAddMedia" sender:nil];
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}
- (IBAction)addFriendClicked:(id)sender {
    @try {
        [self performSegueWithIdentifier:@"segueMemreasAddFriends"
                                  sender:nil];
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

#pragma mark
#pragma mark Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    @try {
        
        if([segue.identifier isEqualToString:@"segueMemreasAddMedia"]){
            AddMemreasShareMediaSelectViewController* addMemreasShareMediaSelectViewController = segue.destinationViewController;
            addMemreasShareMediaSelectViewController.eventId = [self.dicPassedEventDetail valueForKeyPath:@"event_id.text"];
            
        } else if([segue.identifier isEqualToString:@"segueMemreasAddFriends"]){
            AddMemreasShareFriendsSelectViewController* addMemreasShareFriendsSelectViewController = segue.destinationViewController;
            addMemreasShareFriendsSelectViewController.eventId = [self.dicPassedEventDetail valueForKeyPath:@"event_id.text"];
        }
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
}



#pragma mark
#pragma mark UITextfield Delegate methods

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    @try {
        [self.view endEditing:YES];
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

#pragma mark
#pragma mark Custom Methods

- (NSMutableDictionary*)getLocationInformationFromMetaData:(NSString*)metadata {
    @try {
        NSMutableDictionary* location_ = nil;
        NSArray* aryWords = [metadata componentsSeparatedByString:@"\""];
        //    ALog(@"%@", aryWords);
        
        double latIndex = [aryWords indexOfObject:@"latitude"];
        double lngIndex = [aryWords indexOfObject:@"longitude"];
        double addrIndex = [aryWords indexOfObject:@"address"];
        
        if (latIndex > 0 && (latIndex + 2) < aryWords.count && lngIndex > 0 &&
            (lngIndex + 2) < aryWords.count) {
            double lat = [[aryWords objectAtIndex:(latIndex + 2)] doubleValue];
            double lng = [[aryWords objectAtIndex:(lngIndex + 2)] doubleValue];
            NSString* address = [aryWords objectAtIndex:(addrIndex + 2)];
            
            location_ = [NSMutableDictionary
                         dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithDouble:lat], @"latitude",
                         [NSNumber numberWithDouble:lat], @"latitudeBackup",
                         [NSNumber numberWithDouble:lng], @"longitude",
                         [NSNumber numberWithDouble:lng], @"longitudeBackup", address,
                         @"address", address, @"addressBackup", nil];
        } else {
            location_ = [NSMutableDictionary
                         dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithDouble:0], @"latitude",
                         [NSNumber numberWithDouble:0], @"latitudeBackup",
                         [NSNumber numberWithDouble:0], @"longitude",
                         [NSNumber numberWithDouble:0], @"longitudeBackup", @"",
                         @"address", @"", @"addressBackup", nil];
        }
        
        return location_;
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}



#pragma mark
#pragma mark MBProgressHUD Hide/Show Method

- (void)startActivity:(NSString*)message {
    @try {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

- (void)stopActivity {
    @try {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

#pragma mark - AddFriends Delgate
//
// AddMemreasShareFrindsSelectViewController calls this method
//
- (void) handleFriendsMessaging {
    //
    // determine the counts for sms and memreas
    //
    self.shareCreatorInstance = [ShareCreator sharedInstance];
    [self.shareCreatorInstance determineMemreasFriendsCount];
    
    
    //
    // SMS
    //
    if (self.shareCreatorInstance.countSelectedFriendsSMS > 0) {
        
        NSMutableArray* recipients = [self.shareCreatorInstance fetchSMSRecipients:self.shareCreatorInstance.eventId];
        if(![MFMessageComposeViewController canSendText]) {
            [Helper showMessageFade:self.view withMessage:@"sms not supported by device" andWithHideAfterDelay:3];
            
        } else {
            if (recipients.count > 0) {
                MFMessageComposeViewController *messageComposerVC = [[MFMessageComposeViewController alloc] init];
                NSString *struserName =   [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"userDetail.ownerName"];
                NSString *message =[NSString stringWithFormat: @"@%@ invites you to !%@! %@%@",struserName, self.shareCreatorInstance.name, [MyConstant getSMS_URL], self.shareCreatorInstance.eventId];
                ALog(@"recipients :: %@", recipients);
                messageComposerVC.recipients = recipients;
                [messageComposerVC setBody:message];
                
                messageComposerVC.messageComposeDelegate = self;
                [self presentViewController:messageComposerVC animated:NO completion:nil];
            }
            
        }
    }
    
    //
    // memreas
    //
    if (self.shareCreatorInstance.countSelectedFriendsMemreasOrEmails > 0) {
        [self.shareCreatorInstance addfriendtoeventWSCall:self.shareCreatorInstance.eventId
                                      withNotificationKey:MEMREAS_ADDFRIENDS_SELECT_RESULT_NOTIFICATION];
    }
}

- (void) handleAddMemreasFriendsToEventCompleted:(NSNotification*)notification {
    NSDictionary* resultTags = [notification userInfo];
    NSString* status = [resultTags objectForKey:@"status"];
    NSString* message = [resultTags objectForKey:@"message"];
    
    
    if ([[status lowercaseString] isEqualToString:@"success"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //
            // Initiate refresh of events...
            //
            NSMutableDictionary* resultInfo = [NSMutableDictionary dictionary];
            [resultInfo addValueToDictionary:@"Success" andKeyIs:@"status"];
            [resultInfo addValueToDictionary:@"updates submitted..." andKeyIs:@"message"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:MEMREAS_SELECT_RESULT_REFRESH_NOTIFICATION
                                                                object:self
                                                              userInfo:resultInfo];
            
            //
            // event created, media and friends added so move to memreas
            //
            [self.shareCreatorInstance resetSharedInstance];
            
        });
    } else {
        //
        // event created, media and friends added so move to memreas
        //
        [Helper showMessageFade:self.view withMessage:message andWithHideAfterDelay:3];
    }
}

- (void)messageComposeViewController: (MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result)
    {
        case MessageComposeResultCancelled:
            ALog(@"Cancelled");
            break;
        case MessageComposeResultFailed:
            ALog(@"Failed");
            break;
        case MessageComposeResultSent:
            ALog(@"Sent");
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:true completion:nil];
}



#pragma mark - Location VC methods

- (void)loadLocation:(BOOL)load {
    @try {
        
        if (load) {
            
            // build gallery
            ALog(@"vcLocation : self.dicPassedEventDetail --> %@", self.dicPassedEventDetail);
            bool hasArray = NO;
            if([[self.dicPassedEventDetail objectForKey: @"event_media"] isKindOfClass:[NSArray class]]){
                //Is array
                hasArray = YES;
            }
            NSArray* arrEventMedia = [self.dicPassedEventDetail objectForKey:@"event_media"];
            NSMutableArray* arrEventMediaBuilder = [[NSMutableArray alloc] init];
            GalleryManager* sharedGalleryInstance = [GalleryManager sharedGalleryInstance];
            for (int i = 0; i < [arrEventMedia count]; i++) {
                //for (id obj in arrEventMedia) {
                NSDictionary* dict;
                if (!hasArray) {
                    dict = (NSDictionary*) arrEventMedia;
                    //it's single entry so end loop
                    i = (int)[arrEventMedia count];
                } else {
                    dict = (NSDictionary*) arrEventMedia[i];
                }
                ALog(@"key: %@   value:%@", @"event_media_name",  [[dict objectForKey:@"event_media_name"] objectForKey:@"text"]);
                MediaItem* mediaItem = [sharedGalleryInstance.dictGallery objectForKey:[[dict objectForKey:@"event_media_name"] objectForKey:@"text"]];
                if (mediaItem == nil) {
                    //
                    // item must not be in gallery and is friends / public item so create a media item holder
                    //
                    mediaItem = [[MediaItem alloc] initForFriendsOrPublicMemreas:[[dict objectForKey:@"event_media_448x306"] objectForKey:@"text"]
                                                           withEvent_media_79x80:[[dict objectForKey:@"event_media_79x80"] objectForKey:@"text"]
                                                           andWithEvent_media_id:[[dict objectForKey:@"event_media_id"] objectForKey:@"text"]
                                                         andWithEvent_media_name:[[dict objectForKey:@"event_media_name"] objectForKey:@"text"]
                                                  andWithEvent_media_s3_url_path:[[dict objectForKey:@"event_media_s3_url_path"] objectForKey:@"text"]
                                              andWithEvent_media_s3_url_web_path:[[dict objectForKey:@"event_media_s3_url_web_path"] objectForKey:@"text"]
                                         andWithEvent_media_s3file_download_path:[[dict objectForKey:@"event_media_s3file_download_path"] objectForKey:@"text"]
                                              andWithEvent_media_s3file_location:[[dict objectForKey:@"event_media_s3file_location"] objectForKey:@"text"]
                                                         andWithEvent_media_type:[[dict objectForKey:@"event_media_type"] objectForKey:@"text"]
                                                          andWithEvent_media_url:[[dict objectForKey:@"event_media_url"] objectForKey:@"text"]
                                                      andWithEvent_media_url_hls:[[dict objectForKey:@"event_media_url_hls"] objectForKey:@"text"]
                                                      andWithEvent_media_url_web:[[dict objectForKey:@"event_media_url_web"] objectForKey:@"text"]
                                 ];
                    
                }
                [arrEventMediaBuilder addObject:mediaItem];
            }
            
            ALog(@"FINISHED - CHECK OUTPUT");
            
            if (arrEventMediaBuilder.count > 0) {
                //self.vcLocation = [[UIStoryboard storyboardWithName:@"MemreasDetail" bundle:nil] instantiateViewControllerWithIdentifier:@"vcLocation"];
                self.vcLocation = [[UIStoryboard storyboardWithName:@"MemreasDetail" bundle:nil]instantiateViewControllerWithIdentifier:@"MemreasLocationVC"];
                
                [self addChildViewController:self.vcLocation];
                self.vcLocation.view.alpha = 0;
                [self.view addSubview:self.vcLocation.view];
                
                // Pass parameter
                self.vcLocation.selectedSegmentIndex = self.vcGallery.selectedSegmentIndex;
                self.vcLocation.dicPassedEventDetail = self.vcGallery.dicPassedEventDetail;
                self.vcLocation.headerView.dicPassedEventDetail = self.vcGallery.dicPassedEventDetail;
                self.vcLocation.arrMemreasEventGallery = arrEventMediaBuilder;
                
                [UIView beginAnimations:nil context:NULL];
                self.vcLocation.view.alpha = 1;
                [UIView commitAnimations];
            } else {
                [Helper showMessageFade:self.view withMessage:@"no media to display location..." andWithHideAfterDelay:2];
            }
            
        } else {
            
            [UIView beginAnimations:nil context:NULL];
            [UIView animateWithDuration:0.5
                             animations:^{
                                 self.vcLocation.view.alpha = 0;
                                 
                             }
                             completion:^(BOOL finished) {
                                 [self.vcLocation removeFromParentViewController];
                                 [self.vcLocation.view removeFromSuperview];
                                 self.vcLocation = nil;
                                 
                                 //
                                 // Return back to Gallery level
                                 //
                                 self.segGalleryDetail.selectedSegmentIndex = lastSegmentGalleryOrDetail;
                                 
                                 [self segmentChange:self.segGalleryDetail];
                             }];
            [UIView commitAnimations];
        }
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

//
// Recording View Controller Delegates
//
#pragma mark - Recording VC delegates

- (void)loadRecording:(BOOL)load {
    [self loadRecording:load anddicEventMediaDetail:nil];
}


- (void)loadRecording:(BOOL)load anddicEventMediaDetail:(NSDictionary*)dicPassed {
    @try {
        
        if (load) {
            self.recordingVC = [[UIStoryboard storyboardWithName:@"Universal" bundle:nil]
                                instantiateViewControllerWithIdentifier:@"RecordingVC"];
            [self addChildViewController:self.recordingVC];
            self.recordingVC.view.alpha = 0;
            [self.view addSubview:self.recordingVC.view];
            
            // Pass parameter
            if (dicPassed) {
                self.recordingVC.dicPassedEventDetail = dicPassed;
            }else{
                self.recordingVC.dicPassedEventDetail = @{ @"event_id" : [self.dicPassedEventDetail valueForKeyPath:@"event_id.text"]};
            }
            
            [UIView beginAnimations:nil context:NULL];
            self.recordingVC.view.alpha = 1;
            [UIView commitAnimations];
            
        } else {
            
            [UIView beginAnimations:nil context:NULL];
            [UIView animateWithDuration:0.5
                             animations:^{
                                 self.recordingVC.view.alpha = 0;
                                 
                             }
                             completion:^(BOOL finished) {
                                 [self.recordingVC removeFromParentViewController];
                                 [self.recordingVC.view removeFromSuperview];
                                 self.recordingVC = nil;
                                 
                                 if (self.segGalleryDetail.selectedSegmentIndex == 0) {
                                 } else {
                                 }
                                 
                             }];
            [UIView commitAnimations];
        }
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}


- (void) showComments:(BOOL)display withComments:(NSArray*) arrComments andWithEventDetail:(NSDictionary*) dictEvent {
    @try {
        
        if (display) {
            
            self.commentVC = [[UIStoryboard storyboardWithName:@"MemreasDetail" bundle:nil]
                              instantiateViewControllerWithIdentifier:@"CommentVC"];
            self.commentVC.arrComment = arrComments;
            self.commentVC.dicEventNSDictionary = dictEvent;
            [self addChildViewController:self.commentVC];
            self.commentVC.view.alpha = 0;
            [self.view addSubview:self.commentVC.view];
            
            // comments already set ...
            
            [UIView beginAnimations:nil context:NULL];
            self.commentVC.view.alpha = 1;
            [UIView commitAnimations];
            
        } else {
            
            [UIView beginAnimations:nil context:NULL];
            [UIView animateWithDuration:0.5
                             animations:^{
                                 self.commentVC.view.alpha = 0;
                                 
                             }
                             completion:^(BOOL finished) {
                                 [self.commentVC removeFromParentViewController];
                                 [self.commentVC.view removeFromSuperview];
                                 self.commentVC = nil;
                             }];
            [UIView commitAnimations];
        }
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

#pragma mark
#pragma mark GAdBannerViewDelegate Method

- (void)adViewDidReceiveAd:(GADBannerView *) bannerView {
    //ALog(@"ad was received...");
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    //ALog(@"didFailToReceiveAdWithError: %@...", error.localizedFailureReason);
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView {
    //ALog(@"adViewWillPresentScreen...");
}
- (void)adViewDidDismissScreen:(GADBannerView *)bannerView {
    //ALog(@"adViewDidDismissScreen...");
}
- (void)adViewWillDismissScreen:(GADBannerView *)bannerView {
    //ALog(@"adViewWillDismissScreen...");
}


@end




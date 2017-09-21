#import "MemreasMainViewController.h"
#import "XMLParser.h"
#import "MyConstant.h"
#import "MyView.h"
#import "MemreasDetailViewController.h"
#import "WebServiceParser.h"
#import "WebServices.h"
#import "MasterViewController.h"
#import "MyConstant.h"
#import "Util.h"
#import "CellComment.h"
#import "XMLReader.h"
#import "MIOSDeviceDetails.h"
#import "SettingButton.h"
#import "Helper.h"
#import "XMLGenerator.h"
#import "WebServices.h"
#import "MWebServiceHandler.h"
#import "GalleryManager.h"
#import "GridCell.h"
#import "UIViewController+Logout.h"
#import "UIImageView+AFNetworking.h"

typedef enum MemreasType{
    ME,
    FRIENDS,
    PUBLIC
} MemreasType;

// static var to track type from enum above
static MemreasType memreasType;
static bool isPublic = NO;

@implementation MemreasMainViewController

+ (bool) fetchIsPublic
{
    return isPublic;
}


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
    @try {
        
        [SettingButton addRightBarButtonAsNotificationInViewController:self];
        [SettingButton addLeftSearchInViewController:self];
        
        
        //
        // Google Banner View
        //
        self.bannerView.adUnitID = [[MIOSDeviceDetails sharedInstance] getAdUnitId];
        self.bannerView.rootViewController = self;
        [self.bannerView loadRequest:[GADRequest request]];
        
        me_f = 1;
        friends_f = 0;
        public_f = 0;
        
        
        self.arrEvents = [[NSMutableArray alloc] init];
        self.arrFriendEvents = [[NSMutableArray alloc] init];
        self.arrPublicEvents = [[NSMutableArray alloc] init];
        self.operations = [[NSMutableArray alloc] init];
        
        // Set up segment Control
        self.segMeFriendPublic.layer.cornerRadius = 5.0;
        self.segMeFriendPublic.layer.masksToBounds = true;
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys: [UIColor lightGrayColor], NSForegroundColorAttributeName, nil];
        [self.segMeFriendPublic setTitleTextAttributes:attributes forState:UIControlStateNormal];
        [self.segMeFriendPublic setTitleTextAttributes:attributes forState:UIControlStateSelected];
        
        [self segmentChanged:self.segMeFriendPublic];
        
        self.segMeFriendPublic.selectedSegmentIndex = SelectedSegmentForMemreas;
        
        
        /**
         * Set Observer for addcomment web service to refresh
         */
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleRefreshMemreasMWS:)
                                                     name:ADDCOMMENT_RESULT_NOTIFICATION
                                                   object:self];
        
        
        /**
         * Set Observer for add media web service to refresh
         */
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleRefreshMemreasMWS:)
                                                     name:MEMREAS_SELECT_RESULT_REFRESH_NOTIFICATION
                                                   object:nil];
        
        /**
         * Set Observers for viewevents...
         */
        
        //ME
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(objectParsed_ViewEvent:)
                                                     name:MEMREAS_MAIN_VIEW_EVENTS_ME_RESPONSE
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(objectListFriendForEvent:)
                                                     name:MEMREAS_MAIN_VIEW_EVENTS_FRIENDS_RESPONSE
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(objectListPublicForEvent:)
                                                     name:MEMREAS_MAIN_VIEW_EVENTS_PUBLIC_RESPONSE
                                                   object:nil];
        
        
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
}


-(void)handleRefreshMemreasMWS:(NSNotification *)notification
{
    //
    // Comment refresh
    //
    @try {
        NSDictionary* resultTags = [notification userInfo];
        NSString* status = @"";
        status = [resultTags objectForKey:@"status"];
        if ([[status lowercaseString] isEqualToString:@"success"]) {
            [Helper showMessageFade:self.view withMessage:@"loading updates..." andWithHideAfterDelay:2];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self viewEventWSCall];
        });
        ALog(@"[self viewEventWSCall] called...");
        
    } @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    
    
    @try {
        
        [super viewWillAppear:animated];
        
        if (IS_IPAD) {
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"memreas"] forBarMetrics:UIBarMetricsDefault];
        }else{
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_Memreas"] forBarMetrics:UIBarMetricsDefault];
        }
        
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    @try {
        [super viewDidAppear:animated];
        [self segmentChanged:self.segMeFriendPublic];
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
}

#pragma mark
#pragma mark Segment Controller Delegate

- (IBAction)segmentChanged:(UISegmentedControl*)segmentController
{
    @try {
        
        NSInteger selectedIndex = segmentController.selectedSegmentIndex;
        me_f       = 0;
        friends_f  = 0;
        public_f   = 0;
        
        
        switch (selectedIndex) {
            case 0:
                memreasType = ME;
                isPublic = NO;
                me_f = 1;
                self.meView.hidden = NO;
                self.friendsView.hidden = YES;
                self.publicView.hidden = YES;
                [self loadMeUICollectionViewController:YES];
                [self loadPublicUITableViewController:NO];
                [self loadFriendUITableViewController:NO];
                break;
            case 1:
                memreasType = FRIENDS;
                isPublic = NO;
                friends_f = 1;
                self.meView.hidden = YES;
                self.friendsView.hidden = NO;
                self.publicView.hidden = YES;
                [self loadMeUICollectionViewController:NO];
                [self loadFriendUITableViewController:YES];
                [self loadPublicUITableViewController:NO];
                break;
                
            case 2:
                memreasType = PUBLIC;
                isPublic = YES;
                public_f = 1;
                self.meView.hidden = YES;
                self.friendsView.hidden = YES;
                self.publicView.hidden = NO;
                [self loadMeUICollectionViewController:NO];
                [self loadFriendUITableViewController:NO];
                [self loadPublicUITableViewController:YES];
                break;
                
            default:
                break;
        }
        
        [self viewEventWSCall];
        //        [self viewEvents];
        
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
}


#pragma  mark
#pragma  mark Webservice call & parsing
- (void)viewEventWSCall {
    @try {
        
        /**
         * Send Request and Parse Response...
         *  Note: wsHandler calls
         */
        
        MWebServiceHandler* wsHandler = [[MWebServiceHandler alloc] init];
        switch (self.segMeFriendPublic.selectedSegmentIndex) {
            case 0:{
                
                /**
                 * Send Request and Parse Response...
                 *  Note: wsHandler calls
                 */
                if ([Util checkInternetConnection]) {
                    /**
                     * Use XMLGenerator...
                     */
                    lastViewEventsRequestXML = [XMLGenerator generateViewEventsXML:me_f andWithIsFriendEvent:friends_f andWithIsPublicEvent:public_f];
                    
                    ALog(@"Request:- %@", lastViewEventsRequestXML);
                    
                    /**
                     * Use WebServices Request Generator
                     */
                    NSMutableURLRequest* request =
                    [WebServices generateWebServiceRequest:lastViewEventsRequestXML
                                                    action:VIEWEVENTS];
                    // ALog(@"NSMutableRequest request ----> %@", request);
                    
                    /**
                     * Send Request and handle Resonse via Notification
                     */
                    [wsHandler fetchServerResponse:request action:VIEWEVENTS key:MEMREAS_MAIN_VIEW_EVENTS_ME_RESPONSE];
                }
                
                if (!self.arrEvents.count) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD showHUDAddedTo:self.view animated:YES ];
                    });
                }
                break;
            }
                
            case 1:{
                
                /**
                 * Send Request and Parse Response...
                 *  Note: wsHandler calls
                 */
                if ([Util checkInternetConnection]) {
                    /**
                     * Use XMLGenerator...
                     */
                    lastViewEventsRequestXML = [XMLGenerator generateViewEventsXML:me_f andWithIsFriendEvent:friends_f andWithIsPublicEvent:public_f];
                    
                    ALog(@"Request:- %@", lastViewEventsRequestXML);
                    
                    /**
                     * Use WebServices Request Generator
                     */
                    NSMutableURLRequest* request =
                    [WebServices generateWebServiceRequest:lastViewEventsRequestXML
                                                    action:VIEWEVENTS];
                    // ALog(@"NSMutableRequest request ----> %@", request);
                    
                    /**
                     * Send Request and handle Resonse via Notification
                     */
                    [wsHandler fetchServerResponse:request action:VIEWEVENTS key:MEMREAS_MAIN_VIEW_EVENTS_FRIENDS_RESPONSE];
                }
                
                if (!self.arrFriendEvents.count) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD showHUDAddedTo:self.view animated:YES ];
                    });
                }
                
                break;
            }
                
            case 2:{
                /**
                 * Send Request and Parse Response...
                 *  Note: wsHandler calls
                 */
                if ([Util checkInternetConnection]) {
                    /**
                     * Use XMLGenerator...
                     */
                    lastViewEventsRequestXML = [XMLGenerator generateViewEventsXML:me_f andWithIsFriendEvent:friends_f andWithIsPublicEvent:public_f];
                    
                    ALog(@"Request:- %@", lastViewEventsRequestXML);
                    
                    /**
                     * Use WebServices Request Generator
                     */
                    NSMutableURLRequest* request =
                    [WebServices generateWebServiceRequest:lastViewEventsRequestXML
                                                    action:VIEWEVENTS];
                    
                    ALog(@"NSMutableRequest request ----> %@", request);
                    
                    /**
                     * Send Request and handle Resonse via Notification
                     */
                    [wsHandler fetchServerResponse:request action:VIEWEVENTS key:MEMREAS_MAIN_VIEW_EVENTS_PUBLIC_RESPONSE];
                }
                
                if (!self.arrPublicEvents.count) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD showHUDAddedTo:self.view animated:YES ];
                    });
                }
                break;
            }
            default:
                break;
        }
        
        
    } @catch (NSException* exception) {
        ALog(@"object type = %@", [[GalleryManager class] debugDescription]);
        ALog(@"%@", exception);
    }
}


-(void)objectParsed_ViewEvent:(NSNotification *)notification
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    });
    NSDictionary *dictionary = notification.userInfo;
    
    @try {
        [self checkForLogOut:[dictionary description]];
        if([[dictionary valueForKeyPath:@"viewevents.events.event"]  isKindOfClass:[NSArray class]]){
            self.arrEvents =[dictionary valueForKeyPath:@"viewevents.events.event"];
        }
        else if([dictionary valueForKeyPath:@"viewevents.events.event"]  != nil)
        {
            self.arrEvents = (NSMutableArray*) @[[dictionary valueForKeyPath:@"viewevents.events.event"]];
        }
        // update the grid
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.meUICollectionViewController.collectionView reloadData];
        });
        
    } @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
}



-(void)objectListFriendForEvent:(NSNotification *)notification
{
    @try {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        });
        
        NSDictionary *dictionary = notification.userInfo;
        
        if([[dictionary valueForKeyPath:@"viewevents.friends.friend"]  isKindOfClass:[NSArray class]]){
            self.arrFriendEvents =[dictionary valueForKeyPath:@"viewevents.friends.friend"];
        }
        else if([dictionary valueForKeyPath:@"viewevents.friends.friend"]  != nil)
        {
            self.arrFriendEvents = (NSMutableArray*) @[[dictionary valueForKeyPath:@"viewevents.friends.friend"]];
        }
        
        dictionary = nil;
        
    }
    
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
}
-(void)objectListPublicForEvent:(NSNotification *)notification
{
    @try {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        });
        
        NSDictionary *dictionary = notification.userInfo;
        
        if([[dictionary valueForKeyPath:@"viewevents.events.event"]  isKindOfClass:[NSArray class]]){
            self.arrPublicEvents =[dictionary valueForKeyPath:@"viewevents.events.event"];
        }
        else if([dictionary valueForKeyPath:@"viewevents.events.event"]  != nil)
        {
            self.arrPublicEvents = (NSMutableArray*) @[[dictionary valueForKeyPath:@"viewevents.events.event"]];
        }
        dictionary = nil;
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
}

#pragma mark
#pragma mark Button Touch Handling
- (void)CellTap:(NSIndexPath*)indexPath andDictionary:(NSDictionary*)dicPas
{
    
    @try {
        
        NSDictionary *dic;
        
        if (dicPas) {
            dic = dicPas;
        }else{
            //
            // handle in prepare segue
            //
            dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:indexPath.row], @"index", nil];
            //[dic addValueToDictionary:[NSNumber numberWithInteger:indexPath.row] andKeyIs:@"index"];
        }
        
        [self performSegueWithIdentifier:@"segueMemreasDetail" sender:dic];
        
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
}

- (IBAction)btnAddClicked:(id)sender
{
    [self.tabBarController setSelectedIndex:2];
}

#pragma mark
#pragma mark Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)dic{
    
    @try {
        if([segue.identifier isEqualToString:@"segueMemreasDetail"] || [segue.identifier isEqualToString:@"segueMemreasDetailSelf"]){
            
            MemreasDetailViewController *detail = (MemreasDetailViewController *)[segue destinationViewController];
            NSNumber* index = [dic objectForKey:@"index"];
            detail.index = index;
            detail.selectedSegmentIndex = self.segMeFriendPublic.selectedSegmentIndex;
            switch (self.segMeFriendPublic.selectedSegmentIndex) {
                case 0:{
                    detail.dicPassedEventDetail = self.arrEvents[[index integerValue]];
                    detail.arrEventsForSegment = self.arrEvents;
                    break;
                }
                    
                case 1:{
                    detail.dicPassedEventDetail = self.arrFriendEvents[[index integerValue]];
                    detail.arrEventsForSegment = self.arrFriendEvents;
                    break;
                }
                    
                case 2:{
                    detail.dicPassedEventDetail = self.arrPublicEvents[[index integerValue]];
                    detail.arrEventsForSegment = self.arrPublicEvents;
                    break;
                    
                }
                    
            }
        }
    }
    
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
}

#pragma mark
#pragma mark Load Me, Friends, Public ViewControllers
-(void)loadMeUICollectionViewController:(BOOL)load{
    
    @try {
        if (load && self.meUICollectionViewController) {
            [self.meUICollectionViewController.collectionView reloadData];
            return; // Do nothing it is Reload data from server request.
        }
        
        if (load) {
            
            self.meUICollectionViewController =[self.storyboard instantiateViewControllerWithIdentifier:@"MeUICollectionViewController"];
         
            [self addChildViewController:self.meUICollectionViewController];
            [self.meUICollectionViewController didMoveToParentViewController:self];
            [self.meView addSubview:self.meUICollectionViewController.view];
            self.meUICollectionViewController.view.alpha=0;
            
            //set constraints
            [Helper setNSLayoutConstraintsParentMargins:self.meView withChildView:self.meUICollectionViewController.view andWithSpacing:0];
            
            [UIView beginAnimations:nil context:NULL];
            self.meUICollectionViewController.view.alpha=1;
            [UIView commitAnimations];
            [self.meUICollectionViewController.collectionView reloadData];

            
        }else{
            
            [UIView beginAnimations:nil context:NULL];
            [UIView animateWithDuration:0.5 animations:^{
                self.meUICollectionViewController.view.alpha=0;
                
            } completion:^(BOOL finished) {
                [self.meUICollectionViewController removeFromParentViewController];
                [self.meUICollectionViewController.view removeFromSuperview];
                self.meUICollectionViewController =nil;
                
            }];
            [UIView commitAnimations];
        }
        
        
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
}


-(void)loadFriendUITableViewController:(BOOL)load{
    
    @try {
        if (load && self.friendUITableViewController) {
            [self.friendUITableViewController.tableView reloadData];
            return; // Do nothing it is Reload data from server request.
        }
        
        if (load) {
            
            self.friendUITableViewController =[self.storyboard instantiateViewControllerWithIdentifier:@"FriendUITableViewController"];
            
            [self addChildViewController:self.friendUITableViewController];
            [self.friendUITableViewController didMoveToParentViewController:self];
            [self.friendsView addSubview:self.friendUITableViewController.view];
            self.friendUITableViewController.view.alpha=0;
            
            //set constraints
            [Helper setNSLayoutConstraintsParentMargins:self.friendsView withChildView:self.friendUITableViewController.view andWithSpacing:0];

            [UIView beginAnimations:nil context:NULL];
            self.friendUITableViewController.view.alpha=1;
            [UIView commitAnimations];
            
            [self.friendUITableViewController.tableView reloadData];

            
        }else{
            
            [UIView beginAnimations:nil context:NULL];
            [UIView animateWithDuration:0.5 animations:^{
                self.friendUITableViewController.view.alpha=0;
                
            } completion:^(BOOL finished) {
                [self.friendUITableViewController removeFromParentViewController];
                [self.friendUITableViewController.view removeFromSuperview];
                self.friendUITableViewController =nil;
                
            }];
            [UIView commitAnimations];
        }
        
        
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
}

-(void)loadPublicUITableViewController:(BOOL)load{
    
    @try {
        if (load && self.publicUITableViewController) {
            [self.publicUITableViewController.tableView reloadData];
            return; // Do nothing it is Reload data from server request.
        }
        
        if (load ) {
            
            self.publicUITableViewController =[self.storyboard instantiateViewControllerWithIdentifier:@"PublicTableUIViewController"];
            
            [self addChildViewController:self.publicUITableViewController];
            [self.publicUITableViewController didMoveToParentViewController:self];
            [self.publicView addSubview:self.publicUITableViewController.view];
            self.publicUITableViewController.view.alpha=0;
            
            //set constraints
            [Helper setNSLayoutConstraintsParentMargins:self.friendsView withChildView:self.publicUITableViewController.view andWithSpacing:0];
            
            [UIView beginAnimations:nil context:NULL];
            self.publicUITableViewController.view.alpha=1;
            [UIView commitAnimations];
        }else{
            [UIView beginAnimations:nil context:NULL];
            [UIView animateWithDuration:0.5 animations:^{
                self.publicUITableViewController.view.alpha=0;
                
            } completion:^(BOOL finished) {
                [self.publicUITableViewController removeFromParentViewController];
                [self.publicUITableViewController.view removeFromSuperview];
                self.publicUITableViewController =nil;
                
            }];
            [UIView commitAnimations];
        }
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
}

#pragma mark
#pragma mark set arrays

-(void)setArrEvents:(NSMutableArray *)arrEvents{
    
    _arrEvents = arrEvents;
    [self.meUICollectionViewController.collectionView reloadData];
    
}

-(void)setArrFriendEvents:(NSMutableArray *)arrFriendEvents{
    
    _arrFriendEvents = arrFriendEvents;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.friendUITableViewController.tableView reloadData];
    });
    
}

-(void)setArrPublicEvents:(NSMutableArray *)arrPublicEvents{
    
    _arrPublicEvents = arrPublicEvents;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.publicUITableViewController.tableView reloadData];
    });
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


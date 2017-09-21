#define IS_IPHONE_5 (fabs((double) [[UIScreen mainScreen] bounds].size.height-(double)568)<DBL_EPSILON )

#import "AddMediaViewController.h"
#import "MyConstant.h"
#import "WebServiceParser.h"
#import "WebServices.h"
#import "Util.h"
#import "GridCell.h"
#import "XMLParser.h"
#import "ELCAsset.h"
#import "MyConstant.h"
#import "MyView.h"
#import "AudioRecording.h"
#import "RecordingVC.h"
#import "NSString+SrtingUrlValidation.h"

@interface AddMediaViewController (){
    AppDelegate *appDelegate;
    WebServiceParser *wspListPhotos;
}


@property (nonatomic,strong)RecordingVC *recordingVC;

//

@property (nonatomic) BOOL isDone;

// Array For server and Local Images

@property (nonatomic, strong) NSMutableArray * selectedAssetsImages;
@property (nonatomic, strong) NSMutableArray *elcAssets;

@property (nonatomic, retain) NSMutableArray  *arrOnlyServerImages;
@property (nonatomic, retain) NSMutableArray *selectedServerImages;

// Collection View

@property (nonatomic, weak) IBOutlet UICollectionView * collectionView;


@end

@implementation AddMediaViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
//    ALog(@"%s", __PRETTY_FUNCTION__);
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(NSMutableArray *)selectedAssetsImages{
//    ALog(@"%s", __PRETTY_FUNCTION__);
    if (!_selectedAssetsImages) {
        _selectedAssetsImages=[NSMutableArray array];
    }
    return _selectedAssetsImages;
}

-(NSMutableArray *)arrOnlyServerImages{
//    ALog(@"%s", __PRETTY_FUNCTION__);
    if (!_arrOnlyServerImages) {
        _arrOnlyServerImages=[NSMutableArray array];
    }
    return _arrOnlyServerImages;
    
}


-(NSMutableArray *)elcAssets{
//    ALog(@"%s", __PRETTY_FUNCTION__);
    if (!_elcAssets) {
        _elcAssets=[NSMutableArray array];
    }
    return _elcAssets;
    
}

- (void)viewDidLoad
{
//    ALog(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    
    [self getGalleryPhotos];
    [self listallMedia];
    [self.navigationItem setHidesBackButton:YES];
    
    appDelegate.forAssetSize = 0;
    appDelegate.currentView = @"AddMediaViewController";
    
    if (isFirstTimeMedia == YES) {
        isFirstTimeMedia = NO;
    }
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    isFirstTimeMedia = YES;
    isAudioCommentAdded = NO;
}


-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    if (IS_IPAD) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"select gallery photos"] forBarMetrics:UIBarMetricsDefault];
    }else{
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_select_gallery_photo"] forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)didReceiveMemoryWarning
{
//    ALog(@"%s", __PRETTY_FUNCTION__);
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Button Handling methods

- (IBAction)btnSoundClicked:(id)sender {
//    ALog(@"%s", __PRETTY_FUNCTION__);
    
    [self loadRecording:YES];
    
}


-(void)loadRecording:(BOOL)load{
    
    
    int h = self.view.frame.size.height;
    int w = self.view.frame.size.width;
    int yX = 44;
    
    if (load) {
        
        self.recordingVC =[self.storyboard instantiateViewControllerWithIdentifier:@"RecordingVC"];
        self.recordingVC.view.frame = CGRectMake (0, yX, w, h);
        [self addChildViewController:self.recordingVC];
        self.recordingVC.view.alpha=0;
        [self.view addSubview:self.recordingVC.view];
        
        // Pass parameter
        
        if ([[self.arrOnlyServerImages firstObject] valueForKey:@"media_id"]) {
            self.recordingVC.dicPassedEventDetail = @{@"event_id": self.eventId ,@"media_id":[[self.arrOnlyServerImages firstObject] valueForKey:@"media_id"]};
            
        }else{
            self.recordingVC.dicPassedEventDetail = @{@"event_id": self.eventId ,@"media_id":self.eventId};
        }
        
        
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

#pragma  mark
#pragma  mark Webservice call & parsing

-(void)listallMedia{
    
//    ALog(@"%s", __PRETTY_FUNCTION__);
    
    @try {
        
        self.viewLoading.hidden = NO;
        //ADDTOXMLGENERATOR
        NSUserDefaults *defaultUser = [NSUserDefaults standardUserDefaults];
        NSString *userId = [defaultUser stringForKey:@"UserId"];
        NSString *urlString = [NSString stringWithFormat:@"%@?action=listallmedia&sid=%@",[MyConstant getWEB_SERVICE_URL],SID];
        
        NSString *request = @"xml=<xml>";
        request = [request stringByAppendingFormat:@"<listallmedia><user_id>%@</user_id><event_id>0</event_id><device_id>%@</device_id><page>1</page><limit>1000</limit></listallmedia>",userId,appDelegate.deviceUuid];
        request = [request stringByAppendingString:@"</xml>"];
//        ALog(@"Request:- %@",request);
        
        if([Util checkInternetConnection]){
            
            if (!parser) {
                parser = [[XMLParser alloc] init];
            }
            //        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [parser parseWithURL:urlString soapMessage:request startTag:@"media" completedSelector:@selector(objectParesed_ListAllMedia:) handler:self];
        }
        
        
    }
    
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }

 }

- (void) objectParesed_ListAllMedia:(NSDictionary *)dictionary
{
    
//    ALog(@"%s", __PRETTY_FUNCTION__);
    _viewLoading.hidden = YES;

//    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    NSArray *arr = [dictionary objectForKey:@"objects"];
    
    for (NSDictionary *dic in arr) {
        NSString *type = [NSString stringWithFormat:@"%@",[dic valueForKey:@"type"]];
        if(![type isEqualToString:@"audio"])
            [self.arrOnlyServerImages addObject:dic];
    }

    [self.collectionView reloadData];
    _viewLoading.hidden = YES;
}



-(NSMutableArray *)selectedServerImages{

    if (!_selectedServerImages) {
        _selectedServerImages = [[NSMutableArray alloc]init];
        
    }return _selectedServerImages;
    
}   

#pragma mark
#pragma mark UIButton Touch Event Methods

- (IBAction)btnPhotoClicked:(UIButton*)btn {
    
    @try {
        
        int tag = (int)btn.tag;
        
        NSDictionary*dicTemp =[self.arrOnlyServerImages objectAtIndex:(tag)];
        if ([self.selectedServerImages containsObject:dicTemp]) {
            
            [btn setBackgroundImage:nil forState:UIControlStateNormal];
            [self.selectedServerImages removeObject:dicTemp];
            
        } else{
            
            [btn setBackgroundImage:[UIImage imageNamed:@"Overlay"] forState:UIControlStateNormal];
            [self.selectedServerImages addObject:dicTemp];
            
        }
        
    }
    
    @catch (NSException *exception) {
        
        ALog(@"%@",exception);
        
    }
    
    
}

- (IBAction)assetSelect:(UIButton*)btn {
    
    
    @try {
        
        int tag = (int)btn.tag;
        
        ALAsset*dicTemp =[self.elcAssets objectAtIndex:(tag)];
        
        if ([self.selectedAssetsImages containsObject:dicTemp]) {
            
            [btn setBackgroundImage:nil forState:UIControlStateNormal];
            [self.selectedAssetsImages removeObject:dicTemp];
            
        } else{
            
            [btn setBackgroundImage:[UIImage imageNamed:@"Overlay"] forState:UIControlStateNormal];
            [self.selectedAssetsImages addObject:dicTemp];
            
        }
        
    }
    
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
    
}
-(void)getGalleryPhotos{
    
    @try {
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
                           {
                               if (group == nil)
                               {
                                   return;
                               }
                               [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                                   if(asset == nil){
                                       return ;
                                   }
                                   [self.elcAssets addObject:asset];
                               }];
                               [self.collectionView reloadData];
                           };
                           
                           void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
                               ALog(@"A problem occured %@", [error description]);
                           };
                           
                           if (library == nil) {
                               library = [[ALAssetsLibrary alloc] init];
                           }
                           [library enumerateGroupsWithTypes:ALAssetsGroupAll
                                                  usingBlock:assetGroupEnumerator
                                                failureBlock:assetGroupEnumberatorFailure];
                       });
        
    }
    
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
}



#pragma mark - CollectionView DataSource.

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
//    ALog(@"%s", __PRETTY_FUNCTION__);
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    ALog(@"%s", __PRETTY_FUNCTION__);
    return self.arrOnlyServerImages.count+self.elcAssets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    ALog(@"%s", __PRETTY_FUNCTION__);
    
    if (self.arrOnlyServerImages.count>0 && self.arrOnlyServerImages.count>indexPath.item) {
        
        GridCell *cell = (GridCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ServerCell" forIndexPath:indexPath];
        MyView *myView =cell.myView;
        myView.imgPhoto.layer.cornerRadius =10;
        myView.imgPhoto.layer.masksToBounds =YES;
        myView.imgPhoto.clipsToBounds =YES;
        
        NSDictionary*dicTemp =[self.arrOnlyServerImages objectAtIndex:indexPath.item] ;

        
        myView.imgPhoto.layer.borderWidth =2;
        
        myView.imgPhoto.layer.borderColor = [UIColor clearColor].CGColor;
        
        [myView setBackgroundColor:[UIColor clearColor]];
        myView.tag = 50000+indexPath.item;
        [myView.btnPhoto setTag:indexPath.item];
        
        [myView.btnPhoto setBackgroundImage:nil forState:UIControlStateNormal];
        [myView.btnPhoto setBackgroundImage:nil forState:UIControlStateSelected];
        myView.btnPhoto.layer.cornerRadius =10;
        myView.btnPhoto.layer.masksToBounds =YES;
        myView.btnPhoto.clipsToBounds =YES;

        myView.btnPhoto.selected = NO;
        [myView.btnPhoto addTarget:self action:@selector(btnPhotoClicked:) forControlEvents:UIControlEventTouchUpInside];
       
        if ([self.selectedServerImages containsObject:dicTemp]) {
            [myView.btnPhoto setBackgroundImage:[UIImage imageNamed:@"Overlay"] forState:UIControlStateNormal];
        }else{
            [myView.btnPhoto setBackgroundImage:nil forState:UIControlStateNormal];
        }
        
        NSString *type = [NSString stringWithFormat:@"%@",[dicTemp valueForKey:@"type"]];
        if([type isEqualToString:@"video"]){
            [myView.btnPhoto setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateNormal];
        }else{
            [myView.btnPhoto setImage:nil forState:UIControlStateNormal];
        }
        
        
        NSString *thumbURl = [[NSString stringWithFormat:@"%@",[[dicTemp valueForKey:@"media_url_79x80"] convertToJsonWithFirstObject]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
//        if(thumbURl == nil || [myView.imageURL isEqualToString:@"(null)"] || thumbURl.length == 0){
//            thumbURl = [[NSString stringWithFormat:@"%@",[[dicTemp valueForKey:@"main_media_url"] convertToJsonWithFirstObject]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        }
        
        //[myView.imgPhoto setImageWithURL:[NSURL URLWithString:thumbURl] placeholderImage:[UIImage imageNamed:@"gallery_img"]];
        [myView.imgPhoto setImage:[UIImage imageNamed:@"gallery_img"]];
        
        
        if ([dicTemp[@"isDownloaded"] boolValue]) {
            
            myView.imgPhoto.layer.borderColor =[UIColor greenColor].CGColor;
            
        }else{
            
            [self isInGallery:dicTemp[@"media_name"] withCell:cell andServer:YES];
            
        }
        
        
        
        
        return cell;
        
    }else{
        
        
        GridCell *cell = (GridCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"LocalCell" forIndexPath:indexPath];
        
        ALAsset *result = [self.elcAssets objectAtIndex:(indexPath.item - self.arrOnlyServerImages.count)];
        
        cell.imgPhoto.layer.cornerRadius =10;
        cell.imgPhoto.layer.masksToBounds =YES;
        cell.imgPhoto.clipsToBounds =YES;
        
        cell.imgPhoto.layer.borderWidth =2;
        cell.imgPhoto.layer.borderColor = [UIColor redColor].CGColor;
        
        [cell.imgPhoto setImage:[UIImage imageWithCGImage:[result thumbnail]]];
        
        
        if([result valueForProperty:ALAssetPropertyType] == ALAssetTypeVideo){
            [cell.imgVideo setImage:[UIImage imageNamed:@"video_play"]];
        }else{
            [cell.imgVideo setImage:nil];
        }
        
        cell. btnPhoto.tag =  (indexPath.item - self.arrOnlyServerImages.count);
        [cell.btnPhoto  addTarget:self action:@selector(assetSelect:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([self.selectedAssetsImages containsObject:result]) {
            [cell.btnPhoto setBackgroundImage:[UIImage imageNamed:@"Overlay"] forState:UIControlStateNormal];
        }else{
            [cell.btnPhoto setBackgroundImage:nil forState:UIControlStateNormal];
        }
       return cell;
    }
}



-(BOOL)isInGallery:(NSString *)mediaFileName withCell:(GridCell*)cell andServer:(BOOL)server{
    
    @try {
        
        __block BOOL imageExits = NO;
        NSArray *arr = [mediaFileName componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
        if(arr.count>1){
            NSString *assetURL = [NSString stringWithFormat:@"assets-library://asset/asset.%@?id=%@&ext=%@",arr[1],arr[0],arr[1]];
            //@"assets-library://asset/asset.jpg?id=423F1D9B-D717-46CD-9E24-4A51985E9FF6&ext=jpg";
            [library assetForURL:[NSURL URLWithString:assetURL] resultBlock:^(ALAsset *asset) {
                
                @autoreleasepool {
                    
                    if(asset){
                        imageExits = YES;
                        MyView *myView =cell.myView;
                        myView.imgPhoto.layer.borderColor = [UIColor greenColor].CGColor;
                        
                    }else{
                        MyView *myView =cell.myView;
                        myView.imgPhoto.layer.borderColor = [UIColor yellowColor].CGColor;
                        
                    }
                    
                }
                
            } failureBlock:^(NSError *error) {
                //            ALog(@"Error %@", error);
                MyView *myView =cell.myView;
                myView.imgPhoto.layer.borderColor = [UIColor yellowColor].CGColor;
                
                
            }];
        }
        return imageExits;
        
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
}



-(void)viewDidLayoutSubviews{

    [super viewDidLayoutSubviews];
//    [scrForm setContentSize:CGSizeMake(320, 500) ];


}

#pragma mark
#pragma mark UITextfield Delegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    
//    ALog(@"%s", __PRETTY_FUNCTION__);
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDelay:0.1];
    [UIView setAnimationDuration:0.2];
    self.view.transform = CGAffineTransformMakeTranslation(0, -200);

    [UIView commitAnimations];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{

    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDelay:0.1];
    [UIView setAnimationDuration:0.2];

    self.view.transform = CGAffineTransformIdentity;

    
    [UIView commitAnimations];
}
#pragma  mark
#pragma  mark Segue method

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
//    ALog(@"%s", __PRETTY_FUNCTION__);
    if([segue.identifier isEqualToString:@"segueAddFriends"]){
    }
}



#pragma mark
#pragma mark GADBannerViewDelegate Method
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

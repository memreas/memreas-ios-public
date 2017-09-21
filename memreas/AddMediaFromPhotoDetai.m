#import "AddMediaFromPhotoDetai.h"
#import "NSString+SrtingUrlValidation.h"
#import "MyConstant.h"
#import "WebServiceParser.h"
#import "WebServices.h"
#import "Util.h"
#import "GridCell.h"
#import "RecordingVC.h"
#import "XMLParser.h"
#import "ELCAsset.h"
#import "MyConstant.h"
#import "MyView.h"
#import "MIOSDeviceDetails.h"
#import "AudioRecording.h"

@interface AddMediaFromPhotoDetai ()
{
    AppDelegate *appDelegate;
}


@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (nonatomic,strong)RecordingVC *recordingVC;


@end

@implementation AddMediaFromPhotoDetai


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)setArrOnlyServerImages:(NSMutableArray *)arrOnlyServerImages{
    
    _arrOnlyServerImages = arrOnlyServerImages;
    [self.collectionView reloadData];
    
}


-(NSMutableArray *)assetAry{
    
    if (!_assetAry) {
        _assetAry = [[NSMutableArray alloc]init];
        
    }return _assetAry;
    
}

-(NSMutableArray *)serverFileUploadArray{
    
    if (!_serverFileUploadArray) {
        _serverFileUploadArray = [[NSMutableArray alloc] init];
    }return _serverFileUploadArray;
    
}

-(NSMutableArray *)selectedAssetsImages{
    
    
    if (!_selectedAssetsImages) {
        _selectedAssetsImages = [[NSMutableArray alloc] init];
        
    }return _selectedAssetsImages;
    
}

- (void)viewDidLoad{
//    ALog(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    @try {
        
        //
        // Google Banner View
        //
        self.bannerView.adUnitID = [[MIOSDeviceDetails sharedInstance] getAdUnitId];
        self.bannerView.rootViewController = self;
        [self.bannerView loadRequest:[GADRequest request]];
        
        
        self.navigationItem.hidesBackButton = YES;
        
        if (IS_IPAD) {
            
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"select gallery photos"] forBarMetrics:UIBarMetricsDefault];
        
        }else{
            
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_select_gallery_photo"] forBarMetrics:UIBarMetricsDefault];
        }

        
        [self getGalleryPhotos];
        [self listallMedia];
        
    }
    
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
    @try {
        
    }
    
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {

    [super viewDidUnload];
    
}

#pragma mark
#pragma mark Button Method

- (IBAction)btnOkClicked:(id)sender {
    
    @try {
        [txtAddComment resignFirstResponder];
        for (NSObject *file in self.serverFileUploadArray) {
            //
            // Migrate to Queue Controller
            //
            ALog(@"AddMediaFromPhototDetail - - (IBAction)btnOkClicked:(id)sender - migrate to QueueController and Gallery Manager");
        }
        
        [self.serverFileUploadArray removeAllObjects];
        int i=0;
        
        for(ALAsset *asset in self.selectedAssetsImages)
        {
            
            NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
            [workingDictionary setObject:[ asset valueForProperty:ALAssetPropertyType] forKey:@"UIImagePickerControllerMediaType"];
            [workingDictionary setObject:[UIImage imageWithCGImage:[[ asset defaultRepresentation] fullScreenImage]] forKey:@"UIImagePickerControllerOriginalImage"];
            [workingDictionary setObject:[[ asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[ asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:@"UIImagePickerControllerReferenceURL"];
            
            [workingDictionary setObject:[NSNumber numberWithInt:i] forKey:@"mediaTag"];
            i++;
            CLLocation *location = [ asset valueForProperty:ALAssetPropertyLocation];
            NSMutableDictionary *dicLocation = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [NSNumber numberWithDouble:location.coordinate.latitude],   @"latitude",
                                                [NSNumber numberWithDouble:location.coordinate.longitude],  @"longitude",
                                                nil];
            
            [workingDictionary setObject:dicLocation forKey:@"location"];
            //
            // Migrate to Queue Controller
            //
            ALog(@"AddMediaFromPhototDetail - - (IBAction)btnOkClicked:(id)sender - migrate to QueueController and Gallery Manager");
            
        }
        
        
        [self.assetAry removeAllObjects];
        
        self.assetAry =nil;
        self.selectedAssetsImages=nil;
        self.serverFileUploadArray=nil;
        self.arrOnlyServerImages=nil;
        
        
        if(![txtAddComment.text isEqualToString:@""]){
            appDelegate.comment = txtAddComment.text;
            appDelegate.isTextComment = YES;
        }
        
        //        [self.tabBarController setSelectedIndex:1];
        [self.navigationController popViewControllerAnimated:1];
        
    }
    
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
}


- (IBAction)btnCancelClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

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
            self.recordingVC.dicPassedEventDetail = @{@"event_id": self.eventId ,@"media_id":@""};
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


#pragma mark
#pragma mark Custom Methods


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
                                   [self.assetAry addObject:asset];
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


#pragma mark
#pragma mark UITextfield Delegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    [scrForm setContentSize:CGSizeMake(320, 600)];
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDelay:0.1];
    [UIView setAnimationDuration:0.2];
//    [scrForm setContentOffset:CGPointMake(scrForm.contentOffset.x, textField.frame.origin.y + 200)];
    
    self.view.transform = CGAffineTransformMakeTranslation(0, -140);
    
    [UIView commitAnimations];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    CGRect rect = self.view.frame;
    [scrForm setContentSize:CGSizeMake(320, rect.size.height)];
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDelay:0.1];
    [UIView setAnimationDuration:0.2];
//    [scrForm setContentOffset:CGPointMake(scrForm.contentOffset.x, 0)];
    
    self.view.transform = CGAffineTransformIdentity;

    [UIView commitAnimations];
}



#pragma mark
#pragma mark UIButton Touch Event Methods

- (IBAction)btnPhotoClicked:(UIButton*)btn {
    
    
    @try {
        
        int tag = (int)btn.tag;
        
        NSDictionary*dicTemp =[self.arrOnlyServerImages objectAtIndex:(tag)];
        
        if ([self.serverFileUploadArray containsObject:dicTemp]) {
            
            [btn setBackgroundImage:nil forState:UIControlStateNormal];
            [self.serverFileUploadArray removeObject:dicTemp];
            
        } else{
            
            [btn setBackgroundImage:[UIImage imageNamed:@"Overlay"] forState:UIControlStateNormal];
            [self.serverFileUploadArray addObject:dicTemp];
            
        }
        
    }
    
    @catch (NSException *exception) {
        
        ALog(@"%@",exception);
        
    }
    
    
}

- (IBAction)assetSelect:(UIButton*)btn {
    
    
    @try {
        
        int tag = (int)btn.tag;
        ALAsset*dicTemp =[self.assetAry objectAtIndex:(tag)];
        
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

#pragma mark
#pragma mark Check Image on Server

-(void)listallMedia{
    
    // From viewWillapper
    @try {
        //ADDTOXMLGENERATOR
        NSUserDefaults *defaultUser = [NSUserDefaults standardUserDefaults];
        NSString *userId = [defaultUser stringForKey:@"UserId"];
        NSString *request = @"xml=<xml>";
        request = [request stringByAppendingFormat:@"<listallmedia><user_id>%@</user_id><event_id>0</event_id><device_id>%@</device_id><page>1</page><limit>1000</limit></listallmedia>",userId,appDelegate.deviceUuid];
        request = [request stringByAppendingString:@"</xml>"];
        
        if([Util checkInternetConnection]){
            NSString *urlString = [NSString stringWithFormat:@"%@?action=listallmedia&sid=%@",[MyConstant getWEB_SERVICE_URL],SID];
            XMLParser *parser = [[XMLParser alloc] init];
            [parser parseWithURL:urlString soapMessage:request startTag:@"media" completedSelector:@selector(objectParesed_ListAllMedia:) handler:self];
            [self.loadingView setHidden:NO];
        }
    }
    
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
}

- (void) objectParesed_ListAllMedia:(NSMutableDictionary *)dictionary{
    
    @try {
        
        [self.loadingView setHidden:1];
        NSArray *arr = [dictionary objectForKey:@"objects"];
        NSMutableArray*img = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dic in arr) {
            NSString *type = [NSString stringWithFormat:@"%@",[dic valueForKey:@"type"]];
            if(![type isEqualToString:@"audio"])
                [img addObject:dic];
        }
        
        self.arrOnlyServerImages =img;
        arr=nil;
        
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
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

#pragma mark
#pragma mark back button

- (IBAction)backTap:(id)sender {
    
    [self.navigationController popViewControllerAnimated:1];
    
}

#pragma mark
#pragma mark Collection View Method

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arrOnlyServerImages.count+self.assetAry.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.arrOnlyServerImages.count>0 && self.arrOnlyServerImages.count>indexPath.item) {
        
        GridCell *cell = (GridCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ServerCell" forIndexPath:indexPath];
        
        NSDictionary*dicTemp =[self.arrOnlyServerImages objectAtIndex:indexPath.item] ;
        [cell.btnPhoto addTarget:self action:@selector(btnPhotoClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        
        if ([self.serverFileUploadArray containsObject:dicTemp]) {
            [cell.btnPhoto setBackgroundImage:[UIImage imageNamed:@"Overlay"] forState:UIControlStateNormal];
        }else{
            [cell.btnPhoto setBackgroundImage:nil forState:UIControlStateNormal];
        }
        
           cell.imgPhoto.layer.borderWidth =2;
        cell.imgPhoto.layer.cornerRadius =10;
        cell.imgPhoto.layer.masksToBounds =YES;
        cell.imgPhoto.clipsToBounds =YES;
        
        cell.imgPhoto.layer.borderColor = [UIColor clearColor].CGColor;

        
        
        
        if ([dicTemp[@"isDownloaded"] boolValue]) {
            
            cell.imgPhoto.layer.borderColor =[UIColor greenColor].CGColor;
            
        }else{
            
            [self isInGallery:dicTemp[@"media_name"] withCell:cell andServer:YES];
            
        }
        [cell.btnPhoto setTag:indexPath.item];
        
        NSString *type = [NSString stringWithFormat:@"%@",[dicTemp valueForKey:@"type"]];
        if([type isEqualToString:@"video"]){
            [cell.imgVideo setImage:[UIImage imageNamed:@"video_play"]];
        }else{
            [cell.imgVideo setImage:nil ];
        }
        
        NSString *thumbURl = [[NSString stringWithFormat:@"%@",[[dicTemp valueForKey:@"media_url_79x80"]  convertToJsonWithFirstObject]  ] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [cell.imgPhoto setImage:[UIImage imageNamed:@"gallery_img"]];
        
        dicTemp=nil;
        return cell;
        
        
    }else{
        
        GridCell *cell = (GridCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"LocalCell" forIndexPath:indexPath];
        
        ALAsset *result = [self.assetAry objectAtIndex:(indexPath.item - self.arrOnlyServerImages.count)];
        
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
                        
                        cell.imgPhoto.layer.borderColor = [UIColor greenColor].CGColor;
                        
                    }else{
                        
                        cell.imgPhoto.layer.borderColor = [UIColor yellowColor].CGColor;
                        
                    }

                }
                
                           } failureBlock:^(NSError *error) {
                //            ALog(@"Error %@", error);
                cell.imgPhoto.layer.borderColor = [UIColor yellowColor].CGColor;

            }];
        }
        return imageExits;
        
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
}




@end

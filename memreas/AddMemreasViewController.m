/**
 * Copyright (C) 2015 memreas llc. - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */
//
//  AddMemreasViewController.m
//

#import "AddMemreasViewController.h"
#import "AddMediaViewController.h"
#import "MyConstant.h"
#import "RootViewControllerAppDelegate.h"
#import "Util.h"
#import "AddMemreasCollectionCell.h"
#import "FacebookFriendsCell.h"
#import "FriendsCell.h"
//#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Twitter/Twitter.h>
#import "MemreasDetailCell.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "AudioRecording.h"
#import "Helper.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>

#import "MapLocationPicker.h"

#define METERS_PER_MILE 10000
#define METERS_PER_MILE_DETAIL 15000


//@interface AddMemreasViewController ()<CLLocationManagerDelegate,MapPickLocation>{
 /*
    RootViewControllerAppDelegate *appDelegate;
    BOOL bCompletedToLoadLocalImages;
    ALAssetsLibrary *library;
    UITextField * activeField;
    ACAccount * myFaceBookAccount_;
    ACAccount * myAccount_;
    NSMutableString *paramString_;
    AudioRecording *audioRecording;
    UIButton *btnSound;
    float longtt,latt;
    CLLocationManager *locationManager;
    GMSMapView *googlemap;
  
    CLPlacemark *placemark;
 */
//}


/*
@property (strong, nonatomic) CLLocation *selectedLocation;
@property (strong, nonatomic) NSMutableDictionary *placeDictionary;
@property (nonatomic, strong) NSMutableArray * arraySections;
@property (nonatomic, strong) NSMutableDictionary * imageDownloadsInProgress;
@property (nonatomic, strong) NSMutableDictionary * dicForSubmit;
@property (nonatomic, strong) NSMutableArray * facebookFriends;
@property (nonatomic, strong) NSMutableArray * twitterFriends;
@property (nonatomic, strong) NSMutableArray * localFriendList;
@property (nonatomic, readonly) NSArray * selectedFacebookFriend;
@property (nonatomic, readonly) NSArray * selectedTwitterFriend;
@property (nonatomic, readonly) NSArray * selectedLocalFriend;
@property (nonatomic, strong) CLGeocoder *geocoder;


@property(nonatomic) BOOL isDone;

@property (nonatomic,strong) MapLocationPicker*mapPicker;

*/

//@end

@implementation AddMemreasViewController

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/


#pragma mark
#pragma mark Location Picker Start
/*
-(MapLocationPicker *)mapPicker{
    
    if (!_mapPicker) {
        _mapPicker = [self.storyboard instantiateViewControllerWithIdentifier:@"MapLocationPicker"];
        _mapPicker.delegate=self;
    }return _mapPicker;
    
}


-(void)mapPicker:(MapLocationPicker *)mapPicker didFinishWithPickLocation:(NSString *)address andLocation:(CLLocation *)location{

    
    if (address) {
        self.txtLocations.text = address;
        self.selectedLocation = location;
    }else{
    // Do nothing
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView animateWithDuration:0.3 animations:^{
        int width =    self.view.frame.size.width/2;
        self.mapPicker.view.frame = CGRectMake (width-160, -600, 320, 470);

    } completion:^(BOOL finished) {
        [self.mapPicker removeFromParentViewController];
        [self.mapPicker.view removeFromSuperview];
        self.mapPicker =nil;
        
    }];
    [UIView commitAnimations];

}


- (void) initPopUpView {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    int width =    self.view.frame.size.width/2;

    self.mapPicker.view.frame = CGRectMake (width-160, 47, 320, 470);
    [UIView commitAnimations];
}

- (void) animatePopUpShow{
    
    int width =    self.view.frame.size.width/2;
    self.mapPicker.view.frame = CGRectMake (width-160, -600, 320, 470);
    [self.view addSubview:self.mapPicker.view];
    [self addChildViewController:self.mapPicker];
    self.mapPicker.searchText = self.txtLocations.text;
    self.mapPicker.selectedLocation= self.selectedLocation;
    [self initPopUpView];

}

#pragma mark
#pragma mark Location Picker End


#pragma mark - Objects Initialization. 

-(NSMutableArray *)arraySections{
    if (!_arraySections) {
        _arraySections = [NSMutableArray arrayWithArray:@[
                                                          [@{valueT: @"memreas details",    SelectedValue:@"1"} mutableCopy],
                                                          [@{valueT: @"media",              SelectedValue:@"0"} mutableCopy],
                                                          [@{valueT: @"friends",            SelectedValue:@"0"} mutableCopy],
                                                          [@{valueT: @"Facebook",           SelectedValue:@"0"} mutableCopy],
                                                          [@{valueT: @"Twitter",            SelectedValue:@"0"} mutableCopy],
                                                          [@{valueT: @"Local",              SelectedValue:@"0"} mutableCopy],
                                                          [@{valueT: @"",                   SelectedValue:@"0"} mutableCopy],
                                                          
                                                          ]];
    }
    return _arraySections;
}


-(NSMutableDictionary *)imageDownloadsInProgress{
    if (!_imageDownloadsInProgress) {
        _imageDownloadsInProgress=[NSMutableDictionary dictionary];
    }
    return _imageDownloadsInProgress;
    
}




-(CLGeocoder *)geocoder{

    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc]init];
    }return _geocoder;

}

-(NSMutableArray *)imageListingArray{
    if (!_imageListingArray) {
        _imageListingArray=[NSMutableArray array];
    }
    return _imageListingArray;
}


-(NSMutableArray *)assetAry{
    
    if (!_assetAry) {
        _assetAry = [[NSMutableArray alloc]init];
    }return _assetAry;
    
}


-(NSMutableArray *)selectedFileDownload{
    
    if (!_selectedFileDownload) {
        _selectedFileDownload = [[NSMutableArray alloc]init];
    }return _selectedFileDownload;

}

-(NSMutableArray *)selectedAssetsImages{
    if (!_selectedAssetsImages) {
        _selectedAssetsImages = [[NSMutableArray alloc]init];
    }return _selectedAssetsImages;
    
}


-(NSMutableDictionary *)dicForSubmit{
    if (!_dicForSubmit) {
        _dicForSubmit=[NSMutableDictionary dictionary];
    }
    return _dicForSubmit;
}

-(NSMutableArray *)facebookFriends{
    if (!_facebookFriends) {
        _facebookFriends = [[NSMutableArray alloc]init];
    }return _facebookFriends;

}

-(NSMutableArray *)twitterFriends{
    if (!_twitterFriends) {
        _twitterFriends = [[NSMutableArray alloc]init];
    }return _twitterFriends;
    
}

-(NSMutableArray *)localFriendList{
    if (!_localFriendList) {
        _localFriendList = [[NSMutableArray alloc]init];
    }return _localFriendList;
    
}

-(NSArray *)selectedFacebookFriend{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(selected ==  %@)", @"1"];
    return [self.facebookFriends filteredArrayUsingPredicate:predicate];
}

-(NSArray *)selectedTwitterFriend{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(selected ==  %@)", @"1"];
    return [self.twitterFriends filteredArrayUsingPredicate:predicate];
}

-(NSArray *)selectedLocalFriend{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(selected ==  %@)", @"1"];
    return [self.localFriendList filteredArrayUsingPredicate:predicate];
    
}

- (void)viewDidLoad
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    
    
    @try {
        
        self.txtLocations.text = @"";
        
        [SettingButton addRightBarButtonAsNotificationInViewController:self];
        [SettingButton addLeftSearchInViewController:self];
        
        
        self.viewDatepicker.hidden = YES;
        
        NSDate *now = [NSDate date];
        self.pckrDate.date = now;
        self.pckrDate.minimumDate = now;
        [self.pckrDate addTarget:self action:@selector(pickerValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        [self initLocationForMap];

    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    
 }

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self becomeFirstResponder];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    appDelegate = (RootViewControllerAppDelegate *)[UIApplication sharedApplication].delegate;
    
        appDelegate.isAddMemreasDetail = NO;
        _txtDate.text = @"";
        _txtFrom.text = @"";
        _txtName.text = @"";
        _txtSelfDestruct.text = @"";
        _txtTo.text = @"";
        _btnFriendsCanAdd.selected= YES;
        _btnFriendsCanPost.selected = YES;
        _btnPublic.selected = NO;
        UIImage *img = [UIImage imageNamed:@"unchecked_white"];
        [_btnPublic setImage:img forState:UIControlStateNormal];
        img = nil;

        UIImage *img1 = [UIImage imageNamed:@"checked_white"];
        [_btnFriendsCanAdd setImage:img1 forState:UIControlStateNormal];
        [_btnFriendsCanPost setImage:img1 forState:UIControlStateNormal];
        img1 = nil;
    
    if(parser == nil){
        parser = [[XMLParser alloc] init];
    }
        
    if (IS_IPAD) {
        
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"memreas"] forBarMetrics:UIBarMetricsDefault];
        
    }else{
        
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_Memreas"] forBarMetrics:UIBarMetricsDefault];
    }

    [self registerForKeyboardNotifications];
    [self.tableView  scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:1];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

//    [parser removeAllObject];
    [self removeFormKeyboardNotifications];
    
}




#pragma mark
#pragma mark UITextfield Delegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}



-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    @try {
        
        if(_txtDate == textField || _txtFrom == textField || _txtTo == textField || _txtSelfDestruct == textField)
        {
            _tempTxt = textField;
            
            [_txtName resignFirstResponder];
            [_txtLocations resignFirstResponder];
            
            CGPoint centerPoint = textField.center;
            CGPoint pointInView = [self.view convertPoint:centerPoint fromView:textField.superview];
            if (pointInView.y > self.view.frame.size.height/2 ) {
                
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.3];
                [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, centerPoint.y - 80)];
                [UIView commitAnimations];
            }
            
            [self addDatePicker];
            
            // Ronak memreas task 7 Start Self destructive issue solving.
            
            if (self.txtFrom == textField || self.txtTo == textField) {
                self.txtSelfDestruct.text=@"";
            }
            
            if (self.txtFrom == textField ) {
                
                if(self.txtDate.text.length>0){
                    NSDate *date = [self getDateFromString:self.txtDate.text];
                    self.pckrDate.minimumDate = date;
                }else{
                    self.pckrDate.minimumDate = [NSDate date];
                    self.pckrDate.date = [NSDate date];
                }
                
            }
            
            if ( self.txtDate == textField) {
                self.pckrDate.minimumDate = [NSDate date];
                self.pckrDate.date = [NSDate date];
            }
            
            if (self.txtTo == textField) {
                
                if(self.txtFrom.text.length>0){
                    NSDate *date = [self getDateFromString:self.txtFrom.text];
                    self.pckrDate.minimumDate = date;
                }else{
                    self.pckrDate.minimumDate = [NSDate date];
                    self.pckrDate.date = [NSDate date];
                }
                
            }
            
            if (self.txtSelfDestruct == textField) {
                
                if(self.txtFrom.text.length >0 && self.txtTo.text.length>0 ){
                    
                    NSDate *date = [self getDateFromString:self.txtTo.text];
                    self.pckrDate.minimumDate = date;
                    
                }else if (self.txtFrom.text.length >0){
                    
                    NSDate *date = [self getDateFromString:self.txtFrom.text];
                    self.pckrDate.minimumDate = date;
                    
                }else if (self.txtTo.text.length >0){
                    
                    NSDate *date = [self getDateFromString:self.txtTo.text];
                    self.pckrDate.minimumDate = date;
                }else{
                    self.pckrDate.minimumDate = [NSDate date];
                }
                
            }
            
            if(textField.text.length == 0)
            {
                [self pickerValueChanged:self.pckrDate];
            } else
            {
                NSDate *date = [self getDateFromString:textField.text];
                self.pckrDate.date = date;
                [self pickerValueChanged:self.pckrDate];
                
            }
            
            // Ronak memreas task 7 END Self destructive issue solving.
            
            return NO;
        }
        else if (textField == self.txtLocations)
        {

            [self animatePopUpShow];
            return NO;


        }
        else
        {
            self.viewDatepicker.hidden = YES;
        }
        
        
    }
    
    @catch (NSException *exception) {
        
        NSLog(@"%@",exception);
        
    }
    
    return YES;
}




-(void)textFieldDidEndEditing:(UITextField *)textField{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
//    [_scrAddMediaForm setContentOffset:CGPointMake(_scrAddMediaForm.contentOffset.x, 0)];
    [UIView commitAnimations];
    activeField = nil;

}

- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (NSDate *) getDateFromString:(NSString *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd-MM-yyyy";
    
    return [dateFormatter dateFromString:date];
}

- (NSString *) getDateStringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd-MM-yyyy";
    
    return [dateFormatter stringFromDate:date];
}

#pragma mark
#pragma mark Picker  methods

-(void)pickerValueChanged:(id)sender
{
    if(_tempTxt == _txtTo)
    {
        NSDate *from = [self getDateFromString:_txtFrom.text];
        NSDate *to = _pckrDate.date;
        
        if([from compare:to] == NSOrderedDescending)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please select the correct date." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            
            [alertView show];
            
            _tempTxt.text = [self getDateStringFromDate:from];
            _pckrDate.date = from;
        }
        else
        {
            _tempTxt.text = [self getDateStringFromDate:to];
        }
    }
    else if(_tempTxt == _txtFrom)
    {
        NSDate *from = _pckrDate.date;
        NSDate *to = [self getDateFromString:_txtTo.text];
        
        if([from compare:to] == NSOrderedDescending)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please select the correct date." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            _tempTxt.text = [self getDateStringFromDate:to];
            _pckrDate.date = to;
        }
        else
        {
            _tempTxt.text = [self getDateStringFromDate:from];
        }
    }
    else
    {
        _tempTxt.text = [self getDateStringFromDate:_pckrDate.date];
    }
}

#pragma mark
#pragma mark Button Handling methods

- (IBAction)btnDoneClicked:(id)sender
{
    _viewDatepicker.hidden = YES;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
//    [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, 0)];
    [UIView commitAnimations];
}
- (IBAction)brnDoneClicked:(id)sender {
           self.isDone =1;
        [self btnNextClicked:nil];
}

- (IBAction)btnCheckboxClicked:(id)sender {
    UIImage *img;
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        img = [UIImage imageNamed:@"unchecked_white"];
        btn.selected = NO;
        if(btn == _btnSelfDestruct){
            _txtSelfDestruct.hidden = YES;
            _txtSelfDestruct.text = @"";
        }

    } else{
        img = [UIImage imageNamed:@"checked_white"];
        btn.selected = YES;
        if(btn == _btnSelfDestruct){
            _txtSelfDestruct.hidden = NO;
        }
    }
    [btn setImage:img forState:UIControlStateNormal];
    img = nil;
}

- (IBAction)btnNextClicked:(id)sender {
    
    
    NSMutableString *msg = [[NSMutableString alloc] init];

    if ([[_txtName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        [msg appendString:@"Memreas Name"];
    }
    else {
        [self addMemreasDetail];
        return;
    }
    
    [msg appendString:@" should not be empty."];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    alert = nil;
    

}
- (IBAction)btnCancelClicked:(id)sender {
    //[self.navigationController popViewControllerAnimated:YES];
    
    _txtName.text = @"";
    _txtDate.text = @"";
//    _txtLocations.text = @"";
    _txtFrom.text = @"";
    _txtTo.text = @"";
    _txtSelfDestruct.text = @"";
    
    _btnFriendsCanAdd.selected= YES;
    _btnFriendsCanPost.selected = YES;
    _btnPublic.selected = NO;
    
    [self.tabBarController setSelectedIndex:3];
}


#pragma mark
#pragma mark Custom methods

-(void) addDatePicker{
    
    _viewDatepicker.hidden = NO;
    
 
}

-(NSString *)convertBoolToString:(BOOL)boole{
    if(boole)
        return @"YES";
    else
        return @"NO";
}

-(int)convertBoolToInt:(BOOL)boole{
    if(boole)
        return 1;
    else
        return 0;
}

#pragma  mark
#pragma  mark Webservice call & parsing

-(void) addMemreasDetail {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //ADDTOXMLGENERATOR
    NSUserDefaults *defaultUser = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"%@?action=addevent&sid=%@",WEB_SERVICE_URL,SID];
    NSMutableString *xml = [[NSMutableString alloc] init];
    [xml appendFormat:@"xml=<xml version=\"1.0\" encoding=\"utf-8\"><addevent>"];
    [xml appendFormat:@"<user_id>%@</user_id>",[defaultUser objectForKey:@"UserId"]];
    [xml appendFormat:@"<event_name><![CDATA[%@]]></event_name>",_txtName.text];
    [xml appendFormat:@"<event_date>%@</event_date>",_txtDate.text];
    [xml appendFormat:@"<event_location><![CDATA[%@]]></event_location>",_txtLocations.text];
    [xml appendFormat:@"<event_from>%@</event_from>",_txtFrom.text];
    [xml appendFormat:@"<event_to>%@</event_to>",_txtTo.text];
    [xml appendFormat:@"<is_friend_can_add_friend>%d</is_friend_can_add_friend>",[self convertBoolToInt:_btnFriendsCanAdd.isSelected]];
    [xml appendFormat:@"<is_friend_can_post_media>%d</is_friend_can_post_media>",[self convertBoolToInt:_btnFriendsCanPost.isSelected]];
    [xml appendFormat:@"<event_self_destruct>%@</event_self_destruct>",_txtSelfDestruct.text];
    [xml appendFormat:@"<is_public>%d</is_public>",[self convertBoolToInt:_btnPublic.isSelected]];
    [xml appendFormat:@"</addevent></xml>"];
    [_viewLoading setHidden:NO];
    [_actAddMemreas setHidesWhenStopped:YES];
    [_actAddMemreas startAnimating];
    
    
    [parser parseWithURL:urlString soapMessage:xml startTag:@"addeventresponse" completedSelector:@selector(objectParsed_AddMemreasDetail:) handler:self];
    xml = nil;
    urlString = nil;
}

-(void)objectParsed_AddMemreasDetail:(NSMutableDictionary *)dictionary{
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    NSArray *arr = [dictionary objectForKey:@"objects"];
    if([arr count]>0){
        NSString *status = [[arr objectAtIndex:0] valueForKey:@"status"];
        if([[status uppercaseString] isEqualToString:@"SUCCESS"]){

            eventId = [NSString stringWithFormat:@"%@",[[arr objectAtIndex:0] valueForKey:@"event_id"]] ;

            if (self.isDone) {
                self.isDone =0;
                [self.tabBarController setSelectedIndex:3];

            }else{
            
            [self performSegueWithIdentifier:@"segueAddMedia" sender:nil];
                
                [self.dicForSubmit setObject:eventId forKey:@"event_id"];
                [self.dicForSubmit setObject:self.txtName.text forKey:@"event_name"];
                
            }

            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",[[arr objectAtIndex:0] valueForKey:@"status"]] message:[NSString stringWithFormat:@"%@",[[arr objectAtIndex:0] valueForKey:@"message"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            alert = nil;
        }
    } else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry,unable to perform this operation." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert = nil;
    }
    dictionary = nil;
}




#pragma  mark
#pragma  mark Segue method

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"segueAddMedia"]){
        AddMediaViewController *addMedia = (AddMediaViewController *)[segue destinationViewController];
        addMedia.eventId = eventId;
        
        NSMutableDictionary*dic = [NSMutableDictionary dictionary];
        [dic setObject:[NSString stringWithFormat:@"%f",self.selectedLocation.coordinate.latitude] forKey:@"latitude"];
        [dic setObject:[NSString stringWithFormat:@"%f",self.selectedLocation.coordinate.longitude] forKey:@"longitude"];
        [dic setObject:[NSString stringWithFormat:@"%@",self.txtLocations.text] forKey:@"address"];
        addMedia.selectedLocationDic = dic;
        addMedia.dicPassed = self.dicForSubmit;
    }
    else if([segue.identifier isEqualToString:@"Setting"])
    {
        UIViewController *destViewController = segue.destinationViewController;
        destViewController.hidesBottomBarWhenPushed = YES;
    }
}
#pragma mark
#pragma mark AdBannerViewDelegate Method

-(BOOL) bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{
    
    NSLog(@"Banner view is beginning ad action");
    return YES;
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"banner error : %@",error.description);
}


-(BOOL)shouldAutorotate{
    return YES;
}
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}






#pragma  mark
#pragma  mark Webservice call & parsing

-(void)listallMedia{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSUserDefaults *defaultUser = [NSUserDefaults standardUserDefaults];
    NSString *userId = [defaultUser stringForKey:@"UserId"];
    NSString *urlString = [NSString stringWithFormat:@"%@?action=listallmedia&sid=%@",WEB_SERVICE_URL,SID];
    //ADDTOXMLGENERATOR
    NSString *request = @"xml=<xml>";
    request = [request stringByAppendingFormat:@"<listallmedia><user_id>%@</user_id><event_id>0</event_id><device_id>%@</device_id><page>1</page><limit>1000</limit></listallmedia>",userId,appDelegate.deviceUuid];
    request = [request stringByAppendingString:@"</xml>"];
    
    if([Util checkInternetConnection]){
        
        if (!parser) {
            parser = [[XMLParser alloc] init];
        }
        [parser parseWithURL:urlString soapMessage:request startTag:@"media" completedSelector:@selector(objectParesed_ListAllMedia:) handler:self];
    }
}

- (void) objectParesed_ListAllMedia:(NSDictionary *)dictionary
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    NSArray *arr = [dictionary objectForKey:@"objects"];
    
    for (NSDictionary *dic in arr) {
        NSString *type = [NSString stringWithFormat:@"%@",[dic valueForKey:@"type"]];
        if(![type isEqualToString:@"audio"])
            [self.imageListingArray addObject:dic];
    }
}


#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return [self.arraySections[friends][SelectedValue] boolValue]?self.arraySections.count:self.arraySections.count-4;
//    return self.arraySections.count-4;// Old prashant
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    switch (section) {
        case memreasDetail:{
            return ![self.arraySections[section][SelectedValue] boolValue]?0:1;
            break;
        }
        case media:{
//            return [self.arraySections[section][SelectedValue] boolValue]?0:1;
            return 0;
            break;
        }
        case friends:{
            return 0;
            break;
        }
        case FaceBook:{
            return ![self.arraySections[section][SelectedValue] boolValue]?0:self.facebookFriends.count;
            break;
        }
        case Twitter:{
            return ![self.arraySections[section][SelectedValue] boolValue]?0:self.twitterFriends.count;
            break;
        }
        case Local:{
            return ![self.arraySections[section][SelectedValue] boolValue]?0:self.localFriendList.count;
            break;
        }
        case Group:{
            return [self.arraySections[section][SelectedValue] boolValue]?0:1;
            break;
        }
        default:{
            return [self.arraySections[section][SelectedValue] boolValue]?0:1;
            break;
        }
    }
}




-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString * CellIdentifier1 = @"Cell";
    static NSString * CellIdentifier2 = @"Cell1";
    static NSString * CellIdentifier3 = @"Cell3";
    static NSString * CellIdentifier4 = @"Cell4";
    
    
    switch (indexPath.section) {
        case memreasDetail:{
            MemreasDetailCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];

            
            
            cell.backgroundView.backgroundColor = [UIColor clearColor];
            cell.backgroundColor = [UIColor clearColor];
            
            self.txtName=cell.txtTitle;
            self.txtDate=cell.txtDate;
            self.txtLocations=cell.txtLocation;
            self.txtFrom=cell.txtViewableFrom;
            self.txtTo=cell.txtViewableTo;
            self.txtSelfDestruct=cell.txtSelfDestruct;
            self.btnFriendsCanPost=cell.btnFriendsCanPost;
            self.btnFriendsCanAdd=cell.btnFriendsCanAdd;
            self.btnPublic=cell.btnIsPublic;
            return cell;
            break;
        }
            
        case media:{
            AddMemreasCollectionCell * cell1 =[tableView dequeueReusableCellWithIdentifier:CellIdentifier2 forIndexPath:indexPath];
            self.txtComment=cell1.txtComment;
            cell1.delegate=self;
            return cell1;
            
            break;
        }
        case FaceBook:{
            FriendsCell * cell1 =[tableView dequeueReusableCellWithIdentifier:CellIdentifier3 forIndexPath:indexPath];
            [cell1 displayUserInfo:self.facebookFriends[indexPath.row][@"name"] andProfileUrl:self.facebookFriends[indexPath.row][@"picture"][@"data"][@"url"] andSelected:[self.facebookFriends[indexPath.row][@"selected"]boolValue]];
            return cell1;
            
            break;
        }
        case Twitter:{
            FriendsCell * cell1 =[tableView dequeueReusableCellWithIdentifier:CellIdentifier3 forIndexPath:indexPath];
            [cell1 displayUserInfo:self.twitterFriends[indexPath.row][@"name"] andProfileUrl:self.twitterFriends[indexPath.row][@"profile_image_url"] andSelected:[self.twitterFriends[indexPath.row][@"selected"] boolValue]];
            return cell1;
            
            break;
        }
        case Local:
        {
            FriendsCell * cell1 =[tableView dequeueReusableCellWithIdentifier:CellIdentifier3 forIndexPath:indexPath];
            
            if (self.localFriendList[indexPath.row][@"friend"] != nil) {
                    [cell1 displayUserInfo:self.localFriendList[indexPath.row][@"friend"][@"social_username"] andProfileUrl:self.localFriendList[indexPath.row][@"friend"][@"url"] andSelected:[self.localFriendList[indexPath.row][@"friend"][@"selected"] boolValue]];

            } else{
                if (self.localFriendList[indexPath.row][@"group"]!= nil) {
                    [cell1 displayUserInfo:self.localFriendList[indexPath.row][@"group"][@"group_name"] andProfileUrl:@"" andSelected:[self.localFriendList[indexPath.row][@"group"][@"selected"] boolValue] andIsGroup:YES];
                }
            }
            
            return cell1;
            
            break;
        }
        case Group:{
            FriendsCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier4 forIndexPath:indexPath];
            self.txtGroupName=cell.txtGroupName;
            return cell;
            break;
        }
        default:{
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
            
            
            return cell;

            break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case FaceBook:
        case Twitter:
        case Local:
            return 50;
            break;
        case Group:
            return 92;
            break;
            
        default:
            return 354;
            break;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch (indexPath.section) {
        case FaceBook:{
            self.facebookFriends[indexPath.row][@"selected"]=[self.facebookFriends[indexPath.row][@"selected"] boolValue]?@"0":@"1";
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        case Twitter:{
            self.twitterFriends[indexPath.row][@"selected"]=[self.twitterFriends[indexPath.row][@"selected"] boolValue]?@"0":@"1";
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        case Local:{
            
            if (self.localFriendList[indexPath.row][@"friend"] != nil) {
                
                self.localFriendList[indexPath.row][@"friend"][@"selected"]=[self.localFriendList[indexPath.row][@"friend"][@"selected"] boolValue]?@"0":@"1";
            }else if (self.localFriendList[indexPath.row][@"group"]!= nil) {
                self.localFriendList[indexPath.row][@"group"][@"selected"]=[self.localFriendList[indexPath.row][@"group"][@"selected"] boolValue]?@"0":@"1";
                
            }
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        default:
            break;
    }
    
}


-(IBAction)headerTapped:(UIButton *)sender{
    
    NSLog(@"%li",(long)sender.tag);
    switch (sender.tag) {
            
        case memreasDetail:{
            self.arraySections[sender.tag][SelectedValue]=[self.arraySections[sender.tag][SelectedValue] boolValue]?@"0":@"1";
            NSRange range = NSMakeRange(sender.tag, 1);
            NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
            [self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationAutomatic];

            break;
        }
        case media:{
            
            if ([[self.txtName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
     
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Memreas Name should not be empty." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                alert = nil;

            }
            else {
                [self addMemreasDetail];
                return;
            }
            
            
            break;
        }
    }
    
}


-(IBAction)cellButtonTapped:(UIButton *)sender{
    
}
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)removeFormKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}



// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        [self.self.tableView scrollRectToVisible:activeField.frame animated:YES];
    }
}
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}


#pragma mark - Media Region

- (IBAction)btnSoundClicked:(id)sender {
    if(audioRecording == nil){
        audioRecording = [[AudioRecording alloc] init];
        [audioRecording viewDidLoad];
    }
    if(recording){
        [btnSound setBackgroundColor:[UIColor clearColor]];
        recording = NO;
        isAudioCommentAdded = YES;
        [audioRecording recordOrStop:audioRecording.btnRecordComment];
        appDelegate.isAudioComment = YES;
    } else{
        isAudioCommentAdded = NO;
        [btnSound setBackgroundColor:[UIColor redColor]];
        recording = YES;
        [audioRecording recordOrStop:audioRecording.btnRecordComment];
    }
}


#pragma mark Init GoogleMap
- (void)initLocationForMap
{
    locationManager = [[CLLocationManager alloc] init];
    
    if(IS_OS_8_OR_LATER) {
        [locationManager requestWhenInUseAuthorization];
    } else {
        [locationManager requestAlwaysAuthorization];
    }
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Info" message:@"Please turn on location service from setting." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)managerL didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [locationManager stopUpdatingLocation];
    self.selectedLocation = newLocation;
    
    NSString*str =  [[NSString stringWithFormat: @"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true",newLocation.coordinate.latitude,newLocation.coordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:str parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        self.mapPicker.searchText = self.txtLocations.text;
        NSString*locationDic =[[[responseObject valueForKeyPath:@"results"] firstObject] valueForKey:@"formatted_address"];
        self.txtLocations.text  = locationDic;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        
    }];

    
    locationManager=nil;

}

-(NSString*)nullCheckME:(NSString*)class{

    if ([class isKindOfClass:[NSNull class]]||class==nil) {
        return @"";
    }else{
    
        return class;
    
    }
}

 */



@end

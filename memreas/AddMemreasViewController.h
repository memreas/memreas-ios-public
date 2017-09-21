/**
 * Copyright (C) 2015 memreas llc. - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */
//
//  AddMemreasViewController.h
//

#import <UIKit/UIKit.h>
#import "XMLParser.h"
#import <iAd/iAd.h>
#import "MasterViewController.h"
#import <Social/Social.h>




typedef enum SectionTypes{
    memreasDetail,
    media,
    friends,
    FaceBook,
    Twitter,
    Local,
    Group
    
}SectionTypes;

@interface AddMemreasViewController : UIViewController<UITextFieldDelegate,ADBannerViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
 //   NSString *eventId;
 //   XMLParser *parser;
 //   BOOL recording;
 //   BOOL isAudioCommentAdded;


}

/*
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (nonatomic)   BOOL isGrouped;
@property (nonatomic, weak) IBOutlet UITableView * tableView;

@property (nonatomic, assign) IBOutlet UIView *mainView;

@property (nonatomic, assign) IBOutlet UITextField *tfSearchMap;
@property (weak, nonatomic) IBOutlet UITextField *_tfSearchMapCity;
@property (nonatomic, assign) IBOutlet ADBannerView *adView;

//@property (nonatomic, assign) IBOutlet UIScrollView *scrAddMediaForm;
@property (nonatomic, assign) IBOutlet UIView *viewDatepicker;
//@property (nonatomic, assign) IBOutlet UIView *viewLoactionAler;

@property (nonatomic, strong) UITextField *txtComment;
@property (nonatomic, strong) UITextField *txtGroupName;
@property (nonatomic, assign) IBOutlet UITextField *txtName;
@property (nonatomic, assign) IBOutlet UITextField *txtDate;
@property (nonatomic, assign) IBOutlet UITextField *txtLocations;
@property (weak, nonatomic) IBOutlet UITextField *txtLocationsCity;
@property (nonatomic, assign) IBOutlet UITextField *txtFrom;
@property (nonatomic, assign) IBOutlet UITextField *txtTo;
@property (nonatomic, assign) IBOutlet UITextField *txtSelfDestruct;

@property (nonatomic, assign) IBOutlet UIButton *btnFriendsCanPost;
@property (nonatomic, assign) IBOutlet UIButton *btnFriendsCanAdd;
@property (nonatomic, assign) IBOutlet UIButton *btnPublic;
@property (nonatomic, assign) IBOutlet UIButton *btnSelfDestruct;

@property (nonatomic, assign) IBOutlet UIView *viewLoading;
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView *actAddMemreas;

@property (weak, nonatomic) IBOutlet UIDatePicker *pckrDate;

@property (nonatomic, assign) UITextField *tempTxt;
@property (nonatomic, strong) NSMutableArray * imageListingArray;
@property (nonatomic, strong) NSMutableArray * assetAry,*selectedFileDownload,*selectedAssetsImages;
//@property (weak, nonatomic) IBOutlet UIView *viewMap;

- (IBAction)btnCheckboxClicked:(id)sender;
- (IBAction)onAddMedia:(id)sender;
- (IBAction)onFriends:(id)sender;
*/
@end

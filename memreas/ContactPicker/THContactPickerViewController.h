//
//  ContactPickerViewController.h
//  ContactPicker
//
//  Created by Tristan Himmelman on 11/2/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "THContactPickerView.h"
#import "THContactPickerTableViewCell.h"



@class THContactPickerViewController;
@protocol ContactPicking <NSObject>


@optional
-(void)contactpicker:(THContactPickerViewController*)contactPicker didSelectContact:(NSMutableArray*)selectedContacts;

-(void)contactpickerDidCancelPickerController:(THContactPickerViewController*)contactPicker ;


@end




@interface THContactPickerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, THContactPickerDelegate, ABPersonViewControllerDelegate>

@property (nonatomic, strong) THContactPickerView *contactPickerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSMutableArray *selectedContacts;
@property (nonatomic, strong) NSArray *filteredContacts;


@property (nonatomic,assign) id <ContactPicking> delegate;

@end



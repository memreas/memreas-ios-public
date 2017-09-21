#import "SettingButton.h"
#import "SettingSearchbarItem.h"
#import "UIBarButtonItem+Badge.h"
@implementation SettingButton

+(void)addRightBarButtonAsNotificationInViewController:(UIViewController *)controller{
    
    //
    // Create search bar notifications button and setup touch action
    //
    SettingSearchbarItem *rightUIButton = [[SettingSearchbarItem alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    [rightUIButton addTarget:self action:@selector(notificationClicked:) forControlEvents:UIControlEventTouchUpInside];
    [rightUIButton setImage:[UIImage imageNamed:@"btn_setting"] forState:UIControlStateNormal];
    rightUIButton.controller = controller;
    
    //
    // Create UIBarButtonItem badge for notifications count
    //
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightUIButton];
    [[NSNotificationCenter defaultCenter]addObserver:rightButton selector:@selector(addBadge:) name:@"badge" object:nil];
    
    
    //
    // Add buttons in controller navigation
    //
    rightButton.badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long) [NotificationsViewController fetchNoticationsArray].count];
    controller.navigationItem.rightBarButtonItem = rightButton;
    
}

+(void)notificationRemove:(SettingSearchbarItem*)buttonItem{
    
    // Remove
    [UIView beginAnimations:nil context:NULL];
    [UIView animateWithDuration:0.5 animations:^{
        buttonItem.settingVC.view.alpha=0;
        
    } completion:^(BOOL finished) {
        [buttonItem.settingVC removeFromParentViewController];
        [buttonItem.settingVC.view removeFromSuperview];
        buttonItem.settingVC =nil;
    }];
    [UIView commitAnimations];
    
}



+(void)notificationClicked:(SettingSearchbarItem*)buttonItem{
    
    UIViewController*controller = buttonItem.controller;
    UIBarButtonItem *rightButton= controller.navigationItem.leftBarButtonItem;
    SettingSearchbarItem *rightUIButton= (SettingSearchbarItem*)rightButton.customView;
    
    [self searchRemove:rightUIButton];
    
    int h = 470;
    int yX = 44;
    int x = controller.view.frame.size.width -320;
    
    if (!buttonItem.settingVC) {
        // Load
        
        buttonItem.settingVC =[[UIStoryboard storyboardWithName:@"Universal" bundle:nil] instantiateViewControllerWithIdentifier:@"NotificationVC"];
        buttonItem.settingVC.view.frame = CGRectMake (x, yX, 320, h);
        
        [controller.view addSubview:buttonItem.settingVC.view];
        [controller addChildViewController:buttonItem.settingVC];
        buttonItem.settingVC.view.alpha=0;
        
        // Pass parameter
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.6];
        buttonItem.settingVC.view.alpha=1;
        [UIView commitAnimations];
        
    }else{
        
        // Remove
        
        
        [UIView beginAnimations:nil context:NULL];
        [UIView animateWithDuration:0.5 animations:^{
            buttonItem.settingVC.view.alpha=0;
            
        } completion:^(BOOL finished) {
            [buttonItem.settingVC removeFromParentViewController];
            [buttonItem.settingVC.view removeFromSuperview];
            buttonItem.settingVC =nil;
            
        }];
        [UIView commitAnimations];
        
    }
    
    
}


#pragma mark -- Left Search button

+(void)addLeftSearchInViewController:(UIViewController *)controller{
    
    SettingSearchbarItem *leftUIButton = [[SettingSearchbarItem alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    [leftUIButton addTarget:self action:@selector(searchClicked:) forControlEvents:UIControlEventTouchUpInside];
    [leftUIButton setImage:[UIImage imageNamed:@"searchIcon"] forState:UIControlStateNormal];
    leftUIButton.controller = controller;
    
    UIBarButtonItem *LeftButton = [[UIBarButtonItem alloc] initWithCustomView:leftUIButton];
    controller.navigationItem.leftBarButtonItem = LeftButton;
    
}

+(void)searchClicked:(SettingSearchbarItem*)buttonItem{
    
    UIViewController*controller = buttonItem.controller;
    
    UIBarButtonItem *rightButton= controller.navigationItem.rightBarButtonItem;
    SettingSearchbarItem *rightUIButton= (SettingSearchbarItem*)rightButton.customView;
    
    [self notificationRemove:rightUIButton];
    
    int h = 470;
    int yX = 44;
    
    if (!buttonItem.settingVC) {
        // Load
        
        buttonItem.settingVC =[[UIStoryboard storyboardWithName:@"Universal" bundle:nil] instantiateViewControllerWithIdentifier:@"Search"];
        buttonItem.settingVC.view.frame = CGRectMake (0, yX, 320, h);
        [controller.view addSubview:buttonItem.settingVC.view];
        [controller addChildViewController:buttonItem.settingVC];
        buttonItem.settingVC.view.alpha=0;
        
        // Pass parameter
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.6];
        buttonItem.settingVC.view.alpha=1;
        [UIView commitAnimations];
        
    }else{
        
        // Remove
        
        [UIView beginAnimations:nil context:NULL];
        [UIView animateWithDuration:0.5 animations:^{
            buttonItem.settingVC.view.alpha=0;
            
        } completion:^(BOOL finished) {
            [buttonItem.settingVC removeFromParentViewController];
            [buttonItem.settingVC.view removeFromSuperview];
            buttonItem.settingVC =nil;
            
        }];
        [UIView commitAnimations];
        
    }
    
    
}


+(void)searchRemove:(SettingSearchbarItem*)buttonItem{
    
    // Remove
    [UIView beginAnimations:nil context:NULL];
    [UIView animateWithDuration:0.5 animations:^{
        buttonItem.settingVC.view.alpha=0;
        
    } completion:^(BOOL finished) {
        [buttonItem.settingVC removeFromParentViewController];
        [buttonItem.settingVC.view removeFromSuperview];
        buttonItem.settingVC =nil;
        
    }];
    [UIView commitAnimations];
    
}


@end

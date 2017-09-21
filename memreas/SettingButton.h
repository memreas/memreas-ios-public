#import <Foundation/Foundation.h>

#import "SettingSearchbarItem.h"

@interface SettingButton : NSObject

+(void)addRightBarButtonAsNotificationInViewController:(UIViewController*)controller;


+(void)addLeftSearchInViewController:(UIViewController *)controller;

+(void)notificationClicked:(SettingSearchbarItem*)buttonItem;


@end

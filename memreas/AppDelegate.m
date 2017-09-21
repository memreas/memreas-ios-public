#import "AudioRecording.h"
#import "ELCAsset.h"
#import "MyConstant.h"
#import "MyView.h"
#import "NotificationsViewController.h"
#import "QueueController.h"
#import "Util.h"
#import "XMLParser.h"
#import "WebServiceParser.h"
#import "WebServices.h"
#import "Helper.h"

@implementation AppDelegate


#pragma mark
#pragma mark App Method
- (BOOL)application:(UIApplication*)application
            openURL:(NSURL*)url
  sourceApplication:(NSString*)sourceApplication
         annotation:(id)annotation {
    
    return YES;
}

- (BOOL)application:(UIApplication*)application
didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    @try {
        
        /**
         * Fetch and set UDID
         */
        NSString* device_id = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [[NSUserDefaults standardUserDefaults] setObject:device_id
                                                  forKey:@"device_id"];
        
        //
        // Google Services (maps and places) API Access
        //
        [GMSServices provideAPIKey:GMSSERVICESKEY];
        [GMSPlacesClient provideAPIKey:GMSSERVICESKEY];
        
        //
        // Firebase
        //
        [FIRApp configure];
        
        
        // Push notification
        [[UIApplication sharedApplication]
         registerUserNotificationSettings:
         [UIUserNotificationSettings
          settingsForTypes:(UIUserNotificationTypeSound |
                            UIUserNotificationTypeAlert |
                            UIUserNotificationTypeBadge)
          categories:nil]];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        // background fetch interval
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:1.0];
        [self.window makeKeyAndVisible];
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
    
    return YES;
}
- (void)application:(UIApplication*)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    //
    // Set device token in NSUserDefaults
    //
    self.strDeviceToken = [Helper hexadecimalString:deviceToken];
    [[NSUserDefaults standardUserDefaults] setObject:self.strDeviceToken forKey:@"device_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)application:(UIApplication*)application
didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    self.strDeviceToken = @"";
    ALog(@"Fail to registered for remote notification error: %@", error);
}
- (void)application:(UIApplication*)application
didReceiveRemoteNotification:(NSDictionary*)userInfo {
    
    ALog(@"didReceiveRemoteNotification:(NSDictionary*)userInfo --> %@", userInfo);
    [[NotificationsViewController sharedInstance] getNotifications];
    [NotificationsViewController sharedInstance].didGetNotifications = YES;
}

- (void)applicationWillResignActive:(UIApplication*)application {
    /*
     Sent when the application is about to move from active to inactive state.
     This can occur for certain types of temporary interruptions (such as an
     incoming phone call or SMS message) or when the user quits the application
     and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down
     OpenGL ES frame rates. Games should use this method to pause the game.
     */
    //[self setBackgroundTaskKeepAlive:YES];
    // ALog(@"applicationWillResignActive: setBackgroundTaskKeepAlive "
    //      @"backgrounding accepted");
    QueueController.sharedInstance.hasInitiatedBackground = true;
}

- (void)applicationDidEnterBackground:(UIApplication*)application {
    /*
     Use this method to release shared resources, save user data, invalidate
     timers, and store enough application state information to restore your
     application to its current state in case it is terminated later.
     If your application supports background execution, this method is called
     instead of applicationWillTerminate: when the user quits.
     */
    //[self setBackgroundTaskKeepAlive:YES];
    // ALog(@"applicationDidEnterBackground: setBackgroundTaskKeepAlive "
    //      @"backgrounding accepted");
    QueueController.sharedInstance.hasInitiatedBackground = true;
}

- (void)applicationWillEnterForeground:(UIApplication*)application {
    /*
     Called as part of the transition from the background to the inactive state;
     here you can undo many of the changes made on entering the background.
     */
    
    
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary* userDetailDict = [userDefault objectForKey:@"userDetail"];
    
    if (userDetailDict != nil) {
        QueueController.sharedInstance.hasInitiatedBackground = false;
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"TransferQueueViewReload"
         object:self];
    }
    
}

- (void)applicationDidBecomeActive:(UIApplication*)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application
     was inactive. If the application was previously in the background, optionally
     refresh the user interface.
     */
    [self performSelectorInBackground:@selector(processPendingTransfers)
                           withObject:nil];
}

- (void)processPendingTransfers {
    QueueController* queueSharedInstance = [QueueController sharedInstance];
    if (queueSharedInstance.hasPendingTransfers) {
        /**
         * TODO: need to restart queue here. May restart on it's own...
         */
        //[[QueueController sharedInstance] executeTransfers];
    }
}

- (void)applicationWillTerminate:(UIApplication*)application {
    // Close the session before quitting
    QueueController* queueSharedInstance = [QueueController sharedInstance];
    [queueSharedInstance.pendingTransferQueue cancelAllOperations];
}

- (void)application:(UIApplication*)application
handleEventsForBackgroundURLSession:(NSString*)identifier
  completionHandler:(void (^)())completionHandler {
    /*
     Store the completion handler.
     */
    self.backgroundTransferSessionCompletionHandler = completionHandler;
    
    QueueController* queueSharedInstance = [QueueController sharedInstance];
    if (!queueSharedInstance.hasPendingTransfers) {
        [QueueController resetSharedInstance];
    } else {
        // continue processing
        ALog(@"handleEventsForBackgroundURLSession called - continue transfers in background");
    }
}

#pragma mark
#pragma mark Uploading

- (void)objectParsed_addCommentToMedia:(NSMutableDictionary*)dictionary {
    self.isAudioComment = NO;
    
    NSArray* arr = [dictionary objectForKey:@"objects"];
    if ([arr count] > 0) {
        NSString* status = [[arr objectAtIndex:0] valueForKey:@"status"];
        if ([[status uppercaseString] isEqualToString:@"SUCCESS"]) {
        }
    } else {
    }
    dictionary = nil;
}

#pragma mark
#pragma mark fetchTopUIViewController
- (UIViewController *)topViewController{
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

#pragma mark
#pragma mark Loading Method

- (void)startLoading {
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    progressView = [[MBProgressHUD alloc] initWithWindow:window];
    
    // Add HUD to screen
    [window addSubview:progressView];
    
    // Regisete for HUD callbacks so we can remove it from the window at the right
    // time
    progressView.delegate = self;
    
    progressView.detailsLabelText = @"";
    [progressView show:YES];
    //    [self.window setUserInteractionEnabled:NO];
}

- (void)stopLoading {
    [progressView hide:YES];
}
- (void)stopLoadingFromView {
    [progressView removeFromSuperview];
}

- (void)runOnMainWithoutDeadlocking:(void (^)(void))callbackBlock {
    if ([NSThread isMainThread]) {
        callbackBlock();
    } else {
        dispatch_sync(dispatch_get_main_queue(), callbackBlock);
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end

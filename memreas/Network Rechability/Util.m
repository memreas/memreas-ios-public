@import UIKit;
@import Foundation;
#import "Util.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability1.h"
#import "MyConstant.h"

@implementation Util
+(BOOL)checkInternetConnection {
	
    Reachability1 *r = [Reachability1 reachabilityWithHostName:HOSTNAMECHECK];//www.google.com
    
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    r=nil;
    
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Network connection not found."
                                                          message:@"Application requires an active WiFi or Network connection to function fully.  Please check your settings." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [myAlert show];
        return FALSE;
    }
	return TRUE;
}
@end

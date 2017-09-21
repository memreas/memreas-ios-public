//
//  BannerMasterViewController.h
//  Eventmanagement
//
//  Created by sarfaraj on 06/06/13.
//
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface BannerMasterViewController : UIViewController<ADBannerViewDelegate>

@property ADBannerView *adView;

@end

#import "AWSManager.h"
#import "MyConstant.h"
#import "AWSCore.h"
#import "AWSS3.h"

@implementation AWSManager

static AWSManager* sharedInstance = nil;

+ (AWSManager*)sharedInstance {
  @synchronized(self) {
    if(sharedInstance == nil) {
      sharedInstance = [[AWSManager alloc] init];
    }
  }
  return sharedInstance;
}

- (AWSManager*)init {
    
    self = [super init];


    // The Cognito iOS SDK uses Notification Center to let your application know
    // about a change of identity. The first step is to add your observer
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(identityDidChange:)
     name:AWSCognitoIdentityIdChangedNotification object:nil];
    
    self.credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                          identityPoolId:[MyConstant getCOGNITO_POOL_ID]];
    self.configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1
                                                                         credentialsProvider:self.credentialsProvider];
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = self.configuration;
    self.serviceManager = [AWSServiceManager defaultServiceManager];
    self.serviceManager.defaultServiceConfiguration = self.configuration;
    self.logger = [AWSLogger defaultLogger];
    
    if ([MyConstant isDEVENV]) {
        self.logger.logLevel = AWSLogLevelVerbose;
    } else {
        self.logger.logLevel = AWSLogLevelError;
    }

    self.transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    // Retrieve your Amazon Cognito ID
    [[self.credentialsProvider getIdentityId] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            //ALog(@"Error: %@", task.error);
        }
        else {
            // the task result will contain the identity id
            self.cognitoId = task.result;
        }
        return nil;
    }];
    return self;

}

//
// This is an example implementation of the selector
//
-(void) identityDidChange:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    //ALog(@"identity changed from %@ to %@",
    //      [userInfo objectForKey:AWSCognitoNotificationPreviousId],
    //      [userInfo objectForKey:AWSCognitoNotificationNewId]);
    
    self.cognitoId = [userInfo objectForKey:AWSCognitoNotificationNewId];
}

+(void) resetSharedInstance {
    sharedInstance = nil;
    [AWSManager sharedInstance];
}

@end

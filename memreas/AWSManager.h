#import "AWSCore.h"
#import "AWSS3.h"
#import <Foundation/Foundation.h>
#import "TransferType.h"
#import "TransferState.h"

@interface AWSManager : NSObject

@property AWSCognitoCredentialsProvider* credentialsProvider;
@property AWSServiceConfiguration* configuration;
@property AWSServiceManager* serviceManager;
@property AWSLogger* logger;
@property AWSS3TransferManager* transferManager;
@property NSString* cognitoId;
@property bool isLoggedIn;


+ (AWSManager*)sharedInstance;

@end

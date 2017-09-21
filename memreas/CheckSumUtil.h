@import Foundation;
#include <CommonCrypto/CommonDigest.h>

@interface CheckSumUtil : NSObject

+ (NSString *)md5HashOfNSURL:(NSURL *)assetURL;
+ (NSString *)sha1HashOfNSURL:(NSURL *)assetURL;
+ (NSString *)sha256HashOfNSURL:(NSURL *)assetURL;

@end

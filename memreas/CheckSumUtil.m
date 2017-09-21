#import "CheckSumUtil.h"

/* - Usage
#import "CheckSumUtil.h"

NSString* fullPath =
    @"";  // do whatever you need to get the full path to your file
NSString* md5 = [CheckSumUtil md5HashOfPath:fullPath];
NSString* sha1 = [CheckSumUtil shaHashOfPath:fullPath];

ALog(@"MD5: %@", md5);
ALog(@"SHA1: %@", sha1);
*/

#import "CheckSumUtil.h"

@implementation CheckSumUtil
+ (NSString *)md5HashOfNSURL:(NSURL *)assetURL {
  NSData *data = [NSData dataWithContentsOfURL:assetURL];
  unsigned char digest[CC_MD5_DIGEST_LENGTH];
  CC_MD5(data.bytes, (CC_LONG)data.length, digest);

  NSMutableString *output =
      [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];

  for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
    [output appendFormat:@"%02x", digest[i]];
  }

  return output;
}

+ (NSString *)sha1HashOfNSURL:(NSURL *)assetURL {
  NSData *data = [NSData dataWithContentsOfURL:assetURL];
  unsigned char digest[CC_SHA1_DIGEST_LENGTH];
  CC_SHA1(data.bytes, (CC_LONG)data.length, digest);

  NSMutableString *output =
      [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

  for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
    [output appendFormat:@"%02x", digest[i]];
  }

  return output;
}

+ (NSString *)sha256HashOfNSURL:(NSURL *)assetURL {
    NSData *data = [NSData dataWithContentsOfURL:assetURL];
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output =
    [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

@end

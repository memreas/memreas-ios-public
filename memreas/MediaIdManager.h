#import <Foundation/Foundation.h>
@class MediaItem;
@class MyConstant;
@class Util;
@class WebServices;
@class XMLGenerator;
@class MWebServiceHandler;
@class JSONUtil;

@interface MediaIdManager : NSObject

@property NSMutableArray* mediaIdBatchArray;

+ (MediaIdManager*)sharedInstance;
+ (void)resetSharedInstance;
- (NSString*)fetchNextMediaId;

@end

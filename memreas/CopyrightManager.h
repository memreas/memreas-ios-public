#import <Foundation/Foundation.h>
@class MyConstant;
@class Util;
@class XMLGenerator;
@class WebServices;
@class MWebServiceHandler;
@class JSONUtil;
@class Util;


@interface CopyrightManager : NSObject

@property NSMutableArray* copyrightBatchArray;

+ (CopyrightManager*)sharedInstance;
+ (void)resetSharedInstance;
- (NSMutableDictionary*)fetchNextCopyRight;

@end

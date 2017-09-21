#import <Foundation/Foundation.h>
@class MyConstant;

@interface NSDictionary (valueAdd)
    -(void)addValueToDictionary:(id)obj andKeyIs:(NSString*)aKey;
@end

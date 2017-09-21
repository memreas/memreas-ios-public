#import <Foundation/Foundation.h>

@interface JSONUtil : NSObject {
}

+ (NSString*)convertFromNSDictionary:(NSDictionary*)dict;
+ (id)convertToID:(NSString*)json;
+ (id)convertToMutableID:(NSString*)json;
+ (NSMutableArray*)convertToMutableNSArray:(NSString*)json;
+ (NSMutableDictionary*) convertToMutableNSDictionary:(NSString*)json;

@end

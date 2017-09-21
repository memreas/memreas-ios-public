#import <Foundation/Foundation.h>
@class JSONUtil;
@class MyConstant;

@interface MWebServiceBaseParser : NSObject <NSXMLParserDelegate> {
    NSMutableString *currentElementValue;
}

@property NSMutableDictionary *baseParserResult;
@property NSMutableDictionary *resultTags;

- (MWebServiceBaseParser *) init:(NSMutableDictionary *) resultTags;
- (NSMutableDictionary *) doParse:(NSData *)data;
@end

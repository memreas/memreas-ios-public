#import <Foundation/Foundation.h>
@class MyConstant;
@class MediaItem;
@class JSONUtil;

@interface ListAllMediaParser : NSObject <NSXMLParserDelegate> {
    NSMutableString *currentElementValue;
}

@property MediaItem *mediaItem;
@property NSMutableDictionary *mediaItemDictionary;

- (ListAllMediaParser *) init;
- (NSMutableDictionary *) doParse:(NSData *)data;
@end

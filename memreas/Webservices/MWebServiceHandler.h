#import <Foundation/Foundation.h>
@class GalleryManager;
@class ListAllMediaParser;
@class MWebServiceBaseParser;
@class MyConstant;
@class XMLReader;

@interface MWebServiceHandler : NSObject

@property(atomic, strong) NSOperationQueue *mWebServicesNotificationQueue;
@property (nonatomic,assign) BOOL isJsonParsing;
@property NSData* returnData;
@property id delegate;
@property SEL callBackSelector;
@property ListAllMediaParser* listAllMediaParser;

- (void)fetchServerResponse:(NSMutableURLRequest*)request
                     action:(NSString*)action
                        key:(NSString*)key;

@end

@import Foundation;
@import UIKit;

@interface XMLParser : NSObject<NSXMLParserDelegate,NSURLConnectionDataDelegate,NSURLConnectionDelegate>
{
    NSXMLParser *xmlParser_;
    NSMutableArray *arrayResult_;
    NSMutableArray *arrayResult2_;
    NSMutableDictionary *tempDic_;
    NSMutableData *responseData_;
    NSString *startingTag_;
    NSString *thirdStartTag_;
    NSString *currentTag_;
    NSMutableString *currentValue_;
    BOOL isStart;
    NSObject *handler_;
    SEL completedMethod_;
    SEL failMethod_;
    NSURLConnection *connection1;
    int indexLayer;
    int counterLayer;
    int typeParse;
}
@property (strong,nonatomic) NSXMLParser *xmlParser;
@property (strong,nonatomic) NSMutableData *responseData;
@property (strong,nonatomic) NSMutableArray *arrayResult;
@property (strong,nonatomic) NSMutableArray *arrayResult2;
@property (strong,nonatomic) NSMutableDictionary *tempDic;
@property (strong,nonatomic) NSObject *handler;
@property (strong,nonatomic) NSString *startingTag;
@property (strong,nonatomic) NSString *thirdStartTag;
@property (strong,nonatomic) NSString *currentTag;
@property (strong,nonatomic) NSMutableString *currentValue;



@property BOOL isDeepThirdLayer;
@property BOOL startDeepThirdLayer;
@property SEL completedMethod;
@property SEL failMethod;


-(void)parseWithString:(NSString *)stringForParse startTag:(NSString *)startTag completBlock:(void (^)(void))completBlock;
-(void)parseWithString:(NSString *)stringForParse startTag:(NSString *)startTag completedSelector:(SEL)completedSelector handler:(NSObject*)handler;
-(void)parseWithURL:(NSString *)urlString startTag:(NSString *)startTag completedSelector:(SEL)completedSelector handler:(NSObject *)handler;
-(void)parseWithURL:(NSString *)urlString startTag:(NSString *)startTag completedSelector:(SEL)completedSelector failedSelector:(SEL)failedSelector handler:(NSObject *)handler;
-(void)parseWithURL:(NSString *)urlString soapMessage:(NSString *)soadMessage startTag:(NSString *)startTag completedSelector:(SEL)completedSelector handler:(NSObject *)handler isDeepThirdLayer:(BOOL)isDeepThirdLayer;
-(void)parseWithURL:(NSString *)urlString soapMessage:(NSString *)soadMessage startTag:(NSString *)startTag completedSelector:(SEL)completedSelector handler:(NSObject *)handler;
-(void)parseWithURL:(NSString *)urlString soapMessage:(NSString *)soadMessage startTag:(NSString *)startTag completedSelector:(SEL)completedSelector failedSelector:(SEL)failedSelector handler:(NSObject *)handler;
-(void)parseWithURL:(NSString *)urlString typeParse:(int)_typeParse soapMessage:(NSString *)soadMessage startTag:(NSString *)startTag completedSelector:(SEL)completedSelector handler:(NSObject *)handler;
-(void) removeAllObject;

@end

#import "WebServices.h"

@implementation WebServices

#pragma mark
#pragma mark
+(NSMutableURLRequest*) generateWebServiceRequest:(NSString*)xmlRequestData action:(NSString *)action
{
    
    NSString *xmlRequestMessage = [NSString stringWithFormat:@"xml=%@",xmlRequestData];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[xmlRequestMessage length]];
    NSString *urlString = [NSString stringWithFormat:@"%@?action=%@", [MyConstant getWEB_SERVICE_URL], action];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[xmlRequestMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    return request;
}
@end

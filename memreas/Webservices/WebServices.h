#import <Foundation/Foundation.h>
#import "MyConstant.h"


@interface WebServices : NSObject {

}

+(NSMutableURLRequest*) generateWebServiceRequest:(NSString*)xmlRequestMessage action:(NSString *)action;


@end

#import "NSDictionary+valueAdd.h"
#import "MyConstant.h"

@implementation NSDictionary (valueAdd)

-(void)addValueToDictionary:(id)obj andKeyIs:(NSString*)aKey{
    
    @try {
        
        NSMutableDictionary *dic = (NSMutableDictionary*)self;
        NSString *strKey  = aKey?aKey:@"UndifinedData";
        
        if (obj) {
            [dic setObject:obj forKey:strKey];
        }else{
            [dic setObject:@"" forKey:strKey];
        }
        
    }
    @catch (NSException *exception) {
        ALog(@"  addValueToDictionary  %@",exception);
    }
    
}


@end

#import "NSString+SrtingUrlValidation.h"

@implementation NSString (SrtingUrlValidation)

-(BOOL)isValidURL{
    
    return (self.length && ![self isEqualToString:@"(null)"]);
}


- (NSString*) urlEnocodeString {    
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}



-(id)convertToJson{
    
    // create our request
    NSError*error;
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return  [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
}


-(BOOL)isEqualToUpperCase:(NSString*)value{

   return  [[self uppercaseString] isEqualToString:[value uppercaseString]];

}


-(NSString*)convertToJsonWithFirstObject{
// create our request
    if ([self isKindOfClass:[NSString class]]) {
        NSError*error;
        NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
        return  [[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error]  firstObject];
    }
    
    return self;

}




@end

#import <Foundation/Foundation.h>

@interface NSString (SrtingUrlValidation)

- (BOOL)isValidURL;
- (id)convertToJson;
- (NSString*)convertToJsonWithFirstObject;
- (NSString*) urlEnocodeString ;
- (BOOL)isEqualToUpperCase:(NSString*)value;

@end

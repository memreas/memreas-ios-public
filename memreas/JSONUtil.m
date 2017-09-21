#import "JSONUtil.h"

@implementation JSONUtil

+ (NSString*)convertFromNSDictionary:(NSDictionary*)dict {
    NSError* __autoreleasing ns_error;
    NSData* jsonData =
    [NSJSONSerialization dataWithJSONObject:dict
                                    options:NSJSONWritingPrettyPrinted
                                      error:&ns_error];
    NSString* jsonString =
    [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return jsonString;
}

+ (id)convertToID:(NSString*)json {
    NSData* jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError* __autoreleasing ns_error;
    id jsonobject =
    [NSJSONSerialization JSONObjectWithData:jsonData
                                    options:NSJSONReadingAllowFragments
                                      error:&ns_error];
    
    return jsonobject;
}

+ (id)convertToMutableID:(NSString*)json {
    NSData* jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError* __autoreleasing ns_error;
    id jsonobject =
        [NSJSONSerialization JSONObjectWithData:jsonData
                                    options:NSJSONReadingMutableContainers
                                      error:&ns_error];
    
    return jsonobject;
}

+ (NSMutableArray*)convertToMutableNSArray:(NSString*)json {
    NSData* jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError* __autoreleasing ns_error;
    NSMutableArray* jsonobject =
    [NSJSONSerialization JSONObjectWithData:jsonData
                                    options:NSJSONReadingMutableContainers
                                      error:&ns_error];
    
    return jsonobject;
}

+ (NSMutableDictionary*) convertToMutableNSDictionary:(NSString*)json {
    NSData* jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError* __autoreleasing ns_error;
    NSMutableDictionary* jsonobject =
    [NSJSONSerialization JSONObjectWithData:jsonData
                                    options:kNilOptions
                                      error:&ns_error];
    return jsonobject;
}

@end

//+(NSString *) decodeJSONFromResponse:(NSString *) str key:(NSString *) key{
//    NSDictionary *dictionary = [JSONUtil convertToNSDictionary:str];
//    NSString *decodedStr = [dictionary objectForKey:key];
//
//    return decodedStr;
//}

// Test writing json...
//            NSDictionary *data = [NSDictionary
//            dictionaryWithObjectsAndKeys:@"test@test.com", @"user",@"mypass",
//            @"pass", nil];
//            NSError * __autoreleasing ns_error;
//            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
//            options:NSJSONWritingPrettyPrinted error:&ns_error];
//            NSString *jsonString = [[NSString alloc] initWithData:jsonData
//            encoding:NSUTF8StringEncoding];
//            ALog(@"JSON Output: %@", jsonString);

// parse the JSON data into what is ultimately an NSDictionary
//            NSError * __autoreleasing ns_error;
//            id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
//            options:NSJSONReadingAllowFragments error:&ns_error];
//
//            // test that the object we parsed is a dictionary - perhaps you
//            would test for something different
//            if ([jsonObject respondsToSelector:@selector(objectForKey:)]) {
//                ALog(@"User: %@", [jsonObject objectForKey:@"user"]);
//                ALog(@"Pass: %@", [jsonObject objectForKey:@"auth_token"]);
//            }

// string to nsarray
// NSError *e;
// NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:nil
// error:&e];

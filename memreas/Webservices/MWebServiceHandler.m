#import "MWebServiceHandler.h"
#import "GalleryManager.h"
#import "ListAllMediaParser.h"
#import "MWebServiceBaseParser.h"
#import "MyConstant.h"
#import "XMLReader.h"

@implementation MWebServiceHandler
- (void)fetchServerResponse:(NSMutableURLRequest*)request
                     action:(NSString*)action
                        key:(NSString*)key {
    ALog(@"fetchServerResponse action: %@, notification key: %@, request: %@", action, key, request);
    NSURLSession* session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:(NSURLRequest*)request
                completionHandler:^(NSData* data, NSURLResponse* response,
                                    NSError* error) {
                    
                    if (!error) {
                        NSHTTPURLResponse* httpResp = (NSHTTPURLResponse*)response;
                        if (httpResp.statusCode == 200) {
                            if ([action isEqualToString:LISTALLMEDIA]) {
                                ListAllMediaParser* parser =
                                [[ListAllMediaParser alloc] init];
                                [parser doParse:data];
                                [[GalleryManager sharedGalleryInstance]
                                 objectParsed_ListAllMedia:parser.mediaItemDictionary];
                            } else if ([action isEqualToString:LOGIN]) {
                                // Setup tags for response...
                                NSMutableDictionary* responseTags =
                                [[NSMutableDictionary alloc] init];
                                [responseTags setObject:action forKey:@"action"];
                                [responseTags setObject:@"" forKey:@"status"];
                                [responseTags setObject:@"" forKey:@"message"];
                                [responseTags setObject:@"" forKey:@"username"];
                                [responseTags setObject:@"" forKey:@"user_id"];
                                [responseTags setObject:@"" forKey:@"sid"];
                                [responseTags setObject:@"" forKey:@"device_token"];
                                [responseTags setObject:@"" forKey:@"profile_pic_url"];
                                [responseTags setObject:@"" forKey:@"CloudFrontPolicy"];
                                [responseTags setObject:@"" forKey:@"CloudFrontSignature"];
                                [responseTags setObject:@"" forKey:@"CloudFrontKeyPairId"];
                                
                                
                                // Exec MWS
                                [self executeMWebServerCall:data
                                               responseTags:responseTags
                                           notificationName:key];
                            } else if ([action isEqualToString:GETUSERDETAILS]) {
                                NSMutableDictionary* responseTags =
                                [[NSMutableDictionary alloc] init];
                                [responseTags setObject:action forKey:@"action"];
                                [responseTags setObject:@"" forKey:@"status"];
                                [responseTags setObject:@"" forKey:@"message"];
                                [responseTags setObject:@"" forKey:@"username"];
                                [responseTags setObject:@"" forKey:@"profile"];
                                
                                // Exec MWS
                                [self executeMWebServerCall:data
                                               responseTags:responseTags
                                           notificationName:key];
                            } else if ([action isEqualToString:LISTNOTIFICATION]) {
                                //
                                // Here return xml as NSDictionary for notifications
                                //
                                // Exec MWS
                                [self returnMWebServerCallDictionary:action withData:data
                                             andWithNotificationName:LISTNOTIFICATION_RESULT_NOTIFICATION];
                            } else if ([action isEqualToString:REGISTRATION]) {
                                NSMutableDictionary* responseTags =
                                [[NSMutableDictionary alloc] init];
                                [responseTags setObject:action forKey:@"action"];
                                [responseTags setObject:@"" forKey:@"status"];
                                [responseTags setObject:@"" forKey:@"message"];
                                [responseTags setObject:@"" forKey:@"userid"];
                                [responseTags setObject:@""
                                                 forKey:@"email_verification_url"];
                                [responseTags setObject:@"" forKey:@"sid"];
                                // Exec MWS
                                [self executeMWebServerCall:data
                                               responseTags:responseTags
                                           notificationName:key];
                            } else if ([action isEqualToString:ADDMEDIAEVENT]) {
                                NSMutableDictionary* responseTags =
                                [[NSMutableDictionary alloc] init];
                                [responseTags setObject:action forKey:@"action"];
                                [responseTags setObject:@"" forKey:@"status"];
                                [responseTags setObject:@"" forKey:@"message"];
                                // Exec MWS
                                [self executeMWebServerCall:data
                                               responseTags:responseTags
                                           notificationName:key];
                            } else if ([action isEqualToString:FETCHCOPYRIGHTBATCH]) {
                                NSMutableDictionary* responseTags =
                                [[NSMutableDictionary alloc] init];
                                [responseTags setObject:action forKey:@"action"];
                                [responseTags setObject:@"" forKey:@"status"];
                                [responseTags setObject:@"" forKey:@"copyright_batch"];
                                // Exec MWS
                                [self executeMWebServerCall:data
                                               responseTags:responseTags
                                           notificationName:key];
                            } else if ([action isEqualToString:GENERATEMEDIAID]) {
                                NSMutableDictionary* responseTags =
                                [[NSMutableDictionary alloc] init];
                                [responseTags setObject:action forKey:@"action"];
                                [responseTags setObject:@"" forKey:@"status"];
                                [responseTags setObject:@"" forKey:@"media_id"];
                                [responseTags setObject:@"" forKey:@"media_id_batch"];
                                // Exec MWS
                                [self executeMWebServerCall:data
                                               responseTags:responseTags
                                           notificationName:key];
                            } else if ([action isEqualToString:CHECKUSERNAME]) {
                                NSMutableDictionary* responseTags =
                                [[NSMutableDictionary alloc] init];
                                [responseTags setObject:action forKey:@"action"];
                                [responseTags setObject:@"" forKey:@"status"];
                                [responseTags setObject:@"" forKey:@"message"];
                                [responseTags setObject:@"" forKey:@"isexist"];
                                // Exec MWS
                                [self executeMWebServerCall:data
                                               responseTags:responseTags
                                           notificationName:key];
                            } else if ([action isEqualToString:MEDIADEVICETRACKER]) {
                                //ALog(@"MEDIADEVICETRACKER result parsing...");
                                NSMutableDictionary* responseTags =
                                [[NSMutableDictionary alloc] init];
                                [responseTags setObject:action forKey:@"action"];
                                [responseTags setObject:@"" forKey:@"status"];
                                [responseTags setObject:@"" forKey:@"message"];
                                [responseTags setObject:@"" forKey:@"media_id"];
                                [responseTags setObject:@"" forKey:@"user_id"];
                                [responseTags setObject:@"" forKey:@"device_id"];
                                [responseTags setObject:@"" forKey:@"device_type"];
                                [responseTags setObject:@"" forKey:@"device_local_identifier"];
                                [responseTags setObject:@"" forKey:@"task_identifier"];
                                // Exec MWS
                                [self executeMWebServerCall:data
                                               responseTags:responseTags
                                           notificationName:key];
                            } else if ([action isEqualToString:ADDMEDIAEVENTCOMMENT]) {
                                NSMutableDictionary* responseTags =
                                [[NSMutableDictionary alloc] init];
                                [responseTags setObject:action forKey:@"action"];
                                [responseTags setObject:@"" forKey:@"status"];
                                [responseTags setObject:@"" forKey:@"message"];
                                // Exec MWS
                                [self executeMWebServerCall:data
                                               responseTags:responseTags
                                           notificationName:key];
                            } else if ([action isEqualToString:ADDEVENT]) {
                                NSMutableDictionary* responseTags =
                                [[NSMutableDictionary alloc] init];
                                [responseTags setObject:action forKey:@"action"];
                                [responseTags setObject:@"" forKey:@"status"];
                                [responseTags setObject:@"" forKey:@"message"];
                                [responseTags setObject:@"" forKey:@"event_id"];
                                // Exec MWS
                                [self executeMWebServerCall:data
                                               responseTags:responseTags
                                           notificationName:key];
                            } else if ([action isEqualToString:ADDCOMMENTS]) {
                                //ALog(@"ADDCOMMENT result parsing...");
                                NSMutableDictionary* responseTags =
                                [[NSMutableDictionary alloc] init];
                                [responseTags setObject:action forKey:@"action"];
                                [responseTags setObject:@"" forKey:@"status"];
                                [responseTags setObject:@"" forKey:@"message"];
                                // Exec MWS
                                [self executeMWebServerCall:data
                                               responseTags:responseTags
                                           notificationName:key];
                            } else if ([action isEqualToString:REPORTMEDIAINAPPROPRIATE]) {
                                //ALog(@"REPORTMEDIAINAPPROPRIATE result parsing...");
                                NSMutableDictionary* responseTags =
                                [[NSMutableDictionary alloc] init];
                                [responseTags setObject:action forKey:@"action"];
                                [responseTags setObject:@"" forKey:@"status"];
                                [responseTags setObject:@"" forKey:@"message"];
                                // Exec MWS
                                [self executeMWebServerCall:data
                                               responseTags:responseTags
                                           notificationName:key];
                            } else if ([action isEqualToString:ADDEXISTMEDIATOEVENT]) {
                                //ALog(@"ADDEXISTMEDIATOEVENT result parsing...");
                                NSMutableDictionary* responseTags =
                                [[NSMutableDictionary alloc] init];
                                [responseTags setObject:action forKey:@"action"];
                                [responseTags setObject:@"" forKey:@"status"];
                                [responseTags setObject:@"" forKey:@"message"];
                                // Exec MWS
                                [self executeMWebServerCall:data
                                               responseTags:responseTags
                                           notificationName:key];
                            } else if ([action isEqualToString:ADDFRIENDTOEVENT]) {
                                NSMutableDictionary* responseTags =
                                [[NSMutableDictionary alloc] init];
                                [responseTags setObject:action forKey:@"action"];
                                [responseTags setObject:@"" forKey:@"status"];
                                [responseTags setObject:@"" forKey:@"message"];
                                [responseTags setObject:@"" forKey:@"event_id"];
                                
                                //
                                // Handle Search and Memreas addfriendtoevent here
                                // - search uses xml method
                                //
                                
                                if ([key isEqualToString:SEARCH_ADD_FRIEND_TO_EVENT_RESPONSE]) {
                                    // Here return xml as NSDictionary for notifications
                                    [self returnMWebServerCallDictionary:action withData:data
                                                 andWithNotificationName:key];
                                    
                                } else {
                                    // Exec MWS
                                    [self executeMWebServerCall:data
                                                   responseTags:responseTags
                                               notificationName:key];
                                }
                            } else if ([action isEqualToString:UPDATENOTIFICATION]) {
                                NSMutableDictionary* responseTags =
                                [[NSMutableDictionary alloc] init];
                                [responseTags setObject:action forKey:@"action"];
                                [responseTags setObject:@"" forKey:@"status"];
                                [responseTags setObject:@"" forKey:@"message"];
                                [responseTags setObject:@"" forKey:@"notification_id"];
                                // Exec MWS
                                [self executeMWebServerCall:data
                                               responseTags:responseTags
                                           notificationName:key];
                            } else if ([action isEqualToString:LIKEMEDIA]) {
                                // Here return xml as NSDictionary for notifications
                                [self returnMWebServerCallDictionary:action withData:data
                                             andWithNotificationName:key];
                            } else if ([action isEqualToString:VIEWEVENTS]) {
                                // Here return xml as NSDictionary for notifications
                                [self returnMWebServerCallDictionary:action withData:data
                                             andWithNotificationName:key];
                            } else if ([action isEqualToString:VIEWALLFRIENDS]) {
                                // Here return xml as NSDictionary for notifications
                                [self returnMWebServerCallDictionary:action withData:data
                                             andWithNotificationName:key];
                            } else if ([action isEqualToString:ADDFRIEND]) {
                                // Here return xml as NSDictionary for notifications
                                [self returnMWebServerCallDictionary:action withData:data
                                             andWithNotificationName:key];
                            } else if ([action isEqualToString:FINDTAG]) {
                                // Here return xml as NSDictionary for notifications
                                [self returnMWebServerCallDictionary:action withData:data
                                             andWithNotificationName:key];
                            } else  {
                                // catch all
                                // Here return xml as NSDictionary for notifications
                                [self returnMWebServerCallDictionary:action withData:data
                                             andWithNotificationName:key];
                            } // close if ([action...])
                        } // close else if (httpResp.statusCode != 200)
                    } // close if (!error)
                }] resume];
}
- (void)executeMWebServerCall:(NSData*)data
                 responseTags:(NSMutableDictionary*)responseTags
             notificationName:(NSString*)notificationName {
    
    MWebServiceBaseParser* parser =
    [[MWebServiceBaseParser alloc] init:responseTags];
    [parser doParse:data];
    /**
     * Send notification to Caller here...
     */
    //ALog(@"INSIDE executeMWebServerCall::responseTags::%@ \n notificationName::%@",responseTags, notificationName);
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                        object:self
                                                      userInfo:parser.resultTags];
    
    //send on main thread if needed...
    //dispatch_async(dispatch_get_main_queue(), ^{
    //    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
    //                                                        object:self
    //                                                      userInfo:parser.resultTags];
    //});
    
}


//
// For Notifications only...
//
- (void) returnMWebServerCallDictionary:(NSString*)action withData:(NSData*) data
                andWithNotificationName:(NSString*)notificationName {
    
    //
    // Check for json
    //
    NSError *error;
    NSDictionary*dictResponse ;
    if (self.isJsonParsing) {
        dictResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    }else{
        dictResponse = [XMLReader dictionaryForXMLData:data error:&error];
        dictResponse = dictResponse[@"xml"];
    }
    
    /**
     * Send notification to Caller here...
     */
    //ALog(@"INSIDE executeMWebServerCall::dictResponse::%@ \n notificationName::%@",dictResponse, notificationName);
    //ALog(@"INSIDE executeMWebServerCall::notificationName::%@",notificationName);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                            object:self
                                                          userInfo:dictResponse];
    });
}


-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

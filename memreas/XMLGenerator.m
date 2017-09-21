#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "XMLReader requires ARC support."
#endif
#import <Foundation/Foundation.h>
#import "XMLGenerator.h"


@implementation XMLGenerator

+ (NSString*)generateCheckUserNameXML:(NSString*)username {
    NSString* requestXML = @"<xml>";
    requestXML = [requestXML stringByAppendingFormat:@"<checkusername>"];
    requestXML =
    [requestXML stringByAppendingFormat:@"<username>%@</username>", username];
    requestXML = [requestXML stringByAppendingFormat:@"</checkusername>"];
    requestXML = [requestXML stringByAppendingFormat:@"</xml>"];
    
    return requestXML;
}

+ (NSString*)generateLoginXML:(NSString*)username
                     password:(NSString*)password
                    device_id:(NSString*)device_id
                   devicetype:(NSString*)devicetype
                  devicetoken:(NSString*)devicetoken {
    NSString* requestXML = @"<xml>";
    requestXML = [requestXML stringByAppendingFormat:@"<login>"];
    requestXML =
    [requestXML stringByAppendingFormat:@"<username>%@</username>", username];
    requestXML =
    [requestXML stringByAppendingFormat:@"<password>%@</password>", password];
    requestXML = [requestXML
                  stringByAppendingFormat:@"<device_id>%@</device_id>", device_id];
    requestXML = [requestXML
                  stringByAppendingFormat:@"<device_type>%@</device_type>", devicetype];
    requestXML = [requestXML
                  stringByAppendingFormat:@"<device_token>%@</device_token>", devicetoken];
    requestXML = [requestXML stringByAppendingFormat:@"</login>"];
    requestXML = [requestXML stringByAppendingFormat:@"</xml>"];
    
    return requestXML;
}

+ (NSString*)generateGetUserDetailsXML:(NSString*)sid
                               user_id:(NSString*)user_id {
    NSString* requestXML = @"<xml>";
    requestXML = [requestXML stringByAppendingFormat:@"<sid>%@</sid>", sid];
    requestXML = [requestXML stringByAppendingFormat:@"<getuserdetails>"];
    requestXML =
    [requestXML stringByAppendingFormat:@"<user_id>%@</user_id>", user_id];
    requestXML = [requestXML stringByAppendingFormat:@"</getuserdetails>"];
    requestXML = [requestXML stringByAppendingFormat:@"</xml>"];
    
    return requestXML;
}

+ (NSString*)generateListNotificationsXML:(NSString*)sid
                                  user_id:(NSString*)user_id {
    NSString* requestXML = @"<xml>";
    requestXML = [requestXML stringByAppendingFormat:@"<sid>%@</sid>", sid];
    requestXML = [requestXML stringByAppendingFormat:@"<listnotification>"];
    requestXML =
    [requestXML stringByAppendingFormat:@"<user_id>%@</user_id>", user_id];
    requestXML = [requestXML stringByAppendingFormat:@"</listnotification>"];
    requestXML = [requestXML stringByAppendingFormat:@"</xml>"];
    
    return requestXML;
}

+ (NSString*)generateLogoutXML:(NSString*)sid user_id:(NSString*)user_id {
    NSString* requestXML = @"<xml>";
    requestXML = [requestXML stringByAppendingFormat:@"<sid>%@</sid>", sid];
    requestXML = [requestXML stringByAppendingFormat:@"<logout>"];
    requestXML =
    [requestXML stringByAppendingFormat:@"<user_id>%@</user_id>", user_id];
    requestXML = [requestXML stringByAppendingFormat:@"</logout>"];
    requestXML = [requestXML stringByAppendingFormat:@"</xml>"];
    
    return requestXML;
}

+ (NSString*)generateRegistrationXML:(NSString*)email
                            username:(NSString*)username
                            password:(NSString*)password
                           device_id:(NSString*)device_id
                         device_type:(NSString*)device_type
                       profile_photo:(NSString*)profile_photo
                          invited_by:(NSString*)invited_by secret:(NSString*)secret{
    NSString* requestXML = @"<xml>";
    requestXML = [requestXML stringByAppendingFormat:@"<registration>"];
    requestXML = [requestXML stringByAppendingFormat:@"<email>%@</email>", email];
    requestXML =
    [requestXML stringByAppendingFormat:@"<username>%@</username>", username];
    requestXML =
    [requestXML stringByAppendingFormat:@"<password>%@</password>", password];
    requestXML = [requestXML
                  stringByAppendingFormat:@"<device_id>%@</device_id>", device_id];
    requestXML = [requestXML
                  stringByAppendingFormat:@"<device_type>%@</device_type>", device_type];
    requestXML = [requestXML
                  stringByAppendingFormat:@"<profile_photo>%@</profile_photo>", profile_photo];
    requestXML = [requestXML
                  stringByAppendingFormat:@"<secret>%@</secret>", secret];
    
    requestXML = [requestXML
                  stringByAppendingFormat:@"<invited_by>%@</invited_by>", invited_by];
    requestXML = [requestXML stringByAppendingFormat:@"</registration>"];
    requestXML = [requestXML stringByAppendingFormat:@"</xml>"];
    
    return requestXML;
}

+ (NSString*)generateChangePasswordXML:(NSString*)password
                                verify:(NSString*)verify
                                  code:(NSString*)code {
    NSString* requestXML = @"<xml>";
    requestXML = [requestXML stringByAppendingFormat:@"<changepassword>"];
    requestXML = [requestXML stringByAppendingFormat:@"<username></username>"];
    requestXML = [requestXML stringByAppendingFormat:@"<password></password>"];
    requestXML = [requestXML stringByAppendingFormat:@"<new>%@</new>", password];
    requestXML =
    [requestXML stringByAppendingFormat:@"<retype>%@</retype>", verify];
    requestXML = [requestXML stringByAppendingFormat:@"<token>%@</token>", code];
    requestXML = [requestXML stringByAppendingFormat:@"</changepassword>"];
    requestXML = [requestXML stringByAppendingFormat:@"</xml>"];
    
    return requestXML;
}

+ (NSString*)generateForgotPasswordXML:(NSString*)email {
    NSString* requestXML = @"<xml>";
    requestXML = [requestXML stringByAppendingFormat:@"<forgotpassword>"];
    requestXML = [requestXML stringByAppendingFormat:@"<email>%@</email>", email];
    requestXML = [requestXML stringByAppendingFormat:@"</forgotpassword>"];
    requestXML = [requestXML stringByAppendingFormat:@"</xml>"];
    
    return requestXML;
}

+ (NSString*)generateListAllMediaXML:(NSString*)sid
                             user_id:(NSString*)user_id
                            event_id:(NSString*)event_id
                           device_id:(NSString*)device_id
                            metadata:(NSString*)metadata
                                page:(NSString*)page
                               limit:(NSString*)limit {
    NSString* requestXML = @"<xml>";
    requestXML = [requestXML stringByAppendingFormat:@"<sid>%@</sid>", sid];
    requestXML = [requestXML stringByAppendingFormat:@"<listallmedia>"];
    requestXML =
    [requestXML stringByAppendingFormat:@"<user_id>%@</user_id>", user_id];
    requestXML =
    [requestXML stringByAppendingFormat:@"<event_id>%@</event_id>", event_id];
    requestXML = [requestXML
                  stringByAppendingFormat:@"<device_id>%@</device_id>", device_id];
    requestXML =
    [requestXML stringByAppendingFormat:@"<metadata>%@</metadata>", metadata];
    requestXML = [requestXML stringByAppendingFormat:@"<page>%@</page>", page];
    requestXML = [requestXML stringByAppendingFormat:@"<limit>%@</limit>", limit];
    requestXML = [requestXML stringByAppendingFormat:@"</listallmedia>"];
    requestXML = [requestXML stringByAppendingFormat:@"</xml>"];
    
    return requestXML;
}

+ (NSString*)generateAddMediaEventXML:(NSString*)sid
                           withUserId:(NSString*)user_id
                      andWithDeviceId:(NSString*)device_id
                    andWithDeviceTYPE:(NSString*)device_type
                       andWithEventId:(NSString*)event_id
                       andWithMediaId:(NSString*)media_id
                         andWithS3Url:(NSString*)s3url
                   andWithContentType:(NSString*)content_type
                    andWithS3FileName:(NSString*)s3file_name
                 andWithIsServerImage:(NSString*)is_server_image
                  andWithIsProfilePic:(NSString*)is_profile_pic
                      andWithLocation:(NSString*)location
                     andWithCopyRight:(NSString*)copyright isRegistration:(BOOL)isregistration{
    /*
     <xml>
     <addmediaevent>
     <user_id>4b2c6d4c-42a7-11e3-85d4-22000a8a1935</user_id>
     <device_id>354614666375243</device_id>
     <event_id></event_id>
     <media_id></media_id>
     <s3url>0.jpg</s3url>
     <content_type>image/png</content_type>
     <s3file_name>0.jpg</s3file_name>
     <is_server_image>0</is_server_image>
     <is_profile_pic>0</is_profile_pic>
     <location>{"latitude": "my_latitude","longitude": "my_longitude"}</location>
     </addmediaevent>
     </xml>
     */
    
    NSString* requestXML = @"<xml>";
    requestXML = [requestXML stringByAppendingFormat:@"<sid>%@</sid>", sid];
    requestXML = [requestXML stringByAppendingFormat:@"<addmediaevent>"];
    requestXML =
    [requestXML stringByAppendingFormat:@"<user_id>%@</user_id>", user_id];
    requestXML = [requestXML
                  stringByAppendingFormat:@"<device_id>%@</device_id>", device_id];
    requestXML = [requestXML
                  stringByAppendingFormat:@"<device_type>%@</device_type>", device_type];
    requestXML =
    [requestXML stringByAppendingFormat:@"<event_id>%@</event_id>", event_id];
    requestXML =
    [requestXML stringByAppendingFormat:@"<is_registration>%@</is_registration>", isregistration?@"1":@"0"];
    requestXML =
    [requestXML stringByAppendingFormat:@"<media_id>%@</media_id>", media_id];
    requestXML = [requestXML stringByAppendingFormat:@"<s3url>%@</s3url>", s3url];
    requestXML = [requestXML
                  stringByAppendingFormat:@"<content_type>%@</content_type>", content_type];
    requestXML = [requestXML
                  stringByAppendingFormat:@"<s3file_name>%@</s3file_name>", s3file_name];
    requestXML = [requestXML
                  stringByAppendingFormat:@"<is_server_image>%@</is_server_image>",
                  is_server_image];
    requestXML = [requestXML
                  stringByAppendingFormat:@"<is_profile_pic>%@</is_profile_pic>",
                  is_profile_pic];
    requestXML =
    [requestXML stringByAppendingFormat:@"<location>%@</location>", location];
    requestXML = [requestXML
                  stringByAppendingFormat:@"<copyright>%@</copyright>", copyright];
    requestXML = [requestXML stringByAppendingFormat:@"</addmediaevent>"];
    requestXML = [requestXML stringByAppendingFormat:@"</xml>"];
    
    return requestXML;
}

+ (NSString*)generateAddExistingMediaToEventXML:(NSString*)sid
                                    withEventId:(NSString*)eventId
                               andWithMediatems:(NSArray*)mediaItems {
    /*
     <xml>
     <sid></sid>
     <addexistmediatoevent>
     <event_id>1</event_id>
     <media_ids>
     <media_id>1</media_id>
     <media_id>2</media_id>
     </media_ids>
     </addexistmediatoevent>
     </xml>
     */
    
    NSString* requestXML = @"<xml>";
    requestXML = [requestXML stringByAppendingFormat:@"<sid>%@</sid>", sid];
    requestXML = [requestXML stringByAppendingFormat:@"<addexistmediatoevent>"];
    requestXML = [requestXML stringByAppendingFormat:@"<event_id>%@</event_id>", eventId];
    requestXML = [requestXML stringByAppendingFormat:@"<media_ids>"];
    
    //
    // for loop array here...
    //
    for (MediaItem* mediaItem in mediaItems) {
        requestXML = [requestXML stringByAppendingFormat:@"<media_id>%@</media_id>", mediaItem.mediaId];
    }
    
    //
    // Close here
    //
    requestXML = [requestXML stringByAppendingFormat:@"</media_ids>"];
    requestXML = [requestXML stringByAppendingFormat:@"</addexistmediatoevent>"];
    requestXML = [requestXML stringByAppendingFormat:@"</xml>"];
    
    return requestXML;
}


+ (NSString*)generateMediaIdXML:(NSString*)sid {
    NSString* requestXML = @"<xml>";
    requestXML = [requestXML stringByAppendingFormat:@"<sid>%@</sid>", sid];
    requestXML = [requestXML stringByAppendingFormat:@"<generatemediaid>"];
    requestXML = [requestXML stringByAppendingFormat:@"<media_id>0</media_id>"];
    requestXML = [requestXML stringByAppendingFormat:@"<media_id_batch>1</media_id_batch>"];
    requestXML = [requestXML stringByAppendingFormat:@"</generatemediaid>"];
    requestXML = [requestXML stringByAppendingFormat:@"</xml>"];
    
    return requestXML;
}

+ (NSString*)fetchcopyrightbatchXML:(NSString*)sid {
    NSString* requestXML = @"<xml>";
    requestXML = [requestXML stringByAppendingFormat:@"<sid>%@</sid>", sid];
    requestXML = [requestXML stringByAppendingFormat:@"<fetchcopyrightbatch>"];
    requestXML = [requestXML stringByAppendingFormat:@"</fetchcopyrightbatch>"];
    requestXML = [requestXML stringByAppendingFormat:@"</xml>"];
    
    return requestXML;
}

+ (NSString*)fetchmediaidbatchXML:(NSString*)sid {
    NSString* requestXML = @"<xml>";
    requestXML = [requestXML stringByAppendingFormat:@"<sid>%@</sid>", sid];
    requestXML = [requestXML stringByAppendingFormat:@"<fetchcopyrightbatch>"];
    requestXML = [requestXML stringByAppendingFormat:@"</fetchcopyrightbatch>"];
    requestXML = [requestXML stringByAppendingFormat:@"</xml>"];
    
    return requestXML;
}



+ (NSString *)mediaDeviceTrackerXML:(NSString *)sid
                           media_id:(NSString *)media_id
                            user_id:(NSString *)user_id
                          device_id:(NSString *)device_id
                        device_type:(NSString *)device_type
            device_local_identifier:(NSString *)device_local_identifier
                    task_identifier:(NSString *) task_identifier {
    
    // Sample xml
    // <xml>
    //  <mediadevicetracker>
    //      <media>
    //          <media_id></media_id>
    //          <user_id></user_id>
    //          <device_id></device_id>
    //          <device_type></device_type>
    //          <device_local_identifier></device_local_identifier>
    //          <task_identifier></task_identifier>
    //      </media>
    //  <mediadevicetracker>
    // <xml>
    NSString* requestXML = @"<xml>";
    requestXML = [requestXML stringByAppendingFormat:@"<sid>%@</sid>", sid];
    requestXML = [requestXML stringByAppendingFormat:@"<mediadevicetracker>"];
    requestXML =
    [requestXML stringByAppendingFormat:@"<media_id>%@</media_id>", media_id];
    requestXML =
    [requestXML stringByAppendingFormat:@"<user_id>%@</user_id>", user_id];
    requestXML = [requestXML
                  stringByAppendingFormat:@"<device_id>%@</device_id>", device_id];
    requestXML = [requestXML
                  stringByAppendingFormat:@"<device_type>%@</device_type>", device_type];
    requestXML = [requestXML
                  stringByAppendingFormat:@"<device_local_identifier>%@</device_local_identifier>", device_local_identifier];
    requestXML = [requestXML
                  stringByAppendingFormat:@"<task_identifier>%@</task_identifier>", task_identifier];
    requestXML = [requestXML stringByAppendingFormat:@"</mediadevicetracker>"];
    requestXML = [requestXML stringByAppendingFormat:@"</xml>"];
    
    return requestXML;
}


+ (NSString *) generateUpdateMediaXML:(NSString *)sid
                             media_id:(NSString *)media_id
                              address:(NSString *)address
                             latitude:(double)latitude
                            longitude:(double)longitude
{
    
    // Sample xml
    //  <xml>
    //      <sid></sid>
    //      <updatemedia>
    //          <media>
    //              <media_id></media_id>
    //              <location>
    //                  <address></address>
    //                  <latitude></latitude>
    //                  <longitude></longitude>
    //              </location>
    //          </media>
    //      </updatemedia>
    //  </xml>
    NSString* requestXML = @"<xml>";
    requestXML = [requestXML stringByAppendingFormat:@"<sid>%@</sid>", sid];
    requestXML = [requestXML stringByAppendingFormat:@"<updatemedia>"];
    requestXML = [requestXML stringByAppendingFormat:@"<media>"];
    requestXML =
    [requestXML stringByAppendingFormat:@"<media_id>%@</media_id>", media_id];
    requestXML = [requestXML stringByAppendingFormat:@"<location>"];
    requestXML =
    [requestXML stringByAppendingFormat:@"<address>%@</address>", address];
    requestXML = [requestXML
                  stringByAppendingFormat:@"<latitude>%@</latitude>", @(latitude)];
    requestXML = [requestXML
                  stringByAppendingFormat:@"<longitude>%@</longitude>", @(longitude)];
    requestXML = [requestXML stringByAppendingFormat:@"</location>"];
    requestXML = [requestXML stringByAppendingFormat:@"</media>"];
    requestXML = [requestXML stringByAppendingFormat:@"</updatemedia>"];
    requestXML = [requestXML stringByAppendingFormat:@"</xml>"];
    
    return requestXML;
}

+ (NSString *) generateAddEventXML:(NSString *)sid
                           user_id:(NSString *)user_id
                        event_name:(NSString *)event_name
                        event_date:(NSString *)event_date
                    event_location:(NSString *)event_location
                        event_from:(NSString *)event_from
                          event_to:(NSString *)event_to
          is_friend_can_add_friend:(NSString *)is_friend_can_add_friend
          is_friend_can_post_media:(NSString *)is_friend_can_post_media
               event_self_destruct:(NSString *)event_self_destruct
                         is_public:(NSString *)is_public
{
    
    // Sample xml
    //  <xml>
    //      <sid></sid>
    //      <addevent>
    //              <user_id>1</user_id>
    //              <event_name>Event 1</event_name>
    //              <event_date>22/02/2013</event_date>
    //              <event_location>Ahmedabad</event_location>
    //              <event_from>22/02/2013</event_from>
    //              <event_to>28/02/2013</event_to>
    //              <is_friend_can_add_friend>1</is_friend_can_add_friend>
    //              <is_friend_can_post_media>0</is_friend_can_post_media>
    //              <event_self_destruct>02/03/2013</event_self_destruct>
    //              <is_public>1</is_public>
    //      </addevent>
    //    </xml>
    //
    
    NSString* requestXML = @"<xml>";
    requestXML = [requestXML stringByAppendingFormat:@"<sid>%@</sid>", sid];
    requestXML = [requestXML stringByAppendingFormat:@"<addevent>"];
    requestXML = [requestXML stringByAppendingFormat:@"<user_id>%@</user_id>", user_id];
    requestXML = [requestXML stringByAppendingFormat:@"<event_name>%@</event_name>", event_name];
    requestXML = [requestXML stringByAppendingFormat:@"<event_date>%@</event_date>", event_date];
    requestXML = [requestXML stringByAppendingFormat:@"<event_location>%@</event_location>", event_location];
    requestXML = [requestXML stringByAppendingFormat:@"<event_from>%@</event_from>", event_from];
    requestXML = [requestXML stringByAppendingFormat:@"<event_to>%@</event_to>", event_to];
    requestXML = [requestXML stringByAppendingFormat:@"<is_friend_can_add_friend>%@</is_friend_can_add_friend>", is_friend_can_add_friend];
    requestXML = [requestXML stringByAppendingFormat:@"<is_friend_can_post_media>%@</is_friend_can_post_media>", is_friend_can_post_media];
    requestXML = [requestXML stringByAppendingFormat:@"<event_self_destruct>%@</event_self_destruct>", event_self_destruct];
    requestXML = [requestXML stringByAppendingFormat:@"<is_public>%@</is_public>", is_public];
    requestXML = [requestXML stringByAppendingFormat:@"</addevent>"];
    requestXML = [requestXML stringByAppendingFormat:@"</xml>"];
    
    return requestXML;
    
}


+ (NSString *) generateAddFriendToEventXML:(NSString *) sid
                                withUserId:(NSString*) userId
                            andWithEventId:(NSString*) eventId
                           andWithContacts:(NSArray*) contacts
{
    //
    // Sample XML
    //
    //<xml>
    //<sid></sid>
    //<addfriendtoevent>
    //    <user_id></user_id>
    //    <event_id></event_id>
    //    <friends>
    //      <friend>
    //          <friend_name>%@</friend_name>
    //          <friend_id>%@</friend_id>
    //          <network_name>memreas</network_name>
    //      </friend>
    //     </friends>
    //    <emails>
    //      <email></email>
    //    </emails>
    //</addfriendtoevent>
    //</xml>
    
    NSString* requestXML = @"<xml>";
    requestXML = [requestXML stringByAppendingFormat:@"<sid>%@</sid>", sid];
    requestXML = [requestXML stringByAppendingFormat:@"<addfriendtoevent>"];
    requestXML = [requestXML stringByAppendingFormat:@"<user_id>%@</user_id>",userId];
    requestXML = [requestXML stringByAppendingFormat:@"<event_id>%@</event_id>",eventId];
    
    //
    // memreas friends
    //
    requestXML = [requestXML stringByAppendingFormat:@"<friends>"];
    for (int i = 0; i<contacts.count; i++) {
        
        FriendsContactEntry *entry = contacts[i];
        // friends
        if (entry.friendType == MemreasNetwork) {
            requestXML = [requestXML stringByAppendingFormat:@"<friend>"];
            requestXML = [requestXML stringByAppendingFormat:@"<friend_name>%@</friend_name>", [entry.objectOfFriend valueForKeyPath:@"social_username.text"]];
            requestXML = [requestXML stringByAppendingFormat:@"<friend_id>%@</friend_id>", [entry.objectOfFriend valueForKeyPath:@"friend_id.text"]];
            requestXML = [requestXML stringByAppendingFormat:@"<network_name>memreas</network_name>"];
            requestXML = [requestXML stringByAppendingFormat:@"</friend>"];
        }
    }
    requestXML = [requestXML stringByAppendingFormat:@"</friends>"];
    
    //
    // emails
    //
    requestXML = [requestXML stringByAppendingFormat:@"<emails>"];
    for (int i = 0; i<contacts.count; i++) {
        
        FriendsContactEntry *entry = contacts[i];
        if (entry.friendType == PhoneBookContact) {
            NSDictionary *contactDetail = entry.objectOfFriend;
            for (int x = 0; x < [contactDetail[@"EmailArray"] count]; x++) {
                NSString *email = contactDetail[@"EmailArray"][x];
                requestXML = [requestXML stringByAppendingFormat:@"<email>"];
                requestXML = [requestXML stringByAppendingString:email];
                requestXML = [requestXML stringByAppendingFormat:@"</email>"];
            }
        }
    }
    requestXML = [requestXML stringByAppendingFormat:@"</emails>"];
    requestXML = [requestXML stringByAppendingFormat:@"</addfriendtoevent>"];
    requestXML = [requestXML stringByAppendingFormat:@"</xml>"];
    
    return requestXML;
    
}

+(NSString*)generateXMLForListNotification{
    
    NSString* requestXML = @"<xml>";
    requestXML = [requestXML stringByAppendingFormat:@"<sid>%@</sid>", [[NSUserDefaults standardUserDefaults] objectForKey:@"SID"]];
    requestXML = [requestXML stringByAppendingFormat:@"<listnotification>"];
    requestXML =
    [requestXML stringByAppendingFormat:@"<receiver_uid>%@</receiver_uid>", [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"]];
    requestXML = [requestXML stringByAppendingFormat:@"</listnotification>"];
    requestXML = [requestXML stringByAppendingFormat:@"</xml>"];
    
    return requestXML;
    
}


+ (NSString *) generateUpdateNotificationXML:(NSString *) notification_id
                                withStatus:(NSString*) status
                            andWithMessage:(NSString*) message
{
    //
    // Sample XML
    //
    //    <xml>
    //      <sid></sid>
    //      <updatenotification>
    //          <notification>
    //              <notification_id>5f173f40-2d87-11e3-b8a8-27e1f11594a6</notification_id>
    //              <status>2</status>
    //              <message>optinal</message>
    //          </notification>
    //          <notification>
    //              <notification_id>5f173f40-2d87-11e3-b8a8-27e1f11594a6</notification_id>
    //              <status>2</status>
    //          </notification>
    //          <notification>
    //              <notification_id>5f173f40-2d87-11e3-b8a8-27e1f11594a6</notification_id>
    //              <status>2</status>
    //          </notification>
    //      </updatenotification>
    //    </xml>
    
    NSString* requestXML = @"<xml>";
    requestXML = [requestXML stringByAppendingFormat:@"<sid>%@</sid>", [Helper fetchSID]];
    requestXML = [requestXML stringByAppendingFormat:@" <updatenotification>"];
    requestXML = [requestXML stringByAppendingFormat:@"     <notification>"];
    requestXML = [requestXML stringByAppendingFormat:@"         <notification_id>%@</notification_id>",notification_id];
    requestXML = [requestXML stringByAppendingFormat:@"         <status>%@</status>",status];
    requestXML = [requestXML stringByAppendingFormat:@"         <message>%@</message>",message];
    requestXML = [requestXML stringByAppendingFormat:@"     </notification>"];
    requestXML = [requestXML stringByAppendingFormat:@" </updatenotification>"];
    requestXML = [requestXML stringByAppendingFormat:@"</xml>"];
    
    return requestXML;
}


+(NSString*)generateXMLForUpdateNotificationMessage:(NSString*)message andDic:(NSDictionary*)dic andStatus:(NSString*)status{
    
    NSString* requestXML = @"<xml>";
    requestXML = [requestXML stringByAppendingFormat:@"<sid>%@</sid>", [[NSUserDefaults standardUserDefaults] objectForKey:@"SID"]];
    requestXML = [requestXML stringByAppendingFormat:@"<updatenotification>"];
    requestXML = [requestXML stringByAppendingFormat:@"<notification>"];
    
    requestXML = [requestXML stringByAppendingFormat:@"<notification_id>%@</notification_id>",dic[@"notification_id"]];
    requestXML = [requestXML stringByAppendingFormat:@"<message>%@</message>",message?message:@""];
    requestXML = [requestXML stringByAppendingFormat:@"<status>%@</status>",status];
    
    requestXML = [requestXML stringByAppendingFormat:@"</notification>"];
    requestXML = [requestXML stringByAppendingFormat:@"</updatenotification>"];
    requestXML = [requestXML stringByAppendingFormat:@"</xml>"];
    
    
    return requestXML;
    
}

+(NSString *) generateXMLForMediaInappropriate:(NSString*)event_id
                                   withMedidId:(NSString *)media_id
                               withReasonTypes:(NSArray *)reason_types

{
    //
    // Sample xml
    //
    
    //<?xml version="1.0" encoding="UTF-8"?>
    //  <xml>
    //      <sid></sid>
    //      <mediainappropriate>
    //          <event_id>event_id</event_id>
    //          <reporting_user_id>reporting_user_id</reporting_user_id>
    //          <media_id>1</media_id>
    //          <inappropriate>1</inappropriate>
    //          <reason_types>
    //              <reason_type>...</reason_type>
    //          </reason_types>
    //      </mediainappropriate>
    //  </xml>
    
    NSString* requestXML = @"<xml>";
    requestXML = [requestXML stringByAppendingFormat:@"<sid>%@</sid>", [Helper fetchSID]];
    requestXML = [requestXML stringByAppendingFormat:@"<mediainappropriate>"];
    requestXML = [requestXML stringByAppendingFormat:@"<event_id>%@</event_id>", event_id];
    requestXML = [requestXML stringByAppendingFormat:@"<reporting_user_id>%@</reporting_user_id>", [Helper fetchUserId]];
    requestXML = [requestXML stringByAppendingFormat:@"<media_id>%@</media_id>", media_id];
    requestXML = [requestXML stringByAppendingFormat:@"<inappropriate>%@</inappropriate>", @"1"];
    if ([reason_types count] > 0) {
        requestXML = [requestXML stringByAppendingFormat:@"<reason_types>"];
        for (id reason in reason_types) {
            if ([reason isKindOfClass:[NSString class]]) {
                requestXML = [requestXML stringByAppendingFormat:@"<reason_type>%@</reason_type>", reason];
            }
        }
        requestXML = [requestXML stringByAppendingFormat:@"</reason_types>"];
    }
    
    requestXML = [requestXML stringByAppendingFormat:@"</mediainappropriate>"];
    requestXML = [requestXML stringByAppendingFormat:@"</xml>"];
    
    return requestXML;
    
}

+(NSString *) generateAddCommentXML:(NSString*)user_id
                        withEventId:(NSString *)event_id
                     andWithMediaId:(NSString *) media_id
                andWithAudioMediaId:(NSString *) audio_media_id
                    andWithComments:(NSString *)comments
{
    
    //
    // Sample XML
    //
    //    <?xml version="1.0" encoding="UTF-8"?>
    //        <xml>
    //        <sid></sid>
    //        <addcomment>
    //            <event_id>1</event_id>
    //            <media_id>1</media_id>
    //            <user_id />
    //            <comments>comments</comments>
    //            <audio_media_id>audio_id</audio_media_id>
    //        </addcomment>
    //        </xml>
    
    NSString* requestXML = @"<xml>";
    requestXML = [requestXML stringByAppendingFormat:@"<sid>%@</sid>", [Helper fetchSID]];
    requestXML = [requestXML stringByAppendingFormat:@"<addcomment>"];
    requestXML = [requestXML stringByAppendingFormat:@"<event_id>%@</event_id>", event_id];
    requestXML = [requestXML stringByAppendingFormat:@"<user_id>%@</user_id>", [Helper fetchUserId]];
    requestXML = [requestXML stringByAppendingFormat:@"<media_id>%@</media_id>", media_id];
    requestXML = [requestXML stringByAppendingFormat:@"<comments>%@</comments>", comments];
    requestXML = [requestXML stringByAppendingFormat:@"<audio_media_id>%@</audio_media_id>", audio_media_id];
    requestXML = [requestXML stringByAppendingFormat:@"</addcomment>"];
    requestXML = [requestXML stringByAppendingFormat:@"</xml>"];
    
    return requestXML;
    
    
    
}


+ (NSString *) generateViewEventsXML:(int) is_my_event
                andWithIsFriendEvent:(int) is_friend_event
                andWithIsPublicEvent:(int) is_public_event
{
    //
    // Sample XML
    //
    //<xml>
    //  <sid></sid>
    //  <viewevent>
    //      <user_id>1</user_id>
    //      <is_my_event>1</is_my_event>
    //      <is_friend_event>0</is_friend_event>
    //      <is_public_event>0</is_public_event>
    //      <page>1</page>
    //      <limit>500</limit>
    //  </viewevent>
    //</xml>
    
    NSString* requestXML = @"<xml>";
    requestXML = [requestXML stringByAppendingFormat:@"<sid>%@</sid>", [Helper fetchSID]];
    requestXML = [requestXML stringByAppendingFormat:@"<viewevent>"];
    requestXML = [requestXML stringByAppendingFormat:@"<user_id>%@</user_id>", [Helper fetchUserId]];
    requestXML = [requestXML stringByAppendingFormat:@"<is_my_event>%@</is_my_event>", @(is_my_event)];
    requestXML = [requestXML stringByAppendingFormat:@"<is_friend_event>%@</is_friend_event>", @(is_friend_event)];
    requestXML = [requestXML stringByAppendingFormat:@"<is_public_event>%@</is_public_event>", @(is_public_event)];
    requestXML = [requestXML stringByAppendingFormat:@"<page>%@</page>", @(1)]; // fix: hard code
    requestXML = [requestXML stringByAppendingFormat:@"<limit>%@</limit>", @(500)]; // fix: hard code
    requestXML = [requestXML stringByAppendingFormat:@"</viewevent>"];
    requestXML = [requestXML stringByAppendingFormat:@"</xml>"];
    
    return requestXML;
    
}

+ (NSString *)generateXMLForInputDictionary:(NSDictionary*)input andSID:(NSString*)sid andWebMethod:(NSString*)webMethod{
    
    NSString* requestXML = @"<xml>";
    requestXML = [requestXML stringByAppendingFormat:@"<sid>%@</sid>", sid];
    requestXML = [requestXML stringByAppendingFormat:@"<%@>",webMethod];
    
    for (int x = 0; x<input.allKeys.count; x++) {
        NSString *key = [input.allKeys objectAtIndex:x];
        NSString *value = [input.allValues objectAtIndex:x];
        requestXML = [requestXML stringByAppendingFormat:@"<%@>%@</%@>",key,value,key];
    }
    requestXML = [requestXML stringByAppendingFormat:@"</%@>",webMethod];
    requestXML = [requestXML stringByAppendingFormat:@"</xml>"];
    return requestXML;
    
}




@end

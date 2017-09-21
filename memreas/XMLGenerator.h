#import <Foundation/Foundation.h>
#import "Helper.h"
#import "FriendsContactEntry.h"
#import "MyConstant.h"
#import "MediaItem.h"

@interface XMLGenerator : NSObject {
}

+ (NSString *)generateCheckUserNameXML:(NSString *)username;
+ (NSString *)generateLoginXML:(NSString *)username
                      password:(NSString *)password
                     device_id:(NSString *)device_id
                    devicetype:(NSString *)devicetype
                   devicetoken:(NSString *)devicetoken;
+ (NSString *)generateGetUserDetailsXML:(NSString *)sid
                                user_id:(NSString *)user_id;
+ (NSString *)generateListNotificationsXML:(NSString *)sid
                                   user_id:(NSString *)user_id;
+ (NSString *)generateLogoutXML:(NSString *)sid user_id:(NSString *)user_id;
+ (NSString*)generateRegistrationXML:(NSString*)email
                            username:(NSString*)username
                            password:(NSString*)password
                           device_id:(NSString*)device_id
                         device_type:(NSString*)device_type
                       profile_photo:(NSString*)profile_photo
                          invited_by:(NSString*)invited_by secret:(NSString*)secret;
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
                         is_public:(NSString *)is_public;
+ (NSString *)generateAddMediaEventXML:(NSString *)sid
                            withUserId:(NSString *)user_id
                       andWithDeviceId:(NSString *)device_id
                     andWithDeviceTYPE:(NSString *)device_type
                        andWithEventId:(NSString *)event_id
                        andWithMediaId:(NSString *)media_id
                          andWithS3Url:(NSString *)s3url
                    andWithContentType:(NSString *)content_type
                     andWithS3FileName:(NSString *)s3file_name
                  andWithIsServerImage:(NSString *)is_server_image
                   andWithIsProfilePic:(NSString *)is_profile_pic
                       andWithLocation:(NSString *)location
                      andWithCopyRight:(NSString *)copyright
                        isRegistration:(BOOL)isregistration;
+ (NSString*) generateAddExistingMediaToEventXML:(NSString *)sid
                                     withEventId:(NSString *)eventId
                                andWithMediatems:(NSArray *)mediaItems;
+ (NSString *)generateChangePasswordXML:(NSString *)password
                                 verify:(NSString *)verify
                                   code:(NSString *)code;
+ (NSString *)generateForgotPasswordXML:(NSString *)email;
+ (NSString *)generateListAllMediaXML:(NSString *)sid
                              user_id:(NSString *)user_id
                             event_id:(NSString *)event_id
                            device_id:(NSString *)device_id
                             metadata:(NSString *)metadata
                                 page:(NSString *)page
                                limit:(NSString *)limit;
+ (NSString *)generateMediaIdXML:(NSString *)sid;
+ (NSString *)fetchcopyrightbatchXML:(NSString *)sid;
+ (NSString *)fetchmediaidbatchXML:(NSString *)sid;
+ (NSString *)mediaDeviceTrackerXML:(NSString *)sid
                           media_id:(NSString *)media_id
                            user_id:(NSString *)user_id
                          device_id:(NSString *)device_id
                        device_type:(NSString *)device_type
            device_local_identifier:(NSString *)device_local_identifier
                    task_identifier:(NSString *) task_identifier;
+ (NSString *) generateUpdateMediaXML:(NSString *)sid
                             media_id:(NSString *)media_id
                              address:(NSString *)address
                             latitude:(double)latitude
                            longitude:(double)longitude;
+(NSString *) generateXMLForMediaInappropriate:(NSString*)event_id
                                   withMedidId:(NSString *)media_id
                               withReasonTypes:(NSArray *)reason_types
;
+(NSString *) generateAddCommentXML:(NSString*)user_id
                        withEventId:(NSString *)event_id
                     andWithMediaId:(NSString *) media_id
                andWithAudioMediaId:(NSString *) audio_media_id
                    andWithComments:(NSString *)comments;
+ (NSString *) generateAddFriendToEventXML:(NSString *) sid
                                withUserId:(NSString*) userId
                            andWithEventId:(NSString*) eventId
                           andWithContacts:(NSArray*) contacts;
+ (NSString *) generateViewEventsXML:(int) is_my_event
                andWithIsFriendEvent:(int) is_friend_event
                andWithIsPublicEvent:(int) is_public_event;
+ (NSString *) generateUpdateNotificationXML:(NSString *) notification_id
                                  withStatus:(NSString*) status
                              andWithMessage:(NSString*) message;


// - refactor these when possible...

+(NSString*) generateXMLForListNotification;
+(NSString*) generateXMLForUpdateNotificationMessage:(NSString*)message andDic:(NSDictionary*)dic andStatus:(NSString*)status;
+(NSString*) generateXMLForInputDictionary:(NSDictionary*)input andSID:(NSString*)sid andWebMethod:(NSString*)webMethod;



@end

@import Foundation;
@import MessageUI;
@class AppDelegate;
@class MyConstant;
@class FriendsContactEntry;
@class MWebServiceHandler;
@class WebServices;
@class WebServiceParser;
@class XMLGenerator;
@class XMLParser;
@class JSONUtil;
@class GalleryManager;
@class QueueController;
@class JSONUtil;

@interface ShareCreator : NSObject {
    AppDelegate* appDelegate;
}

//
// properties
//
@property (nonatomic) NSString* eventId;
@property (nonatomic) NSString* name;
@property (nonatomic) NSString* date;
@property (nonatomic) NSString* location;
@property (nonatomic) BOOL friendsCanPost;
@property (nonatomic) BOOL friendsCanAddFriends;
@property (nonatomic) BOOL isPublic;
@property (nonatomic) BOOL isViewable;
@property (nonatomic) NSString* fromDate;
@property (nonatomic) NSString* toDate;
@property (nonatomic) BOOL isGhost;
@property (nonatomic) NSString* ghostDate;
// media data structure next
@property (nonatomic) NSMutableArray* selectedMedia;
// friends data structure next
@property (nonatomic) NSMutableArray* selectedFriends;
@property (nonatomic) int countSelectedFriendsMemreasOrEmails;
@property (nonatomic) int countSelectedFriendsSMS;



//
// methods
//
+ (ShareCreator*) sharedInstance;
+ (void) resetSharedInstance;
- (void) resetSharedInstance ;

- (NSString*) storeShareDetailsCompositeData:(NSString*) name
                               withDate:(NSString*) date
                        andWithLocation:(NSDictionary*) addressDict
                  andWithFriendsCanPost:(bool) friendsCanPost
            andWithFriendsCanAddFriends:(bool) friendsCanAddFriends
                        andWithIsPublic:(bool) isPublic
                      andWithIsViewable:(bool) isViewable
                        andWithFromDate:(NSString*) fromDate
                          andWithToDate:(NSString*) toDate
                         andWithIsGhost:(bool) isGhost
                       andWithGhostDate:(NSString*) ghostDate;
- (void) addeventWSCall:(NSString*) notificationKey;
- (void) addMediaToEvent:(NSString*)eventID withNotificationKey:(NSString*) notificationKey;
- (void) sendMediaToQueueForSync:(NSArray*)selectedForSync;
- (void) addfriendtoeventWSCall:(NSString*)eventID withNotificationKey:(NSString*) notificationKey;
- (NSMutableArray*) fetchSMSRecipients:(NSString*)eventID;
- (void) determineMemreasFriendsCount;
@end

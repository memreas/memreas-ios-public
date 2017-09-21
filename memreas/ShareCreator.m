#import "ShareCreator.h"
#import "AppDelegate.h"
#import "MyConstant.h"
#import "FriendsContactEntry.h"
#import "MWebServiceHandler.h"
#import "WebServices.h"
#import "WebServiceParser.h"
#import "XMLGenerator.h"
#import "XMLParser.h"
#import "GalleryManager.h"
#import "QueueController.h"
#import "NSString+SrtingUrlValidation.h"
#import "NSDictionary+valueAdd.h"
#import "JSONUtil.h" 

@implementation ShareCreator

#pragma mark Singleton Methods
static ShareCreator* sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (ShareCreator*)sharedInstance {
    @synchronized(self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[ShareCreator alloc] init];
        });
    }
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        //
        // alloc vars here
        //
        self.selectedMedia = [[NSMutableArray alloc] init];
        self.selectedFriends = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (void)resetSharedInstance {
    
    //    sharedInstance = [ShareCreator sharedInstance];
    sharedInstance.name = @"";
    sharedInstance.date = @"";
    sharedInstance.location = nil;
    sharedInstance.friendsCanPost = NO;
    sharedInstance.friendsCanAddFriends = NO;
    sharedInstance.isPublic = NO;
    sharedInstance.isViewable = NO;
    sharedInstance.fromDate = @"";
    sharedInstance.toDate = @"";
    sharedInstance.isGhost = NO;
    sharedInstance.ghostDate = @"";
    sharedInstance.selectedMedia = [NSMutableArray array];
    sharedInstance.selectedFriends = [NSMutableArray array];
    
}

- (void)resetSharedInstance {
    
    //    sharedInstance = [ShareCreator sharedInstance];
    sharedInstance.name = @"";
    sharedInstance.date = @"";
    sharedInstance.location = nil;
    sharedInstance.friendsCanPost = NO;
    sharedInstance.friendsCanAddFriends = NO;
    sharedInstance.isPublic = NO;
    sharedInstance.isViewable = NO;
    sharedInstance.fromDate = @"";
    sharedInstance.toDate = @"";
    sharedInstance.isGhost = NO;
    sharedInstance.ghostDate = @"";
    sharedInstance.selectedMedia = [NSMutableArray array];
    sharedInstance.selectedFriends = [NSMutableArray array];
    
}
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
                            andWithGhostDate:(NSString*) ghostDate {
    //
    // Store / Update all fields
    //
    self.name = name;
    self.date = date;
    self.location = @"";
    if (addressDict != nil) {
        NSMutableDictionary* dictFormattedLocation = [NSMutableDictionary dictionary];
        CLLocation* clLocation = [addressDict objectForKey:@"location"];
        [dictFormattedLocation setObject:[addressDict objectForKey:@"address"] forKey:@"address"];
        [dictFormattedLocation setObject:[[NSNumber alloc] initWithDouble:clLocation.coordinate.latitude] forKey:@"latitude"];
        [dictFormattedLocation setObject:[[NSNumber alloc] initWithDouble:clLocation.coordinate.longitude] forKey:@"longitude"];
        self.location = [JSONUtil convertFromNSDictionary:dictFormattedLocation];
    }
    self.friendsCanPost = friendsCanPost;
    self.friendsCanAddFriends = friendsCanAddFriends;
    self.isPublic = isPublic;
    self.isViewable = isViewable;
    self.fromDate = fromDate;
    self.toDate = toDate;
    if (self.isViewable) {
        if ( ([self.fromDate isEqualToString:@""]) || ([self.toDate isEqualToString:@""]) ) {
            return @"please check from and to dates";
        }
    }
    self.isGhost = isGhost;
    self.ghostDate = ghostDate;
    if (self.isGhost) {
        if ([self.ghostDate isEqualToString:@""]) {
            return @"please check ghost date" ;
        }
    }
    return @"";
}



//
// Call Web Service to create share
//
- (void)addeventWSCall:(NSString*) notificationKey {
    @try {
        
        /**
         * Use XMLGenerator...
         */
        NSString* requestXML = [XMLGenerator generateAddEventXML:[Helper fetchSID]
                                                         user_id:[Helper fetchUserId]
                                                      event_name:self.name
                                                      event_date:self.date
                                                  event_location:self.location
                                                      event_from:self.fromDate
                                                        event_to:self.toDate
                                        is_friend_can_add_friend:self.friendsCanAddFriends?@"1":@"0"
                                        is_friend_can_post_media:self.friendsCanPost?@"1":@"0"
                                             event_self_destruct:self.ghostDate
                                                       is_public:self.isPublic?@"1":@"0"];
        
        //ALog(@"Request:- %@", requestXML);
        
        /**
         * Use WebServices Request Generator
         */
        
        NSMutableURLRequest* request =
        [WebServices generateWebServiceRequest:requestXML action:ADDEVENT];
        //ALog(@"NSMutableRequest request ----> %@", request);
        
        /**
         * Send Request and Parse Response...
         */
        MWebServiceHandler* wsHandler = [[MWebServiceHandler alloc] init];
        [wsHandler fetchServerResponse:request action:ADDEVENT key:notificationKey];
        
    } @catch (NSException* exception) {
        ALog(@"object type = %@", [[GalleryManager class] debugDescription]);
        ALog(@"%@", exception);
    }
}


//
// Add media via queue then call web service to link to share
//
- (void)addMediaToEvent:(NSString*) eventID
    withNotificationKey:(NSString*) notificationKey{
    @try {
        
        //
        // First add NOT_SYNC media to queue - queue adds to event
        //
        NSPredicate *predicateNotSync = [NSPredicate predicateWithFormat:@"self.mediaState == %d",NOT_SYNC];
        __weak NSArray *arrNotSyncMedias = [self.selectedMedia filteredArrayUsingPredicate:predicateNotSync];
        //
        // Handle NOT_SYNC media
        //
        sharedInstance.eventId = eventID;
        [self sendMediaToQueueForSync:arrNotSyncMedias];
        
        //
        // Handle SYNC and SERVER media
        // - add via media_id via web service...
        //
        NSPredicate *predicateServerSync = [NSPredicate predicateWithFormat:@"self.mediaState == %d OR self.mediaState == %d",SERVER,SYNC];
        NSArray *arrServerSyncMedia = [self.selectedMedia filteredArrayUsingPredicate:predicateServerSync];
        
        if (arrServerSyncMedia.count > 0) {
            //
            // generate xml
            //
            NSString* requestXML = [XMLGenerator generateAddExistingMediaToEventXML:[Helper fetchSID]
                                                                        withEventId:self.eventId
                                                                   andWithMediatems:arrServerSyncMedia];
            
            //
            // Use WebServices Request Generator
            //
            NSMutableURLRequest* request = [WebServices generateWebServiceRequest:requestXML action:ADDEXISTMEDIATOEVENT];
            
            
            //
            //  Send Request and Parse Response.
            //  Note: wsHandler sends notification
            //
            MWebServiceHandler* wsHandler = [[MWebServiceHandler alloc] init];
            [wsHandler fetchServerResponse:request action:ADDEXISTMEDIATOEVENT key:notificationKey];
        } else {
            NSMutableDictionary* resultInfo = [NSMutableDictionary dictionary];
            [resultInfo addValueToDictionary:@"Success" andKeyIs:@"status"];
            [resultInfo addValueToDictionary:@"move to memreas" andKeyIs:@"message"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationKey
                                                                object:self
                                                              userInfo:resultInfo];
        }
        
        
    } @catch (NSException* exception) {
        ALog(@"object type = %@", [[GalleryManager class] debugDescription]);
        ALog(@"%@", exception);
    }
}


- (void)sendMediaToQueueForSync:(NSArray*)selectedForSync {
    @try {
        // add transfer
        QueueController* queueController = [QueueController sharedInstance];
        for (MediaItem* mediaItem in selectedForSync) {
            mediaItem.eventId = sharedInstance.eventId;
            [queueController addToPendingTransferArray:mediaItem
                                      withTransferType:UPLOAD];
        }
        
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}



//
// Call Web Service to add friends to event
//
- (void)addfriendtoeventWSCall:(NSString*)eventID
           withNotificationKey:(NSString*) notificationKey{
    @try {
        //
        // generate xml
        //
        NSString* requestXML = [XMLGenerator generateAddFriendToEventXML:[Helper fetchSID]
                                                              withUserId:[Helper fetchUserId]
                                                          andWithEventId:self.eventId
                                                         andWithContacts:self.selectedFriends];
        
        //
        // Use WebServices Request Generator
        //
        NSMutableURLRequest* request = [WebServices generateWebServiceRequest:requestXML action:ADDFRIENDTOEVENT];
        
        //
        //  Send Request and Parse Response.
        //  Note: wsHandler sends notification
        //
        MWebServiceHandler* wsHandler = [[MWebServiceHandler alloc] init];
        [wsHandler fetchServerResponse:request action:ADDFRIENDTOEVENT key:notificationKey];
        
        
    } @catch (NSException* exception) {
        ALog(@"object type = %@", [[GalleryManager class] debugDescription]);
        ALog(@"%@", exception);
    }
}


-(void) determineMemreasFriendsCount {
    //
    // memreas
    //
    int memreasFriendsCount = 0;
    for (int i = 0; i<self.selectedFriends.count; i++) {
        FriendsContactEntry *entry = self.selectedFriends[i];
        // friends
        if (entry.friendType == MemreasNetwork) {
            memreasFriendsCount++;
        }
    }
    
    //
    // emails
    //
    for (int i = 0; i<self.selectedFriends.count; i++) {
        
        FriendsContactEntry *entry = self.selectedFriends[i];
        if (entry.friendType == PhoneBookContact) {
            NSDictionary *contactDetail = entry.objectOfFriend;
            for (int x = 0; x < [contactDetail[@"EmailArray"] count]; x++) {
                memreasFriendsCount++;
            }
        }
    }
    
    //
    // SMS
    //
    int memreasSMSCount = 0;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.friendType == %d",PhoneBookContact];
    NSArray *arrPhoneBookFrnd = [self.selectedFriends filteredArrayUsingPredicate:predicate];
    for (int i = 0; i<arrPhoneBookFrnd.count; i++) {
        FriendsContactEntry *frndContact =[arrPhoneBookFrnd objectAtIndex:i];
        NSDictionary *contact = frndContact.objectOfFriend;
        if( [contact[@"PhoneArray"] count]){
            NSArray* phoneArray = contact[@"PhoneArray"];
            ALog(@"phoneArray :: %@", phoneArray);
            for (int i=0; i<phoneArray.count; i++) {
                memreasSMSCount++;
            }
        }
    }
    
    //
    // set property
    //
    self.countSelectedFriendsMemreasOrEmails = memreasFriendsCount;
    self.countSelectedFriendsSMS = memreasSMSCount;
}


//
// Send SMS for selected friends
//
- (NSMutableArray*) fetchSMSRecipients:(NSString*)eventID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.friendType == %d",PhoneBookContact];
    NSArray *arrPhoneBookFrnd = [self.selectedFriends filteredArrayUsingPredicate:predicate];
    NSMutableArray *recipients = [NSMutableArray array];
    
    for (int i = 0; i<arrPhoneBookFrnd.count; i++) {
        FriendsContactEntry *frndContact =[arrPhoneBookFrnd objectAtIndex:i];
        NSDictionary *contact = frndContact.objectOfFriend;
        if( [contact[@"PhoneArray"] count]){
            NSArray* phoneArray = contact[@"PhoneArray"];
            ALog(@"phoneArray :: %@", phoneArray);
            for (int i=0; i<phoneArray.count; i++) {
                NSString* dirtyPhoneNumber = phoneArray[i];
                NSString* cleanPhoneNumber = [[dirtyPhoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
                [recipients addObject:cleanPhoneNumber];
                
            }
        }
    }
    
    return recipients;
}

@end


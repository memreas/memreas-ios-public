#import <Foundation/Foundation.h>
#import "MediaItem.h"
#import "MyConstant.h"
#import "Util.h"
#import "WebServices.h"
#import "XMLGenerator.h"
#import "MWebServiceHandler.h"
#import "JSONUtil.h"
#import "MediaIdManager.h"

@implementation MediaIdManager

#pragma mark Singleton Methods
static MediaIdManager* sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (MediaIdManager*)sharedInstance {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[MediaIdManager alloc] init];
        }
    }
    return sharedInstance;
}

- (id)init {
    self = [super init];
    
    /**
     * Add Observer for fetchcopyright web service
     */
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(fetchmediaidbatchMWSHandlerComplete:)
     name:GENERATEMEDIAID_RESULT_NOTIFICATION
     object:nil];
    
    if (self.mediaIdBatchArray == nil) {
        [self fetchMediaIdBatch];
    }
    
    return self;
}

+ (void)resetSharedInstance {
    @synchronized(self) {
        sharedInstance = nil;
    }
}

- (void)fetchMediaIdBatch {
    if ([Util checkInternetConnection]) {
        /**
         * Use XMLGenerator...
         */
        NSString* requestXML = [XMLGenerator
                                generateMediaIdXML:[Helper fetchSID]];
        //ALog(@"Request:- %@", requestXML);
        
        /**
         * Use WebServices Request Generator
         */
        NSMutableURLRequest* request =
        [WebServices generateWebServiceRequest:requestXML
                                        action:GENERATEMEDIAID];
        //ALog(@"NSMutableRequest request ----> %@", request);
        
        /**
         * Send Request and Parse Response...
         */
        MWebServiceHandler* wsHandler = [[MWebServiceHandler alloc] init];
        [wsHandler fetchServerResponse:request
                                action:GENERATEMEDIAID
                                   key:GENERATEMEDIAID_RESULT_NOTIFICATION];
    }
}

/**
 * Web Service Response via notification here...
 */
- (void)fetchmediaidbatchMWSHandlerComplete:(NSNotification*)notification {
    NSDictionary* resultTags = [notification userInfo];
    NSString* status = [resultTags objectForKey:@"status"];
    if ((status != nil) &&
        ([[status lowercaseString] isEqualToString:@"success"])) {
        // handle result tags
        NSString* media_id_batch = [resultTags objectForKey:@"media_id_batch"];
        self.mediaIdBatchArray = [JSONUtil convertToMutableNSArray:media_id_batch];
    }
}

- (NSString*)fetchNextMediaId {
    NSString* media_id;

    
    //if media id batch < 5 fetch a new one.
    if ([self.mediaIdBatchArray count] <= FETCHMEDIAIDBATCH_RUNNING_LOW) {
        [self performSelectorInBackground:@selector(fetchMediaIdBatch)
                               withObject:nil];
    }
    
    media_id = self.mediaIdBatchArray[0];
    [self.mediaIdBatchArray removeObjectAtIndex:0];
    ALog(@"media_id:%@", media_id);
    
    return media_id;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end


#import "CopyrightManager.h"
#import "MyConstant.h"
#import "XMLGenerator.h"
#import "WebServices.h"
#import "MWebServiceHandler.h"
#import "JSONUtil.h"
#import "Util.h"

@implementation CopyrightManager

#pragma mark Singleton Methods
static CopyrightManager* sharedInstance = nil;
static bool isAlreadyFetching = NO;
NSInteger lastCopyRightIndex = 0;

// Get the shared instance and create it if necessary.
+ (CopyrightManager*)sharedInstance {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[CopyrightManager alloc] init];
            lastCopyRightIndex = 0;
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
     selector:@selector(fetchcopyrightbatchMWSHandlerComplete:)
     name:FETCHCOPYRIGHTBATCH_RESULT_NOTIFICATION
     object:nil];
    
    if (self.copyrightBatchArray == nil) {
        [self fetchCopyRightBatch];
    }
    
    return self;
}

+ (void)resetSharedInstance {
    @synchronized(self) {
        sharedInstance = nil;
    }
}

- (void)fetchCopyRightBatch {
    if ([Util checkInternetConnection]) {
        /**
         * Use XMLGenerator...
         */
        NSString* requestXML = [XMLGenerator
                                fetchcopyrightbatchXML:[[NSUserDefaults standardUserDefaults]
                                                        objectForKey:@"SID"]];
        //ALog(@"Request:- %@", requestXML);
        
        /**
         * Use WebServices Request Generator
         */
        NSMutableURLRequest* request =
        [WebServices generateWebServiceRequest:requestXML
                                        action:FETCHCOPYRIGHTBATCH];
        //ALog(@"NSMutableRequest request ----> %@", request);
        
        /**
         * Send Request and Parse Response...
         */
        MWebServiceHandler* wsHandler = [[MWebServiceHandler alloc] init];
        [wsHandler fetchServerResponse:request
                                action:FETCHCOPYRIGHTBATCH
                                   key:FETCHCOPYRIGHTBATCH_RESULT_NOTIFICATION];
        
    }
}

/**
 * Web Service Response via notification here...
 */
- (void)fetchcopyrightbatchMWSHandlerComplete:(NSNotification*)notification {
    //
    // Note fetch has completed
    //
    isAlreadyFetching = NO;
    
    NSDictionary* resultTags = [notification userInfo];
    NSString* status = [resultTags objectForKey:@"status"];
    if ((status != nil) &&
        ([[status lowercaseString] isEqualToString:@"success"])) {
        // handle result tags
        NSString* copyright_batch = [resultTags objectForKey:@"copyright_batch"];
        self.copyrightBatchArray = [JSONUtil convertToMutableID:copyright_batch];
    }
}

- (NSMutableDictionary*)fetchNextCopyRight {
    NSMutableDictionary* copyright;
    while (true) {
        copyright = self.copyrightBatchArray[lastCopyRightIndex];
        
        NSNumber* used = [copyright objectForKey:@"used"];
        if (used.intValue == 0) {
            [copyright setObject:[NSNumber numberWithInt:1] forKey:@"used"];
            break;
        }
        lastCopyRightIndex++;
        if ((lastCopyRightIndex <= FETCHCOPYRIGHTBATCH_RUNNING_LOW) && (!isAlreadyFetching))  {
            ALog(@"next lastCopyRightIndex %@ while FETCHCOPYRIGHTBATCH_RUNNING_LOW is %@", @(lastCopyRightIndex), @(FETCHCOPYRIGHTBATCH_RUNNING_LOW));
            
            //
            // Note fetch is in progress
            //
            isAlreadyFetching = YES;

            //
            // Fetch in background
            //
            [self performSelectorInBackground:@selector(fetchCopyRightBatch)
                                   withObject:nil];
        }
    }
    //ALog(@"Is of type: %@", NSStringFromClass([copyright class]));
    
    return copyright;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

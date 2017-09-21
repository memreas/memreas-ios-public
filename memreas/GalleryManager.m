#import "GalleryManager.h"
#import "NSDictionary+valueAdd.h"

@implementation GalleryManager

#pragma mark Singleton Methods
static GalleryManager* sharedGalleryInstance = nil;

// Get the shared instance and create it if necessary.
+ (GalleryManager*)sharedGalleryInstance {
    @synchronized(self) {
        if (sharedGalleryInstance == nil) {
            sharedGalleryInstance = [[GalleryManager alloc] init];
        }
    }
    return sharedGalleryInstance;
}

- (id)init {
    if (self = [super init]) {
        self.imageGalleryNSMutableArray = [[NSMutableArray alloc] init];
        self.galleryNSMutableArray = [[NSMutableArray alloc] init];
        self.dictGallery = [[NSMutableDictionary alloc] init];
        self.isLoading = YES;
        self.hasFinishedLoading = NO;
        self.galleryNSOperationQueue = [[NSOperationQueue alloc] init];
        [self loadLocalMedia];
    }
    return self;
}

+ (void)resetSharedGalleryInstance {
    @synchronized(self) {
        sharedGalleryInstance = nil;
        [GalleryManager sharedGalleryInstance];
    }
}

- (void)loadLocalMedia {
    @try {
        
        //
        //Block operation example...
        // - sample with dependency
        // queue = [[NSOperationQueue alloc] init];
        // NSOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:block];
        // NSOperation *completionOperation = [NSBlockOperation blockOperationWithBlock:^{
        //    completion(blockOperation.isFinished);
        // }];
        // [completionOperation addDependency:blockOperation];
        // [[NSOperationQueue currentQueue] addOperation:completionOperation];
        // [queue addOperation:blockOperation];
        
        NSBlockOperation* galleryNSBlockOperation = [NSBlockOperation blockOperationWithBlock:^{
            
            __block int totalAssets = 0;
            //
            // Sort descriptor
            //
            PHFetchOptions* mediaByDateDescending = [PHFetchOptions new];
            mediaByDateDescending.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            
            //
            // All Photos
            //
            PHFetchResult* result =
            [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage
                                      options:mediaByDateDescending];
            
            ALog(@"allPhotosResult.count:%lu", (unsigned long)result.count);
            totalAssets += result.count;
            
            // update progress
            [self postProgressUpdate:@"loading images..."];
            ALog(@"album title %@, result.count: %lu", @"images", (unsigned long)result.count);
            [result enumerateObjectsUsingBlock:^(PHAsset* asset, NSUInteger idx,
                                                 BOOL* stop) {
                
                // add to dictGallery here...
                [self addToGallery:asset andWithAlbum:@"images"];
            }];
            
            //
            // All Videos
            //
            result =
            [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo
                                      options:mediaByDateDescending];
            
            ALog(@"allPhotosResult.count:%lu", (unsigned long)result.count);
            totalAssets += result.count;
            
            // update progress
            [self postProgressUpdate:@"loading videos..."];
            ALog(@"album title %@, result.count: %lu", @"videos", (unsigned long)result.count);
            [result enumerateObjectsUsingBlock:^(PHAsset* asset, NSUInteger idx,
                                                 BOOL* stop) {
                
                // add to dictGallery here...
                [self addToGallery:asset andWithAlbum:@"videos"];
            }];
            ALog(@"all media:%lu", (unsigned long)result.count);
         
            //
            // Debugging
            //
            ALog(@"totalAssets: %d", totalAssets);
            ALog(@"Finished fetching PHAssets...");
            NSUInteger keyCount = [self.dictGallery count];
            ALog(@"self.dictGallery inside loadLocalMedia: %lu", (unsigned long)keyCount);
            ALog(@"self.galleryNSMutableArray inside loadLocalMedia: %lu", (unsigned long)self.galleryNSMutableArray.count);
            
            //
            // List All Media block - has callback below
            //
            [self postProgressUpdate:@"loading server media..."];
            [self listAllMedia];
            
        }];
        [self.galleryNSOperationQueue addOperation:galleryNSBlockOperation];
        
    } @catch (NSException* exception) {
        ALog(@"object type = %@", [[GalleryManager class] debugDescription]);
        ALog(@"%@", exception);
    }
}

- (void)addToGallery:(PHAsset*)phAsset andWithAlbum:(NSString*)album {
    MediaItem* mediaItemLocal = [[MediaItem alloc] initWithPHAsset:phAsset];
    // Store to Gallery
    // ALog(@"self addToGallery-->%@", mediaItemLocal.mediaNamePrefix);
    @try {
        @synchronized (self) {
            if (mediaItemLocal.mediaNamePrefix != nil) {
                
                // all items are NOT_SYNC until process is finished
                mediaItemLocal.mediaState = NOT_SYNC;
                
                
                if ([self.dictGallery objectForKey:mediaItemLocal.mediaNamePrefix] == nil) {
                    [self.dictGallery setObject:mediaItemLocal
                                         forKey:mediaItemLocal.mediaNamePrefix];
                    [self.phAssetsNSMutableArray addObject:mediaItemLocal.mediaLocalPHAsset];
                    [self.galleryNSMutableArray addObject:mediaItemLocal];
                    if ([[mediaItemLocal.mediaType lowercaseString] isEqualToString:@"image"]) {
                        [self.imageGalleryNSMutableArray addObject:mediaItemLocal];
                    }
                    //
                    // Store location
                    //
                    mediaItemLocal.mediaLocation = mediaItemLocal.mediaLocalPHAsset.location;
                    if ( (mediaItemLocal.mediaLocalPHAsset.location != nil) && (mediaItemLocal.mediaLocalPHAsset.location.coordinate.latitude != 0) && (mediaItemLocal.mediaLocalPHAsset.location.coordinate.longitude != 0) ) {
                        mediaItemLocal.hasLocation = YES;
                    } else {
                        mediaItemLocal.hasLocation = NO;
                    }
                    
                    //
                    // Set isLocal flag
                    //
                    mediaItemLocal.isLocal = YES;
                    //ALog(@"Case data for date:: mediaItemLocal.mediaDate::%@", @(mediaItemLocal.mediaDate));

                } else {
                    // Item is already stored
                }
                
                // end if (mediaItemLocal.mediaNamePrefix != nil)
            } else {
                // Item is already stored
            }
        } // end @synchronized
    } @catch (NSException* exception) {
        ALog(@"%@ ", exception.name);
        ALog(@"Reason: %@ ", exception.reason);
        ALog(@"Exception: %@ ", exception);
    }
}

- (void)listAllMedia {
    @try {
        // Debugging
        NSUInteger keyCount = [self.dictGallery count];
        ALog(@"self.dictGallery inside listallmedia: %lu", (unsigned long)keyCount);
        // End Debugging
        NSUserDefaults* defaultUser = [NSUserDefaults standardUserDefaults];
        NSString* userId = [defaultUser stringForKey:@"UserId"];
        NSString* sid = [defaultUser stringForKey:@"SID"];
        NSString* device_id = [defaultUser stringForKey:@"device_id"];
        NSString* meta_flag = @"true";
        NSString* page = @"1";
        NSString* limit = @"1000";
        
        if ([Util checkInternetConnection]) {
            /**
             * Use XMLGenerator...
             */
            NSString* requestXML = [XMLGenerator generateListAllMediaXML:sid
                                                                 user_id:userId
                                                                event_id:@""
                                                               device_id:device_id
                                                                metadata:meta_flag
                                                                    page:page
                                                                   limit:limit];
            ALog(@"Request:- %@", requestXML);
            
            /**
             * Use WebServices Request Generator
             */
            
            NSMutableURLRequest* request =
            [WebServices generateWebServiceRequest:requestXML
                                            action:@"listallmedia"];
            // ALog(@"NSMutableRequest request ----> %@", request);
            
            /**
             * Send Request and Parse Response...
             *  Note: wsHandler calls objectParsed_ListAllMedia
             */
            MWebServiceHandler* wsHandler = [[MWebServiceHandler alloc] init];
            [wsHandler fetchServerResponse:request action:LISTALLMEDIA key:nil];
        }
    } @catch (NSException* exception) {
        ALog(@"object type = %@", [[GalleryManager class] debugDescription]);
        ALog(@"%@", exception);
    }
}

- (void)objectParsed_ListAllMedia:(NSMutableDictionary*)dictionary {
    //    ALog(@"listallmedia ----> %@", dictionary);
    
    @try {
        /*
         * Add server media to the dictionary as media items...
         */
        /**
         * Create tmpGallery to add assets to after Server Items (avoid
         * duplicates)
         */
        NSArray* keys = [dictionary allKeys];
        for (int i = 0; i < keys.count; i++) {
            MediaItem* mediaItemServer = [dictionary objectForKey:keys[i]];
            
            // Get the local device id
            NSUserDefaults* defaultUser = [NSUserDefaults standardUserDefaults];
            NSString* local_device_id = [defaultUser stringForKey:@"device_id"];
            //            ALog(@"mediaItemServer.userMediaDevice::%@", mediaItemServer.userMediaDevice);
            bool isSyncd = NO;
            
            //
            // Determine Sync status here
            //
            // Case 1: Sync ios to ios - device id must be same to avoid name - invalid if delete of app
            // Case 2: Sync Android to ios only device type must differ
            // Case 3: name matches with dictGallery but not device_id or !device_type
            // Case 4: media was downloaded and iOS stores as different name - mediaLocalIdentifier
            // - need to check if self.dictGallery contains mediaNamePrefix from mediaLocalIdentifier
            // - if found then mark local as sync'd
            //
            
            //
            // Case 1: Sync ios to ios - device id must be same to avoid name collision
            //
            
            MediaItem* mediaItemStoredLocal = [self.dictGallery objectForKey:mediaItemServer.mediaNamePrefix];
            //ALog(@"Case data start:: ");
            //ALog(@"Case data:: mediaItemStoredLocal.mediaNamePrefix: %@, mediaItemServer.mediaNamePrefix: %@, local_device_id: %@, mediaItemServer.deviceId: %@", mediaItemStoredLocal.mediaNamePrefix, mediaItemServer.mediaNamePrefix, [local_device_id lowercaseString], [mediaItemServer.deviceId lowercaseString]);
            if ((mediaItemStoredLocal != nil) &&
                ([[local_device_id lowercaseString]
                  isEqualToString:[mediaItemServer.deviceId lowercaseString]])) {
                isSyncd = YES;
                //ALog(@"Case 1 ios to ios:: media in dictGallery mediaItemServer.mediaNamePrefix: %@, local_device_id: %@, mediaItemServer.deviceId: %@", mediaItemServer.mediaNamePrefix, [local_device_id lowercaseString], [mediaItemServer.deviceId lowercaseString]);
            }
            //
            // Case 2: Sync Android to ios only device type must differ
            //
            else if ((mediaItemStoredLocal != nil) &&
                     (![[mediaItemServer.deviceType lowercaseString]
                        isEqualToString:[DEVICE_TYPE lowercaseString]])) {
                isSyncd = YES;
                //ALog(@"Case 2 Android to ios:: media in dictGallery mediaItemServer.mediaNamePrefix: %@, media_device_type: %@, local_device_type: %@", mediaItemServer.mediaNamePrefix, [mediaItemServer.deviceType lowercaseString], [mediaItemServer.deviceId lowercaseString]);
            } else if(mediaItemStoredLocal != nil) {
                //
                // Case 3: name matches with dictGallery but not device_id or !device_type
                //
                isSyncd = YES;
                //ALog(@"Case 3 Name match but device_id or device_type mismatch:: media in dictGallery mediaItemServer.mediaNamePrefix: %@, local_device_id: %@, mediaItemServer.deviceId: %@, media_device_type: %@, local_device_type: %@", mediaItemServer.mediaNamePrefix, [local_device_id lowercaseString], [mediaItemServer.deviceId lowercaseString], [mediaItemServer.deviceType lowercaseString], [mediaItemServer.deviceId lowercaseString]);
            } else if (mediaItemServer.userMediaDevice != nil) {
                //
                // Case 4: media was downloaded and iOS stores as different name - mediaLocalIdentifier
                // - need to check if self.dictGallery contains mediaNamePrefix from mediaLocalIdentifier
                // - if found then mark local as sync'd
                //
                NSArray* userMediaDeviceArray = mediaItemServer.userMediaDevice;
                for (int i=0; i<userMediaDeviceArray.count; i++) {
                    NSDictionary* userMediaDeviceDict = userMediaDeviceArray[i];
                    NSString* userMediaDeviceId = [userMediaDeviceDict objectForKey:@"device_id"];
                    if ([local_device_id isEqualToString:userMediaDeviceId]) {
                        NSString* userMediaLocalIdentifier = [userMediaDeviceDict objectForKey:@"device_local_identifier"];
                        NSString* mediaNamePrefixFromServerLocalIdentifier = [userMediaLocalIdentifier
                                                                              stringByReplacingOccurrencesOfString:@"/"
                                                                              withString:@""];
                        mediaItemStoredLocal = [self.dictGallery objectForKey:mediaNamePrefixFromServerLocalIdentifier];
                        if (mediaItemStoredLocal != nil) {
                            isSyncd = YES;
                            //ALog(@"Case 4: media was downloaded and iOS stores as different name:: media in dictGallery mediaItemServer.mediaLocalIdentifier: %@, local_device_id: %@, mediaItemServer.deviceId: %@, media_device_type: %@, local_device_type: %@", mediaItemServer.mediaLocalIdentifier, [local_device_id lowercaseString], [mediaItemServer.deviceId lowercaseString], [mediaItemServer.deviceType lowercaseString], [mediaItemServer.deviceId lowercaseString]);
                        }
                    }
                }
                
                //
                // Check location for local and server
                //  - if not local and server has then use server
                //
                //                ALog(@"userMediaDeviceDict::%@",mediaItemServer.userMediaDevice);
            } else if (mediaItemStoredLocal != nil) {
                //
                // match on file name since that is last best effort
                // - Android file names won't match but iOS might???
                //
                isSyncd = YES;
                //ALog(@"Case 5: mediaNamePrefix matches: %@, local_device_id: %@, mediaItemServer.deviceId: %@, media_device_type: %@, local_device_type: %@", mediaItemServer.mediaNamePrefix, [local_device_id lowercaseString], [mediaItemServer.deviceId lowercaseString], [mediaItemServer.deviceType lowercaseString], [mediaItemServer.deviceId lowercaseString]);
            } else {
                //ALog(@"no match");
            }
            
            if (isSyncd) {
                /**
                 * Sync'd section
                 * - update mediaItemStoredLocal since we have a match
                 */
                mediaItemStoredLocal.mediaState = SYNC;
                mediaItemStoredLocal.mediaId = mediaItemServer.mediaId;
                mediaItemStoredLocal.mimeType = mediaItemServer.mimeType;
                mediaItemStoredLocal.mimeType = mediaItemServer.mimeType;
                mediaItemStoredLocal.mediaUrlWebS3Path = mediaItemServer.mediaUrlWebS3Path;
                mediaItemStoredLocal.mediaThumbnailUrl = mediaItemServer.mediaThumbnailUrl;
                mediaItemStoredLocal.mediaThumbnailUrl1280x720 = mediaItemServer.mediaThumbnailUrl1280x720;
                mediaItemStoredLocal.mediaThumbnailUrl448x306 = mediaItemServer.mediaThumbnailUrl448x306;
                mediaItemStoredLocal.mediaThumbnailUrl79x80 = mediaItemServer.mediaThumbnailUrl79x80;
                mediaItemStoredLocal.mediaThumbnailUrl98x78 = mediaItemServer.mediaThumbnailUrl98x78;
                
                if ( (mediaItemStoredLocal.mediaLocalPHAsset.location.coordinate.latitude == 0) && (mediaItemStoredLocal.mediaLocalPHAsset.location.coordinate.longitude == 0) && (mediaItemServer.hasLocation) )  {
                    mediaItemStoredLocal.hasLocation = mediaItemServer.hasLocation;
                    mediaItemStoredLocal.mediaLocation = mediaItemServer.mediaLocation;
                }
            } else {
                // Store server only code in dictionary
                [self.dictGallery setObject:mediaItemServer
                                     forKey:mediaItemServer.mediaNamePrefix];
                [self.galleryNSMutableArray addObject:mediaItemServer];
                if ([[mediaItemServer.mediaType lowercaseString] isEqualToString:@"image"]) {
                    [self.imageGalleryNSMutableArray addObject:mediaItemServer];
                }
            }
            //ALog(@"Case data for date:: mediaItemServer.mediaDate::%@", @(mediaItemServer.mediaDate));

            //ALog(@"Case data end:: ");
        }  // end for loop
        
        //
        // Sort the array date desc and update progress
        //
        [self postProgressUpdate:@"sorting media..."];
        [self fetchGalleryOrderedByDate];
        
        //
        // Finished loading and sorting...
        //
        self.isLoading = NO;
        self.hasFinishedLoading = YES;
        
        //
        // Udate view here once we've sorted the gallery...
        //
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.delegate closeSpinnerView];
            [weakSelf.delegate refreshGalleryView];
            //[weakSelf.delegate startCaching];
        });
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
}

-(void) fetchGalleryOrderedByDate {
    
    //
    // Descriptor approach
    //
    NSSortDescriptor *mediaDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"mediaDate" ascending:NO];
    self.galleryNSMutableArray = [NSMutableArray arrayWithArray:[self.galleryNSMutableArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:mediaDateDescriptor, nil]]];
    self.imageGalleryNSMutableArray = [NSMutableArray arrayWithArray:[self.imageGalleryNSMutableArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:mediaDateDescriptor, nil]]];
    
}

/*
 - (void) postProgressUpdate:(NSString*) progress {
 __weak typeof(self) weakSelf = self;
 dispatch_async(dispatch_get_main_queue(), ^{
 [weakSelf.delegate updateLblProgress:progress];
 });
 }
 */
- (void) postProgressUpdate:(NSString*) progress {
    NSMutableDictionary* resultInfo = [NSMutableDictionary dictionary];
    [resultInfo addValueToDictionary:progress andKeyIs:@"progress"];
    
    //__weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(),^{
        [[NSNotificationCenter defaultCenter] postNotificationName:GALLERY_UPDATE_PROGRESS
                                                            object:nil
                                                          userInfo:resultInfo];
    });
    
}
@end

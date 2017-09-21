#import "MediaItem.h"
#import "JSONUtil.h"

@implementation MediaItem
- (MediaItem *) initForFriendsOrPublicMemreas:(NSString*) event_media_448x306_
                        withEvent_media_79x80:(NSString*) event_media_79x80_
                        andWithEvent_media_id:(NSString*) event_media_id_
                      andWithEvent_media_name:(NSString*) event_media_name_
               andWithEvent_media_s3_url_path:(NSString*) event_media_s3_url_path_
           andWithEvent_media_s3_url_web_path:(NSString*) event_media_s3_url_web_path_
      andWithEvent_media_s3file_download_path:(NSString*) event_media_s3file_download_path_
           andWithEvent_media_s3file_location:(NSString*) event_media_s3file_location_
                      andWithEvent_media_type:(NSString*) event_media_type_
                       andWithEvent_media_url:(NSString*) event_media_url_
                   andWithEvent_media_url_hls:(NSString*) event_media_url_hls_
                   andWithEvent_media_url_web:(NSString*) event_media_url_web_
{
    MediaItem* mediaItem = [[MediaItem alloc] init];
    if (event_media_448x306_ != nil) {
        mediaItem.mediaThumbnailUrl448x306 = [JSONUtil convertToID:event_media_448x306_];
    }
    if (event_media_79x80_ != nil) {
        mediaItem.mediaThumbnailUrl79x80 = [JSONUtil convertToID:event_media_79x80_];
    }
    if (event_media_id_ != nil) {
        mediaItem.mediaId = event_media_id_;
    }
    if (event_media_name_ != nil) {
        mediaItem.mediaName = event_media_name_;
    }
    if (event_media_s3_url_path_ != nil) {
        mediaItem.mediaUrlS3Path = event_media_s3_url_path_;
    }
    if (event_media_s3_url_web_path_ != nil) {
        mediaItem.mediaUrlWebS3Path = event_media_s3_url_web_path_;
    }
    if (event_media_s3file_download_path_ != nil) {
        mediaItem.mediaUrlDownload = [JSONUtil convertToID:event_media_s3file_download_path_];
    }
    //
    // Location
    //
    if (event_media_s3file_location_ != nil) {
        NSDictionary* locationDict = [JSONUtil convertToID:event_media_s3file_location_];
        double latitude = 0;
        double longitude = 0;
        if ([locationDict objectForKey:@"latitude"]) {
            latitude = [[locationDict objectForKey:@"latitude"] doubleValue];
            longitude = [[locationDict objectForKey:@"longitude"] doubleValue];
        }
        CLLocation* location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        mediaItem.mediaLocation = location;
        
        //
        // hasLocation is true only when lat/lng != 0
        //
        if ( (location.coordinate.latitude == 0) && (location.coordinate.longitude == 0) )  {
            mediaItem.hasLocation = NO;
        } else {
            mediaItem.hasLocation = YES;
        }
    }
    
    if (event_media_type_ != nil) {
        mediaItem.mediaType = event_media_type_;
    }
    
    if (event_media_url_ != nil) {
        mediaItem.mediaUrl = [JSONUtil convertToID:event_media_url_];
    }
    if (event_media_url_hls_ != nil) {
        mediaItem.mediaUrlWeb =[JSONUtil convertToID:event_media_url_hls_];
    }
    if (event_media_url_web_ != nil) {
        mediaItem.mediaUrlHls = [JSONUtil convertToID:event_media_url_web_];
    }
    
    return mediaItem;
    
}


- (MediaItem *)initWithNSURL:(NSURL *)url {
    
    //
    // Fetch the PHAsset base on ALAsset URL
    //
    NSArray *holderURLs = [[NSArray alloc] initWithObjects:url, nil];
    PHFetchResult *result =
    [PHAsset fetchAssetsWithALAssetURLs:holderURLs options:nil];
    PHAsset *phAsset = [result firstObject];
    [self setData:phAsset];
    
    return self;
}

- (MediaItem *)initWithPHAsset:(PHAsset *)phAsset {
    
    [self setData:phAsset];
    
    return self;
}

- (MediaItem *)setData:(PHAsset *)phAsset {
    //
    // Setup the mediaItem
    //
    self.mediaState = NOT_SYNC;
    self.mediaLocalPHAsset = phAsset;
    if (self.mediaLocalPHAsset.mediaType == PHAssetMediaTypeImage) {
        self.mediaType = @"image";
        //[self fetchMetaDataForPHAsset];
    } else if (self.mediaLocalPHAsset.mediaType == PHAssetMediaTypeVideo) {
        self.mediaType = @"video";
    }
    
    //
    // Store the creation date of the local asset
    //
    NSDate *date = self.mediaLocalPHAsset.creationDate;
    long timestamp = [date timeIntervalSince1970];
    self.mediaDate = timestamp;
    
    //set the codec level to ""
    self.codecLevel = @"";
    
    //set eventId to ""
    self.eventId = @"";
    
    //
    // Fetch local file data for gallery 
    //
    if (self.mediaState != SERVER) {
        [self fetchFileDatafromPHAsset];
        self.mediaLocalPHAsset = phAsset;
    }
    
    
    return self;
}
- (void) fetchFileDatafromPHAsset {
    
    NSArray *resources = [PHAssetResource assetResourcesForAsset:self.mediaLocalPHAsset];
    if (resources.count > 0) {
        //ALog(@"((PHAssetResource*)resources[0]).originalFilename--->%@", ((PHAssetResource*)resources[0]).originalFilename);
        self.mediaName = ((PHAssetResource*)resources[0]).originalFilename;
        self.mediaNamePrefix = [self.mediaName stringByDeletingPathExtension];
        self.mediaLocalIdentifier = ((PHAssetResource*)resources[0]).assetLocalIdentifier;
        self.mediaLocalIdentifier = [self.mediaLocalIdentifier
                                     stringByReplacingOccurrencesOfString:@"/"
                                     withString:@""];
        self.mediaDate = self.mediaLocalPHAsset.creationDate.timeIntervalSince1970;
        
        //get url info from asset lookup
        if (([self.mediaType length] != 0) &&
            [self.mediaType isEqualToString:@"image"]) {
            self.mimeType = [NSString stringWithFormat:@"%@/%@", @"image", [self.mediaName  pathExtension]];
        } else {
            self.mimeType = [NSString stringWithFormat:@"%@/%@", @"video", [self.mediaName pathExtension]];
        }
    } else {
        //something is wrong so don't add
        self.mediaName = nil;
    }
    
    //ALog(@"fetchFileDatafromPHAsset::self.mediaName::%@", self.mediaName);
    //ALog(@"fetchFileDatafromPHAsset::self.mediaLocalIdentifier::%@", self.mediaLocalIdentifier);
    //ALog(@"fetchFileDatafromPHAsset::self.mediaNamePrefix::%@", self.mediaNamePrefix);
    //ALog(@"fetchFileDatafromPHAsset::self.mimeType::%@", self.mimeType);
}


- (void)fetchThumbnailForPHAsset:(CGSize)cgSize {
    @autoreleasepool {
        PHImageRequestOptions *imageRequestOptions =
        [[PHImageRequestOptions alloc] init];
        imageRequestOptions.synchronous = YES;
        [[PHImageManager defaultManager]
         requestImageForAsset:self.mediaLocalPHAsset
         targetSize:cgSize
         contentMode:PHImageContentModeAspectFit
         options:imageRequestOptions
         resultHandler:^(UIImage *result, NSDictionary *info) {
             self.mediaLocalThumbnail = result;
         }];
    }
}

-(void)fetchMetaDataForPHAsset {
    @autoreleasepool {
        [[PHImageManager defaultManager] requestImageDataForAsset:self.mediaLocalPHAsset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
            CIImage *image = [CIImage imageWithData:imageData];
            self.metadata = [image properties];
            //ALog(@"self.metadata--->%@", self.metadata);
        }];
    }
}

- (NSString *)getMediaStateAsString {
    NSString *state;
    switch (self.mediaState) {
        case SERVER:
            state = @"SERVER";
            break;
        case SYNC:
            state = @"SYNC";
            break;
        case IN_TRANSIT:
            state = @"IN_TRANSIT";
            break;
        case NOT_SYNC:
            state = @"NOT_SYNC";
            break;
        default:
            state = nil;
            break;
    }
    return state;
}

- (id)copyWithZone:(NSZone *)zone {
    
    MediaItem* mediaItemCopy = [[MediaItem alloc] init];
    
    mediaItemCopy.mediaId = [self.mediaId copy];
    mediaItemCopy.deviceId = [self.deviceId copy];
    mediaItemCopy.deviceType = [self.deviceType copy];
    mediaItemCopy.mediaState = self.mediaState;
    mediaItemCopy.mediaType = [self.mediaType copy];
    mediaItemCopy.mediaName = [self.mediaName copy];
    mediaItemCopy.mediaNamePrefix = [self.mediaNamePrefix copy];
    mediaItemCopy.mediaAlbum = [self.mediaAlbum copy];
    mediaItemCopy.mediaTranscodeStatus = [self.mediaTranscodeStatus copy];
    mediaItemCopy.mediaSize = self.mediaSize; //int no need to copy;
    mediaItemCopy.metadata = [self.metadata copy];
    mediaItemCopy.mediaUrl = [self.mediaUrl copy];
    mediaItemCopy.mediaPath = [self.mediaPath copy];
    mediaItemCopy.mediaUrlS3Path = [self.mediaUrlS3Path copy];
    mediaItemCopy.mediaUrlWeb = [self.mediaUrlWeb copy];
    mediaItemCopy.mediaUrl1080p = [self.mediaUrl1080p copy];
    mediaItemCopy.mediaUrlHls = [self.mediaUrlHls copy];
    mediaItemCopy.mediaUrlDownload = [self.mediaUrlDownload copy];
    mediaItemCopy.mediaUrlWebS3Path = [self.mediaUrlWebS3Path copy];
    mediaItemCopy.mediaUrl1080pS3Path = [self.mediaUrl1080pS3Path copy];
    mediaItemCopy.mediaThumbnailUrl = [self.mediaThumbnailUrl copy];
    mediaItemCopy.mediaThumbnailUrl79x80 = [self.mediaThumbnailUrl79x80 copy];
    mediaItemCopy.mediaThumbnailUrl98x78 = [self.mediaThumbnailUrl98x78 copy];
    mediaItemCopy.mediaThumbnailUrl448x306 = [self.mediaThumbnailUrl448x306 copy];
    mediaItemCopy.mediaThumbnailUrl1280x720 = [self.mediaThumbnailUrl1280x720 copy];
    mediaItemCopy.mediaLocalIdentifier = [self.mediaLocalIdentifier copy];
    mediaItemCopy.mediaLocalPath = [self.mediaLocalPath copy];
    mediaItemCopy.mediaLocalPHAsset = [self.mediaLocalPHAsset copy];
    mediaItemCopy.mediaLocalThumbnail = [self.mediaLocalThumbnail copy];
    mediaItemCopy.mLatitude = self.mLatitude;
    mediaItemCopy.mLongitude = self.mLongitude;
    mediaItemCopy.mCountry = [self.mCountry copy];
    mediaItemCopy.mCity = [self.mCity copy];
    mediaItemCopy.serverPath = [self.serverPath copy];
    mediaItemCopy.videoDuration = self.videoDuration;
    mediaItemCopy.mediaDate = self.mediaDate;
    mediaItemCopy.isLocal = self.isLocal;
    mediaItemCopy.hasLocation = self.hasLocation;
    mediaItemCopy.mediaLocation = [self.mediaLocation copy];
    mediaItemCopy.mimeType = [self.mimeType copy];
    mediaItemCopy.isSelectedForSync = self.isSelectedForSync;
    mediaItemCopy.transferType = self.transferType;
    mediaItemCopy.transferState = self.transferState;
    mediaItemCopy.copyright = [self.copyright copy];
    mediaItemCopy.shootNSData = [self.shootNSData copy];
    mediaItemCopy.hasShootNSData = self.hasShootNSData;
    mediaItemCopy.codecLevel = [self.codecLevel copy];
    mediaItemCopy.userMediaDevice = [self.userMediaDevice copy];
    mediaItemCopy.indexPath = [self.indexPath copy];

    return mediaItemCopy;
}



@end

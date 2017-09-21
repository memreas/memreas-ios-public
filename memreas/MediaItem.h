#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
@import CoreLocation;
@import Photos;
#import "TransferType.h"
#import "TransferState.h"

typedef NS_ENUM(NSInteger, MediaItemState) { SERVER, SYNC, NOT_SYNC, IN_TRANSIT };

@interface MediaItem : NSObject<NSCopying>

@property(nonatomic) NSString *mediaId;
@property(nonatomic) NSString *eventId;
@property(nonatomic) NSString *deviceId;
@property(nonatomic) NSString *deviceType;
@property(nonatomic) MediaItemState mediaState;
@property(nonatomic) NSString *mediaType;
@property(nonatomic) NSString *mediaName;
@property(nonatomic) NSString *mediaNamePrefix;
@property(nonatomic) NSString *mediaAlbum;
@property(nonatomic) NSString *mediaTranscodeStatus;
@property(nonatomic) int mediaSize;
@property(nonatomic) id metadata;
@property(nonatomic) id mediaUrl;
@property(nonatomic) id mediaPath;
@property(nonatomic) id mediaUrlS3Path;
@property(nonatomic) id mediaUrlWeb;
@property(nonatomic) id mediaUrl1080p;
@property(nonatomic) id mediaUrlHls;
@property(nonatomic) id mediaUrlDownload;
@property(nonatomic) id mediaUrlWebS3Path;
@property(nonatomic) id mediaUrl1080pS3Path;
@property(nonatomic) id mediaThumbnailUrl;
@property(nonatomic) id mediaThumbnailUrl79x80;
@property(nonatomic) id mediaThumbnailUrl98x78;
@property(nonatomic) id mediaThumbnailUrl448x306;
@property(nonatomic) id mediaThumbnailUrl1280x720;
@property(nonatomic) NSString *mediaLocalIdentifier;
@property(nonatomic) NSString *mediaLocalPath;
@property(nonatomic) PHAsset *mediaLocalPHAsset;
@property(nonatomic) UIImage *mediaLocalThumbnail;
@property(nonatomic) double mLatitude;
@property(nonatomic) double mLongitude;
@property(nonatomic) NSString *mCountry;
@property(nonatomic) NSString *mCity;
@property(nonatomic) NSString *serverPath;
@property(nonatomic) long videoDuration;
@property(nonatomic) long mediaDate;
@property(nonatomic) bool isLocal;
@property(nonatomic) bool hasLocation;
@property(nonatomic) CLLocation *mediaLocation;
@property(nonatomic) NSString *mimeType;
@property(nonatomic) bool isSelectedForSync;
@property(nonatomic) TransferType transferType;
@property(nonatomic) TransferState transferState;
@property(nonatomic) NSMutableDictionary *copyright;
@property(nonatomic) NSData *shootNSData;
@property(nonatomic) bool hasShootNSData;
@property(nonatomic) NSString* codecLevel;
@property(nonatomic) id userMediaDevice;
@property(nonatomic) NSIndexPath* indexPath;
@property(nonatomic) bool isSelectedForLocation;
@property NSDictionary* dictTransferProgress;

- (MediaItem *)initWithNSURL:(NSURL *)url;
- (MediaItem *)initWithPHAsset:(PHAsset *)phAsset;
- (void)fetchThumbnailForPHAsset:(CGSize)cgSize;
- (NSString *)getMediaStateAsString;
- (void) fetchFileDatafromPHAsset;
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
                   andWithEvent_media_url_web:(NSString*) event_media_url_web_;

@end

#import <Foundation/Foundation.h>
@import AssetsLibrary;
@import Photos;
@import CoreLocation;
#import "MyConstant.h"
#import "MWebServiceHandler.h"
#import "WebServices.h"
#import "WebServiceParser.h"
#import "XMLGenerator.h"
#import "XMLParser.h"

@protocol GalleryManagerDelegate
- (void)updateLblProgress:(NSString*)txtProgress;
- (void)refreshGalleryView;
- (void)closeSpinnerView;
//- (void)startCaching;
@end

@interface GalleryManager : NSObject

//@property NSMutableOrderedSet* galleryNSMutableOrderedSet;
@property NSMutableArray* galleryNSMutableArray;
@property NSMutableArray* imageGalleryNSMutableArray;
@property NSMutableArray* phAssetsNSMutableArray;
@property NSMutableDictionary* dictGallery;
@property NSOperationQueue* galleryNSOperationQueue;
@property bool hasLocationsLoaded;
@property bool isLoading;
@property bool hasFinishedLoading;
@property(nonatomic, weak) NSObject<GalleryManagerDelegate>* delegate;


+ (GalleryManager*)sharedGalleryInstance;
+ (void)resetSharedGalleryInstance;
- (void)objectParsed_ListAllMedia:(NSMutableDictionary*)dictionary;


@end

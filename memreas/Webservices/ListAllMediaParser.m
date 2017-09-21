#import "ListAllMediaParser.h"
#import "MyConstant.h"
#import "MediaItem.h"
#import "JSONUtil.h"
#import "UIImageView+AFNetworking.h"
#import "NSString+SrtingUrlValidation.h"

@implementation ListAllMediaParser

- (ListAllMediaParser*)init {
    self = [super init];
    // init array of user objects
    self.mediaItemDictionary = [[NSMutableDictionary alloc] init];
    return self;
}

- (NSDictionary*)doParse:(NSData*)data {
    // Converto to String, trim, then back to NSData (remove tabs)
    //  NSString* receivedDataString =     [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //  NSString* trimmedDataString = [receivedDataString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //ALog(@"data ---> %@",receivedDataString);
    //  NSData* trimmedData = [trimmedDataString dataUsingEncoding:NSUTF8StringEncoding];
    
    // create and init NSXMLParser object
    @try {
        
        NSXMLParser* nsXmlParser = [[NSXMLParser alloc] initWithData:data];
        
        // set delegate
        [nsXmlParser setDelegate:self];
        
        // parse using methods below as delegate
        BOOL success = [nsXmlParser parse];
        
        if (nsXmlParser.parserError) {
            ALog(@"Failed to parse XML (line %ld, column %ld): %@!",
                 (long)nsXmlParser.lineNumber, (long)nsXmlParser.columnNumber,
                 nsXmlParser.parserError.localizedDescription);
        }
        // test the result
        if (success) {
            return self.mediaItemDictionary;
        } else {
            ALog(@"Error parsing document!");
            ALog(@"parser error ----> %@", nsXmlParser.parserError);
        }
    } @catch (NSException* exception) {
        ALog(@"%@", exception);
    }
    
    return nil;
}

/**
 * Read start elements
 */
- (void)parser:(NSXMLParser*)parser
didStartElement:(NSString*)elementName
  namespaceURI:(NSString*)namespaceURI
 qualifiedName:(NSString*)qualifiedName
    attributes:(NSDictionary*)attributeDict {
    // ALog(@"Element name start --> %@", elementName);
    if ([elementName isEqualToString:@"media"]) {
        self.mediaItem = [[MediaItem alloc] init];
        // We do not have any attributes in the user elements, but if
        // you do, you can extract them here:
        // user.att = [[attributeDict objectForKey:@"<att name>"] ...];
    }
}

/**
 * Get current value
 */
- (void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string {
    // init the ad hoc string with the value
    currentElementValue = [[NSMutableString alloc] initWithString:string];
    // ALog(@"Processing value for : *%@*", string);
}

/**
 * Read end elements
 */
- (void)parser:(NSXMLParser*)parser
 didEndElement:(NSString*)elementName
  namespaceURI:(NSString*)namespaceURI
 qualifiedName:(NSString*)qName {
    @try {
        if ([elementName isEqualToString:@"listallmediaresponse"]) {
            // We reached the end of the XML document
            return;
        }
        
        if ([elementName isEqualToString:@"media"]) {
            // We are done with user entry – add the parsed user
            // object to our user array
            if (self.mediaItem.mediaNamePrefix.length != 0) {
                //ALog(@"self.mediaItem.mediaNamePrefix forKey %@",
                //      self.mediaItem.mediaNamePrefix);
                self.mediaItem.mediaState = SERVER;
                [self.mediaItemDictionary setObject:self.mediaItem
                                             forKey:self.mediaItem.mediaNamePrefix];
            }
        } else if ([elementName isEqualToString:@"media_id"]) {
            self.mediaItem.mediaId = currentElementValue;
        } else if ([elementName isEqualToString:@"device_id"]) {
            self.mediaItem.deviceId = currentElementValue;
        } else if ([elementName isEqualToString:@"device_type"]) {
            self.mediaItem.deviceType = currentElementValue;
        } else if ([elementName isEqualToString:@"media_date"]) {
            self.mediaItem.mediaDate = [currentElementValue longLongValue];
        } else if ([elementName isEqualToString:@"media_transcode_status"]) {
            self.mediaItem.mediaTranscodeStatus = currentElementValue;
        } else if ([elementName isEqualToString:@"codec_level"]) {
            self.mediaItem.codecLevel = currentElementValue;
        } else if ([elementName isEqualToString:@"main_media_url"]) {
            self.mediaItem.mediaUrl = [JSONUtil convertToID:currentElementValue];
            // ALog(@"self.mediaItem.mediaUrl %@", self.mediaItem.mediaUrl);
        } else if ([elementName isEqualToString:@"main_media_path"]) {
            self.mediaItem.mediaPath = currentElementValue;
            // ALog(@"self.mediaItem.mediaUrl %@", self.mediaItem.mediaUrl);
        } else if ([elementName isEqualToString:@"media_url_hls"]) {
            self.mediaItem.mediaUrlHls = [JSONUtil convertToID:currentElementValue];
            // ALog(@"self.mediaItem.mediaUrlHls %@", self.mediaItem.mediaUrlHls);
        } else if ([elementName isEqualToString:@"media_url_web"]) {
            self.mediaItem.mediaUrlWeb = [JSONUtil convertToID:currentElementValue];
        } else if ([elementName isEqualToString:@"media_url_download"]) {
            self.mediaItem.mediaUrlDownload = [JSONUtil convertToID:currentElementValue];
            // ALog(@"self.mediaItem.mediaUrlDownload %@", self.mediaItem.mediaUrlDownload);
        } else if ([elementName isEqualToString:@"media_url_webs3path"]) {
            self.mediaItem.mediaUrlWebS3Path = currentElementValue;
        } else if ([elementName isEqualToString:@"metadata"]) {
            @try {
                
                self.mediaItem.metadata = [JSONUtil convertToMutableNSDictionary:currentElementValue];
                if (self.mediaItem.metadata != nil) {
                    //
                    // Add Location
                    //
                    NSDictionary* locationDict = [[self.mediaItem.metadata objectForKey:@"S3_files"] objectForKey:@"location"];
                    double latitude = 0;
                    double longitude = 0;
                    if (![locationDict isKindOfClass:[NSNull class]]) {
                        latitude = [[locationDict objectForKey:@"latitude"] doubleValue];
                        longitude = [[locationDict objectForKey:@"longitude"] doubleValue];
                    }
                    CLLocation* location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
                    self.mediaItem.mediaLocation = location;
                    //
                    // hasLocation is true only when lat/lng != 0
                    //
                    if ( (location.coordinate.latitude == 0) && (location.coordinate.longitude == 0) )  {
                        self.mediaItem.hasLocation = NO;
                    } else {
                        self.mediaItem.hasLocation = YES;
                    }
                } else {
                    self.mediaItem.hasLocation = NO;
                }
            } @catch (NSException* exception) {
                self.mediaItem.hasLocation = NO;
            }
            
            // ALog(@"self.mediaItem.metadata %@", self.mediaItem.metadata);
        } else if ([elementName isEqualToString:@"media_url_79x80"]) {
            self.mediaItem.mediaThumbnailUrl79x80 =
            [JSONUtil convertToID:currentElementValue];
            // ALog(@"self.mediaItem.mediaThumbnailUrl79x80 %@",
            //      self.mediaItem.mediaThumbnailUrl79x80);
        } else if ([elementName isEqualToString:@"media_url_98x78"]) {
            self.mediaItem.mediaThumbnailUrl98x78 =
            [JSONUtil convertToID:currentElementValue];
            // ALog(@"self.mediaItem.mediaThumbnailUrl98x78 %@",
            //      self.mediaItem.mediaThumbnailUrl98x78);
        } else if ([elementName isEqualToString:@"media_url_448x306"]) {
            self.mediaItem.mediaThumbnailUrl448x306 =
            [JSONUtil convertToID:currentElementValue];
            // ALog(@"self.mediaItem.mediaThumbnailUrl448x306 %@",
            //      self.mediaItem.mediaThumbnailUrl448x306);
        } else if ([elementName isEqualToString:@"media_url_1280x720"]) {
            self.mediaItem.mediaThumbnailUrl1280x720 =
            [JSONUtil convertToID:currentElementValue];
            // ALog(@"self.mediaItem.mediaThumbnailUrl1280x720 %@",
            //      self.mediaItem.mediaThumbnailUrl1280x720);
        } else if ([elementName isEqualToString:@"type"]) {
            self.mediaItem.mediaType = currentElementValue;
        } else if ([elementName isEqualToString:@"content_type"]) {
            self.mediaItem.mimeType = currentElementValue;
        } else if ([elementName isEqualToString:@"media_name"]) {
            self.mediaItem.mediaName = currentElementValue;
        } else if ([elementName isEqualToString:@"media_name_prefix"]) {
            self.mediaItem.mediaNamePrefix = currentElementValue;
        } else if ([elementName isEqualToString:@"user_media_device"]) {
            self.mediaItem.userMediaDevice = [JSONUtil convertToID:currentElementValue];
        } else if ([elementName isEqualToString:@"listmediaresponse"]) {
            // ALog(@"finished listmediareponse parsing...");
        }
        
    } @catch (NSException* exception) {
        ALog(@"currentElementValue = %@", currentElementValue);
        ALog(@"object type = %@", [[self class] debugDescription]);
        ALog(@"%@", exception);
    }
}

@end

#import "MWebServiceBaseParser.h"
#import "MyConstant.h"
#import "JSONUtil.h"
@implementation MWebServiceBaseParser

- (MWebServiceBaseParser*)init:(NSMutableDictionary*)resultTags {
  self = [super init];
  // init result dictionary
  _resultTags = resultTags;
  return self;
}

- (NSDictionary*)doParse:(NSData*)data {
  // Converto to String, trim, then back to NSData (remove tabs)
  NSString* receivedDataString =
      [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  NSString* trimmedDataString = [receivedDataString
      stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  NSData* trimmedData =
      [trimmedDataString dataUsingEncoding:NSUTF8StringEncoding];

  // create and init NSXMLParser object
  NSXMLParser* nsXmlParser = [[NSXMLParser alloc] initWithData:trimmedData];

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
    return _baseParserResult;
  } else {
    ALog(@"Error parsing document!");
    ALog(@"parser error ----> %@", nsXmlParser.parserError);
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
  // Do nothing - handle end nodes...
  // ALog(@"Element name start --> %@", elementName);
  // if ([elementName isEqualToString:@"status"]) {
  //}
}

/**
 * Get current value
 */
- (void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string {
  // init the ad hoc string with the value
  currentElementValue = [[NSMutableString alloc] initWithString:string];
}

/**
 * Read end elements
 */
- (void)parser:(NSXMLParser*)parser
 didEndElement:(NSString*)elementName
  namespaceURI:(NSString*)namespaceURI
 qualifiedName:(NSString*)qName {
  @try {
    // Handle nodes - expected nodes sent in as dictionary parameter...
    //ALog(@"elementName: %@, currentElementValue: %@", elementName,
    //      currentElementValue);
    if ([_resultTags objectForKey:elementName]) {
      [_resultTags setObject:currentElementValue forKey:elementName];
    }
  } @catch (NSException* exception) {
    ALog(@"object type = %@", [[self class] debugDescription]);
    ALog(@"%@", exception);
  }
}

@end

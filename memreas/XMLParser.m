#import "XMLParser.h"
#import "Util.h"
#import "XMLReader.h"
#import "MyConstant.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@implementation XMLParser

@synthesize xmlParser    = xmlParser_;
@synthesize arrayResult  = arrayResult_;
@synthesize arrayResult2 = arrayResult2_;
@synthesize startingTag  = startingTag_;
@synthesize thirdStartTag = thirdStartTag_;
@synthesize currentTag   = currentTag_;
@synthesize currentValue =currentValue_;
@synthesize tempDic = tempDic_;
@synthesize handler = handler_;
@synthesize completedMethod = completedMethod_;
@synthesize responseData = responseData_;

-(id)init{
    self = [super init];
    if(self){
        self.completedMethod= nil;
        responseData_ = [[NSMutableData alloc] init];
        return self;
    }
    return nil;
}

- (void)parseWithString:(NSString *)stringForParse startTag:(NSString *)startTag completBlock:(void (^)(void))completBlock{
    
}
-(void)parseWithString:(NSString *)stringForParse startTag:(NSString *)startTag completedSelector:(SEL)completedSelector handler:(NSObject*)handler{
    
    
    
    @try {
        
        
          self.handler = handler;
    self.completedMethod = completedSelector;
    isStart = NO;
    arrayResult_ =[[NSMutableArray alloc] init];
    self.startingTag = startTag;
    NSData *data = [stringForParse dataUsingEncoding:NSUTF8StringEncoding];
    stringForParse = nil;
    self.xmlParser = [[NSXMLParser alloc] initWithData:data];
    self.xmlParser.delegate = self;
    [self.xmlParser parse];
    //    if(responseData_ != nil){
    //        responseData_ = [NSMutableData data];
    //        [responseData_ setLength:0];
    //        //        [responseData_ setLength:0];
    //    }

        
        
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
    
      
}

-(void)parseWithURL:(NSString *)urlString startTag:(NSString *)startTag completedSelector:(SEL)completedSelector handler:(NSObject *)handler{
    
    
    @try {
        
        
    self.handler = handler;
    self.completedMethod = completedSelector;
    isStart = NO;
    arrayResult_ =[[NSMutableArray alloc] init];
    self.startingTag = startTag;
    NSURL *url = [NSURL URLWithString:urlString];//listagenda
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:180];
    
    connection1 = [NSURLConnection connectionWithRequest:request delegate:self];
    
    if([Util checkInternetConnection])
        [connection1 start];
    
    url = nil;
    request = nil;

        
        
        
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
    
  }
//With Fail Selector

-(void)parseWithURL:(NSString *)urlString startTag:(NSString *)startTag completedSelector:(SEL)completedSelector failedSelector:(SEL)failedSelector handler:(NSObject *)handler;{
    
}

-(void)parseWithURL:(NSString *)urlString typeParse:(int)_typeParse soapMessage:(NSString *)soadMessage startTag:(NSString *)startTag completedSelector:(SEL)completedSelector handler:(NSObject *)handler{
  
    
    
    
    @try {
        
        
        
    typeParse = _typeParse;
    self.handler = handler;
    self.completedMethod = completedSelector;
    isStart = NO;
    self.isDeepThirdLayer = NO;
    arrayResult_ =[[NSMutableArray alloc] init];
    self.startingTag = startTag;
    if([Util checkInternetConnection]){
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soadMessage length]];
        //    NSMutableURLRequest *request = [NSURLRequest requestWithURL:url];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setTimeoutInterval:180];
        [request setURL:url];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        //    NSMutableString *str = [[NSMutableString alloc] initWithData:[soadMessage dataUsingEncoding:NSUTF8StringEncoding] encoding:NSUTF8StringEncoding];
        //    ALog(@"str: %@",str);
        [request setHTTPBody:[soadMessage dataUsingEncoding:NSUTF8StringEncoding]];
        connection1 = [NSURLConnection connectionWithRequest:request delegate:self];
        
        [connection1 start];
        
        url = nil;
    }

        
        
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
    
    
       //    request = nil;
}
-(void)parseWithURL:(NSString *)urlString soapMessage:(NSString *)soadMessage startTag:(NSString *)startTag completedSelector:(SEL)completedSelector handler:(NSObject *)handler{
   
    
    
    
    @try {
        
           self.handler = handler;
    self.completedMethod = completedSelector;
    isStart = NO;
    self.isDeepThirdLayer = NO;
    arrayResult_ =[[NSMutableArray alloc] init];
    self.startingTag = startTag;
    if([Util checkInternetConnection]){
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soadMessage length]];
        //    NSMutableURLRequest *request = [NSURLRequest requestWithURL:url];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setTimeoutInterval:180];
        [request setURL:url];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        //    NSMutableString *str = [[NSMutableString alloc] initWithData:[soadMessage dataUsingEncoding:NSUTF8StringEncoding] encoding:NSUTF8StringEncoding];
        //    ALog(@"str: %@",str);
        [request setHTTPBody:[soadMessage dataUsingEncoding:NSUTF8StringEncoding]];
        connection1 = [NSURLConnection connectionWithRequest:request delegate:self];
        
        [connection1 start];
        
        url = nil;
    }
    //    request = nil;

        
        
        
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
    
    
 }


-(void)parseWithURL:(NSString *)urlString soapMessage:(NSString *)soadMessage startTag:(NSString *)startTag completedSelector:(SEL)completedSelector handler:(NSObject *)handler isDeepThirdLayer:(BOOL)isDeepThirdLayer{
    
    
    
    
    
    @try {
        
        
         self.handler = handler;
    self.completedMethod = completedSelector;
    isStart = NO;
    self.isDeepThirdLayer = isDeepThirdLayer;
    arrayResult_ =[[NSMutableArray alloc] init];
    self.startingTag = startTag;
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soadMessage length]];
    //    NSMutableURLRequest *request = [NSURLRequest requestWithURL:url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setTimeoutInterval:180];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[soadMessage dataUsingEncoding:NSUTF8StringEncoding]];
    connection1 = [NSURLConnection connectionWithRequest:request delegate:self];
    if([Util checkInternetConnection])
        [connection1 start];
    url = nil;
    //    request = nil;

        
        
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
    
    
   }
//With Fail Selector
-(void)parseWithURL:(NSString *)urlString soapMessage:(NSString *)soadMessage startTag:(NSString *)startTag completedSelector:(SEL)completedSelector failedSelector:(SEL)failedSelector handler:(NSObject *)handler;
{
    
}
#pragma mark
#pragma mark NSURLConnection METHODS

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    
    @try {
        
    [self.handler performSelector:self.completedMethod withObject:[NSDictionary dictionary]];

    }    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    @try {
        if (responseData_ == nil) {
            responseData_ = [[NSMutableData alloc] initWithData:data];
        } else {
            [responseData_ appendData:data];
        }
        
    } @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    @try {
        
    NSString *str = [[[NSString alloc] initWithData:responseData_ encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([str rangeOfString:@"Please Login"].length) {
            [[[UIAlertView alloc] initWithTitle:@"Your session has expired,Please Login again" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            
            UIViewController*c=     (UIViewController*)   self.handler;
            [c dismissViewControllerAnimated:1 completion:nil];

        }
        
        
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];

    if (typeParse == 0) {
        self.xmlParser = [[NSXMLParser alloc] initWithData:data];
        self.xmlParser.delegate = self;
        [self.xmlParser parse];
    }
    else
    {
        NSError *error = nil;
        NSDictionary *dict = [XMLReader dictionaryForXMLData:data
                                                     options:XMLReaderOptionsProcessNamespaces
                                                       error:&error];
        if (!dict) {
            dict = [XMLReader dictionaryForXMLString:str error:&error];
        }
        
        [self.handler performSelector:self.completedMethod withObject:dict];
        typeParse = 0;
    }
    [responseData_ setLength:0];
    responseData_ = nil;
    connection1 = nil;
    str=nil;

        
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
       
}
-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    
}

#pragma mark
#pragma mark Parsing Delegate METHODS

-(void)parserDidStartDocument:(NSXMLParser *)parser{
    
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
   
    
    
    @try {
        
        
        
    if([self.startingTag isEqualToString:@"agendas"]){
        
    } else if([self.startingTag isEqualToString:elementName] && !self.isDeepThirdLayer){
        isStart = YES;
        if(tempDic_ == nil){
            tempDic_ = [[NSMutableDictionary alloc] init];
        }
    } else if([self.startingTag isEqualToString:elementName] && self.isDeepThirdLayer){
        //        isStart = YES;
        self.startDeepThirdLayer = YES;
        if(tempDic_ == nil){
            tempDic_ = [[NSMutableDictionary alloc] init];
        }
    } else if(self.startDeepThirdLayer == YES && ![elementName isEqualToString:@"message"] && ![elementName isEqualToString:@"status"]){
        
        counterLayer++;
        if (counterLayer==1) {
            indexLayer = 0;
            thirdStartTag_ = elementName;
            if(tempDic_ == nil){
                tempDic_ = [[NSMutableDictionary alloc] init];
            }
            if (!arrayResult2_) {
                arrayResult2_ = [[NSMutableArray alloc] init];
            }
            if ([thirdStartTag_ isEqualToString:@"groups"]) {
                //                ALog(@"Groups");
                self.thirdStartTag = @"group";
                counterLayer=0;
                //self.startDeepThirdLayer = NO;
                isStart = NO;
            } else{
                self.startDeepThirdLayer = NO;
                isStart = YES;
            }
        }
    }
    
    if(isStart == YES){
        currentTag_ = elementName;
    }

        
        
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
    
    
  }

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    
    
    @try {
        
          string = [string stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    //    string = [string stringByReplacingOccurrencesOfString:@"'t" withString:@"''t"];
    if([currentTag_ isEqualToString:@"description"]){
        string = [string stringByReplacingOccurrencesOfString: @"\n" withString: @"" ];
        //        ALog(@"%@",string);
    }
    if(currentValue_ == nil){
        currentValue_ = [[NSMutableString alloc] initWithString:string];
    } else{
        [currentValue_ appendString:string];
    }
        
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
    
    
  }

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    
    @try {
        
        
        
    if (!self.isDeepThirdLayer) {
        if([self.startingTag isEqualToString:elementName]){
            if([self.startingTag isEqualToString:@"status"])
                [tempDic_ setValue:currentValue_ forKey:currentTag_];
            if([tempDic_ count] >0)
                [arrayResult_ addObject:tempDic_];
            tempDic_ = nil;
            isStart = NO;
        }
        else{
            if([self.currentTag isEqualToString:elementName]){
                if(currentValue_ == nil) currentValue_ = [[NSMutableString alloc] initWithString:@""];
                [tempDic_ setValue:currentValue_ forKey:currentTag_];
            }
        }
    } else if(counterLayer==1) {
        if ([self.thirdStartTag isEqualToString:elementName] && tempDic_!= nil) {
            [arrayResult2_ addObject:[NSDictionary dictionaryWithObject:tempDic_ forKey:self.thirdStartTag]];
            tempDic_ = nil;
            counterLayer=0;
            self.startDeepThirdLayer = YES;
        }else{
            if (currentValue_ != nil) {
                [tempDic_ setValue:currentValue_ forKey:currentTag_];
            }
        }
    }
    currentValue_ = nil;
    currentTag_ = nil;

        
        
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
    
  }

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    
    
    @try {
        
        
           //    ALog(@"Parsed Result : %@",arrayResult_);
    tempDic_ = nil;
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSMutableDictionary *dic = nil;
    if(self.isDeepThirdLayer){
        if([arrayResult2_ count]>0){
            dic = [NSMutableDictionary dictionaryWithObject:arrayResult2_ forKey:@"objects"];
        }
    } else{
        if([arrayResult_ count]>0)
            dic = [NSMutableDictionary dictionaryWithObject:arrayResult_ forKey:@"objects"];
    }
    [self.handler performSelector:self.completedMethod withObject:dic];
    //    [arrayResult_ removeAllObjects];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];

        
        
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
    
    
 }
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    
    
    
    @try {
            [self.handler performSelector:self.completedMethod withObject:nil];
        
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
    

    
}

-(void) removeAllObject{
    startingTag_ = nil;
    xmlParser_.delegate = nil;
    xmlParser_ = nil;
    if(responseData_ != nil){
        responseData_ = nil;
    }
    if(arrayResult_ != nil){
        arrayResult_ = nil;
    }
    if(tempDic_ != nil){
        tempDic_ = nil;
    }
    currentTag_ = nil;
    currentValue_ = nil;
    handler_ = nil;
}


@end

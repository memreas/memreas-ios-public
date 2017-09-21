#import "WebServiceParser.h"
#import "MyConstant.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@interface WebServiceParser()
    @property SEL targetSelector;
@end

@implementation WebServiceParser


@synthesize isProfile;

-(id)initWithURL:(NSURL*)url arrayRootObjectTags:(NSArray*)arrTags sel:(SEL)selector andHandler:(NSObject*)handler{

    
	if(self = [super init] ){
		self->mainArray=arrTags;
		self.MainHandler=handler;
		self.targetSelector=selector;
		
		NSURLRequest *req=[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100];
        
		if([Util checkInternetConnection]) {
			con=[[NSURLConnection alloc] initWithRequest:req delegate:self];
			if(con){
				myWebData=[NSMutableData data];
			} else {
				[self.MainHandler performSelector:self.targetSelector withObject:nil];
            }
		}
		else {
			ALog(@"No network::");
			return 0;
			
		}

	}
	return self;
}



-(id)initWithRequest:(NSMutableURLRequest*)theReq arrayRootObjectTags:(NSArray*)arrTags sel:(SEL)seletor andHandler:(NSObject*)handler{

    

	if(self = [super init] ){
		self->mainArray=arrTags;
		self.MainHandler=handler;
		self.targetSelector=seletor;
        self->isFriendList = NO;
				ALog(@"con::: %@",con);
		
		if([Util checkInternetConnection]) {
			con=[[NSURLConnection alloc] initWithRequest:theReq delegate:self];
            
			ALog(@"con::: %@",con);
			if(con){
				myWebData=[NSMutableData data];
			} else {
				[self.MainHandler performSelector:self.targetSelector withObject:nil];
			}	
		}
		else {
			ALog(@"No network::");
			return 0;
		}

	} else {
		ALog(@"In the else for init[]");
	}

	
	ALog(@"Out initWithRequest:::::: method");
	return self;	
	
}
-(id)initWithRequest:(NSMutableURLRequest*)theReq arrayRootObjectTags:(NSArray*)arrTags sel:(SEL)seletor andHandler:(NSObject*)handler isFriend:(BOOL)isFriend{
	ALog(@"In initWithRequest:::::: method");
    
	if(self = [super init] ){
		self->mainArray=arrTags;
		self.MainHandler=handler;
		self.targetSelector=seletor;
        self->isFriendList = isFriend;
		
		if([Util checkInternetConnection]) {
			con=[[NSURLConnection alloc] initWithRequest:theReq delegate:self];
			if(con){
				myWebData=[NSMutableData data];
			} else {
				[self.MainHandler performSelector:self.targetSelector withObject:nil];
			}
		}
		else {
			return 0;
		}
        
	} else {
	}
    
	return self;
	
}

-(id)initWithRequest:(NSMutableURLRequest*)theReq typeParse:(int)_typeParse arrayRootObjectTags:(NSArray*)arrTags sel:(SEL)seletor andHandler:(NSObject*)handler isFriend:(BOOL)isFriend{
	ALog(@"In initWithRequest:::::: method");
    //	self=nil;
	if(self = [super init] ){
        typeParse = _typeParse;
		self->mainArray=arrTags;
		self.MainHandler=handler;
		self.targetSelector=seletor;
        self->isFriendList = isFriend;
        //        ALog(@"con::: %@",con);
		
		if([Util checkInternetConnection]) {
			con=[[NSURLConnection alloc] initWithRequest:theReq delegate:self];
            //			ALog(@"con::: %@",con);
			if(con){
				myWebData=[NSMutableData data];
			} else {
				[self.MainHandler performSelector:self.targetSelector withObject:nil];
			}
		}
		else {
            //			ALog(@"No network::");
			return 0;
		}
        
	} else {
        //		ALog(@"In the else for init[]");
	}
    
	
    //	ALog(@"Out initWithRequest:::::: method");
	return self;
	
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//	ALog(@"In didReceiveResponse:::::: method");
	[myWebData setLength: 0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//	ALog(@"In didReceiveData:::::: method");
	[myWebData appendData:data];
//	ALog(@"Out didReceiveData:::::: method value for myWebData::%@",myWebData);
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
//	[connection release];
//	ALog(@"In didFailWithError:::::: method");
//	ALog(@"Error::: %@",error);
	[self parserDidEndDocument:nil];
    [self.MainHandler performSelector:self.targetSelector withObject:nil];
	ALog(@"Out didFailWithError:::::: method");
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {

    /*
     * Receive valid response here...
     */
    
    NSString *str = [[NSString alloc] initWithData:myWebData encoding:NSUTF8StringEncoding];
    str = [str stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    ALog(@"response xml here --->%@",str);
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    myWebData = [NSMutableData dataWithData:data];
	if( myXMLParser!=nil ) { myXMLParser.delegate=nil; }
        myXMLParser = [[NSXMLParser alloc] initWithData: myWebData];
        [myXMLParser setDelegate: self]; [myXMLParser setShouldResolveExternalEntities: YES];
        [myXMLParser parse];
    
    
	if (self->isFriendList) {
        [self.MainHandler performSelector:self.targetSelector withObject:objDic];
    }else{
        if(!didGetHTML){
            if(objectsArray!=nil && [objectsArray count]>0){
                [self.MainHandler performSelector:self.targetSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:objectsArray,@"objects",tmpOther,@"others",nil]];
            } else {
                [self.MainHandler performSelector:self.targetSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:@[],@"objects",@[],@"others",nil]];
            }
        }
        else {
            [self.MainHandler performSelector:self.targetSelector withObject:nil];
        }
    }
    ALog(@"array: %@", objectsArray);

}

#pragma mark
#pragma mark XMLParsing Methods

-(void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qualifiedName attributes:(NSDictionary*)attributeDict {
//	ALog(@"START ELEMENT=%@",elementName);
	
    /*
     * Parse response here...
     */

    if(self->isFriendList){
        strTemp = nil;
        
        if([elementName isEqualToString:@"viewevents"])
        {
//            ALog(@"level1 start");
            arrFriends = nil;
            arrFriends = [[NSMutableArray alloc]init];
            arrViewEvent = [[NSMutableArray alloc]init];
            objDic = [[NSMutableDictionary alloc]init];
            counterInside = 1;
        }
        if([elementName isEqualToString:@"friend"])
        {
//            ALog(@"level2 start");
            frndDic = nil;
            frndDic = [[NSMutableDictionary alloc]init];
            counterInside = 2;
            
        }
        if([elementName isEqualToString:@"events"])
        {
//            ALog(@"level3 start");
            arrMultiEvent = nil;
            arrEvent = nil;
            arrEvent = [[NSMutableArray alloc]init];
            arrMultiEvent = [[NSMutableArray alloc]init];
            counterInside = 3;
        }
        if([elementName isEqualToString:@"event"])
        {
            
            eventDic = nil;
            eventDic = [[NSMutableDictionary alloc]init];
            tmpArr = [[NSMutableArray alloc]init];
            tmpdics = nil;
            tmpdics = [[NSMutableDictionary alloc]init];
            counterInside = 4;
        }
    }
    /***pratik **/
    
    if([elementName isEqualToString:@"html"] || [elementName isEqualToString:@"HTML"]){
        didGetHTML=YES; [self parserDidEndDocument:parser];
    } else if([[self->mainArray objectAtIndex:0] isEqualToString:elementName] && [[self->mainArray objectAtIndex:1] isEqualToString:elementName] && !didGetHTML) {
        objectsArray=[[NSMutableArray alloc] init];
        tmpD=[[NSMutableDictionary alloc] init];
        if(tmpOther==nil) tmpOther=[[NSMutableDictionary alloc] init];
//        ALog(@"Log - 1");
    } else if([[self->mainArray objectAtIndex:0] isEqualToString:elementName] && !didGetHTML ) {
        objectsArray=[[NSMutableArray alloc] init];
        if(tmpOther==nil) tmpOther=[[NSMutableDictionary alloc] init];
        //added by pranav - start
        if(tmpD==nil) tmpD=[[NSMutableDictionary alloc] init];
        //added by pranav - end
//        ALog(@"Log - 2");
    } else if([[self->mainArray objectAtIndex:1] isEqualToString:elementName] && !didGetHTML ) {
        //added by pranav - start
        if(tmpD==nil) tmpD=[[NSMutableDictionary alloc] init];
        //added by pranav - end
//        ALog(@"Log - 3");
    }
    
}

-(void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string {
//	ALog(@"In foundCharacters:::::: method");
	string=[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //code by girish
    string = [string stringByReplacingOccurrencesOfString:@"'" withString:@"`"];
//	ALog(@"FOUND CHARACTER===%@",string);
    if(self->isFriendList){
        strTemp = [[NSString alloc] initWithString:string];
    }else{
        if(tmpString==nil && !didGetHTML){
            tmpString=[[NSString alloc] initWithString:string];
        } else if(!didGetHTML){
            NSString *t=[NSString stringWithString:tmpString];
            //		if([tmpString retainCount]>0) { [tmpString release]; tmpString=nil; }
            tmpString=nil;
            tmpString=[[NSString alloc] initWithFormat:@"%@ %@",t,string];
        }
    }

//	ALog(@"Out foundCharacters:::::: method");
}



-(void)parser:(NSXMLParser*)parser didEndElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qualifiedName {
//	ALog(@"In didEndElement:::::: method");
//	ALog(@"END ELEMENT===%@",elementName);
//	ALog(@"END ELEMENT 1===%@",tmpString);
	if([[self->mainArray objectAtIndex:0] isEqualToString:elementName] && [[self->mainArray objectAtIndex:1] isEqualToString:elementName] && !didGetHTML){
//		ALog(@"NIKETA 1");
		[objectsArray addObject:tmpD];
		//Added by Pranav - start
//		[tmpD release];
        tmpD=nil;
		//Added by Pranav - end
	} else if([elementName isEqualToString:[self->mainArray objectAtIndex:1]] && !didGetHTML){
//		ALog(@"NIKETA 2");
		[objectsArray addObject:tmpD];
//		[tmpD release];
        tmpD=nil;
		[tmpOther setValue:tmpString forKey:elementName];
	} else if([self->mainArray containsObject:elementName] && !didGetHTML) {
//		ALog(@"NIKETA 3");
		[tmpD setValue:tmpString forKey:elementName];
//		[tmpString release];
        tmpString=nil;
	} else {
//		ALog(@"NIKETA 4");
		[tmpD setValue:tmpString forKey:elementName];
//		[tmpString release];
        tmpString=nil;
	}
    
    /**pratik**/
    if(self->isFriendList){
        if(counterInside == 1)
        {
            [objDic setValue:strTemp forKey:elementName];
            //        return;
        }
        if(counterInside == 2)
        {
            [frndDic setValue:strTemp forKey:elementName];
        }
        if(counterInside == 4)
        {
            if(![elementName isEqualToString:@"event"] && ![elementName isEqualToString:@"events"] && ![elementName isEqualToString:@"friends"] && ![elementName isEqualToString:@"friend"])
                [tmpdics setValue:strTemp forKey:elementName];
        }
        if([elementName isEqualToString:@"event"])
        {
            [arrEvent addObject:tmpdics];
        }
         if([elementName isEqualToString:@"events"])
        {
            [frndDic setValue:arrEvent forKey:elementName];
        }
        else if([elementName isEqualToString:@"friend"])
        {
            [arrFriends addObject:frndDic];
        }
        else if([elementName isEqualToString:@"friends"])
        {
            [objDic setValue:arrFriends forKey:elementName];
        }
        if (counterInside == 5)
        {
            [objDic setValue:strTemp forKey:elementName];
        }
    }


}



-(void)parserDidEndDocument:(NSXMLParser *)parser{
	
}


- (void)cancelDownload {
	//[con cancel];
	[myXMLParser setDelegate:nil];
}

-(void)stopDelegate {
	[myXMLParser setDelegate:nil];
	if(con!=nil ) {  con=nil; }
	if(myWebData!=nil) {  myWebData=nil; }
	if(self->mainArray!=nil ){ self->mainArray=nil; }
	if(objectsArray!=nil) { objectsArray=nil; }
	if(tmpString!=nil) {tmpString=nil; }
	if(tmpD!=nil ) { tmpD=nil; }
	if(tmpOther!=nil) { tmpOther=nil; }
}

-(void)dealloc{
	if(con!=nil) {  con=nil; }
	if(myWebData!=nil) {myWebData=nil; }
	if(myXMLParser!=nil ) { myXMLParser.delegate=nil; myXMLParser=nil; }
	if(self->mainArray!=nil){  self->mainArray=nil; }
	
	if(objectsArray!=nil ) { objectsArray=nil; }
	if(tmpString!=nil ) {  tmpString=nil; }
	if(tmpD!=nil ) {  tmpD=nil; }
	if(tmpOther!=nil) { tmpOther=nil; }
//	[super dealloc];
}
@end

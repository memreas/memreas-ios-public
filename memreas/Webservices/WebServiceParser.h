#import <Foundation/Foundation.h>
#import "Util.h"

@interface WebServiceParser : NSObject<NSXMLParserDelegate> {
	NSURLConnection *con;
	NSMutableData *myWebData;
	NSXMLParser *myXMLParser;
	NSMutableArray *objectsArray;
	NSString *tmpString;
	NSMutableDictionary *tmpD;
	NSMutableDictionary *tmpOther;
	BOOL didGetHTML;
	NSArray *mainArray;
	BOOL isProfile;
	BOOL isFriendList;
    int counterInside;
    NSMutableArray *arrViewEvent,*arrFriends,*arrEvent,*arrMultiEvent,*tmpArr;
    NSMutableDictionary *objDic,*tmpdics,*eventDic,*frndDic;
    NSString *strTemp;
    int typeParse;
}

@property bool isForXMLDataOnly;
@property BOOL isFriendList;
@property BOOL isProfile;
@property NSObject *MainHandler;

-(id)initWithURL:(NSURL*)url arrayRootObjectTags:(NSArray*)arrTags sel:(SEL)seletor andHandler:(NSObject*)handler;

-(id)initWithRequest:(NSMutableURLRequest*)theReq arrayRootObjectTags:(NSArray*)arrTags sel:(SEL)seletor andHandler:(NSObject*)handler;
//-(id)initWithRequest:(NSMutableURLRequest*)theReq arrayRootObjectTags:(NSArray*)arrTags sel:(SEL)seletor andHandler:(NSObject*)handler;

-(id)initWithRequest:(NSMutableURLRequest*)theReq arrayRootObjectTags:(NSArray*)arrTags sel:(SEL)seletor andHandler:(NSObject*)handler isFriend:(BOOL)isFriend;
-(id)initWithRequest:(NSMutableURLRequest*)theReq typeParse:(int)typeParse arrayRootObjectTags:(NSArray*)arrTags sel:(SEL)seletor andHandler:(NSObject*)handler isFriend:(BOOL)isFriend;
-(void)parserDidEndDocument:(NSXMLParser *)parser;
-(void)cancelDownload;
-(void)stopDelegate;
@end

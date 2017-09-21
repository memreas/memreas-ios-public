#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, FriendType) { MemreasNetwork, Email, SMS, PhoneBookContact };

@interface FriendsContactEntry : NSObject

@property (nonatomic) FriendType friendType;
@property (nonatomic) id objectOfFriend;
@property (nonatomic) id Identifier;
+(instancetype)friendInstance;
@end

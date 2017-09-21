#import "HeaderView.h"
#import "Helper.h"
#import "NSString+SrtingUrlValidation.h"
#import "UIImageView+AFNetworking.h"

#pragma mark - Header View Class

//
// Header View
//
@implementation HeaderView

#pragma mark - IB Actions
-(void)setDicPassedEventDetail:(NSDictionary *)dicPassedEventDetail{
    _dicPassedEventDetail = dicPassedEventDetail;
    [self loadheaderData];
}

-(void)loadheaderData{
    
    @try {
        
        ALog(@"%@", self.dicPassedEventDetail );
        //
        // User Header
        //
        switch (self.selectedSegmentIndex) {
            case 0:{
                //
                // Me header view
                //
                self.lblEventName.text =[NSString stringWithFormat:@"!%@", [self.dicPassedEventDetail valueForKeyPath:@"event_name.text"]];
                self.lblUserName.text =[NSString stringWithFormat:@"@%@",[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"userDetail.ownerName"]];
                [self.imgUserImage setImageWithURL:[NSURL URLWithString:[[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"userDetail.ownerImage"] urlEnocodeString]] placeholderImage:[UIImage imageNamed:@"profile_img"]];
                
                [self.btnLikeUserHeader setTitle:[self.dicPassedEventDetail valueForKeyPath:@"like_count.text"] forState:UIControlStateNormal];
                [self.btnCommentUserHeader setTitle:[self.dicPassedEventDetail valueForKeyPath:@"comment_count.text"] forState:UIControlStateNormal];
                
                // Friends
                if ([[self.dicPassedEventDetail valueForKeyPath:@"event_friends.event_friend"] isKindOfClass:[NSArray class]]) {
                    self.friendCollectionView.arrFriends = [self.dicPassedEventDetail valueForKeyPath:@"event_friends.event_friend"];
                }else if ([self.dicPassedEventDetail valueForKeyPath:@"event_friends.event_friend"]){
                    self.friendCollectionView.arrFriends =@[ [self.dicPassedEventDetail valueForKeyPath:@"event_friends.event_friend"]];
                }else{
                    self.friendCollectionView.arrFriends =@[ ];
                }
                
                
                break;
            }
            case 1:{
                //
                // Friends header view
                //
                NSArray* arrEvents;
                NSDictionary* dictEvent;
                if ([[self.dicPassedEventDetail valueForKeyPath:@"events.event"] isKindOfClass:[NSArray class]]) {
                    arrEvents = [self.dicPassedEventDetail valueForKeyPath:@"events.event"];
                    dictEvent = [arrEvents objectAtIndex:self.selectedEventIndex];
                }
                
                //top level data - uname and pic
                self.lblUserName.text =[NSString stringWithFormat:@"@%@",[self.dicPassedEventDetail valueForKeyPath:@"event_creator.text"]];
                [self.imgUserImage setImageWithURL:[NSURL URLWithString:[[[self.dicPassedEventDetail valueForKeyPath:@"profile_pic_79x80.text"] convertToJsonWithFirstObject] urlEnocodeString]] placeholderImage:[UIImage imageNamed:@"profile_img"]];
                
                
                //event level data - event_name. like and comment count...
                self.lblEventName.text =[NSString stringWithFormat:@"!%@", [dictEvent valueForKeyPath:@"event_name.text"]];
                
                [self.btnLikeUserHeader setTitle:[dictEvent valueForKeyPath:@"like_count.text"] forState:UIControlStateNormal];
                [self.btnCommentUserHeader setTitle:[dictEvent valueForKeyPath:@"comment_count.text"] forState:UIControlStateNormal];
                
                // Friends - sub event level...
                if ([[dictEvent valueForKeyPath:@"event_friends.event_friend"] isKindOfClass:[NSArray class]]) {
                    self.friendCollectionView.arrFriends = [self.dicPassedEventDetail valueForKeyPath:@"event_friends.event_friend"];
                }else if ([self.dicPassedEventDetail valueForKeyPath:@"event_friends.event_friend"]){
                    self.friendCollectionView.arrFriends =@[ [self.dicPassedEventDetail valueForKeyPath:@"event_friends.event_friend"]];
                }else{
                    self.friendCollectionView.arrFriends =@[ ];
                }
                break;
            }
            case 2:{
                //
                // Public header view
                //
                self.lblEventName.text =[NSString stringWithFormat:@"!%@", [self.dicPassedEventDetail valueForKeyPath:@"event_name.text"]];
                self.lblUserName.text =[NSString stringWithFormat:@"@%@",[self.dicPassedEventDetail valueForKeyPath:@"event_creator.text"]];
                
                [self.imgUserImage setImageWithURL:[NSURL URLWithString:[[[self.dicPassedEventDetail valueForKeyPath:@"profile_pic_79x80.text"] convertToJsonWithFirstObject] urlEnocodeString]] placeholderImage:[UIImage imageNamed:@"profile_img"]];
                
                [self.btnLikeUserHeader setTitle:[self.dicPassedEventDetail valueForKeyPath:@"event_like_total.text"] forState:UIControlStateNormal];
                [self.btnCommentUserHeader setTitle:[self.dicPassedEventDetail valueForKeyPath:@"event_comment_total.text"] forState:UIControlStateNormal];
                
                // Friends
                if ([[self.dicPassedEventDetail valueForKeyPath:@"event_friends.event_friend"] isKindOfClass:[NSArray class]]) {
                    self.friendCollectionView.arrFriends = [self.dicPassedEventDetail valueForKeyPath:@"event_friends.event_friend"];
                }else if ([self.dicPassedEventDetail valueForKeyPath:@"event_friends.event_friend"]){
                    self.friendCollectionView.arrFriends =@[ [self.dicPassedEventDetail valueForKeyPath:@"event_friends.event_friend"]];
                }else{
                    self.friendCollectionView.arrFriends =@[ ];
                }
                break;
            }
            case 3:{
                self.lblEventName.text =[NSString stringWithFormat:@"!%@", [self.dicPassedEventDetail valueForKeyPath:@"name"]];
                self.lblUserName.text =[NSString stringWithFormat:@"@%@",[self.dicPassedEventDetail valueForKeyPath:@"event_creator"]];
                
                [self.imgUserImage setImageWithURL:[NSURL URLWithString:[[[self.dicPassedEventDetail valueForKeyPath:@"event_creator_pic"] firstObject] urlEnocodeString]] placeholderImage:[UIImage imageNamed:@"profile_img"]];
                
                [self.btnLikeUserHeader setTitle:[self.dicPassedEventDetail valueForKeyPath:@"like_count"] forState:UIControlStateNormal];
                [self.btnCommentUserHeader setTitle:[self.dicPassedEventDetail valueForKeyPath:@"comment_count"] forState:UIControlStateNormal];
                
                // Friends
                self.friendCollectionView.selectedSegmentIndex = self.selectedSegmentIndex;
                if ([[self.dicPassedEventDetail valueForKeyPath:@"friends"] isKindOfClass:[NSArray class]]) {
                    self.friendCollectionView.arrFriends = [self.dicPassedEventDetail valueForKeyPath:@"friends"];
                }else if ([self.dicPassedEventDetail valueForKeyPath:@"friends"]){
                    self.friendCollectionView.arrFriends =@[ [self.dicPassedEventDetail valueForKeyPath:@"friends"]];
                }else{
                    self.friendCollectionView.arrFriends =@[ ];
                }
                
                
                break;
            }
                
                
            default:
                break;
        }
        
    }
    @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
}

@end

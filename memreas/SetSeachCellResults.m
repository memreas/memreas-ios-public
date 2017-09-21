#import "SetSeachCellResults.h"
#import "Helper.h"
#import "MyConstant.h"
#import "UIImageView+AFNetworking.h"
#import "NSString+SrtingUrlValidation.h"

@implementation CellButton


@end

@implementation SetSeachCellResults

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];// 138, 123, 125
    // Configure the view for the selected state
}

-(void)assignTags :(NSIndexPath*)indexPath{
    self.btnAcceptRequest.tag = indexPath.row;
    self.btnAddFriend.tag = indexPath.row;
    self.btnDeclineRequest.tag = indexPath.row;
    self.btnIgnoreRequest.tag = indexPath.row;
    self.btnReply.tag = indexPath.row;
}

-(void)configureFriendsdetail:(NSDictionary *)dic{
    
    //@search person
    @try {
        
        [self.profileImage setImageWithURL:[NSURL URLWithString:[[dic[@"profile_photo"] firstObject] urlEnocodeString]] placeholderImage:[UIImage imageNamed:@"profile_img"]];
        self.btnAddFriend.tag = self.tag;
        self.lblName.text = dic[@"username"];
        
        //handle current user
        if ([dic[@"username"] isEqualToString:[Helper fetchUserName]] ) {
            [self.btnAddFriend setHidden:YES];
            self.btnAddFriend.enabled=NO;
        } else {
            [self.btnAddFriend setHidden:NO];
            self.btnAddFriend.enabled=1;
        }

        if (dic[@"friend_request_sent"]) {
            if ([dic[@"friend_request_sent"] boolValue]) {
                [self.btnAddFriend setTitle:@"friend" forState:UIControlStateDisabled];
                self.btnAddFriend.enabled=NO;
                [self.btnAddFriend setHidden:NO];
                
            }else{
                [self.btnAddFriend setTitle:@"friend request sent" forState:UIControlStateDisabled];
                self.btnAddFriend.enabled=NO;
            }
        }else{
            [self.btnAddFriend setTitle:@"add friend" forState:UIControlStateNormal];
        }
    } @catch (NSException *exception) {
        ALog(@"Class : %@ :::  Method : %s %@",NSStringFromClass([self class]),__PRETTY_FUNCTION__,exception);
    }
    
}



-(void)configureDiscoverdetail:(NSDictionary *)dic{
    
    // #discover
    [self.profileImage setImageWithURL:[NSURL URLWithString:[[dic[@"commenter_photo"] firstObject] urlEnocodeString]] placeholderImage:[UIImage imageNamed:@"profile_img"]];
    [self.imageEvent setImageWithURL:[NSURL URLWithString:[[dic[@"event_photo"] firstObject] urlEnocodeString]] placeholderImage:[UIImage imageNamed:@"Galr"]];
    
    self.btnAddFriend.tag = self.tag;
    self.btnAddFriend.enabled=1;
    [self.btnAddFriend setHidden:YES];
    self.lblComment.text = dic[@"comment"];
    self.lblName.text = dic[@"event_name"];
    
}


-(void)configureMemreasdetail:(NSDictionary *)dic{
    
    // !event
    ALog(@"event dictionary --->%@", dic);
    [self.profileImage setImageWithURL:[NSURL URLWithString:[[dic[@"event_creator_pic"] firstObject] urlEnocodeString]] placeholderImage:[UIImage imageNamed:@"profile_img"]];
    [self.imageEvent setImageWithURL:[NSURL URLWithString:[[dic[@"event_photo"] firstObject] urlEnocodeString]] placeholderImage:[UIImage imageNamed:@"Galr"]];
    self.btnAddFriend.tag = self.tag;
    self.btnAddFriend.enabled=YES;
    [self.btnAddFriend setHidden:NO];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"] isEqualToString:dic[@"user_id"]]) {
        [self.btnAddFriend setTitle:@"Your own event" forState:UIControlStateDisabled];
        self.btnAddFriend.enabled=NO;
        [self.btnAddFriend setHidden:YES];
    }else{
        if (dic[@"event_request_sent"] ) {
            if ([dic[@"event_request_sent"] boolValue]) {
                //event_request_sent = 1   : means accepted
                [self.btnAddFriend setTitle:@"event request accepted." forState:UIControlStateDisabled];
                self.btnAddFriend.enabled=NO;
                [self.btnAddFriend setHidden:NO];
            }else{
                
                //event_request_sent = 0   : means request sent
                [self.btnAddFriend setTitle:@"event request sent." forState:UIControlStateDisabled];
                self.btnAddFriend.enabled=NO;
                [self.btnAddFriend setHidden:NO];
            }
        }else{
            [self.btnAddFriend setTitle:@"add me" forState:UIControlStateNormal];
        }
    }
    self.lblName.text = dic[@"name"];
}




+(NSString*)convertIntegerToTime:(NSString*)timeStamp{
    
    //    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    //    NSDateComponents *weekdayComponents = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:date];
    //    int weekday = [weekdayComponents weekday];
    
    ALog(@"weekday== %@",timeStamp);
    return timeStamp;
    
}

@end

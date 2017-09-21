#import "FriendsCell.h"
#import "AddMemreasViewController.h"

@implementation FriendsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)displayUserInfo:(NSString *)userName andProfileUrl:(NSString * )profileUrl andSelected:(BOOL)selected{
    
    self.userName.text=userName;
    self.btnSelected.selected=selected;
    //profileUrl = [profileUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self.profilePic setImage:[UIImage imageNamed:@"placeholder.png"]];
    
}

-(void)displayUserInfo:(NSString *)userName andProfileUrl:(NSString * )profileUrl andSelected:(BOOL)selected andIsGroup:(BOOL)isGroup{
    
    self.userName.text=userName;
    self.btnSelected.selected=selected;
    //profileUrl = [profileUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self.profilePic setImage:[UIImage imageNamed:@"group_icon"]];
    
}

-(IBAction)btnGroupPressed:(UIButton *)sender{
    sender.selected=!sender.selected;
//    self.txtGroupName.enabled=sender.selected;
    
    if (sender.selected) {
        [self.txtGroupName setEnabled:YES];
    }else{
        [self.txtGroupName setEnabled:NO];
        [self.txtGroupName setText:@""];
        [self.txtGroupName resignFirstResponder];
    }
    //__weak AddMemreasViewController * controller = self.delegate;
    //[controller setIsGrouped:sender.selected];

}



@end

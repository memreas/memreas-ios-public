#import "PublicTableUIViewController.h"
#import "PublicUITableViewCell.h"
#import "MyConstant.h"
#import "MemreasMainViewController.h"
#import "NSString+SrtingUrlValidation.h"
#import "UIImageView+AFNetworking.h"

@implementation PublicTableUIViewController{
    MemreasMainViewController* parent;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)viewDidLoad
{
    //    ALog(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //setup parent
    [self setParentMemreasMainViewController];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setParentMemreasMainViewController{
    parent = (MemreasMainViewController*)self.parentViewController;
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self->parent.arrPublicEvents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PublicUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellPublic" forIndexPath:indexPath];
    cell.tableVC = self;
    cell.indexpath = indexPath;
    
    @try {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSDictionary *dic ;
            //set public events dictionary
            dic = self->parent.arrPublicEvents[indexPath.row];
            [cell.imgProfilePics setImageWithURL:[NSURL URLWithString:[[[dic valueForKeyPath:@"profile_pic_98x78.text"] convertToJsonWithFirstObject] urlEnocodeString]] placeholderImage:[UIImage imageNamed:@"TranscodingDisc"]];
            
            NSString *eventImage = @"";
            //set public events eventImage
            if ([[dic valueForKeyPath:@"event_media"] isKindOfClass:[NSArray class]]) {
                eventImage = [[dic valueForKeyPath:@"event_media"] firstObject][@"event_media_98x78"][@"text"];
                
            }else if([dic valueForKeyPath:@"event_media"]){
                eventImage = [dic valueForKeyPath:@"event_media.event_media_98x78.text"];
            }
        
            //ALog("eventImage-->%@", eventImage);
            [cell.imgEventPics setImageWithURL:[NSURL URLWithString:[[eventImage convertToJsonWithFirstObject] urlEnocodeString]] placeholderImage:[UIImage imageNamed:@"TranscodingDisc"]];
            
            //set public events event name
            cell.lblName.text = [NSString stringWithFormat:@"!%@",[dic valueForKeyPath:@"event_name.text"]];
            [cell.btnLikeCount setTitle:[dic valueForKeyPath:@"event_like_total.text"] forState:UIControlStateNormal];
            [cell.btnCommentCount setTitle:[dic valueForKeyPath:@"event_comment_total.text"] forState:UIControlStateNormal];
            
            //ALog(@"%@", dic);
            if ([[dic valueForKeyPath:@"event_friends.event_friend"] isKindOfClass:[NSArray class]]) {
                cell.dicDetail = [dic valueForKeyPath:@"event_friends.event_friend"];
            }else if ([dic valueForKeyPath:@"event_friends.event_friend"]){
                cell.dicDetail =@[ [dic valueForKeyPath:@"event_friends.event_friend"]];
            }else{
                cell.dicDetail =@[ ];
            }
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
    cell.backgroundView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self->parent CellTap:indexPath andDictionary:nil];
}


-(void)selectedEvent:(NSDictionary*)dictionary  andIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dic ;

    dic = self->parent.arrPublicEvents[indexPath.row];
    
    NSMutableDictionary *dicPassed = [NSMutableDictionary dictionaryWithDictionary:dic];
    [dicPassed addEntriesFromDictionary:dictionary];
    
    [self->parent CellTap:indexPath andDictionary:dicPassed];
    
}

@end

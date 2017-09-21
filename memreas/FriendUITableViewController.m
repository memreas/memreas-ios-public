#import "MyConstant.h"
#import "MemreasMainViewController.h"
#import "FriendUITableViewController.h"
#import "FriendUITableViewCell.h"
#import "NSString+SrtingUrlValidation.h"
#import "UIImageView+AFNetworking.h"

@implementation FriendUITableViewController{
    MemreasMainViewController* parent;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

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

#pragma mark
#pragma mark - Table view delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self->parent.arrFriendEvents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.tableVC = self;
    cell.indexpath = indexPath;
    
    @try {
        
        
        NSDictionary *dic ;
        
        //event_creator - username
        dic = self->parent.arrFriendEvents[indexPath.row];
        cell.lblName.text = [NSString stringWithFormat:@"@%@",[dic valueForKeyPath:@"event_creator.text"]];
        
        //event_creator - profile pic
        [cell.imgProfilePics setImageWithURL:[NSURL URLWithString:[[[dic valueForKeyPath:@"profile_pic_98x78.text"] convertToJsonWithFirstObject] urlEnocodeString]] placeholderImage:[UIImage imageNamed:@"TranscodingDisc"]];
        
        //ALog("dic --> %@",dic);
        if ([[dic valueForKeyPath:@"events.event"] isKindOfClass:[NSArray class]]) {
            cell.dicDetail = [dic valueForKeyPath:@"events.event"];
            
        }else if([dic valueForKeyPath:@"events.event"]){
            cell.dicDetail =@[ [dic valueForKeyPath:@"events.event"]];
        }else{
            cell.dicDetail =@[ ];
        }
        
        //load the events
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self->parent CellTap:indexPath andDictionary:nil];
}


-(void)selectedEvent:(NSDictionary*)dictionary  andIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dic ;
    
    dic = self->parent.arrFriendEvents[indexPath.row];
    
    NSMutableDictionary *dicPassed = [NSMutableDictionary dictionaryWithDictionary:dic];
    [dicPassed addEntriesFromDictionary:dictionary];
    
    [self->parent CellTap:indexPath andDictionary:dicPassed];
    
}


@end

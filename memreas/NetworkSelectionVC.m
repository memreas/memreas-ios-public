#import "NetworkSelectionVC.h"
#import "MyConstant.h"

@implementation NetworkCell
@end

@implementation NetworkSelectionVC

- (void)viewDidLoad {
    ALog(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    
    self.arrayName = [NSMutableArray arrayWithObjects:@"memreas",@"facebook",@"email",@"sms", nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return     self.arrayName.count;
}

- (IBAction)btnRadioTapped:(UIButton*)sender {
    
    
    @try {
        
        
    self.selectedNetwork = sender.tag;
    [self.tableView reloadData];
    
    [self.delegate didselectNetwork:self selectedIndex:sender.tag];


        
        
        
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
    }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NetworkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    [cell.btnRadio addTarget:self action:@selector(btnRadioTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    // Configure the cell...
    
    cell.lblNetworkName.text =     self.arrayName[indexPath.row];
    cell.btnRadio.tag = indexPath.row;
    
    cell.btnRadio.layer.cornerRadius = cell.btnRadio.frame.size.width/2;
    cell.btnRadio.layer.masksToBounds = 1;
    
           [cell.btnRadio setBackgroundImage:nil forState:UIControlStateNormal];
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView.backgroundColor = [UIColor clearColor];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    @try {
        
        self.selectedNetwork = indexPath.row;
        [self.tableView reloadData];
        [self.delegate didselectNetwork:self selectedIndex:indexPath.row];
        
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

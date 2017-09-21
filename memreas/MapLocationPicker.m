#import "MapLocationPicker.h"
#import "MyConstant.h"

@interface MapLocationPicker ()<GMSMapViewDelegate,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet GMSMapView *googlemap;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray*arryLocation;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (nonatomic,strong)NSMutableArray*arry;
@end

@implementation MapLocationPicker

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    ALog(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    self.view.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.view.layer.cornerRadius =10;
    self.view.layer.borderWidth=5;
    self.view.layer.masksToBounds=1;
    
    [self initUIGooleMap];
    self.searchBar.text = self.searchText;
    
    // Do any additional setup after loading the view.
}

-(void)setArryLocation:(NSMutableArray *)arryLocation{
    
    _arryLocation = arryLocation;
    [self.tableView reloadData];
    
}

-(void)setSearchText:(NSString *)searchText{
    
    _searchText=searchText;
    self.searchBar.text = searchText;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)closePressed:(id)sender {
    
    
    @try {
        //        [self removeFromParentViewController];
        //        [self.view removeFromSuperview];
        [self.delegate mapPicker:self didFinishWithPickLocation:nil andLocation:nil];
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
}


-(void)setSelectedLocation:(CLLocation *)selectedLocation{
    
    _selectedLocation = selectedLocation;
    
    @try {
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.selectedLocation.coordinate.latitude longitude:self.selectedLocation.coordinate.longitude zoom:16];
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = camera.target;
        marker.snippet = self.searchText;
        marker.map = self.googlemap;
        [self.googlemap setCamera:camera];
    } @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
}
-(NSMutableArray *)arry{
    
    if (!_arry) {
        _arry = [[NSMutableArray alloc]init];
    }return _arry;
}


- (IBAction)okPressed:(id)sender {
    
    @try {
        [self.delegate mapPicker:self didFinishWithPickLocation:self.searchBar.text andLocation:self.selectedLocation];
    }
    @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
    
    
}

- (void)initUIGooleMap
{
    self.googlemap.myLocationEnabled = YES;
    self.googlemap.delegate = self;
    
    @try {
        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.selectedLocation.coordinate.latitude longitude:self.selectedLocation.coordinate.longitude zoom:16];
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = camera.target;
        marker.snippet = self.searchText;
        marker.map = self.googlemap;
        [self.googlemap setCamera:camera];
    } @catch (NSException *exception) {
        ALog(@"%@",exception);
    }
}

#pragma mark -------- search bar delegate ---------

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self.searchBar resignFirstResponder];
    self.tableView.hidden=1;
    
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
    self.tableView.hidden=1;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    NSString*str =  [[NSString stringWithFormat: @"%@/autocomplete/json?sensor=false&key=%@&input=%@",PLACES_API_BASE,GMSSERVICESKEY,self.searchBar.text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:str parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        ALog(@"JSON: %@", responseObject);
        self.arryLocation =responseObject[@"predictions"];
        self.tableView.hidden  =!self.arryLocation.count;
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        ALog(@"Error: %@", error);
        self.tableView.hidden=1;
    }];
    [self.arry addObject:manager];
}

#pragma mark - UITableView DataSource


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.arryLocation.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary*dic = self.arryLocation[indexPath.row];
    cell.textLabel.text =dic[@"description"];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.tableView.hidden=1;
    [self.searchBar resignFirstResponder];
    
    [self.arry makeObjectsPerformSelector:@selector(cancel)];
    
    NSDictionary*dic = self.arryLocation[indexPath.row];
    self.searchBar.text =dic[@"description"];
    
    self.loadingView.hidden=0;
    NSString*str =  [[NSString stringWithFormat: @"%@/details/json?&key=%@&reference=%@",PLACES_API_BASE,GMSSERVICESKEY,dic[@"reference"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:str parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        ALog(@"JSON: %@", responseObject);
        self.loadingView.hidden=1;
        [self.googlemap clear];
        NSDictionary*locationDic =[responseObject valueForKeyPath:@"result.geometry.location"];
        CLLocation *location = [[CLLocation alloc]initWithLatitude:[locationDic[@"lat"] floatValue]   longitude:[locationDic[@"lng"] floatValue]];
        self.searchText = dic[@"description"];
        self.selectedLocation =location;
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        ALog(@"Error: %@", error);
        self.loadingView.hidden=1;
    }];
    
}




@end

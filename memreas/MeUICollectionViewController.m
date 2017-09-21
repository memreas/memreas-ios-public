#import "MeUICollectionViewController.h"
#import "MyConstant.h"
#import "GridCell.h"
#import "MemreasMainViewController.h"
#import "NSString+SrtingUrlValidation.h"
#import "UIImageView+AFNetworking.h"

@implementation MeUICollectionViewController{
    NSInteger dynamicCellSizeHeight, dynamicCellSizeWidth;
    MemreasMainViewController* parent;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    
    //setup parent
    [self setParentMemreasMainViewController];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setParentMemreasMainViewController{
    parent = (MemreasMainViewController*)self.parentViewController;
}


#pragma mark
#pragma mark Me Grid View Delegates
//set a custom size for iPad...
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // setup cell size
    if (IS_IPAD) {
        dynamicCellSizeHeight = MEMREAS_MAIN_CELLSIZE_IPAD_HEIGHT;
        dynamicCellSizeWidth = MEMREAS_MAIN_CELLSIZE_IPAD_WIDTH;
    } else {
        dynamicCellSizeHeight = MEMREAS_MAIN_CELLSIZE_IPHONE_HEIGHT;
        dynamicCellSizeWidth = MEMREAS_MAIN_CELLSIZE_IPHONE_WIDTH;
    }
    
    
    return CGSizeMake(dynamicCellSizeWidth, dynamicCellSizeHeight);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self->parent.arrEvents.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [self->parent CellTap:indexPath andDictionary:nil];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    GridCell *cell = (GridCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSDictionary*dic = self->parent.arrEvents[indexPath.row];
    
    NSString *eventImage = @"";
    
    if ([[dic valueForKeyPath:@"event_media"] isKindOfClass:[NSArray class]]) {
        eventImage = [[dic valueForKeyPath:@"event_media"] firstObject][@"event_media_98x78"][@"text"];
        
    }else if([dic valueForKeyPath:@"event_media"]){
        eventImage = [dic valueForKeyPath:@"event_media.event_media_98x78.text"];
    }
    
    NSString *urlForImaage = [[eventImage convertToJsonWithFirstObject] urlEnocodeString];
    [cell.imgPhoto setImageWithURL:[NSURL URLWithString:urlForImaage] placeholderImage:[UIImage imageNamed:@"TranscodingDisc"]];
    
    cell.lblEventName.text = [NSString stringWithFormat:@"!%@",[dic valueForKeyPath:@"event_name.text"]];
    NSString *type = [NSString stringWithFormat:@"%@",[dic valueForKeyPath:@"event_media_type.text"] ];
    
    if([type isEqualToString:@"video"]) {
        [cell.imgVideo setImage:[UIImage imageNamed:@"video_play"]];
    } else {
        [cell.imgVideo setImage:nil];
    }
    
    return cell;
    
}
@end

#import "PublicUITableViewCell.h"
#import "MemreasEventViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "NSString+SrtingUrlValidation.h"
#import "GridCell.h"


@implementation PublicUITableViewCell

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

-(void)setDicDetail:(NSArray *)dicDetail{
    
    _dicDetail = dicDetail;
    [self.collectionView reloadData];
    
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dicDetail.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary*dic = self.dicDetail[indexPath.item];
    [self.tableVC selectedEvent:dic andIndexPath:self.indexpath];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    GridCell *cell = (GridCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    @try {
        NSDictionary*dic = self.dicDetail[indexPath.item];
        
        [cell.imgVideo setImage:nil];
        cell.lblEventName.text =@"";
        
        [cell.imgPhoto setImageWithURL:[NSURL URLWithString:[[[dic valueForKeyPath:@"event_friend_url_image.text"] convertToJsonWithFirstObject] urlEnocodeString]] placeholderImage:[UIImage imageNamed:@"TranscodingDisc"]];
        
        //round corner
        cell.imgPhoto.layer.cornerRadius = 5.0;
        cell.imgPhoto.clipsToBounds = YES;
        

    }
    @catch (NSException *exception) {
        cell.lblEventName.text =@"";
        [cell.imgPhoto
         setImage:[UIImage imageNamed:@"TranscodingDisc"]];
        return cell;
        
        ALog(@"Exception populating MemreasEventViewCell data :: %@",exception);
    }
    
    return cell;
    
}



@end

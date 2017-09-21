#import "MyConstant.h"
#import "FriendUITableViewCell.h"
#import "MemreasEventViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "NSString+SrtingUrlValidation.h"

@implementation FriendUITableViewCell
/*
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
*/
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)setDicDetail:(NSArray *)dicDetail{

    _dicDetail = dicDetail;
    ALog("dicDetail --> %@",dicDetail);
    ALog("self.dicDetail.count --> %@",@(self.dicDetail.count));
    [self.collectionView reloadData];

}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    ALog("self.dicDetail.count --> %@",@(self.dicDetail.count));
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
        
        NSString *eventImage = @"";
        
        if ([[dic valueForKeyPath:@"event_media"] isKindOfClass:[NSArray class]]) {
            eventImage = [[dic valueForKeyPath:@"event_media"] firstObject][@"event_media_98x78"][@"text"];
        }else if([dic valueForKeyPath:@"event_media"]){
            eventImage = [dic valueForKeyPath:@"event_media.event_media_98x78.text"];
        }
        ALog("eventImage url--> %@",eventImage);
        [cell.imgPhoto setImageWithURL:[NSURL URLWithString:[[eventImage convertToJsonWithFirstObject] urlEnocodeString]] placeholderImage:[UIImage imageNamed:@"TranscodingDisc"]];
        
        //round corner
        cell.imgPhoto.layer.cornerRadius = 5.0;
        cell.imgPhoto.clipsToBounds = YES;
        
        cell.lblEventName.text = [NSString stringWithFormat:@"!%@",[dic valueForKeyPath:@"event_name.text"]];
        NSString *type = [NSString stringWithFormat:@"%@",[dic valueForKeyPath:@"event_media_type.text"] ];
        
        if([type isEqualToString:@"video"])
        {
            [cell.imgVideo setImage:[UIImage imageNamed:@"video_play"]];
        }
        else{
            [cell.imgVideo setImage:nil];
        }
    }
    @catch (NSException *exception) {
        //cell.lblEventName.text =@"";
        //[cell.imgPhoto setImage:[UIImage imageNamed:@"TranscodingDisc"]];
        //return cell;

        ALog(@"Exception populating MemreasEventViewCell data :: %@",exception);
    }
    return cell;
}



@end

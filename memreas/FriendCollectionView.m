#import "FriendCollectionView.h"
#import "NSString+SrtingUrlValidation.h"
#import "UIImageView+AFNetworking.h"

@implementation FriendCollectionView

-(void)setArrFriends:(NSArray *)arrFriends{
    _arrFriends = arrFriends;
    [self reloadData];
}
-(void)awakeFromNib{
    [super awakeFromNib];
    self.dataSource = self;
    self.delegate = self;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.arrFriends != nil) {
        return self.arrFriends.count;
    }
    return 0;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GridCell *cell = (GridCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    @try {
        
        NSDictionary*dic = self.arrFriends[indexPath.item];
        
        if (self.selectedSegmentIndex ==3) {
            [cell.imgPhoto setImageWithURL:[NSURL URLWithString:[[[dic valueForKeyPath:@"profile_photo"] firstObject] urlEnocodeString]] placeholderImage:[UIImage imageNamed:@"profile_img"]];
        }else{
            [cell.imgPhoto setImageWithURL:[NSURL URLWithString:[[[dic valueForKeyPath:@"event_friend_url_image.text"] convertToJsonWithFirstObject] urlEnocodeString]] placeholderImage:[UIImage imageNamed:@"profile_img"]];
        }
        
    }
    @catch (NSException *exception) {
        return cell;
        ALog(@"%@",exception);
    }
    return cell;
}
@end

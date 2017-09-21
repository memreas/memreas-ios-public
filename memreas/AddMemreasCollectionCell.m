#import "AddMemreasCollectionCell.h"
#import "AddMemreasViewController.h"
#import "GridCell.h"
#import "NSString+SrtingUrlValidation.h"
@implementation AddMemreasCollectionCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString*)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // Initialization code
  }
  return self;
}

- (void)awakeFromNib {
  // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
  // Configure the view for the selected state
}

- (NSMutableArray*)arrOnlyServerImages {
  //__weak AddMemreasViewController* controller = self.delegate;

    return nil;
  //return controller.imageListingArray;
}

- (NSMutableArray*)assetAry {
  //__weak AddMemreasViewController* controller = self.delegate;

    return nil;
  //return controller.assetAry;
}

- (NSMutableArray*)selectedFileDownload {
  //__weak AddMemreasViewController* controller = self.delegate;

    return nil;
  //return controller.selectedFileDownload;
}

- (NSMutableArray*)selectedAssetsImages {
  //__weak AddMemreasViewController* controller = self.delegate;

    return nil;
  //return controller.selectedAssetsImages;
}

#pragma mark - CollectionView DataSource.

- (NSInteger)numberOfSectionsInCollectionView:
    (UICollectionView*)collectionView {
  return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return self.arrOnlyServerImages.count + self.assetAry.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
                 cellForItemAtIndexPath:(NSIndexPath*)indexPath {
  float widthB = 2;

  if (self.arrOnlyServerImages.count > 0 &&
      self.arrOnlyServerImages.count > indexPath.item) {
    GridCell* cell = (GridCell*)
        [collectionView dequeueReusableCellWithReuseIdentifier:@"ServerCell"
                                                  forIndexPath:indexPath];

    MyView* myView = cell.myView;
    myView.imgPhoto.layer.cornerRadius = 10;
    myView.imgPhoto.layer.masksToBounds = YES;
    myView.imgPhoto.clipsToBounds = YES;
    myView.layer.borderWidth = widthB;

    NSDictionary* dicTemp =
        [self.arrOnlyServerImages objectAtIndex:indexPath.item];

    [myView setBackgroundColor:[UIColor blackColor]];

    //        NSString*strUserID = [NSString
    //        stringWithFormat:@"/%@/image",[[NSUserDefaults
    //        standardUserDefaults] valueForKey:@"UserId"]];
    //        NSString *urlMedia = [[dicTemp valueForKey:@"main_media_url"]
    //        stringByReplacingOccurrencesOfString:strUserID
    //        withString:strUserID];
    //        NSString *urlMedia = [dicTemp valueForKey:@"main_media_url"];
    //        urlMedia = [urlMedia
    //        stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //        myView.imageURL = urlMedia;
    //          ALog(@"%@",urlMedia);

    myView.tag = 50000 + indexPath.item;
    [myView.btnPhoto setTag:60000 + indexPath.item];

    myView.layer.borderColor = [UIColor clearColor].CGColor;
    [myView.btnPhoto setBackgroundImage:nil forState:UIControlStateNormal];
    [myView.btnPhoto setBackgroundImage:nil forState:UIControlStateSelected];
    myView.btnPhoto.selected = NO;

    //        switch (self.segViewSync.selectedSegmentIndex) {
    //            case 0:{
    //
    //                [myView.btnPhoto removeTarget:self
    //                action:@selector(btnPhotoClicked:)
    //                forControlEvents:UIControlEventTouchUpInside];
    //                [myView.btnPhoto addTarget:self
    //                action:@selector(openGalleryImage:) forControlEvents:
    //                 UIControlEventTouchUpInside];
    //                break;
    //            }
    //
    //            case 1:{
    //
    //                [myView.btnPhoto removeTarget:self
    //                action:@selector(btnPhotoClicked:)
    //                forControlEvents:UIControlEventTouchUpInside];
    //                [myView.btnPhoto addTarget:self
    //                action:@selector(openGalleryImage:)
    //                forControlEvents:UIControlEventTouchUpInside];
    //                break;
    //            }
    //
    //            case 2:{

    //                [myView.btnPhoto removeTarget:self
    //                action:@selector(openGalleryImage:)
    //                forControlEvents:UIControlEventTouchUpInside];
    [myView.btnPhoto addTarget:self
                        action:@selector(btnPhotoClicked:)
              forControlEvents:UIControlEventTouchUpInside];

    if ([self.selectedFileDownload containsObject:dicTemp]) {
      myView.btnPhoto.selected = YES;
      [myView.btnPhoto setBackgroundImage:[UIImage imageNamed:@"Overlay"]
                                 forState:UIControlStateNormal];
      [myView.btnPhoto setBackgroundImage:[UIImage imageNamed:@"Overlay"]
                                 forState:UIControlStateSelected];
    } else {
      myView.btnPhoto.selected = NO;
      [myView.btnPhoto setBackgroundImage:nil forState:UIControlStateNormal];
      [myView.btnPhoto setBackgroundImage:nil forState:UIControlStateSelected];
    }

    //                [self isInGallery:dicTemp[@"media_name"] withCell:cell
    //                andServer:YES];
    //                if([self isInGallery:dicTemp[@"media_name"] withCell:cell
    //                andServer:YES]){
    //                    myView.layer.borderColor = [UIColor
    //                    greenColor].CGColor;
    //                } else{
    //                    myView.layer.borderColor = [UIColor
    //                    clearColor].CGColor;
    //                }

    //                break;
    //            }
    //
    //            default:
    //                break;
    //        }

    NSString* type =
        [NSString stringWithFormat:@"%@", [dicTemp valueForKey:@"type"]];
    if ([type isEqualToString:@"video"]) {
      [myView.btnPhoto setImage:[UIImage imageNamed:@"video_play"]
                       forState:UIControlStateNormal];
    } else {
      [myView.btnPhoto setImage:nil forState:UIControlStateNormal];
    }

    NSString* thumbURl = [[NSString
        stringWithFormat:
            @"%@",
            [[dicTemp
                valueForKey:@"media_url_79x80"] convertToJsonWithFirstObject]]
        stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (thumbURl == nil || [myView.imageURL isEqualToString:@"(null)"] ||
        thumbURl.length == 0) {
      thumbURl = [[NSString
          stringWithFormat:
              @"%@",
              [[dicTemp
                  valueForKey:@"main_media_url"] convertToJsonWithFirstObject]]
          stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }

      [myView.imgPhoto setImage:[UIImage imageNamed:@"gallery_img"]];
    return cell;

  } else {
    GridCell* cell = (GridCell*)
        [collectionView dequeueReusableCellWithReuseIdentifier:@"LocalCell"
                                                  forIndexPath:indexPath];

    ALAsset* result = [self.assetAry
        objectAtIndex:(indexPath.item - self.arrOnlyServerImages.count)];

    int assetViewTag =
        10000 + (int)(indexPath.item - self.arrOnlyServerImages.count);

    ELCAsset* elcAsset = cell.elcAsset;
    [elcAsset.assetImageViewHome
        setImage:[UIImage imageWithCGImage:[result thumbnail]]];
    elcAsset.asset = result;
    [elcAsset setBackgroundColor:[UIColor clearColor]];

    elcAsset.assetImageViewHome.layer.cornerRadius = 10;
    elcAsset.assetImageViewHome.layer.masksToBounds = YES;
    elcAsset.assetImageViewHome.clipsToBounds = YES;
    elcAsset.layer.borderWidth = widthB;
    elcAsset.layer.borderColor = [UIColor clearColor].CGColor;
    elcAsset.layer.cornerRadius = 10;

    if ([result valueForProperty:ALAssetPropertyType] == ALAssetTypeVideo) {
      [elcAsset.videoImageViewHome setContentMode:UIViewContentModeCenter];
      [elcAsset.videoImageViewHome setImage:[UIImage imageNamed:@"video_play"]];
    } else {
      [elcAsset.videoImageViewHome setImage:nil];
    }

    [elcAsset setParent:self];
    elcAsset.tag = assetViewTag;
    elcAsset.buttonHome.tag =
        20000 + (indexPath.item - self.arrOnlyServerImages.count);
    ELCAsset* view = cell.elcAsset;

    //        switch (self.segViewSync.selectedSegmentIndex) {
    //
    //            case 0:{
    //
    //                [elcAsset.buttonHome removeTarget:self
    //                action:@selector(assetSelect:)
    //                forControlEvents:UIControlEventTouchUpInside];
    //                [elcAsset.buttonHome  addTarget:self
    //                action:@selector(openGalleryImage:)
    //                forControlEvents:UIControlEventTouchUpInside];
    //
    //                elcAsset.overlayViewHome.hidden = YES;
    //                elcAsset.buttonHome.hidden = NO;
    //                [cell bringSubviewToFront:view];
    //
    //                break;
    //            }
    //            case 1:{
    //
    //                [elcAsset.buttonHome removeTarget:self
    //                action:@selector(assetSelect:)
    //                forControlEvents:UIControlEventTouchUpInside];
    //                [elcAsset.buttonHome  addTarget:self
    //                action:@selector(openGalleryImage:)
    //                forControlEvents:UIControlEventTouchUpInside];
    //                view.buttonHome.hidden = NO;
    //                [cell bringSubviewToFront:view.buttonHome];
    //                elcAsset.overlayViewHome.hidden = YES;
    //
    //
    //                break;
    //            }
    //            case 2:{
    //                elcAsset.layer.borderColor = [UIColor redColor].CGColor;
    elcAsset.buttonHome.hidden = NO;
    //                [elcAsset.buttonHome removeTarget:self
    //                action:@selector(openGalleryImage:)
    //                forControlEvents:UIControlEventTouchUpInside];
    [elcAsset.buttonHome addTarget:self
                            action:@selector(assetSelect:)
                  forControlEvents:UIControlEventTouchUpInside];

    if ([self.selectedAssetsImages containsObject:result]) {
      elcAsset.overlayViewHome.hidden = NO;

    } else {
      elcAsset.overlayViewHome.hidden = YES;
    }
    [cell bringSubviewToFront:view];
    //                break;
    //            }
    //            default:
    //                break;
    //        }

    return cell;
  }
}

- (void)assetSelect:(UIButton*)button {
  ALAsset* result = [self.assetAry objectAtIndex:button.tag - 20000];

  if ([self.selectedAssetsImages containsObject:result]) {
    [self.selectedAssetsImages removeObject:result];

  } else {
    [self.selectedAssetsImages addObject:result];
  }
  //    [self.gridCollectionView reloadData]

  [self.collectionView reloadItemsAtIndexPaths:@[
    [NSIndexPath
        indexPathForItem:button.tag - 20000 + self.arrOnlyServerImages.count
               inSection:0]
  ]];
}

- (IBAction)btnPhotoClicked:(id)sender {
  UIButton* btn = (UIButton*)sender;
  int tag = (int)btn.tag - 60000;
  //        ALog(@"tag:- %d",tag);
  //        ALog(@"clicked url :- %@",[[self.arrOnlyServerImages
  //        objectAtIndex:tag] valueForKey:@"main_media_url"]);
  if (btn.selected) {
    btn.selected = NO;
    [btn setBackgroundImage:[UIImage imageNamed:nil]
                   forState:UIControlStateNormal];
    [self.selectedFileDownload
        removeObject:[self.arrOnlyServerImages objectAtIndex:(tag)]];
    //            selectCounter--;
  } else {
    btn.selected = YES;
    [btn setBackgroundImage:[UIImage imageNamed:@"Overlay"]
                   forState:UIControlStateNormal];
    NSMutableDictionary* dic = [self.arrOnlyServerImages objectAtIndex:(tag)];
    MyView* myview2 = (MyView*)[btn superview];
    if (myview2.imgPhoto.image != nil) {
      [dic setObject:myview2.imgPhoto.image forKey:@"thumbImage"];
      [dic setObject:[NSNumber numberWithInt:(int)myview2.tag]
              forKey:@"mediaTag"];
      [self.arrOnlyServerImages replaceObjectAtIndex:tag withObject:dic];
    }
    [self.selectedFileDownload
        addObject:[self.arrOnlyServerImages objectAtIndex:(tag)]];
    //            selectCounter++;
  }
}

@end

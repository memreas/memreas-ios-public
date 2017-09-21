#import <UIKit/UIKit.h>
@class AMGProgressView;
@class MyConstant;
@class TransferModel;

@interface UploadCustomCell : UITableViewCell {
}
@property(strong, nonatomic) NSString* imgURL;
@property(strong, nonatomic) IBOutlet UIView* uploadTransferView;
@property(strong, nonatomic) IBOutlet UIImageView* uploadVideoView;
@property(strong, nonatomic) IBOutlet UIImageView* uploadImageView;
@property(strong, nonatomic) IBOutlet UIButton* btnCancel;
@property(strong, nonatomic) IBOutlet UIButton* btnClose;
@property(strong, nonatomic) IBOutlet AMGProgressView* uploadProgressbar;
@property(strong, nonatomic) IBOutlet UILabel* uploadPercentage;
@property(strong, nonatomic) NSString* fileName;
@property(weak, nonatomic) TransferModel* transferModel;

@end

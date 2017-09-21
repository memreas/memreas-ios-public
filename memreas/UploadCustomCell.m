#import "UploadCustomCell.h"
#import "AMGProgressView.h"
#import "MyConstant.h"
#import "TransferModel.h"

@implementation UploadCustomCell

@synthesize imgURL = _imgURL;
@synthesize uploadImageView = _uploadImageView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
@end

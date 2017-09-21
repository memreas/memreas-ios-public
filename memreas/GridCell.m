#import "GridCell.h"

@implementation GridCell

- (id)init {
  // Assumes cell size set in Interface Builder (i.e. 100x100)
  return [super init];
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    self.size = frame.size;
  }
  return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

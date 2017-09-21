#import "AppDelegate.h"
#import "ELCAsset.h"
#import "MyConstant.h"
@implementation ELCAsset

@synthesize asset;
@synthesize parent;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

-(id)initWithAsset:(ALAsset*)_asset {
	
	if (self = [super initWithFrame:CGRectMake(0, 0, 0, 0)]) {
		
		self.asset = _asset;
		
        //		CGRect viewFrames = CGRectMake(0, 0, 75, 75);
        CGRect viewFrames;
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if(app.forAssetSize == 1)
            viewFrames = CGRectMake(1, 1, 95, 76);
        else
            viewFrames = CGRectMake(1, 1, 84, 84);
        
		UIImageView *assetImageView = [[UIImageView alloc] initWithFrame:viewFrames];
		[assetImageView setContentMode:UIViewContentModeScaleToFill];
		[assetImageView setImage:[UIImage imageWithCGImage:[self.asset thumbnail]]];
		[self addSubview:assetImageView];
		assetImageView =nil;
		
        
        if([self.asset valueForProperty:ALAssetPropertyType] == ALAssetTypeVideo){
            UIImageView *videoImageView = [[UIImageView alloc] initWithFrame:viewFrames];
            [videoImageView setContentMode:UIViewContentModeCenter];
            [videoImageView setImage:[UIImage imageNamed:@"video_play"]];
            [self addSubview:videoImageView];
            videoImageView =nil;
        }
        
        //        if ([mediaType isEqualToString:@"ALAssetTypePhoto"]){
        
		overlayView = [[UIImageView alloc] initWithFrame:viewFrames];
		[overlayView setImage:[UIImage imageNamed:@"Overlay"]];
		[overlayView setHidden:YES];
		[self addSubview:overlayView];
    }
    
	return self;
}

-(id)initWithAsset:(ALAsset*)_asset withFrame:(CGRect)frame{
	
	if (self = [super initWithFrame:CGRectMake(0, 0, 0, 0)]) {
		
		self.asset = _asset;
		
        //		CGRect viewFrames = CGRectMake(0, 0, 75, 75);
        /*
         CGRect viewFrames;
         
         AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
         if(app.forAssetSize == 1)
         viewFrames = CGRectMake(1, 1, 95, 76);
         else
         viewFrames = CGRectMake(1, 1, 84, 84);
         */
        viewBack = [[UIView alloc] initWithFrame:frame];
        viewBack.backgroundColor = [UIColor blackColor];
        [self addSubview:viewBack];
        viewBack =nil;
        
        //		UIImageView *assetImageView = [[UIImageView alloc] initWithFrame:frame];
        UIImageView *assetImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, frame.size.width-2, frame.size.height-2)];
        //[assetImageView setContentMode:UIViewContentModeScaleToFill];
		[assetImageView setContentMode:UIViewContentModeScaleToFill];
		[assetImageView setImage:[UIImage imageWithCGImage:[self.asset thumbnail]]];
		[self addSubview:assetImageView];
		assetImageView =nil;
		
        
        if([self.asset valueForProperty:ALAssetPropertyType] == ALAssetTypeVideo){
            UIImageView *videoImageView = [[UIImageView alloc] initWithFrame:frame];
            [videoImageView setContentMode:UIViewContentModeCenter];
            [videoImageView setImage:[UIImage imageNamed:@"video_play"]];
            [self addSubview:videoImageView];
            videoImageView=nil ;
        }
        
        //        if ([mediaType isEqualToString:@"ALAssetTypePhoto"]){
        
		overlayView = [[UIImageView alloc] initWithFrame:frame];
		[overlayView setImage:[UIImage imageNamed:@"Overlay"]];
		[overlayView setHidden:YES];
		[self addSubview:overlayView];
    }
    
	return self;
}
-(void)setColor:(UIColor *)color{
    viewBack.backgroundColor = color;
}
-(void)colorHide{
    viewBack.hidden = YES;
}
-(void)colorUnhide{
    viewBack.hidden = NO;
}
-(void)toggleSelection {
    //ALAssetRepresentation *rep = [self.asset defaultRepresentation];
    //    if(rep.size > fileMaxSize){
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"You can not upload file which exceed size 10 MB." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //        [alert show];
    //        alert = nil;
    //    } else{
    
    overlayView.hidden = !overlayView.hidden;
    //    }
    //    if([(ELCAssetTablePicker*)self.parent totalSelectedAssets] >= 10) {
    //
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Maximum Reached" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    //		[alert show];
    //		[alert release];
    //
    //        [(ELCAssetTablePicker*)self.parent doneAction:nil];
    //    }
}

-(BOOL)selected {
	
	return !overlayView.hidden;
}

-(void)setSelected:(BOOL)_selected {
    
    //ALAssetRepresentation *rep = [self.asset defaultRepresentation];
    //    if(rep.size > fileMaxSize){
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"You can not upload file which exceed size 10 MB." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //        [alert show];
    //        alert = nil;
    //    } else{
    [overlayView setHidden:!_selected];
    //    }
}

//- (void)dealloc
//{    
//    self.asset = nil;
//	[overlayView release];
//    [super dealloc];
//}

@end


#import "BackSegue.h"

@implementation BackSegue

-(void)perform{
    UIViewController *destination = [self destinationViewController];
    UIViewController *source = [self sourceViewController];
    [destination viewWillAppear:NO];
    [destination viewDidAppear:NO];
    //[source retain]; only if ARC is not used
    [source.view addSubview:destination.view];
    CGRect original = destination.view.frame;
    //    destination.view.frame = CGRectMake(destination.view.frame.origin.x+destination.view.frame.size.width, 0-destination.view.frame.size.height, destination.view.frame.size.width, destination.view.frame.size.height);
    
    
    original.origin.y -= destination.view.frame.size.height;
    destination.view.frame = CGRectMake(original.origin.x, original.origin.y, original.size.height, original.size.width);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    original.origin.y += original.size.height;
    destination.view.frame = CGRectMake(original.origin.x, original.origin.y, original.size.height, original.size.width);
    
    [UIView commitAnimations];
    
    [self performSelector:@selector(animationDone:) withObject:destination afterDelay:0.2f];
}
- (void)animationDone:(id)vc{
    //    UIViewController *destination = (UIViewController*)vc;
    UINavigationController *navController = [[self sourceViewController] navigationController];
    //    [navController pushViewController:destination animated:NO];
    [navController popViewControllerAnimated:NO];
    //[[self sourceViewController] release]; only if ARC is not used
}
@end

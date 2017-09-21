#import "ALAsset+DateOrder.h"

@implementation ALAsset (DateOrder)

- (NSDate *) date
{
    return [self valueForProperty:ALAssetPropertyDate];
}

@end

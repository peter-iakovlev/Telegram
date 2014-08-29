#import "TGMediaUsageUserItem.h"

#import "TGMediaUsageUserItemView.h"

@implementation TGMediaUsageUserItem

- (Class)itemViewClass
{
    return [TGMediaUsageUserItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 44.0f);
}

@end

#import "TGModernMediaListVideoItemView.h"

#import "TGModernMediaListVideoItem.h"

@implementation TGModernMediaListVideoItemView

- (void)setItem:(TGModernMediaListVideoItem *)item
{
    [super setItem:item];
    
    [super setImageUri:item.imageUri];
}

@end

#import "TGModernMediaListImageItemView.h"

#import "TGImageView.h"

#import "TGModernMediaListImageItem.h"

@interface TGModernMediaListImageItemView ()
{
}

@end

@implementation TGModernMediaListImageItemView

- (void)setItem:(TGModernMediaListImageItem *)item
{
    [super setItem:item];
    
    [super setImageUri:item.imageUri];
}

@end

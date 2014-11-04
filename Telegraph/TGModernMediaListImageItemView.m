#import "TGModernMediaListImageItemView.h"

#import "TGImageView.h"

#import "TGModernMediaListImageItem.h"

@interface TGModernMediaListImageItemView ()
{
}

@end

@implementation TGModernMediaListImageItemView

- (void)setItem:(TGModernMediaListImageItem *)item synchronously:(bool)synchronously
{
    [super setItem:item synchronously:synchronously];
    
    [super setImageUri:item.imageUri];
}

@end

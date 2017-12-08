#import "TGModernMediaListImageItemView.h"

#import <LegacyComponents/TGImageView.h>

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

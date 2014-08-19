#import "TGModernMediaListImageItem.h"

#import "TGModernMediaListImageItemView.h"

@implementation TGModernMediaListImageItem

- (instancetype)initWithImageUri:(NSString *)imageUri
{
    self = [super init];
    if (self != nil)
    {
        _imageUri = imageUri;
    }
    return self;
}

- (Class)viewClass
{
    return [TGModernMediaListImageItemView class];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGModernMediaListImageItem class]] && TGStringCompare(_imageUri,  ((TGModernMediaListImageItem *)object).imageUri);
}

@end

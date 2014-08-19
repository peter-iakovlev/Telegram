#import "TGModernMediaListVideoItem.h"

#import "TGModernMediaListVideoItemView.h"

@implementation TGModernMediaListVideoItem

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
    return [TGModernMediaListVideoItemView class];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGModernMediaListVideoItem class]] && TGStringCompare(_imageUri,  ((TGModernMediaListVideoItem *)object).imageUri);
}

@end

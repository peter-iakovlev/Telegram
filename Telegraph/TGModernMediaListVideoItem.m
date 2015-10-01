#import "TGModernMediaListVideoItem.h"

#import "TGModernMediaListVideoItemView.h"

@implementation TGModernMediaListVideoItem

- (instancetype)initWithImageUri:(NSString *)imageUri duration:(NSTimeInterval)duration
{
    self = [super init];
    if (self != nil)
    {
        _imageUri = imageUri;
        _duration = duration;
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

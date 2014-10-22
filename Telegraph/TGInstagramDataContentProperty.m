#import "TGInstagramDataContentProperty.h"

#import "PSKeyValueCoder.h"

@implementation TGInstagramDataContentProperty

- (instancetype)initWithImageUrl:(NSString *)imageUrl
{
    self = [super init];
    if (self != nil)
    {
        _imageUrl = imageUrl;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    return [self initWithImageUrl:[coder decodeStringForCKey:"u"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeString:_imageUrl forCKey:"u"];
}

@end

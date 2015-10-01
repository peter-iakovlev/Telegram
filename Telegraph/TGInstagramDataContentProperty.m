#import "TGInstagramDataContentProperty.h"

#import "PSKeyValueCoder.h"

@implementation TGInstagramDataContentProperty

- (instancetype)initWithImageUrl:(NSString *)imageUrl mediaId:(NSString *)mediaId
{
    self = [super init];
    if (self != nil)
    {
        _imageUrl = imageUrl;
        _mediaId = mediaId;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    return [self initWithImageUrl:[coder decodeStringForCKey:"u"] mediaId:[coder decodeStringForCKey:"m"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeString:_imageUrl forCKey:"u"];
    [coder encodeString:_mediaId forCKey:"m"];
}

@end

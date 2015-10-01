#import "TGLinkPreviewsContentProperty.h"

#import "PSKeyValueCoder.h"

@implementation TGLinkPreviewsContentProperty

- (instancetype)initWithDisableLinkPreviews:(bool)disableLinkPreviews
{
    self = [super init];
    if (self != nil)
    {
        _disableLinkPreviews = disableLinkPreviews;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    return [self initWithDisableLinkPreviews:[coder decodeInt32ForCKey:"disableLinkPreviews"] != 0];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeInt32:_disableLinkPreviews ? 1 : 0 forCKey:"disableLinkPreviews"];
}

@end

#import "TGYoutubeDataContentProperty.h"

#import "PSKeyValueCoder.h"

@implementation TGYoutubeDataContentProperty

- (instancetype)initWithTitle:(NSString *)title duration:(NSUInteger)duration
{
    self = [super init];
    if (self != nil)
    {
        _title = title;
        _duration = duration;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    return [self initWithTitle:[coder decodeStringForCKey:"t"] duration:(NSUInteger)[coder decodeInt32ForCKey:"d"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeString:_title forCKey:"t"];
    [coder encodeInt32:(int32_t)_duration forCKey:"d"];
}

@end

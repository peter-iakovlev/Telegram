#import "TGBotReplyMarkupButton.h"

#import "PSKeyValueCoder.h"

@implementation TGBotReplyMarkupButton

- (instancetype)initWithText:(NSString *)text
{
    self = [super init];
    if (self != nil)
    {
        _text = text;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    return [self initWithText:[coder decodeStringForCKey:"text"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeString:_text forCKey:"text"];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGBotReplyMarkupButton class]] && [((TGBotReplyMarkupButton *)object)->_text isEqualToString:_text];
}

@end

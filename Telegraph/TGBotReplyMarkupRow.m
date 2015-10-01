#import "TGBotReplyMarkupRow.h"

#import "PSKeyValueCoder.h"

@implementation TGBotReplyMarkupRow

- (instancetype)initWithButtons:(NSArray *)buttons
{
    self = [super init];
    if (self != nil)
    {
        _buttons = buttons;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    return [self initWithButtons:[coder decodeArrayForCKey:"buttons"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeArray:_buttons forCKey:"buttons"];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGBotReplyMarkupRow class]] && [((TGBotReplyMarkupRow *)object)->_buttons isEqual:_buttons];
}

@end

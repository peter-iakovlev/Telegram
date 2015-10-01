#import "TGSharedMediaMessageItem.h"

@interface TGSharedMediaMessageItem ()
{
    TGMessage *_message;
}

@end

@implementation TGSharedMediaMessageItem

- (instancetype)initWithMessage:(TGMessage *)__unused message
{
    self = [super init];
    if (self != nil)
    {
        _message = message;
    }
    return self;
}

- (bool)passesFilter:(id<TGSharedMediaFilter>)__unused filter
{
    return false;
}

- (NSTimeInterval)date
{
    return 0.0;
}

- (TGMessage *)message
{
    return nil;
}

- (int32_t)messageId
{
    return 0;
}

- (instancetype)copyWithZone:(NSZone *)__unused zone
{
    return self;
}

@end

#import "TGConversationScrollState.h"

#import "PSKeyValueCoder.h"

@implementation TGConversationScrollState

- (instancetype)initWithMessageId:(int32_t)messageId messageOffset:(int32_t)messageOffset {
    self = [super init];
    if (self != nil) {
        _messageId = messageId;
        _messageOffset = messageOffset;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder {
    return [self initWithMessageId:[coder decodeInt32ForCKey:"messageId"] messageOffset:[coder decodeInt32ForCKey:"messageOffset"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder {
    [coder encodeInt32:_messageId forCKey:"messageId"];
    [coder encodeInt32:_messageOffset forCKey:"messageOffset"];
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[TGConversationScrollState class]] && ((TGConversationScrollState *)object)->_messageId == _messageId && ((TGConversationScrollState *)object)->_messageOffset == _messageOffset;
}

@end

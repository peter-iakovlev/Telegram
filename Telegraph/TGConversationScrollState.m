#import "TGConversationScrollState.h"

#import <LegacyComponents/LegacyComponents.h>

@implementation TGConversationScrollState

- (instancetype)initWithPeerId:(int64_t)peerId messageId:(int32_t)messageId messageOffset:(int32_t)messageOffset {
    self = [super init];
    if (self != nil) {
        _peerId = peerId;
        _messageId = messageId;
        _messageOffset = messageOffset;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder {
    return [self initWithPeerId:[coder decodeInt64ForCKey:"peerId"] messageId:[coder decodeInt32ForCKey:"messageId"] messageOffset:[coder decodeInt32ForCKey:"messageOffset"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder {
    [coder encodeInt64:_peerId forCKey:"peerId"];
    [coder encodeInt32:_messageId forCKey:"messageId"];
    [coder encodeInt32:_messageOffset forCKey:"messageOffset"];
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[TGConversationScrollState class]] && ((TGConversationScrollState *)object)->_peerId == _peerId && ((TGConversationScrollState *)object)->_messageId == _messageId && ((TGConversationScrollState *)object)->_messageOffset == _messageOffset;
}

@end

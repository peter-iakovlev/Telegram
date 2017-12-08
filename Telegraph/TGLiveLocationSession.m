#import "TGLiveLocationSession.h"

@implementation TGLiveLocationSession

- (instancetype)initWithPeerId:(int64_t)peerId messageId:(int32_t)messageId expires:(int32_t)expires
{
    self = [super init];
    if (self != nil)
    {
        _peerId = peerId;
        _messageId = messageId;
        _expires = expires;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    return [self initWithPeerId:[coder decodeInt64ForCKey:"peerId"] messageId:[coder decodeInt32ForCKey:"mid"] expires:[coder decodeInt32ForCKey:"expires"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeInt64:_peerId forCKey:"peerId"];
    [coder encodeInt32:_messageId forCKey:"mid"];
    [coder encodeInt32:_expires forCKey:"expires"];
}

@end

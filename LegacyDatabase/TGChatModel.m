#import "TGChatModel.h"

@implementation TGChatModel

- (instancetype)initWithPeerId:(TGPeerId)peerId
{
    self = [super init];
    if (self != nil)
    {
        _peerId = peerId;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (object == self) {
        return true;
    }
    
    if (!object || ![object isKindOfClass:[self class]]) {
        return false;
    }
    
    TGChatModel *value = (TGChatModel *)object;
    return value.peerId.namespaceId == _peerId.namespaceId && value.peerId.peerId == _peerId.peerId;
}

@end

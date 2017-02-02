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

@end

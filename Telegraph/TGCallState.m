#import "TGCallState.h"

@implementation TGCallStateData

- (instancetype)initWithInternalId:(NSNumber *)internalId callId:(int64_t)callId state:(TGCallState)state peerId:(int64_t)peerId connection:(TGCallConnection *)connection {
    self = [super init];
    if (self != nil) {
        _internalId = internalId;
        _callId = callId;
        _state = state;
        _peerId = peerId;
        _connection = connection;
    }
    return self;
}

@end

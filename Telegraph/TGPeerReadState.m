#import "TGPeerReadState.h"

@implementation TGPeerReadState

- (instancetype)initWithMaxReadMessageId:(int32_t)maxReadMessageId maxOutgoingReadMessageId:(int32_t)maxOutgoingReadMessageId maxKnownMessageId:(int32_t)maxKnownMessageId unreadCount:(int32_t)unreadCount {
    self = [super init];
    if (self != nil) {
        _maxReadMessageId = maxReadMessageId;
        _maxOutgoingReadMessageId = maxOutgoingReadMessageId;
        _maxKnownMessageId = maxKnownMessageId;
        _unreadCount = unreadCount;
    }
    return self;
}

@end

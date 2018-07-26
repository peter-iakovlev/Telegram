#import "TGQueuedReadChannelMessages.h"

@implementation TGReadPeerMessagesRequest

- (instancetype)initWithPeerId:(int64_t)peerId maxMessageIndex:(TGMessageIndex *)maxMessageIndex date:(int32_t)date length:(int32_t)length unread:(bool)unread {
    self = [super init];
    if (self != nil) {
        _peerId = peerId;
        _maxMessageIndex = maxMessageIndex;
        _date = date;
        _length = length;
        _unread = unread;
    }
    return self;
}

@end

@implementation TGQueuedReadChannelMessages

- (instancetype)initWithPeerId:(int64_t)peerId accessHash:(int64_t)accessHash maxId:(int32_t)maxId unread:(bool)unread {
    self = [super init];
    if (self != nil) {
        _peerId = peerId;
        _accessHash = accessHash;
        _maxId = maxId;
        _unread = unread;
    }
    return self;
}

@end

@implementation TGQueuedReadFeedMessages

- (instancetype)initWithFeedPeerId:(int64_t)feedPeerId maxPeerId:(int64_t)maxPeerId maxId:(int32_t)maxId maxDate:(int32_t)maxDate {
    self = [super init];
    if (self != nil) {
        _feedPeerId = feedPeerId;
        _maxPeerId = maxPeerId;
        _maxId = maxId;
        _maxDate = maxDate;
    }
    return self;
}

@end

#import "TGDialogListRemoteOffset.h"

@implementation TGDialogListRemoteOffset

- (instancetype)initWithDate:(int32_t)date peerId:(int64_t)peerId accessHash:(int64_t)accessHash messageId:(int32_t)messageId {
    self = [super init];
    if (self != nil) {
        _date = date;
        _peerId = peerId;
        _accessHash = accessHash;
        _messageId = messageId;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithDate:[aDecoder decodeInt32ForKey:@"date"] peerId:[aDecoder decodeInt64ForKey:@"peerId"] accessHash:[aDecoder decodeInt64ForKey:@"accessHash"] messageId:[aDecoder decodeInt32ForKey:@"messageId"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt32:_date forKey:@"date"];
    [aCoder encodeInt64:_peerId forKey:@"peerId"];
    [aCoder encodeInt64:_accessHash forKey:@"accessHash"];
    [aCoder encodeInt32:_messageId forKey:@"messageId"];
}

- (NSString *)description {
    return [[NSString alloc] initWithFormat:@"(TGDialogListRemoteOffset date: %d, peerId: %lld, accessHash: %lld, messageId: %d)", _date, _peerId, _accessHash, _messageId];
}

- (NSComparisonResult)compare:(TGDialogListRemoteOffset *)other {
    if (_date < other->_date) {
        return NSOrderedAscending;
    } else if (_date > other->_date) {
        return NSOrderedDescending;
    } else if (_peerId < other->_peerId) {
        return NSOrderedAscending;
    } else if (_peerId > other->_peerId) {
        return NSOrderedDescending;
    } else if (_messageId < other->_messageId) {
        return NSOrderedAscending;
    } else if (_messageId > other->_messageId) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

@end

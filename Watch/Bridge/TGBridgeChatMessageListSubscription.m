#import "TGBridgeChatMessageListSubscription.h"

NSString *const TGBridgeChatMessageListSubscriptionName = @"chats.chatMessageList";
NSString *const TGBridgeChatMessageListSubscriptionPeerIdKey = @"peerId";
NSString *const TGBridgeChatMessageListSubscriptionAtMessageIdKey = @"atMessageId";
NSString *const TGBridgeChatMessageListSubscriptionRangeMessageCountKey = @"rangeMessageCount";

@implementation TGBridgeChatMessageListSubscription

- (instancetype)initWithPeerId:(int64_t)peerId atMessageId:(int32_t)messageId rangeMessageCount:(NSUInteger)rangeMessageCount
{
    self = [super init];
    if (self != nil)
    {
        _peerId = peerId;
        _atMessageId = messageId;
        _rangeMessageCount = rangeMessageCount;
    }
    return self;
}

- (bool)dropPreviouslyQueued
{
    return true;
}

- (void)_serializeParametersWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:self.peerId forKey:TGBridgeChatMessageListSubscriptionPeerIdKey];
    [aCoder encodeInt32:self.atMessageId forKey:TGBridgeChatMessageListSubscriptionAtMessageIdKey];
    [aCoder encodeInt32:(int32_t)self.rangeMessageCount forKey:TGBridgeChatMessageListSubscriptionRangeMessageCountKey];
}

- (void)_unserializeParametersWithCoder:(NSCoder *)aDecoder
{
    _peerId = [aDecoder decodeInt64ForKey:TGBridgeChatMessageListSubscriptionPeerIdKey];
    _atMessageId = [aDecoder decodeInt32ForKey:TGBridgeChatMessageListSubscriptionAtMessageIdKey];
    _rangeMessageCount = [aDecoder decodeInt32ForKey:TGBridgeChatMessageListSubscriptionRangeMessageCountKey];
}

+ (NSString *)subscriptionName
{
    return TGBridgeChatMessageListSubscriptionName;
}

@end


NSString *const TGBridgeChatMessageSubscriptionName = @"chats.message";
NSString *const TGBridgeChatMessageSubscriptionPeerIdKey = @"peerId";
NSString *const TGBridgeChatMessageSubscriptionMessageIdKey = @"mid";

@implementation TGBridgeChatMessageSubscription

- (instancetype)initWithPeerId:(int64_t)peerId messageId:(int32_t)messageId
{
    self = [super init];
    if (self != nil)
    {
        _peerId = peerId;
        _messageId = messageId;
    }
    return self;
}

- (bool)synchronous
{
    return true;
}

- (bool)renewable
{
    return false;
}

- (void)_serializeParametersWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:self.peerId forKey:TGBridgeChatMessageSubscriptionPeerIdKey];
    [aCoder encodeInt32:self.messageId forKey:TGBridgeChatMessageSubscriptionMessageIdKey];
}

- (void)_unserializeParametersWithCoder:(NSCoder *)aDecoder
{
    _peerId = [aDecoder decodeInt64ForKey:TGBridgeChatMessageSubscriptionPeerIdKey];
    _messageId = [aDecoder decodeInt32ForKey:TGBridgeChatMessageSubscriptionMessageIdKey];
}

+ (NSString *)subscriptionName
{
    return TGBridgeChatMessageSubscriptionName;
}

@end


NSString *const TGBridgeReadChatMessageListSubscriptionName = @"chats.readChatMessageList";
NSString *const TGBridgeReadChatMessageListSubscriptionPeerIdKey = @"peerId";

@implementation TGBridgeReadChatMessageListSubscription

- (instancetype)initWithPeerId:(int64_t)peerId
{
    self = [super init];
    if (self != nil)
    {
        _peerId = peerId;
    }
    return self;
}

- (void)_serializeParametersWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:self.peerId forKey:TGBridgeReadChatMessageListSubscriptionPeerIdKey];
}

- (void)_unserializeParametersWithCoder:(NSCoder *)aDecoder
{
    _peerId = [aDecoder decodeInt64ForKey:TGBridgeReadChatMessageListSubscriptionPeerIdKey];
}

+ (NSString *)subscriptionName
{
    return TGBridgeReadChatMessageListSubscriptionName;
}

@end

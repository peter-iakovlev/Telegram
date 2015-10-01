#import "TGBridgeConversationSubscription.h"

NSString *const TGBridgeConversationSubscriptionName = @"chats.conversation";
NSString *const TGBridgeConversationSubscriptionPeerIdKey = @"peerId";

@implementation TGBridgeConversationSubscription

- (instancetype)initWithPeerId:(int64_t)peerId
{
    self = [super init];
    if (self != nil)
    {
        _peerId = peerId;
    }
    return self;
}

- (bool)dropPreviouslyQueued
{
    return true;
}

- (void)_serializeParametersWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:self.peerId forKey:TGBridgeConversationSubscriptionPeerIdKey];
}

- (void)_unserializeParametersWithCoder:(NSCoder *)aDecoder
{
    _peerId = [aDecoder decodeInt64ForKey:TGBridgeConversationSubscriptionPeerIdKey];
}

+ (NSString *)subscriptionName
{
    return TGBridgeConversationSubscriptionName;
}

@end

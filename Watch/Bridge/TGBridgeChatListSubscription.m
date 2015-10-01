#import "TGBridgeChatListSubscription.h"

NSString *const TGBridgeChatListSubscriptionName = @"chats.chatList";
NSString *const TGBridgeChatListSubscriptionLimitKey = @"limit";

@implementation TGBridgeChatListSubscription

- (instancetype)initWithLimit:(int32_t)limit
{
    self = [super init];
    if (self != nil)
    {
        _limit = limit;
    }
    return self;
}

- (bool)dropPreviouslyQueued
{
    return true;
}

- (void)_serializeParametersWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt32:self.limit forKey:TGBridgeChatListSubscriptionLimitKey];
}

- (void)_unserializeParametersWithCoder:(NSCoder *)aDecoder
{
    _limit = [aDecoder decodeInt32ForKey:TGBridgeChatListSubscriptionLimitKey];
}

+ (NSString *)subscriptionName
{
    return TGBridgeChatListSubscriptionName;
}

@end

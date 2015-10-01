#import "TGBridgeStickersSubscription.h"

NSString *const TGBridgeStickerPacksSubscriptionName = @"stickers.packs";

@implementation TGBridgeStickerPacksSubscription

+ (NSString *)subscriptionName
{
    return TGBridgeStickerPacksSubscriptionName;
}

@end


NSString *const TGBridgeRecentStickersSubscriptionName = @"stickers.recent";
NSString *const TGBridgeRecentStickersSubscriptionLimitKey = @"limit";

@implementation TGBridgeRecentStickersSubscription

- (instancetype)initWithLimit:(int32_t)limit
{
    self = [super init];
    if (self != nil)
    {
        _limit = limit;
    }
    return self;
}

- (void)_serializeParametersWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt32:self.limit forKey:TGBridgeRecentStickersSubscriptionLimitKey];
}

- (void)_unserializeParametersWithCoder:(NSCoder *)aDecoder
{
    _limit = [aDecoder decodeInt32ForKey:TGBridgeRecentStickersSubscriptionLimitKey];
}

+ (NSString *)subscriptionName
{
    return TGBridgeRecentStickersSubscriptionName;
}

@end

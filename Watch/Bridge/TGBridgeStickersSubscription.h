#import "TGBridgeSubscription.h"

@interface TGBridgeStickerPacksSubscription : TGBridgeSubscription

@end


@interface TGBridgeRecentStickersSubscription : TGBridgeSubscription

@property (nonatomic, readonly) int32_t limit;

- (instancetype)initWithLimit:(int32_t)limit;

@end

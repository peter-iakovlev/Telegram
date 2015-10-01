#import "TGBridgeSubscription.h"

@interface TGBridgeChatListSubscription : TGBridgeSubscription

@property (nonatomic, readonly) int32_t limit;

- (instancetype)initWithLimit:(int32_t)limit;

@end

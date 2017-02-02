#import "TLMessageAction.h"

@class TLPhoneCallDiscardReason;

@interface TLMessageAction$messageActionPhoneCall : TLMessageAction

@property (nonatomic) int32_t flags;
@property (nonatomic) int64_t call_id;
@property (nonatomic, strong) TLPhoneCallDiscardReason *reason;
@property (nonatomic) int32_t duration;

@end

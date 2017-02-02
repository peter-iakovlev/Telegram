#import "TLUpdate.h"

//updateChannelTooLong flags:# channel_id:int pts:flags.0?int = Update

@interface TLUpdate$updateChannelTooLong : TLUpdate

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t channel_id;
@property (nonatomic) int32_t pts;

@end

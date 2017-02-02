#import "TLUpdate$updateChannelTooLong.h"

@implementation TLUpdate$updateChannelTooLong

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLUpdate$updateChannelTooLong serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLUpdate$updateChannelTooLong *result = [[TLUpdate$updateChannelTooLong alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    result.channel_id = [is readInt32];
    
    if (flags & (1 << 0)) {
        result.pts = [is readInt32];
    }
    
    return result;
}

@end

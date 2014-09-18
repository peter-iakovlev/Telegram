#import "TLMsgsAck$msgs_ack_manual.h"

@implementation TLMsgsAck$msgs_ack_manual

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLResPQ_resPQ_manual serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLMsgsAck$msgs_ack_manual *result = [[TLMsgsAck$msgs_ack_manual alloc] init];
    
    [is readInt32]; // Vector
    
    int32_t count = [is readInt32];
    NSMutableArray *vector = [[NSMutableArray alloc] initWithCapacity:(NSUInteger)count];
    
    for (int i = 0; i < count; i++)
    {
        int64_t value = [is readInt64];
        [vector addObject:[[NSNumber alloc] initWithLongLong:value]];
    }
    
    result.msg_ids = vector;
    
    return result;
}

@end

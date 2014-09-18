#import "TLResPQ$resPQ_manual.h"

@implementation TLResPQ$resPQ_manual

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLResPQ_resPQ_manual serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLResPQ$resPQ_manual *result = [[TLResPQ$resPQ_manual alloc] init];
    
    result.nonce = [is readData:16];
    result.server_nonce = [is readData:16];
    result.pq = [is readBytes];
    
    [is readInt32]; // Vector
    
    int32_t count = [is readInt32];
    NSMutableArray *vector = [[NSMutableArray alloc] initWithCapacity:(NSUInteger)count];
    
    for (int i = 0; i < count; i++)
    {
        int64_t value = [is readInt64];
        [vector addObject:[[NSNumber alloc] initWithLongLong:value]];
    }
    
    result.server_public_key_fingerprints = vector;
    
    return result;
}

@end

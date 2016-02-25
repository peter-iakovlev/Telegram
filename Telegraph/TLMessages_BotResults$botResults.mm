#import "TLMessages_BotResults$botResults.h"

#import "TLMetaClassStore.h"

@implementation TLMessages_BotResults$botResults

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLMessages_BotResults$botResults serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLMessages_BotResults$botResults *result = [[TLMessages_BotResults$botResults alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    result.query_id = [is readInt64];
    
    if (flags & (1 << 1)) {
        result.next_offset = [is readString];
    }
    
    {
        [is readInt32];
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        int32_t count = [is readInt32];
        for (int32_t i = 0; i < count; i++) {
            int32_t signature = [is readInt32];
            id item = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
            if (item != nil) {
                [items addObject:item];
            }
        }
        
        result.results = items;
    }
    
    return result;
}

- (bool)isMedia {
    return self.flags & (1 << 0);
}

@end

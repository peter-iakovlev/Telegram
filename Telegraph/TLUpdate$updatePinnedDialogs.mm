#import "TLUpdate$updatePinnedDialogs.h"

#import "TLMetaClassStore.h"

//updatePinnedDialogs flags:# order:flags.0?Vector<Peer> = Update;

@implementation TLUpdate$updatePinnedDialogs

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLUpdate$updatePinnedDialogs serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLUpdate$updatePinnedDialogs *result = [[TLUpdate$updatePinnedDialogs alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    if (flags & (1 << 0) ) {
        [is readInt32];
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        int32_t count = [is readInt32];
        for (int32_t i = 0; i < count; i++) {
            int32_t signature = [is readInt32];
            id item = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
            if (error != nil && *error != nil) {
                return nil;
            }
            if (item != nil) {
                [items addObject:item];
            }
        }
        
        result.order = items;
    }
    
    return result;
}


@end

#import "TLUpdate$updateServiceNotification.h"

#import "TLMetaClassStore.h"

@implementation TLUpdate$updateServiceNotification

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLUpdate$updateServiceNotification serialization not supported");
}

//updateServiceNotification#ebe46819 flags:# popup:flags.0?true inbox_date:flags.1?int type:string message:string media:MessageMedia entities:Vector<MessageEntity> = Update;

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLUpdate$updateServiceNotification *result = [[TLUpdate$updateServiceNotification alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    if (flags & (1 << 1) ) {
        result.inbox_date = [is readInt32];
    }
    
    result.type = [is readString];
    result.message = [is readString];
    
    {
        int32_t signature = [is readInt32];
        result.media = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    {
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
        
        result.entities = items;
    }
    
    return result;
}


@end

#import "TLUpdates_ChannelDifference_manual.h"
#import "TLMetaClassStore.h"

@implementation TLUpdates_ChannelDifference$empty

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLUpdates_ChannelDifference$empty serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLUpdates_ChannelDifference$empty *result = [[TLUpdates_ChannelDifference$empty alloc] init];
    
    int32_t flags = [is readInt32];
    
    result.flags = flags;
    result.pts = [is readInt32];
    
    if (flags & (1 << 1)) {
        result.timeout = [is readInt32];
    }
    
    return result;
}

@end

@implementation TLUpdates_ChannelDifference$tooLong

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLUpdates_ChannelDifference$tooLong serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLUpdates_ChannelDifference$tooLong *result = [[TLUpdates_ChannelDifference$tooLong alloc] init];
    
    int32_t flags = [is readInt32];
    
    result.flags = flags;
    result.pts = [is readInt32];
    
    if (flags & (1 << 1)) {
        result.timeout = [is readInt32];
    }
    
    result.top_message = [is readInt32];
    result.read_inbox_max_id = [is readInt32];
    result.read_outbox_max_id = [is readInt32];
    result.unread_count = [is readInt32];
    
    {
        __unused int32_t vectorSignature = [is readInt32];
        int32_t count = [is readInt32];
        NSMutableArray *items = [[NSMutableArray alloc] init];
        for (int32_t i = 0; i < count; i++)
        {
            int32_t signature = [is readInt32];
            id object = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
            if (error != nil && *error != nil) {
                return nil;
            }
            if (object != nil)
            {
                [items addObject:object];
            }
        }
        result.messages = items;
    }
    
    {
        __unused int32_t vectorSignature = [is readInt32];
        int32_t count = [is readInt32];
        NSMutableArray *items = [[NSMutableArray alloc] init];
        for (int32_t i = 0; i < count; i++)
        {
            int32_t signature = [is readInt32];
            id object = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
            if (error != nil && *error != nil) {
                return nil;
            }
            if (object != nil)
            {
                [items addObject:object];
            }
        }
        result.chats = items;
    }
    
    {
        __unused int32_t vectorSignature = [is readInt32];
        int32_t count = [is readInt32];
        NSMutableArray *items = [[NSMutableArray alloc] init];
        for (int32_t i = 0; i < count; i++)
        {
            int32_t signature = [is readInt32];
            id object = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
            if (error != nil && *error != nil) {
                return nil;
            }
            if (object != nil)
            {
                [items addObject:object];
            }
        }
        result.users = items;
    }
    
    return result;
}

@end

@implementation TLUpdates_ChannelDifference$channelDifference

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLUpdates_ChannelDifference$channelDifference serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)error
{
    TLUpdates_ChannelDifference$channelDifference *result = [[TLUpdates_ChannelDifference$channelDifference alloc] init];
    
    int32_t flags = [is readInt32];
    
    result.flags = flags;
    result.pts = [is readInt32];
    
    if (flags & (1 << 1)) {
        result.timeout = [is readInt32];
    }
    
    {
        __unused int32_t vectorSignature = [is readInt32];
        int32_t count = [is readInt32];
        NSMutableArray *items = [[NSMutableArray alloc] init];
        for (int32_t i = 0; i < count; i++)
        {
            int32_t signature = [is readInt32];
            id object = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
            if (error != nil && *error != nil) {
                return nil;
            }
            if (object != nil)
            {
                [items addObject:object];
            }
        }
        result.n_new_messages = items;
    }
    
    {
        __unused int32_t vectorSignature = [is readInt32];
        int32_t count = [is readInt32];
        NSMutableArray *items = [[NSMutableArray alloc] init];
        for (int32_t i = 0; i < count; i++)
        {
            int32_t signature = [is readInt32];
            id object = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
            if (error != nil && *error != nil) {
                return nil;
            }
            if (object != nil)
            {
                [items addObject:object];
            }
        }
        result.other_updates = items;
    }
    
    {
        __unused int32_t vectorSignature = [is readInt32];
        int32_t count = [is readInt32];
        NSMutableArray *items = [[NSMutableArray alloc] init];
        for (int32_t i = 0; i < count; i++)
        {
            int32_t signature = [is readInt32];
            id object = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
            if (error != nil && *error != nil) {
                return nil;
            }
            if (object != nil)
            {
                [items addObject:object];
            }
        }
        result.chats = items;
    }
    
    {
        __unused int32_t vectorSignature = [is readInt32];
        int32_t count = [is readInt32];
        NSMutableArray *items = [[NSMutableArray alloc] init];
        for (int32_t i = 0; i < count; i++)
        {
            int32_t signature = [is readInt32];
            id object = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
            if (error != nil && *error != nil) {
                return nil;
            }
            if (object != nil)
            {
                [items addObject:object];
            }
        }
        result.users = items;
    }
    
    return result;
}

@end

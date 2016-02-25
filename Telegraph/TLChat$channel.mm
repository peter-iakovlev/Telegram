#import "TLChat$channel.h"
#import "TLMetaClassStore.h"

//channel flags:# creator:flags.0?true kicked:flags.1?true left:flags.2?true editor:flags.3?true moderator:flags.4?true broadcast:flags.5?true verified:flags.7?true megagroup:flags.8?true restricted:flags.9?true id:int access_hash:long title:string username:flags.6?string photo:ChatPhoto date:int version:int restriction_reason:flags.9?string = Chat;

@implementation TLChat$channel

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLChat$channel serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)error
{
    TLChat$channel *result = [[TLChat$channel alloc] init];
    
    int32_t flags = [is readInt32];
    
    result.flags = flags;
    
    result.n_id = [is readInt32];
    result.access_hash = [is readInt64];
    
    result.title = [is readString];
    
    if (flags & (1 << 6)) {
        result.username = [is readString];
    }
    
    {
        int32_t signature = [is readInt32];
        result.photo = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    result.date = [is readInt32];
    result.version = [is readInt32];
    
    if (flags & (1 << 9)) {
        result.restriction_reason = [is readString];
    }
    
    return result;
}

@end

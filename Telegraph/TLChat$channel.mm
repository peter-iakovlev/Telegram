#import "TLChat$channel.h"
#import "TLMetaClassStore.h"

//channel flags:# id:int access_hash:long title:string username:flags.6?string photo:ChatPhoto date:int version:int = Chat;

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
    
    return result;
}

@end

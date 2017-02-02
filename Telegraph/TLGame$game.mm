#import "TLGame$game.h"

#import "TLMetaClassStore.h"

//game flags:# id:long access_hash:long short_name:string title:string description:string url:string photo:Photo document:flags.0?Document = Game;

@implementation TLGame$game

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLGame$game serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLGame$game *result = [[TLGame$game alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    result.n_id = [is readInt64];
    result.access_hash = [is readInt64];
    result.short_name = [is readString];
    result.title = [is readString];
    result.n_description = [is readString];
    
    {
        int32_t signature = [is readInt32];
        result.photo = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    if (flags & (1 << 0)) {
        int32_t signature = [is readInt32];
        result.document = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    return result;
}

@end

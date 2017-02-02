#import "TLChat$chat.h"
#import "TLMetaClassStore.h"

//chat#D91CDD54 flags:# creator:flags.0?true kicked:flags.1?true left:flags.2?true admins_enabled:flags.3?true admin:flags.4?true deactivated:flags.5?true id:int title:string photo:ChatPhoto participants_count:int date:int version:int migrated_to:flags.6?InputChannel = Chat;

@implementation TLChat$chat

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLChat$chat serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)error
{
    TLChat$chat *result = [[TLChat$chat alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    result.creator = (flags & (1 << 0));
    result.kicked = (flags & (1 << 1));
    result.left = (flags & (1 << 2));
    result.admins_enabled = (flags & (1 << 3));
    result.admin = (flags & (1 << 4));
    result.deactivated = (flags & (1 << 5));
    
    result.n_id = [is readInt32];

    result.title = [is readString];
    
    {
        int32_t signature = [is readInt32];
        result.photo = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    result.participants_count = [is readInt32];
    result.date = [is readInt32];
    result.version = [is readInt32];
    
    if (flags & (1 << 6)) {
        int32_t signature = [is readInt32];
        result.migrated_to = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    return result;
}

@end

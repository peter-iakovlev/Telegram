#import "TLUser$modernUser.h"

#import "TLMetaClassStore.h"

@implementation TLUser$modernUser

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLUser$modernUser serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)error
{
    TLUser$modernUser *object = [[TLUser$modernUser alloc] init];
    
    object.flags = [is readInt32];
    
    object.n_id = [is readInt32];
    
    if (object.flags & (1 << 0))
        object.access_hash = [is readInt64];
    
    if (object.flags & (1 << 1))
        object.first_name = [is readString];
    if (object.flags & (1 << 2))
        object.last_name = [is readString];
    
    if (object.flags & (1 << 3))
        object.username = [is readString];
    
    if (object.flags & (1 << 4))
        object.phone = [is readString];
    
    if (object.flags & (1 << 5))
    {
        int32_t signature = [is readInt32];
        object.photo = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    if (object.flags & (1 << 6))
    {
        int32_t signature = [is readInt32];
        object.status = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    if (object.flags & (1 << 14))
        object.bot_info_version = [is readInt32];
    
    if (object.flags & (1 << 18)) {
        object.restriction_reason = [is readString];
    }
    
    if (object.flags & (1 << 19)) {
        object.inlineBotPlaceholder = [is readString];
    }
    
    if (object.flags & (1 << 22)) {
        __unused NSString *langCode = [is readString];
    }
    
    return object;
}

@end

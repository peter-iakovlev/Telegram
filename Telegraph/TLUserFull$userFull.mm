#import "TLUserFull$userFull.h"

#import "TLMetaClassStore.h"

//userFull flags:# blocked:flags.0?true user:User about:flags.1?string link:contacts.Link profile_photo:flags.2?Photo notify_settings:PeerNotifySettings bot_info:flags.3?BotInfo common_chats_count:int = UserFull;

@implementation TLUserFull$userFull

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLUserFull$userFull serialization not supported");
}

- (bool)blocked {
    return self.flags & (1 << 0);
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLUserFull$userFull *result = [[TLUserFull$userFull alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    {
        int32_t signature = [is readInt32];
        result.user = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    if (flags & (1 << 1)) {
        result.about = [is readString];
    }
    
    {
        int32_t signature = [is readInt32];
        result.link = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    if (flags & (1 << 2)) {
        int32_t signature = [is readInt32];
        result.profile_photo = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    {
        int32_t signature = [is readInt32];
        result.notify_settings = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    if (flags & (1 << 3)) {
        int32_t signature = [is readInt32];
        result.bot_info = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    result.common_chats_count = [is readInt32];
    
    return result;
}


@end

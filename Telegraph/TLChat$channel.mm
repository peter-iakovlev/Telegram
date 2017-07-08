#import "TLChat$channel.h"
#import "TLMetaClassStore.h"

@implementation TLChat$channel

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLChat$channel serialization not supported");
}

- (bool)creator {
    return self.flags & (1 << 0);
}

- (bool)kicked {
    return self.flags & (1 << 1);
}

- (bool)left {
    return self.flags & (1 << 2);
}

- (bool)editor {
    return self.flags & (1 << 3);
}

- (bool)broadcast {
    return self.flags & (1 << 5);
}

- (bool)verified {
    return self.flags & (1 << 7);
}

- (bool)megagroup {
    return self.flags & (1 << 8);
}

- (bool)restricted {
    return self.flags & (1 << 9);
}

- (bool)democracy {
    return self.flags & (1 << 10);
}

- (bool)signatures {
    return self.flags & (1 << 11);
}

- (bool)min {
    return self.flags & (1 << 12);
}

//channel flags:# creator:flags.0?true kicked:flags.1?true left:flags.2?true editor:flags.3?true broadcast:flags.5?true verified:flags.7?true megagroup:flags.8?true restricted:flags.9?true democracy:flags.10?true signatures:flags.11?true min:flags.12?true id:int access_hash:flags.13?long title:string username:flags.6?string photo:ChatPhoto date:int version:int restriction_reason:flags.9?string admin_rights:flags.14?ChannelAdminRights = Chat;

//channel flags:# creator:flags.0?true kicked:flags.1?true left:flags.2?true editor:flags.3?true broadcast:flags.5?true verified:flags.7?true megagroup:flags.8?true restricted:flags.9?true democracy:flags.10?true signatures:flags.11?true min:flags.12?true id:int access_hash:flags.13?long title:string username:flags.6?string photo:ChatPhoto date:int version:int restriction_reason:flags.9?string admin_rights:flags.14?ChannelAdminRights banned_rights:flags.15?ChannelBannedRights = Chat;

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)error
{
    TLChat$channel *result = [[TLChat$channel alloc] init];
    
    int32_t flags = [is readInt32];
    
    result.flags = flags;
    
    result.n_id = [is readInt32];
    
    if (flags & (1 << 13)) {
        result.access_hash = [is readInt64];
    }
    
    result.title = [is readString];
    
    if (flags & (1 << 6)) {
        result.username = [is readString];
    }
    
    {
        int32_t signature = [is readInt32];
        result.photo = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    result.date = [is readInt32];
    result.version = [is readInt32];
    
    if (flags & (1 << 9)) {
        result.restriction_reason = [is readString];
    }
    
    if (flags & (1 << 14)) {
        int32_t signature = [is readInt32];
        result.admin_rights = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    if (flags & (1 << 15)) {
        int32_t signature = [is readInt32];
        result.banned_rights = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    if (flags & (1 << 16)) {
        result.banned_until = [is readInt32];
    }
    
    return result;
}

@end

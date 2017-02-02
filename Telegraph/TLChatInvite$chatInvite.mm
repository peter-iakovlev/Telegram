#import "TLChatInvite$chatInvite.h"

#import "TLMetaClassStore.h"

//chatInvite flags:# channel:flags.0?true broadcast:flags.1?true public:flags.2?true megagroup:flags.3?true title:string photo:ChatPhoto participants:flags.4?Vector<User> = ChatInvite;

@implementation TLChatInvite$chatInvite

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLChatInvite$chatInvite serialization not supported");
}

- (bool)isChannel {
    return self.flags & (1 << 0);
}

- (bool)isBroadcast {
    return self.flags & (1 << 1);
}

- (bool)isPublic {
    return self.flags & (1 << 2);
}

- (bool)isSupergroup {
    return self.flags & (1 << 3);
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLChatInvite$chatInvite *result = [[TLChatInvite$chatInvite alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    result.title = [is readString];
    
    {
        int32_t signature = [is readInt32];
        result.photo = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    result.participants_count = [is readInt32];
    
    if (flags & (1 << 4)) {
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
        
        result.participants = items;
    }
    
    return result;
}

@end

#import "TLmessages_Messages$modernChannelMessages.h"

#import "TLMetaClassStore.h"

//messages.channelMessages flags:# pts:int count:int messages:Vector<Message> collapsed:flags.0?Vector<MessageGroup> chats:Vector<Chat> users:Vector<User> = messages.Messages

@implementation TLmessages_Messages$modernChannelMessages

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLMessage$modernChannelMessages serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)error
{
    TLmessages_Messages$modernChannelMessages *result = [[TLmessages_Messages$modernChannelMessages alloc] init];
    
    int32_t flags = [is readInt32];
    
    result.flags = flags;
    result.pts = [is readInt32];
    result.count = [is readInt32];
    
    {
        __unused int32_t signature = [is readInt32];
        int32_t count = [is readInt32];
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        for (int32_t i = 0; i < count; i++)
        {
            int32_t signature = [is readInt32];
            id object = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
            if (error != nil && *error != nil) {
                return nil;
            }
            if (object != nil)
            {
                [messages addObject:object];
            }
        }
        result.messages = messages;
    }
    
    if (flags & (1 << 0))
    {
        __unused int32_t signature = [is readInt32];
        int32_t count = [is readInt32];
        NSMutableArray *collapsed = [[NSMutableArray alloc] init];
        for (int32_t i = 0; i < count; i++)
        {
            int32_t signature = [is readInt32];
            id object = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
            if (error != nil && *error != nil) {
                return nil;
            }
            if (object != nil)
            {
                [collapsed addObject:object];
            }
        }
        result.collapsed = collapsed;
    }
    
    {
        __unused int32_t signature = [is readInt32];
        int32_t count = [is readInt32];
        NSMutableArray *chats = [[NSMutableArray alloc] init];
        for (int32_t i = 0; i < count; i++)
        {
            int32_t signature = [is readInt32];
            id object = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
            if (error != nil && *error != nil) {
                return nil;
            }
            if (object != nil)
            {
                [chats addObject:object];
            }
        }
        result.chats = chats;
    }
    
    {
        __unused int32_t signature = [is readInt32];
        int32_t count = [is readInt32];
        NSMutableArray *users = [[NSMutableArray alloc] init];
        for (int32_t i = 0; i < count; i++)
        {
            int32_t signature = [is readInt32];
            id object = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
            if (error != nil && *error != nil) {
                return nil;
            }
            if (object != nil)
            {
                [users addObject:object];
            }
        }
        result.users = users;
    }
    
    return result;
}

@end

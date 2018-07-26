#import "TLmessages_FeedMessages$messages_feedMessages.h"

#import "TLMetaClassStore.h"

//messages.feedMessages#b295e17 flags:# max_position:flags.0?FeedPosition min_position:flags.1?FeedPosition messages:Vector<Message> chats:Vector<Chat> users:Vector<User> = messages.FeedMessages;

@implementation TLmessages_FeedMessages$messages_feedMessages

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLmessages_FeedMessages$messages_feedMessages *result = [[TLmessages_FeedMessages$messages_feedMessages alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    if (flags & (1 << 0)) {
        int32_t signature = [is readInt32];
        result.max_position = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    if (flags & (1 << 1)) {
        int32_t signature = [is readInt32];
        result.min_position = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    if (flags & (1 << 2)) {
        int32_t signature = [is readInt32];
        result.read_max_position = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    {
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
        
        result.messages = items;
    }
    
    {
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
        
        result.chats = items;
    }
    
    {
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
        
        result.users = items;
    }
    
    return result;
}

@end

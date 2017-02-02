#import "TLChatParticipants$chatParticipantsForbidden.h"
#import "TLMetaClassStore.h"

//chatParticipantsForbidden flags:# chat_id:int self_participant:flags.0?ChatParticipant = ChatParticipants

@implementation TLChatParticipants$chatParticipantsForbidden

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLChatParticipants$chatParticipantsForbidden serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)error
{
    TLChatParticipants$chatParticipantsForbidden *result = [[TLChatParticipants$chatParticipantsForbidden alloc] init];
    
    int32_t flags = [is readInt32];
    
    result.flags = flags;
    result.chat_id = [is readInt32];
    
    if (flags & (1 << 0)) {
        int32_t signature = [is readInt32];
        result.self_participant = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    return result;
}

@end

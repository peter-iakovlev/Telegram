#import "TLDraftMessage$draftMessage.h"

#import "TLMetaClassStore.h"

//draftMessage flags:# no_webpage:flags.1?true reply_to_msg_id:flags.0?int message:string entities:flags.3?Vector<MessageEntity> date:int = DraftMessage;

@implementation TLDraftMessage$draftMessage

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLDraftMessage$draftMessage serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLDraftMessage$draftMessage *result = [[TLDraftMessage$draftMessage alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    if (flags & (1 << 0)) {
        result.reply_to_msg_id = [is readInt32];
    }
    
    result.message = [is readString];
    
    if (flags & (1 << 3)) {
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
        
        result.entities = items;
    }
    
    result.date = [is readInt32];
    
    return result;
}

@end

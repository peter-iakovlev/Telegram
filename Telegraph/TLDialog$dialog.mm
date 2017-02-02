#import "TLDialog$dialog.h"

#import "TLMetaClassStore.h"

//dialog flags:# peer:Peer top_message:int read_inbox_max_id:int read_outbox_max_id:int unread_count:int notify_settings:PeerNotifySettings pts:flags.0?int draft:flags.1?DraftMessage = Dialog;

@implementation TLDialog$dialog

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLBotInlineMessage$botInlineMessageMediaContact serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLDialog$dialog *result = [[TLDialog$dialog alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    {
        int32_t signature = [is readInt32];
        result.peer = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    result.top_message = [is readInt32];
    
    result.read_inbox_max_id = [is readInt32];
    result.read_outbox_max_id = [is readInt32];
    result.unread_count = [is readInt32];
    
    {
        int32_t signature = [is readInt32];
        result.notify_settings = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    if (flags & (1 << 0)) {
        result.pts = [is readInt32];
    }
    
    if (flags & (1 << 1)) {
        int32_t signature = [is readInt32];
        result.draft = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    return result;
}

@end

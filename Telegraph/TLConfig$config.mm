#import "TLConfig$config.h"

#import "TLMetaClassStore.h"

@implementation TLConfig$config

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLConfig$config serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLConfig$config *result = [[TLConfig$config alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    result.date = [is readInt32];
    result.expires = [is readInt32];
    result.test_mode = [is readInt32] == TL_BOOL_TRUE_CONSTRUCTOR;
    result.this_dc = [is readInt32];
    
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
        
        result.dc_options = items;
    }
    
    result.chat_size_max = [is readInt32];
    result.megagroup_size_max = [is readInt32];
    result.forwarded_count_max = [is readInt32];
    result.online_update_period_ms = [is readInt32];
    result.offline_blur_timeout_ms = [is readInt32];
    result.offline_idle_timeout_ms = [is readInt32];
    result.online_cloud_timeout_ms = [is readInt32];
    result.notify_cloud_delay_ms = [is readInt32];
    result.notify_default_delay_ms = [is readInt32];
    result.chat_big_size = [is readInt32];
    result.push_chat_period_ms = [is readInt32];
    result.push_chat_limit = [is readInt32];
    result.saved_gifs_limit = [is readInt32];
    result.edit_time_limit = [is readInt32];
    result.rating_e_decay = [is readInt32];
    result.stickers_recent_limit = [is readInt32];
    if (flags & (1 << 0)) {
        result.tmp_sessions = [is readInt32];
    }
    result.pinned_dialogs_count_max = [is readInt32];
    result.call_receive_timeout_ms = [is readInt32];
    result.call_ring_timeout_ms = [is readInt32];
    result.call_connect_timeout_ms = [is readInt32];
    result.call_packet_timeout_ms = [is readInt32];
    result.me_url_prefix = [is readString];
    if (flags & (1 << 2)) {
        result.suggested_lang_code = [is readString];
        result.lang_pack_version = [is readInt32];
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
        
        result.disabled_features = items;
    }
    
    return result;
}

@end

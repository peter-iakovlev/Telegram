#import "TLConfig$config.h"

#import "TLMetaClassStore.h"

//config#3213dbba flags:# phonecalls_enabled:flags.1?true default_p2p_contacts:flags.3?true preload_featured_stickers:flags.4?true ignore_phone_entities:flags.5?true revoke_pm_inbox:flags.6?true blocked_mode:flags.8?true date:int expires:int test_mode:Bool this_dc:int dc_options:Vector<DcOption> dc_txt_domain_name:string chat_size_max:int megagroup_size_max:int forwarded_count_max:int online_update_period_ms:int offline_blur_timeout_ms:int offline_idle_timeout_ms:int online_cloud_timeout_ms:int notify_cloud_delay_ms:int notify_default_delay_ms:int push_chat_period_ms:int push_chat_limit:int saved_gifs_limit:int edit_time_limit:int revoke_time_limit:int revoke_pm_time_limit:int rating_e_decay:int stickers_recent_limit:int stickers_faved_limit:int channels_read_media_period:int tmp_sessions:flags.0?int pinned_dialogs_count_max:int call_receive_timeout_ms:int call_ring_timeout_ms:int call_connect_timeout_ms:int call_packet_timeout_ms:int me_url_prefix:string autoupdate_url_prefix:flags.7?string gif_search_username:flags.9?string venue_search_username:flags.10?string img_search_username:flags.11?string static_maps_provider:flags.12?string caption_length_max:int message_length_max:int webfile_dc_id:int suggested_lang_code:flags.2?string lang_pack_version:flags.2?int = Config;


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
    result.dc_txt_domain_name = [is readString];
    result.chat_size_max = [is readInt32];
    result.megagroup_size_max = [is readInt32];
    result.forwarded_count_max = [is readInt32];
    result.online_update_period_ms = [is readInt32];
    result.offline_blur_timeout_ms = [is readInt32];
    result.offline_idle_timeout_ms = [is readInt32];
    result.online_cloud_timeout_ms = [is readInt32];
    result.notify_cloud_delay_ms = [is readInt32];
    result.notify_default_delay_ms = [is readInt32];
    result.push_chat_period_ms = [is readInt32];
    result.push_chat_limit = [is readInt32];
    result.saved_gifs_limit = [is readInt32];
    result.edit_time_limit = [is readInt32];
    result.revoke_time_limit = [is readInt32];
    result.revoke_pm_time_limit = [is readInt32];
    result.rating_e_decay = [is readInt32];
    result.stickers_recent_limit = [is readInt32];
    result.stickers_faved_limit = [is readInt32];
    result.channels_read_media_period = [is readInt32];
    if (flags & (1 << 0)) {
        result.tmp_sessions = [is readInt32];
    }
    result.pinned_dialogs_count_max = [is readInt32];
    result.call_receive_timeout_ms = [is readInt32];
    result.call_ring_timeout_ms = [is readInt32];
    result.call_connect_timeout_ms = [is readInt32];
    result.call_packet_timeout_ms = [is readInt32];
    result.me_url_prefix = [is readString];
    if (flags & (1 << 7)) {
        result.autoupdate_url_prefix = [is readString];
    }
    
    if (flags & (1 << 9)) {
        result.gif_search_username = [is readString];
    }
    if (flags & (1 << 10)) {
        result.venue_search_username = [is readString];
    }
    if (flags & (1 << 11)) {
        result.img_search_username = [is readString];
    }
    if (flags & (1 << 12)) {
        result.static_maps_provider = [is readString];
    }
    
    result.caption_length_max = [is readInt32];
    result.message_length_max = [is readInt32];
    result.webfile_dc_id = [is readInt32];
    
    if (flags & (1 << 2)) {
        result.suggested_lang_code = [is readString];
        result.lang_pack_version = [is readInt32];
    }
    
    return result;
}

@end

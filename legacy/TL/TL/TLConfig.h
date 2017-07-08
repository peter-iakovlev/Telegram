#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLConfig : NSObject <TLObject>

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t expires;
@property (nonatomic) bool test_mode;
@property (nonatomic) int32_t this_dc;
@property (nonatomic, retain) NSArray *dc_options;
@property (nonatomic) int32_t chat_size_max;
@property (nonatomic) int32_t megagroup_size_max;
@property (nonatomic) int32_t forwarded_count_max;
@property (nonatomic) int32_t online_update_period_ms;
@property (nonatomic) int32_t offline_blur_timeout_ms;
@property (nonatomic) int32_t offline_idle_timeout_ms;
@property (nonatomic) int32_t online_cloud_timeout_ms;
@property (nonatomic) int32_t notify_cloud_delay_ms;
@property (nonatomic) int32_t notify_default_delay_ms;
@property (nonatomic) int32_t chat_big_size;
@property (nonatomic) int32_t push_chat_period_ms;
@property (nonatomic) int32_t push_chat_limit;
@property (nonatomic) int32_t saved_gifs_limit;
@property (nonatomic) int32_t edit_time_limit;
@property (nonatomic) int32_t rating_e_decay;
@property (nonatomic) int32_t stickers_recent_limit;
@property (nonatomic) int32_t tmp_sessions;
@property (nonatomic) int32_t pinned_dialogs_count_max;
@property (nonatomic) int32_t call_receive_timeout_ms;
@property (nonatomic) int32_t call_ring_timeout_ms;
@property (nonatomic) int32_t call_connect_timeout_ms;
@property (nonatomic) int32_t call_packet_timeout_ms;
@property (nonatomic, retain) NSString *me_url_prefix;
@property (nonatomic, retain) NSString *suggested_lang_code;
@property (nonatomic) int32_t lang_pack_version;
@property (nonatomic, retain) NSArray *disabled_features;

@end

@interface TLConfig$configMeta : TLConfig


@end


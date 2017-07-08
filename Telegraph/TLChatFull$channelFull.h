#import "TLChatFull.h"

@class TLPhoto;
@class TLPeerNotifySettings;
@class TLExportedChatInvite;

//channelFull flags:# can_view_participants:flags.3?true can_set_username:flags.6?true id:int about:string participants_count:flags.0?int admins_count:flags.1?int kicked_count:flags.2?int banned_count:flags.2?int read_inbox_max_id:int read_outbox_max_id:int unread_count:int chat_photo:Photo notify_settings:PeerNotifySettings exported_invite:ExportedChatInvite bot_info:Vector<BotInfo> migrated_from_chat_id:flags.4?int migrated_from_max_id:flags.4?int pinned_msg_id:flags.5?int = ChatFull;


@interface TLChatFull$channelFull : TLChatFull

@property (nonatomic) int32_t flags;

@property (nonatomic) bool canViewParticipants;
@property (nonatomic) bool can_set_username;

@property (nonatomic) NSString *about;
@property (nonatomic) int32_t participants_count;
@property (nonatomic) int32_t admins_count;
@property (nonatomic) int32_t kicked_count;
@property (nonatomic) int32_t banned_count;
@property (nonatomic) int32_t read_inbox_max_id;
@property (nonatomic) int32_t read_outbox_max_id;
@property (nonatomic) int32_t unread_count;
@property (nonatomic) int32_t migrated_from_chat_id;
@property (nonatomic) int32_t migrated_from_max_id;
@property (nonatomic) int32_t pinned_msg_id;

@end

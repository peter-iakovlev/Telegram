#import "TLUpdates.h"

@class TLPeer;
@class TLMessageFwdHeader;

@interface TLUpdates$modernUpdateShortChatMessage : TLUpdates

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t n_id;
@property (nonatomic) int32_t from_id;
@property (nonatomic) int32_t chat_id;
@property (nonatomic) NSString *message;
@property (nonatomic) int32_t pts;
@property (nonatomic) int32_t pts_count;
@property (nonatomic) int32_t date;
@property (nonatomic) TLMessageFwdHeader *fwd_header;
@property (nonatomic) int32_t via_bot_id;
@property (nonatomic) int32_t reply_to_msg_id;
@property (nonatomic, strong) NSArray *entities;

@end

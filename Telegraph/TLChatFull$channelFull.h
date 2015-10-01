#import "TLChatFull.h"

@class TLPhoto;
@class TLPeerNotifySettings;
@class TLExportedChatInvite;

@interface TLChatFull$channelFull : TLChatFull

@property (nonatomic) int32_t flags;
@property (nonatomic) NSString *about;
@property (nonatomic) int32_t participants_count;
@property (nonatomic) int32_t admins_count;
@property (nonatomic) int32_t kicked_count;
@property (nonatomic) int32_t read_inbox_max_id;
@property (nonatomic) int32_t unread_count;
@property (nonatomic) int32_t unread_important_count;

@end

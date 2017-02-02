#import "TLUserFull.h"

@class TLUser;
@class TLcontacts_Link;
@class TLPhoto;
@class TLPeerNotifySettings;
@class TLBotInfo;

@interface TLUserFull$userFull : TLUserFull

@property (nonatomic) int32_t flags;
@property (nonatomic, readonly) bool blocked;
@property (nonatomic, strong) TLUser *user;
@property (nonatomic, strong) NSString *about;
@property (nonatomic, strong) TLcontacts_Link *link;
@property (nonatomic, strong) TLPhoto *profile_photo;
@property (nonatomic, strong) TLPeerNotifySettings *notify_settings;
@property (nonatomic, strong) TLBotInfo *bot_info;
@property (nonatomic) int32_t common_chats_count;

@end

#import "TLChat.h"

//channel flags:# creator:flags.0?true kicked:flags.1?true left:flags.2?true editor:flags.3?true broadcast:flags.5?true verified:flags.7?true megagroup:flags.8?true restricted:flags.9?true democracy:flags.10?true signatures:flags.11?true min:flags.12?true id:int access_hash:flags.13?long title:string username:flags.6?string photo:ChatPhoto date:int version:int restriction_reason:flags.9?string admin_rights:flags.14?ChannelAdminRights = Chat;

@class TLChatPhoto;
@class TLChannelAdminRights;
@class TLChannelBannedRights;

@interface TLChat$channel : TLChat

@property (nonatomic) int32_t flags;

@property (nonatomic, readonly) bool creator;
@property (nonatomic, readonly) bool kicked;
@property (nonatomic, readonly) bool left;
@property (nonatomic, readonly) bool editor;
@property (nonatomic, readonly) bool broadcast;
@property (nonatomic, readonly) bool verified;
@property (nonatomic, readonly) bool megagroup;
@property (nonatomic, readonly) bool restricted;
@property (nonatomic, readonly) bool democracy;
@property (nonatomic, readonly) bool signatures;
@property (nonatomic, readonly) bool min;

@property (nonatomic) int64_t access_hash;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) TLChatPhoto *photo;
@property (nonatomic) int32_t date;
@property (nonatomic) int32_t version;
@property (nonatomic, strong) NSString *restriction_reason;
@property (nonatomic, strong) TLChannelAdminRights *admin_rights;
@property (nonatomic, strong) TLChannelBannedRights *banned_rights;
@property (nonatomic) int32_t banned_until;

@end

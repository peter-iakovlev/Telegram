#import "TLChat.h"


@class TLChatPhoto;
@class TLChannelAdminRights;
@class TLChannelBannedRights;

@interface TLChat$channel : TLChat

@property (nonatomic) int32_t flags;

@property (nonatomic, readonly) bool creator;
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
@property (nonatomic) int32_t participants_count;

@end

#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLChannelAdminRights;
@class TLChannelBannedRights;

@interface TLChannelParticipant : NSObject <TLObject>

@property (nonatomic) int32_t user_id;

@end

@interface TLChannelParticipant$channelParticipant : TLChannelParticipant

@property (nonatomic) int32_t date;

@end

@interface TLChannelParticipant$channelParticipantSelf : TLChannelParticipant

@property (nonatomic) int32_t inviter_id;
@property (nonatomic) int32_t date;

@end

@interface TLChannelParticipant$channelParticipantCreator : TLChannelParticipant


@end

@interface TLChannelParticipant$channelParticipantAdmin : TLChannelParticipant

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t inviter_id;
@property (nonatomic) int32_t promoted_by;
@property (nonatomic) int32_t date;
@property (nonatomic, retain) TLChannelAdminRights *admin_rights;

@end

@interface TLChannelParticipant$channelParticipantBanned : TLChannelParticipant

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t kicked_by;
@property (nonatomic) int32_t date;
@property (nonatomic, retain) TLChannelBannedRights *banned_rights;

@end


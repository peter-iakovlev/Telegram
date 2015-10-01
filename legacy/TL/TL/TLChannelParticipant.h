#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


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

@interface TLChannelParticipant$channelParticipantModerator : TLChannelParticipant

@property (nonatomic) int32_t inviter_id;
@property (nonatomic) int32_t date;

@end

@interface TLChannelParticipant$channelParticipantEditor : TLChannelParticipant

@property (nonatomic) int32_t inviter_id;
@property (nonatomic) int32_t date;

@end

@interface TLChannelParticipant$channelParticipantKicked : TLChannelParticipant

@property (nonatomic) int32_t kicked_by;
@property (nonatomic) int32_t date;

@end

@interface TLChannelParticipant$channelParticipantCreator : TLChannelParticipant


@end


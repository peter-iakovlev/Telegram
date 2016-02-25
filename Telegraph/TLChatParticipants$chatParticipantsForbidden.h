#import "TLChatParticipants.h"

@class TLChatParticipant;

@interface TLChatParticipants$chatParticipantsForbidden : TLChatParticipants

@property (nonatomic) int32_t flags;
@property (nonatomic, strong) TLChatParticipant *self_participant;

@end

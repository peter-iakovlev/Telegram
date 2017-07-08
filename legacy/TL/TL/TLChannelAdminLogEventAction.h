#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLChatPhoto;
@class TLMessage;
@class TLChannelParticipant;

@interface TLChannelAdminLogEventAction : NSObject <TLObject>


@end

@interface TLChannelAdminLogEventAction$channelAdminLogEventActionChangeTitle : TLChannelAdminLogEventAction

@property (nonatomic, retain) NSString *prev_value;
@property (nonatomic, retain) NSString *n_new_value;

@end

@interface TLChannelAdminLogEventAction$channelAdminLogEventActionChangeAbout : TLChannelAdminLogEventAction

@property (nonatomic, retain) NSString *prev_value;
@property (nonatomic, retain) NSString *n_new_value;

@end

@interface TLChannelAdminLogEventAction$channelAdminLogEventActionChangeUsername : TLChannelAdminLogEventAction

@property (nonatomic, retain) NSString *prev_value;
@property (nonatomic, retain) NSString *n_new_value;

@end

@interface TLChannelAdminLogEventAction$channelAdminLogEventActionChangePhoto : TLChannelAdminLogEventAction

@property (nonatomic, retain) TLChatPhoto *prev_photo;
@property (nonatomic, retain) TLChatPhoto *n_new_photo;

@end

@interface TLChannelAdminLogEventAction$channelAdminLogEventActionToggleInvites : TLChannelAdminLogEventAction

@property (nonatomic) bool n_new_value;

@end

@interface TLChannelAdminLogEventAction$channelAdminLogEventActionToggleSignatures : TLChannelAdminLogEventAction

@property (nonatomic) bool n_new_value;

@end

@interface TLChannelAdminLogEventAction$channelAdminLogEventActionUpdatePinned : TLChannelAdminLogEventAction

@property (nonatomic, retain) TLMessage *message;

@end

@interface TLChannelAdminLogEventAction$channelAdminLogEventActionEditMessage : TLChannelAdminLogEventAction

@property (nonatomic, retain) TLMessage *prev_message;
@property (nonatomic, retain) TLMessage *n_new_message;

@end

@interface TLChannelAdminLogEventAction$channelAdminLogEventActionDeleteMessage : TLChannelAdminLogEventAction

@property (nonatomic, retain) TLMessage *message;

@end

@interface TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantJoin : TLChannelAdminLogEventAction


@end

@interface TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantLeave : TLChannelAdminLogEventAction


@end

@interface TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantInvite : TLChannelAdminLogEventAction

@property (nonatomic, retain) TLChannelParticipant *participant;

@end

@interface TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantToggleBan : TLChannelAdminLogEventAction

@property (nonatomic, retain) TLChannelParticipant *prev_participant;
@property (nonatomic, retain) TLChannelParticipant *n_new_participant;

@end

@interface TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantToggleAdmin : TLChannelAdminLogEventAction

@property (nonatomic, retain) TLChannelParticipant *prev_participant;
@property (nonatomic, retain) TLChannelParticipant *n_new_participant;

@end


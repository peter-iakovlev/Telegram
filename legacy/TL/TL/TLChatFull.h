#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLChatParticipants;
@class TLPhoto;
@class TLPeerNotifySettings;
@class TLExportedChatInvite;

@interface TLChatFull : NSObject <TLObject>

@property (nonatomic) int32_t n_id;
@property (nonatomic, retain) TLChatParticipants *participants;
@property (nonatomic, retain) TLPhoto *chat_photo;
@property (nonatomic, retain) TLPeerNotifySettings *notify_settings;
@property (nonatomic, retain) TLExportedChatInvite *exported_invite;
@property (nonatomic, retain) NSArray *bot_info;

@end

@interface TLChatFull$chatFull : TLChatFull


@end


#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLChatParticipants;
@class TLPhoto;
@class TLPeerNotifySettings;

@interface TLChatFull : NSObject <TLObject>

@property (nonatomic) int32_t n_id;
@property (nonatomic, retain) TLChatParticipants *participants;
@property (nonatomic, retain) TLPhoto *chat_photo;
@property (nonatomic, retain) TLPeerNotifySettings *notify_settings;

@end

@interface TLChatFull$chatFull : TLChatFull


@end


#import "TLMessage.h"

@class TLMessageAction;
@class TLPeer;

@interface TLMessage$modernMessageService : TLMessage

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t from_id;
@property (nonatomic) TLPeer *to_id;
@property (nonatomic) int32_t reply_to_msg_id;
@property (nonatomic) int32_t date;
@property (nonatomic, strong) TLMessageAction *action;

@end

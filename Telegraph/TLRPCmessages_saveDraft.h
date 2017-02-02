#import "TLMetaRpc.h"

@class TLInputPeer;
@class TLMessageEntity;

//messages.saveDraft flags:# no_webpage:flags.1?true reply_to_msg_id:flags.0?int peer:InputPeer message:string entities:flags.3?Vector<MessageEntity> = Bool;

@interface TLRPCmessages_saveDraft : TLMetaRpc

@property (nonatomic) bool no_webpage;
@property (nonatomic) int32_t reply_to_msg_id;
@property (nonatomic, strong) TLInputPeer *peer;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSArray<TLMessageEntity *> *entities;

@end

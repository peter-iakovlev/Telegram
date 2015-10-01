#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPeer;
@class TLInputMedia;
@class TLUpdates;

//messages.sendMedia flags:# peer:InputPeer reply_to_msg_id:flags.0?int media:InputMedia random_id:long = Updates;

@interface TLRPCmessages_sendMedia_manual : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic, strong) TLInputPeer *peer;
@property (nonatomic) int32_t reply_to_msg_id;
@property (nonatomic, strong) TLInputMedia *media;
@property (nonatomic) int64_t random_id;

@end

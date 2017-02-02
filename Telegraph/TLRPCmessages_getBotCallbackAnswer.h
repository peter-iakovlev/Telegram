#import "TLMetaRpc.h"

@class TLInputPeer;

@interface TLRPCmessages_getBotCallbackAnswer : TLMetaRpc

@property (nonatomic) bool game;

@property (nonatomic, strong) TLInputPeer *peer;
@property (nonatomic) int32_t msg_id;
@property (nonatomic) NSData *data;

@end

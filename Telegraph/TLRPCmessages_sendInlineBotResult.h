#import "TLMetaRpc.h"
#import "TLObject.h"

#import "TLMetaRpc.h"

@class TLInputPeer;

@interface TLRPCmessages_sendInlineBotResult : TLMetaRpc

@property (nonatomic) int32_t flags;
@property (nonatomic, strong) TLInputPeer *peer;
@property (nonatomic) int32_t reply_to_msg_id;
@property (nonatomic) int64_t random_id;
@property (nonatomic) int64_t query_id;
@property (nonatomic) NSString *n_id;

@end

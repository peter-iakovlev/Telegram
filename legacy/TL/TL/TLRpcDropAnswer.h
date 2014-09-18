#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLRpcDropAnswer : NSObject <TLObject>


@end

@interface TLRpcDropAnswer$rpc_answer_unknown : TLRpcDropAnswer


@end

@interface TLRpcDropAnswer$rpc_answer_dropped_running : TLRpcDropAnswer


@end

@interface TLRpcDropAnswer$rpc_answer_dropped : TLRpcDropAnswer

@property (nonatomic) int64_t msg_id;
@property (nonatomic) int32_t seq_no;
@property (nonatomic) int32_t bytes;

@end


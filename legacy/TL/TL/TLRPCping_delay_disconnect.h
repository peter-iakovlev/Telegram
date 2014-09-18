#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLPong;

@interface TLRPCping_delay_disconnect : TLMetaRpc

@property (nonatomic) int64_t ping_id;
@property (nonatomic) int32_t disconnect_delay;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCping_delay_disconnect$ping_delay_disconnect : TLRPCping_delay_disconnect


@end


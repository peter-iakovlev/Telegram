#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLPong;

@interface TLRPCping : TLMetaRpc

@property (nonatomic) int64_t ping_id;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCping$ping : TLRPCping


@end


#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLResPQ;

@interface TLRPCreq_pq : TLMetaRpc

@property (nonatomic, retain) NSData *nonce;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCreq_pq$req_pq : TLRPCreq_pq


@end


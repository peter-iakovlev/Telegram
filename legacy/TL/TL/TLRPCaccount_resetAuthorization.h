#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLRPCaccount_resetAuthorization : TLMetaRpc

@property (nonatomic) int64_t n_hash;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_resetAuthorization$account_resetAuthorization : TLRPCaccount_resetAuthorization


@end


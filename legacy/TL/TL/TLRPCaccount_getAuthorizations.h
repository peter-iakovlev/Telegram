#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLaccount_Authorizations;

@interface TLRPCaccount_getAuthorizations : TLMetaRpc


- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_getAuthorizations$account_getAuthorizations : TLRPCaccount_getAuthorizations


@end


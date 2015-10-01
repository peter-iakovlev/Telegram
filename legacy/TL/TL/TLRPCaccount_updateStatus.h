#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLRPCaccount_updateStatus : TLMetaRpc

@property (nonatomic) bool offline;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_updateStatus$account_updateStatus : TLRPCaccount_updateStatus


@end


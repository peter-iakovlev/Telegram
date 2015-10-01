#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLRPCaccount_deleteAccount : TLMetaRpc

@property (nonatomic, retain) NSString *reason;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_deleteAccount$account_deleteAccount : TLRPCaccount_deleteAccount


@end


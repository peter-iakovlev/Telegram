#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLaccount_TmpPassword;

@interface TLRPCaccount_getTmpPassword : TLMetaRpc

@property (nonatomic, retain) NSData *password_hash;
@property (nonatomic) int32_t period;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_getTmpPassword$account_getTmpPassword : TLRPCaccount_getTmpPassword


@end


#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLaccount_TmpPassword;
@class TLInputCheckPasswordSRP;

@interface TLRPCaccount_getTmpPassword : TLMetaRpc

@property (nonatomic, retain) TLInputCheckPasswordSRP *password;
@property (nonatomic) int32_t period;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_getTmpPassword$account_getTmpPassword : TLRPCaccount_getTmpPassword


@end


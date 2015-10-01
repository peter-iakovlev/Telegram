#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLRPCaccount_updateDeviceLocked : TLMetaRpc

@property (nonatomic) int32_t period;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_updateDeviceLocked$account_updateDeviceLocked : TLRPCaccount_updateDeviceLocked


@end


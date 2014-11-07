#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLAccountDaysTTL;

@interface TLRPCaccount_setAccountTTL : TLMetaRpc

@property (nonatomic, retain) TLAccountDaysTTL *ttl;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_setAccountTTL$account_setAccountTTL : TLRPCaccount_setAccountTTL


@end


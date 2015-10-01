#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLRPCaccount_unregisterDevice : TLMetaRpc

@property (nonatomic) int32_t token_type;
@property (nonatomic, retain) NSString *token;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_unregisterDevice$account_unregisterDevice : TLRPCaccount_unregisterDevice


@end


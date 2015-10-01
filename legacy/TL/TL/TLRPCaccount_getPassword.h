#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLaccount_Password;

@interface TLRPCaccount_getPassword : TLMetaRpc


- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_getPassword$account_getPassword : TLRPCaccount_getPassword


@end


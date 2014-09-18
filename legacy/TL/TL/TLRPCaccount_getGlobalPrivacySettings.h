#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLGlobalPrivacySettings;

@interface TLRPCaccount_getGlobalPrivacySettings : TLMetaRpc


- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_getGlobalPrivacySettings$account_getGlobalPrivacySettings : TLRPCaccount_getGlobalPrivacySettings


@end


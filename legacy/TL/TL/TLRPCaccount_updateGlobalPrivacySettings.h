#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLRPCaccount_updateGlobalPrivacySettings : TLMetaRpc

@property (nonatomic) bool no_suggestions;
@property (nonatomic) bool hide_contacts;
@property (nonatomic) bool hide_located;
@property (nonatomic) bool hide_last_visit;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_updateGlobalPrivacySettings$account_updateGlobalPrivacySettings : TLRPCaccount_updateGlobalPrivacySettings


@end


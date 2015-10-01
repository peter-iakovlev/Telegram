#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPrivacyKey;
@class TLaccount_PrivacyRules;

@interface TLRPCaccount_getPrivacy : TLMetaRpc

@property (nonatomic, retain) TLInputPrivacyKey *key;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_getPrivacy$account_getPrivacy : TLRPCaccount_getPrivacy


@end


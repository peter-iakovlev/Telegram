#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputPrivacyKey;
@class TLaccount_PrivacyRules;

@interface TLRPCaccount_setPrivacy : TLMetaRpc

@property (nonatomic, retain) TLInputPrivacyKey *key;
@property (nonatomic, retain) NSArray *rules;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_setPrivacy$account_setPrivacy : TLRPCaccount_setPrivacy


@end


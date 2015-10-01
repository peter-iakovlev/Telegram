#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLUser;

@interface TLRPCaccount_updateUsername : TLMetaRpc

@property (nonatomic, retain) NSString *username;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_updateUsername$account_updateUsername : TLRPCaccount_updateUsername


@end


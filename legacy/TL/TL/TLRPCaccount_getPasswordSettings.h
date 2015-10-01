#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLaccount_PasswordSettings;

@interface TLRPCaccount_getPasswordSettings : TLMetaRpc

@property (nonatomic, retain) NSData *current_password_hash;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_getPasswordSettings$account_getPasswordSettings : TLRPCaccount_getPasswordSettings


@end


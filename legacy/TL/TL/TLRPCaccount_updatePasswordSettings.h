#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLaccount_PasswordInputSettings;

@interface TLRPCaccount_updatePasswordSettings : TLMetaRpc

@property (nonatomic, retain) NSData *current_password_hash;
@property (nonatomic, retain) TLaccount_PasswordInputSettings *n_new_settings;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_updatePasswordSettings$account_updatePasswordSettings : TLRPCaccount_updatePasswordSettings


@end

